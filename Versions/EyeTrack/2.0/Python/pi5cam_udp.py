import os
import socket
import threading
import time
from picamera2 import Picamera2
import numpy as np
import RPi.GPIO as GPIO
import shutil

"""
This script handles UDP/TCP communication to receive commands from and send data to the Raspberry Pi 4 running Godot.
UDP communication is used to transfer commands (e.g. send a TTL signal, capture a frame) and small sets of data (e.g. individual camera frames).
TCP communication is used to transfer large amounts of data (i.e. files of eye video recordings of the duration of an experiment).
Camera frames are captured at 250x250 resolution, which is close to the maximum resolution that frame can be transferred over UDP in one block.
Output signals are sent over GPIO2 or GPIO3 (pins 3 and 5 on the Raspberry Pi 5, respectively)
Video files are saved in a binary format. See "cam_binary_viewer.py" for an example of how to read these files.

list of UDP commands:
H: handshake (receive "H", send "H" back)
F: frames (receive "F", capture frames, then send "F" and frames back)
V: start video (receive "V", filename, and duration; start video, then send "V" back)
X: stop video (receive "X", stop video, send "X" back)
O: send output TTL signal (receive "O")
"""

# ============================================================
# CAMERA CONFIGURATION
# ============================================================

# --- Output resolution ---
# Size of the captured/saved frame in pixels (width, height).
# Keep at or below 250x250 to fit a single UDP packet for the "F" command.
CAPTURE_SIZE = (250, 250)

# --- Crop window (region of interest on the sensor) ---
# Selects a sub-region of the full sensor to capture, then scales it to CAPTURE_SIZE.
# CROP_WIDTH and CROP_HEIGHT are shared across both cameras; CROP_X and CROP_Y are
# set independently per camera so each lens can be centered individually.
CROP_ENABLED  = False  # CROP_ENABLED = False uses the camera's default full-sensor view
CROP_WIDTH    = 1000   # width of crop window (pixels) — shared by both cameras
CROP_HEIGHT   = 1000   # height of crop window (pixels) — shared by both cameras
CAM0_CROP_X   = 796    # cam 0 left boundary of the crop window (pixels)
CAM0_CROP_Y   = 472    # cam 0 top boundary of the crop window (pixels)
CAM1_CROP_X   = 796    # cam 1 left boundary of the crop window (pixels)
CAM1_CROP_Y   = 472    # cam 1 top boundary of the crop window (pixels)
# (for reference) Spy camera resolution = 2592 x 1944

# --- Exposure & gain (brightness) ---
# Auto-exposure is DISABLED so brightness stays fixed across every frame. Adjust these values instead:
EXPOSURE_TIME_US  = 25000  # shutter duration (microseconds). Lower = darker. Must be < 1000000/TARGET_FPS (can't expose longer than one frame period).
CAM0_ANALOGUE_GAIN = 1.0  # cam 0 sensor amplification; 1.0–16.0. 1.0 = minimum noise; increase only if exposure alone is too dark
CAM1_ANALOGUE_GAIN = 1.0  # cam 1 sensor amplification

# --- Frame rate ---
# Attempts to lock the camera to a rate for consistent inter-frame timing. Though, the actual framerate
# can be different; timestamps in the .bin file are the ground truth for timing analysis.
TARGET_FPS = 30  # target frame rate (frames per second). Make sure EXPOSURE_TIME_US isn't set so high that this frame rate isn't possible

# --- Directory ---
# Hardcode the directory of the Current Godot Project log folder (where camera videos will be saved)
base_log_dir = "/home/mg2/MouseGoggles/Godot/MouseVR Godot Project V2.2/logs"


# ============================================================
# END OF CONFIGURATION
# ============================================================

# Derived from TARGET_FPS; used for FrameDurationLimits and sleep interval.
_FRAME_DURATION_US = 1_000_000 // TARGET_FPS  # microseconds per frame

