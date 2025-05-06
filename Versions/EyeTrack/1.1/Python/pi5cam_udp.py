import io
import os
import socket
import threading
import time
from picamera2 import Picamera2
from picamera2.encoders import JpegEncoder
import numpy as np

"""
list of UDP commands:
H: handshake (recieve "H", send "H" back)
F: frames (recieve "F", capture frames, then send "F" and frames back)
V: start video (recieve "V", filename, and duration; start video, then send "V" back)
X: stop video (recieve "X", stop video, send "X" back)
T: transfer video (recieve "T" and filename, locate files, then send "T" and videos back via TCP (or send "M" back if files not found))
"""

class VideoRecorder:
	def __init__(self):
		self.cams = [Picamera2(0), Picamera2(1)]
		self.encoders = [JpegEncoder(q=70), JpegEncoder(q=70)]
		self.recording = False
		self.stop_event = threading.Event()
		
		# Configure cameras
		for cam in self.cams:
			config = cam.create_video_configuration(main={"size": (300, 300)})
			cam.configure(config)
			
	
	def capture_frames(self):
		frames = []
		for i, cam in enumerate(self.cams):
			cam.start()
			try: 
				jpeg_bytes = io.BytesIO()
				cam.capture_file(jpeg_bytes, format='jpeg')
				frames.append((i, jpeg_bytes.getvalue()))
				
			finally:
				cam.stop()
		return frames

	def start_recording(self, exp_name: str, max_duration: float):
		if not self.recording:
			self.recording = True
			self.stop_event.clear()

			for i, cam in enumerate(self.cams):
				cam.start_recording(self.encoders[i], f'{exp_name}{i}.mjpg')

			# Auto-stop thread
			threading.Thread(target=self._auto_stop, args=(max_duration,)).start()

	def stop_recording(self):
		if self.recording:
			self.stop_event.set()
			for cam in self.cams:
				cam.stop_recording()
			self.recording = False

	def _auto_stop(self, max_duration: float):
		time.sleep(max_duration)
		self.stop_recording()


def udp_server():
	recorder = VideoRecorder()
	
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
		
		if message == "H": # Handshake
			udp_sock.sendto(b"H", addr)
			
		if message == "F": # capture Frames (one frame for each camera)
			frames = recorder.capture_frames()
			for cam_idx, frame in frames:
				udp_sock.sendto(f"F{cam_idx}".encode() + frame, addr)
			print('frames captured')
				
		elif message.startswith("V"): # start Video (for both cameras)
			_, exp_name, duration = message.split(":")
			recorder.start_recording(exp_name, float(duration))
			udp_sock.sendto(b"V", addr)
			print('video started')
			
		elif message == "X": # stop video
			recorder.stop_recording()
			udp_sock.sendto(b"X", addr)
			print('video stopped')
			
		elif message.startswith("T"):
			_, exp_name, cam_idx = message.split(":")
			filepath = f'{exp_name}{cam_idx}.mjpg'
			conn, addr = tcp_sock.accept()
			if os.path.exists(filepath):
				udp_sock.sendto(b"T", addr)
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


if __name__ == "__main__":
	udp_server()
