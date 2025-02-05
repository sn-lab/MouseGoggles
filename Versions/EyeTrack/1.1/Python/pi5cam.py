from picamera2 import Picamera2, Preview
from picamera2.encoders import JpegEncoder #creates video, but missing metadata
#from picamera2.encoders import H264Encoder #unknown error, doesn't create video
from time import sleep
picam0 = Picamera2(0)
picam1 = Picamera2(1)

picam0.configure(picam0.create_video_configuration(main={"size": (500, 500)}))
picam1.configure(picam1.create_video_configuration(main={"size": (500, 500)}))
picam0.start_preview(Preview.QTGL, x=100,y=100,width=500,height=500)
picam1.start_preview(Preview.QTGL, x=600,y=100,width=500,height=500)
encoder0 = JpegEncoder(q=70)
encoder1 = JpegEncoder(q=70)
picam0.start_recording(encoder0, 'test0.mjpg')
picam1.start_recording(encoder1, 'test1.mjpg')
sleep(2)
picam0.stop_recording()
picam1.stop_recording()
picam0.stop_preview()
picam1.stop_preview()

"""
this script successfully captures video from both cameras and saves the 
video to .mjpg files, which are essentially just stacks of images. These
files have no metadata on framerate or image timestamps, so attempting 
to play back the video ma not work. To add this missing metadata after
the files have been created, open up the command prompt and type
the following line, replacing the input .mjpg and output .mkv filenames 
as needed:
ffmpeg -framerate 25 -i input.mjpg -c:v copy -metadata fps=25 output.mkv
"""