# Per-camera crop origin and gain, indexed by camera index (0 or 1).
_CAM_CROP_X = [CAM0_CROP_X, CAM1_CROP_X]
_CAM_CROP_Y = [CAM0_CROP_Y, CAM1_CROP_Y]
_CAM_GAIN   = [CAM0_ANALOGUE_GAIN, CAM1_ANALOGUE_GAIN]


# handling camera recording (and output signaling)
class VideoRecorder:
	def __init__(self):
		self.cams = [Picamera2(0), Picamera2(1)]
		self.recording = False
		self.stop_event = threading.Event()
		self.experiment_start_time = None
		self.output_file = None

		# configure cameras
		for cam_idx, cam in enumerate(self.cams):
			config = cam.create_video_configuration(
				main={"size": CAPTURE_SIZE},
				controls={
					# Disable automatic exposure and white balance so that
					# brightness is fully determined by EXPOSURE_TIME_US and
					# the per-camera ANALOGUE_GAIN.
					"AeEnable":            False,
					"AwbEnable":           False,
					"ExposureTime":        EXPOSURE_TIME_US,
					"AnalogueGain":        _CAM_GAIN[cam_idx],
					# Lock the frame rate so inter-frame intervals are uniform.
					# Both min and max are set to the same value to remove jitter.
					"FrameDurationLimits": (_FRAME_DURATION_US, _FRAME_DURATION_US),
				}
			)
			cam.configure(config)

		if CROP_ENABLED:
			crop_msg = (f", crop: "
			            f"cam0 ({CAM0_CROP_X},{CAM0_CROP_Y}) "
			            f"cam1 ({CAM1_CROP_X},{CAM1_CROP_Y}) "
			            f"{CROP_WIDTH}×{CROP_HEIGHT}px")
		else:
			crop_msg = ", full-sensor crop"

		print(f"Cameras configured — {TARGET_FPS} fps, exposure {EXPOSURE_TIME_US} µs"
		      f", gain cam0={CAM0_ANALOGUE_GAIN} cam1={CAM1_ANALOGUE_GAIN}"
		      + crop_msg)

		# configure output pins
		GPIO.setmode(GPIO.BCM)  # Use Broadcom (BCM) pin numbering
		GPIO.setup(2, GPIO.OUT)  # set pin as output
		GPIO.setup(3, GPIO.OUT)
		GPIO.output(2, 0)  # set output to LOW
		GPIO.output(3, 0)
		print("Output pins configured")

	def _apply_controls(self, cam_idx, cam):
		"""Apply crop and exposure controls after a camera start().
		Controls that depend on the sensor running (e.g. ScalerCrop) must be
		set here rather than in the configuration, because the pipeline is not
		active until start() is called.
		cam_idx is used to select the per-camera crop origin and gain."""
		controls = {
			# Re-assert fixed exposure in case the camera reset them on start.
			"AeEnable":     False,
			"ExposureTime": EXPOSURE_TIME_US,
			"AnalogueGain": _CAM_GAIN[cam_idx],
		}
		if CROP_ENABLED:
			# ScalerCrop defines the sensor rectangle that is captured and then
			# scaled to CAPTURE_SIZE. Tuple order: (x, y, width, height).
			controls["ScalerCrop"] = (_CAM_CROP_X[cam_idx], _CAM_CROP_Y[cam_idx],
			                          CROP_WIDTH, CROP_HEIGHT)
		cam.set_controls(controls)

	def capture_frame(self):
		frames = []
		for i, cam in enumerate(self.cams):
			cam.start()
			self._apply_controls(i, cam)
			try:
				# capture image as an array
				rgb_array = cam.capture_array("main")
				red_channel = rgb_array[:, :, 0]  # only the red channel (sensitive to IR, not blue display)
				red_bytes = red_channel.astype(np.uint8).tobytes()  # convert to bytes (uint8 grayscale)
				frames.append((i, red_bytes))
			finally:
				cam.stop()

		return frames

	def start_recording(self, exp_name: str, max_duration: float):
		if not self.recording:
			self.recording = True
			self.stop_event.clear()
			log_dir = f"{base_log_dir}/{exp_name}"
			os.makedirs(log_dir, exist_ok=True)
			file_path = os.path.join(log_dir, f"{exp_name}_frames.bin")
			self.output_file = open(file_path, "wb")
			for cam_idx, cam in enumerate(self.cams):
				cam.start()
				self._apply_controls(cam_idx, cam)

			# frame capturing thread
			threading.Thread(target=self._capture_frames).start()

			# auto-stop thread
			threading.Thread(target=self._auto_stop, args=(max_duration,)).start()

	def _capture_frames(self):
		frame_interval = 1.0 / TARGET_FPS  # seconds; matches hardware lock
		while not self.stop_event.is_set():
			frame_data = bytearray()
			timestamp = int(time.time() * 1000 - self.experiment_start_time)  # ms from experiment start

			for cam_idx, cam in enumerate(self.cams):
				try:
					# capture image as an array
					rgb_array = cam.capture_array("main")
					red_channel = rgb_array[:, :, 0]  # only the red channel (sensitive to IR, not blue display)
					# convert to bytes (uint8 grayscale)
					red_bytes = red_channel.astype(np.uint8).tobytes()
					# add metadata to image data
					frame_data.extend(
						timestamp.to_bytes(4, 'big') +             # 4 bytes: timestamp (from godot exp start, in ms)
						cam_idx.to_bytes(1, 'big') +               # 1 byte: camera idx (0 or 1)
						red_channel.shape[0].to_bytes(2, 'big') +  # 2 bytes: frame height (M pixels)
						red_channel.shape[1].to_bytes(2, 'big') +  # 2 bytes: frame width (N pixels)
						red_bytes)                                  # MxN bytes: frame data
				except Exception:
					print("could not capture array for video")

			# write data
			self.output_file.write(frame_data)
			self.output_file.flush()
			time.sleep(frame_interval)  # ~TARGET_FPS; hardware lock provides fine-grained timing

	def stop_recording(self):
		if self.recording:
			self.stop_event.set()
			for cam in self.cams:
				cam.stop()
			if self.output_file:
				self.output_file.close()
				self.output_file = None
			self.recording = False

	def _auto_stop(self, max_duration: float):
		time.sleep(max_duration)
		self.stop_recording()


