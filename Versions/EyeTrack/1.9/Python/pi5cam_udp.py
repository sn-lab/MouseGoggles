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
T: transfer video (receive "T" and filename, locate files, then send "T" and videos back via TCP (or send "M" back if files not found))
O: send output TTL signal (receive "O")
"""

# handling camera recording (and output signaling)
class VideoRecorder:
	def __init__(self):
		self.cams = [Picamera2(0), Picamera2(1)]
		self.recording = False
		self.stop_event = threading.Event()
		self.experiment_start_time = None
		self.output_file = None
		
		# configure cameras
		for cam in self.cams:
			config = cam.create_video_configuration(main={"size": (250, 250)})
			cam.configure(config)
		print("Cameras configured")
		
		# configure output pins
		GPIO.setmode(GPIO.BCM)  # Use Broadcom (BCM) pin numbering
		GPIO.setup(2, GPIO.OUT) #set pin as output
		GPIO.setup(3, GPIO.OUT)
		GPIO.output(2, 0) # set output to LOW
		GPIO.output(3, 0)
		print("Output pins configured")

	def capture_frame(self):
		frames = []
		for i, cam in enumerate(self.cams):
			cam.start()
			try:
				# capture image as an array
				rgb_array = cam.capture_array("main")
				red_channel = rgb_array[:, :, 0]  # only the red channel (sensitive to IR, not blue display)
				red_bytes = red_channel.astype(np.uint8).tobytes() # convert to bytes (uint8 grayscale)
				frames.append((i, red_bytes))

			finally:
				cam.stop()

		return frames

	def start_recording(self, exp_name: str, max_duration: float):
		if not self.recording:
			self.recording = True
			self.stop_event.clear()
			self.output_file = open(f"{exp_name}_frames.bin", "wb")
			for i, cam in enumerate(self.cams):
				cam.start()
				
			# frame capturing thread
			threading.Thread(target=self._capture_frames).start()
			
			# auto-stop thread
			threading.Thread(target=self._auto_stop, args=(max_duration,)).start()

	def _capture_frames(self):
		while not self.stop_event.is_set():
			frame_data = bytearray()
			timestamp = int(time.time()*1000 - self.experiment_start_time) #timestamp from experiment start, in ms
			
			for cam_idx, cam in enumerate(self.cams):
				try:
					# capture image as an array
					rgb_array = cam.capture_array("main")
					red_channel = rgb_array[:, :, 0]  # only the red channel (sensitive to IR, not blue display)
					# convert to bytes (uint8 grayscale)
					red_bytes = red_channel.astype(np.uint8).tobytes()
					#add metadata to image data
					frame_data.extend(
						timestamp.to_bytes(4, 'big') + 				# 4 bytes: timestamp (from godot exp start, in ms)
						cam_idx.to_bytes(1, 'big') + 				# 1 byte: camera idx (0 or 1)
						red_channel.shape[0].to_bytes(2, 'big') + 	# 2 bytes: frame height (M pixels)
						red_channel.shape[1].to_bytes(2, 'big') + 	# 2 bytes: frame width (N pixels)
						red_bytes) 									# MxN bytes: frame data
				except:
					print("could not capture array for video")
					
			# write data
			self.output_file.write(frame_data)
			self.output_file.flush()
			time.sleep(0.033) #~30 fps max (closer to 20 fps; max speed may be ~75 fps)
	
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

	tcp_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	tcp_sock.bind(("0.0.0.0", 5002))
	tcp_sock.listen(1)
	print("TCP server started")
	
	while True:
		data, addr = udp_sock.recvfrom(1024)
		message = data.decode().strip()
		
		if message.startswith("H"): # handshake
			_, ms_now = message.split(":")
			recorder.experiment_start_time = time.time()*1000 - int(ms_now)
			usage = shutil.disk_usage("/")
			free_gb = round(usage.free/(1024**3), 2)
			if free_gb > 5:
				udp_sock.sendto(b"H", addr) # confirm handshake
			else:
				udp_sock.sendto(b"E", addr) # send warning about low space
			print("Godot connection verified")
			print(f"(free disk space: {free_gb} GB)")
			
		if message.startswith("O"): # output TTL signal
			_, pin_num, duration = message.split(":") 
			GPIO.output(int(pin_num), 1)  # turn on GPIO
			time.sleep(float(duration))
			GPIO.output(int(pin_num), 0)  # turn off GPIO
			print("output signal pulsed")
			
		if message == "F": # capture frame (one frame for each camera)
			frames = recorder.capture_frame()
			for cam_idx, red_bytes in frames:
				udp_sock.sendto(f"F{cam_idx}".encode() + red_bytes, addr)
			print('frame captured')

		elif message.startswith("V"): # start Video (for both cameras)
			_, exp_name, duration = message.split(":")
			recorder.start_recording(exp_name, float(duration))
			udp_sock.sendto(b"V", addr)
			print('video started')
			
		elif message == "X": # stop video
			recorder.stop_recording()
			print('video stopped')
			
		elif message.startswith("T"): # transfer video
			_, exp_name = message.split(":")
			filepath = f"{exp_name}_frames.bin"
			conn, addr = tcp_sock.accept()
			if os.path.exists(filepath):
				print(f"transferring video: {filepath}")
				with open(filepath,"rb") as f:
					try:
						conn.sendall(f.read())
					except BrokenPipeError:
						print("TCP connection broken")
						conn.close()
						break
			else:
				udp_sock.sendto(b"M", addr)
				print(f"file not found: {filepath}")
			conn.close()


# run main script (start UDP/TCP communication and video recording functions)
if __name__ == "__main__":
	recorder = VideoRecorder()
	udp_server(recorder)
