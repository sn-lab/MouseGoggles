#import libraries
from picamera import PiCamera
from time import sleep

#set camera settings
camera = PiCamera()
#camera.rotation = 90
camera.resolution = (800, 800)
camera.framerate = 30
camera.brightness = 55
camera.contrast = 50
camera.exposure_mode = 'fixedfps'
camera.awb_mode = 'sunlight'

#start preview and record
camera.start_preview()
camera.start_recording('/test.h264')
sleep(10)
camera.stop_recording()
camera.stop_preview()