#this script reads raw image data from a single optical flow sensor and 
#displays the image on a figure window in real time

import serial
import time
import numpy as np
import imagewindow

window = imagewindow.ImageWindow(300, 300)

#establish connection to an Arduino which is connected to an optical
#flow sensor, and is running the script "MouseCamImages.ino"
serial_port_name = 'COM5'
serial_port = serial.Serial(serial_port_name, 115200, timeout=1)
time.sleep(1)
serial_port.read(serial_port.inWaiting())
print('sending message')

#request data from the arduino
serial_port.write(b'h')

count = 0
time.sleep(1)
t_0 = time.time()
while True:
    #wit until 900 bytes are available (for a 30x30 byte image)
    while serial_port.inWaiting() < 900:
        pass
    m = 900
    a = serial_port.read(m)
    count += 1
    a = np.frombuffer(a, dtype=np.uint8)
    
    #draw the image in a window
    image = np.reshape(a, [30, 30])
    window.draw(image)
    image = None
    a = None

    #request another image from the arduino
    serial_port.write(b'h')
