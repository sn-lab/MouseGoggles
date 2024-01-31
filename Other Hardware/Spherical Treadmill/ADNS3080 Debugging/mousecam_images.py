import serial
import time
import numpy as np
import imagewindow

window = imagewindow.ImageWindow(300, 300)

serial_port_name = 'COM5'

serial_port = serial.Serial(serial_port_name, 115200, timeout=1)
time.sleep(1)
serial_port.read(serial_port.inWaiting())
print('sending message')

serial_port.write(b'h')

count = 0
time.sleep(1)
t_0 = time.time()
while True:
    while serial_port.inWaiting() < 900:
        pass
    m = 900
    a = serial_port.read(m)
    count += 1
    a = np.frombuffer(a, dtype=np.uint8)
    image = np.reshape(a, [30, 30])
    window.draw(image)
    print('hi')
    image = None
    a = None


    serial_port.write(b'h')
