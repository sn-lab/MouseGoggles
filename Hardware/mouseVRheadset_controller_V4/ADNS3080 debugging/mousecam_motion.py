import serial
import time
import numpy as np
import matplotlib.pyplot as plt


import matplotlib.pyplot as plt


serial_port_name = 'COM5'

# struct MD
# {
#  byte motion;
#  char dx, dy;
#  byte squal;
#  word shutter;
#  byte max_pix;
# };

byteorder = 'little'

X = 4294967296
Y = (X // 2) - 1

def fix_sign(x):
    if x > Y:
        return x - X
    else:
        return x

def convert_motion_record(record):

    dx_1 = fix_sign(int.from_bytes(record[:4], byteorder=byteorder))
    dy_1 = fix_sign(int.from_bytes(record[4:8], byteorder=byteorder))
    dx_2 = fix_sign(int.from_bytes(record[8:12], byteorder=byteorder))
    dy_2 = fix_sign(int.from_bytes(record[12:16], byteorder=byteorder))
    sq1 = fix_sign(int.from_bytes(record[16:20], byteorder=byteorder))
    sq2 = fix_sign(int.from_bytes(record[20:24], byteorder=byteorder))

    return dx_1, dy_1, dx_2, dy_2, sq1, sq2




serial_port = serial.Serial(serial_port_name, 115200, timeout=1)
time.sleep(4)
serial_port.read(serial_port.inWaiting())
print('sending message')
count = 0
time.sleep(1)
t_0 = time.time()

offset_x = 0
offset_y = 0

q = np.arange(0, 200)
q = np.expand_dims(q, 1)
w = np.transpose(q, axes=[1, 0])

y = q*w

import imagewindow

window = imagewindow.ImageWindow(200, 200)
window.draw((np.mod(q + offset_x, 200) * np.mod(w + offset_y, 200)) / 200 / 200 * 255)

print('hi')
serial_port.write(b'h')



time.sleep(4)
print(serial_port.inWaiting())
number_of_datapoints = 1000
dxdys = np.zeros([number_of_datapoints, 6])
index = 0
while True:
    while serial_port.inWaiting() < 24:
        pass
    a = serial_port.read(24)

    dx_1, dy_1, dx_2, dy_2, sq1, sq2 = convert_motion_record(a)


    offset_x += dx_1/4.0
    offset_y += dy_1/4.0

    dxdys[index, 0] = dx_1
    dxdys[index, 1] = dy_1

    dxdys[index, 2] = dx_2
    dxdys[index, 3] = dy_2

    dxdys[index, 4] = sq1
    dxdys[index, 5] = sq2

    window.draw((np.mod(q + offset_x, 200) * np.mod(w + offset_y, 200)) / 200 / 200 * 255)


    serial_port.write(b'h')

    index += 1
    if index >= number_of_datapoints:
        break

window.close()
for i in range(4):
    plt.plot(dxdys[2:, i], label=str(i))
plt.legend()
plt.show()



