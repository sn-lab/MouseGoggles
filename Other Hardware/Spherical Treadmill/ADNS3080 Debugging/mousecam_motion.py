#this script functions to read x,y motion from two optical flow sensors, 
#storing the motion data in arrays for later inspection, as well as visualizing 
#the motion of one sensor by cicularly shifting an image in a window in real-
#time based on x,y motion data from that sensor


import serial
import time
import numpy as np
import matplotlib.pyplot as plt


serial_port_name = 'COM5'

## struct the arduino to uses to store sensor data
# struct MD
# {
#  byte motion;
#  char dx, dy;
#  byte squal;
#  word shutter;
#  byte max_pix;
# };

byteorder = 'little'

X = 4294967296 #max value for 32-bit unsigned
Y = (X // 2) - 1 #max values for 32-bit signed

def fix_sign(x):
    if x > Y: #if exceeds max 32-bit signed value, make it negative
        return x - X
    else:
        return x


def convert_motion_record(record):
    # convert all values to 32-bit signed
    dx_1 = fix_sign(int.from_bytes(record[:4], byteorder=byteorder))
    dy_1 = fix_sign(int.from_bytes(record[4:8], byteorder=byteorder))
    dx_2 = fix_sign(int.from_bytes(record[8:12], byteorder=byteorder))
    dy_2 = fix_sign(int.from_bytes(record[12:16], byteorder=byteorder))
    sq1 = fix_sign(int.from_bytes(record[16:20], byteorder=byteorder))
    sq2 = fix_sign(int.from_bytes(record[20:24], byteorder=byteorder))
    return dx_1, dy_1, dx_2, dy_2, sq1, sq2



#open a serial connection to the arduino
serial_port = serial.Serial(serial_port_name, 115200, timeout=1)
time.sleep(4)
serial_port.read(serial_port.inWaiting())
print('sending message')
count = 0
time.sleep(1)
t_0 = time.time()

offset_x = 0
offset_y = 0

#create an arbitrary image to visualize motion
q = np.arange(0, 200) #evenly spaced values
q = np.expand_dims(q, 1)
w = np.transpose(q, axes=[1, 0])
y = q*w
import imagewindow
window = imagewindow.ImageWindow(200, 200)
window.draw((np.mod(q + offset_x, 200) * np.mod(w + offset_y, 200)) / 200 / 200 * 255)

#send "h" to arduino to request a sensor read
serial_port.write(b'h')
time.sleep(4)


#collect a number of motion datapoints
print(serial_port.inWaiting())
number_of_datapoints = 1000
dxdys = np.zeros([number_of_datapoints, 6]) #pre-allocate space for motion data
index = 0
while True:
    while serial_port.inWaiting() < 24:
        pass
    a = serial_port.read(24)

    dx_1, dy_1, dx_2, dy_2, sq1, sq2 = convert_motion_record(a)

    #[x,y] motion data from sensor 1
    dxdys[index, 0] = dx_1
    dxdys[index, 1] = dy_1

    #[x,y] motion data from sensor 2
    dxdys[index, 2] = dx_2
    dxdys[index, 3] = dy_2

    # motion data quality from sensors 1 and 2
    dxdys[index, 4] = sq1
    dxdys[index, 5] = sq2


    #increase x/y image offsets based on sensor 1 motion
    offset_x += dx_1/4.0
    offset_y += dy_1/4.0
    
    #increase x/y image offsets based on sensor 2 motion
    #offset_x += dx_2/4.0
    #offset_y += dy_2/4.0
    
    #circularly shift image in x,y directions to visualize x,y motion
    window.draw((np.mod(q + offset_x, 200) * np.mod(w + offset_y, 200)) / 200 / 200 * 255)

    #request another sensor read
    serial_port.write(b'h')

    index += 1
    if index >= number_of_datapoints:
        break

window.close()
for i in range(4):
    plt.plot(dxdys[2:, i], label=str(i))
plt.legend()
plt.show()



