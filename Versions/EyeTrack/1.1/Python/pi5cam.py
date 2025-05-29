from picamera2 import Picamera2, Preview
from time import sleep
import time
import numpy as np
import threading

camera_duration = 3 # duration of camera operation, in s

"""
This script contains 2 code blocks, 1 of which is commented out. 
Uncomment the code block that you want to run and comment out the other (use three " symbols to start/stop a comment block)

Block 1: open windows to view both cameras in real time (for 5 seconds), side-by-side. (RGB color channels)

Block 2: capture a 5-s video from both cameras simultaneously, and saves the video to a binary file. (R-channel only)
        (see the "pi5cam_binaryviewer.py" script for an example of how to load this binary video data file)
"""



#---Block 1: viewing the cameras

picam0 = Picamera2(0)
picam1 = Picamera2(1)
picam0.configure(picam0.create_video_configuration(main={"size": (250, 250)}))
picam1.configure(picam1.create_video_configuration(main={"size": (250, 250)}))
picam0.start_preview(Preview.QTGL, x=100,y=100,width=500,height=500)
picam1.start_preview(Preview.QTGL, x=600,y=100,width=500,height=500)
picam0.start()
picam1.start()
sleep(camera_duration)
picam0.stop()
picam1.stop()
picam0.stop_preview()
picam1.stop_preview()

#---Block 1 end

"""

#---Block 2: recording frames from both cameras to a single binary file

# handling camera recording (and output signaling)
class VideoRecorder:
	def __init__(self):
		self.cams = [Picamera2(0), Picamera2(1)]
		self.recording = False
		self.stop_event = threading.Event()
		self.experiment_start_time = None
		self.start_time = None
		self.output_file = None
		
		# configure cameras
		for cam in self.cams:
			config = cam.create_video_configuration(main={"size": (250, 250)})
			cam.configure(config)
		print("Cameras configured")
		
	def start_recording(self, exp_name: str, max_duration: float):
		if not self.recording:
			self.recording = True
			self.stop_event.clear()
			self.output_file = open(f"{exp_name}_frames.bin", "wb")
			self.experiment_start_time = time.time()*1000
			
			# start cameras
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
		
# main script
if __name__ == "__main__":
	recorder = VideoRecorder()
	recorder.start_recording("test", float(camera_duration))

#---Block 2 end

"""