# handling UDP/TCP communication
def udp_server(recorder):
	udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	udp_sock.bind(("0.0.0.0", 5001))
	print("UDP server started")

	while True:
		data, addr = udp_sock.recvfrom(1024)
		message = data.decode().strip()

		if message.startswith("H"):  # handshake
			_, ms_now = message.split(":")
			recorder.experiment_start_time = time.time() * 1000 - int(ms_now)
			usage = shutil.disk_usage("/")
			free_gb = round(usage.free / (1024 ** 3), 2)
			if free_gb > 5:
				udp_sock.sendto(b"H", addr)  # confirm handshake
			else:
				udp_sock.sendto(b"E", addr)  # send warning about low space
			print("Godot connection verified")
			print(f"(free disk space: {free_gb} GB)")

		if message.startswith("O"):  # output TTL signal
			_, pin_num, duration = message.split(":")
			GPIO.output(int(pin_num), 1)  # turn on GPIO
			time.sleep(float(duration))
			GPIO.output(int(pin_num), 0)  # turn off GPIO
			print("output signal pulsed")

		if message == "F":  # capture frame (one frame for each camera)
			frames = recorder.capture_frame()
			for cam_idx, red_bytes in frames:
				udp_sock.sendto(f"F{cam_idx}".encode() + red_bytes, addr)
			print('frame captured')

		elif message.startswith("V"):  # start Video (for both cameras)
			_, exp_name, duration = message.split(":")
			recorder.start_recording(exp_name, float(duration))
			udp_sock.sendto(b"V", addr)
			print('video started')

		elif message == "X":  # stop video
			recorder.stop_recording()
			print('video stopped')


# run main script (start UDP/TCP communication and video recording functions)
if __name__ == "__main__":
	recorder = VideoRecorder()
	udp_server(recorder)
