This document contains installation instructions for code to read treadmill motion and transmit this data in the format expected by the MouseGoggles Godot game engine. Software support for two different treadmill systems is described -- one spherical and one linear -- though many more treadmill systems can easily be supported simply by adapting the treadmill motion detection system to output motion in the format of computer mouse emulation, as the code linked below does. For building or purchasing the required treadmill hardware, see the links in each treadmill section. For a description of headbars and mounts that can head-fix a mouse above these treadmills while still leaving enought space for a MouseGoggles Headset, see the section at the bottom.

# Spherical Treadmill

The spherical treadmill system used with MouseGoggles is based on an open design originally described [here](https://pubmed.ncbi.nlm.nih.gov/19829374/). This treadmill simulates 2D navigation to a head-fixed mouse, allowing ground translation and yaw rotation. The treadmill motion is measured using two optical flow sensors pointed at the treadmill along orthogonal axes, with sensor data acquired by an Arduino Due micrcontroller. To be compatabile with MouseGoggles, the microcontroller code should be customized to convert these two sources of horizontal and vertical optic flow into treadmill spherical rotations: yaw, pitch, and roll. These rotation values are then sent to the Raspberry Pi over USB through computer mouse emulation: yaw rotations mapped as mouse x movement, pitch as mouse y movement, and roll as mouse scroll wheel movement. Follow the instructions below to upload the [ADNS3080_Mouse_Controller_V5.ino](https://github.com/sn-lab/MouseGoggles/blob/main/Other%20Hardware/Spherical%20Treadmill/ADNS3080_Mouse_Controller_V5/ADNS3080_Mouse_Controller_V5.ino) Arduino code to the treadmill microcontroller.

- Download the latest [Arduino IDE](https://www.arduino.cc/en/software) on your PC/laptop

- In the Arduino IDE, load the ADNS3080_Mouse_Controller_V5.ino script.

- Plug in the treadmill microcontroller to your PC with a microUSB-USB cable. On the Ardunio Due, Use the [Programming Serial USB](https://wiki-content.arduino.cc/en/Guide/ArduinoDue).

- In `Tools>Board`, select `Arduino ARM (32-bits) Boards>Arduino Due (Programming Port)`

- In `Tools>USB Type`, select `Keyboard+Mouse+Joystick`

- In `Tools>Port`, select the serial port the microcontroller is connected to (if you're not sure, disconnect and reconnect the microcontroller to see which COM port changes)

- Click the check mark on the upper left side of the window to verify/compile the sketch, then click the arrow button next to it to upload the code to the microcontroller.

- After the code has been uploaded, plug in the Arduino due to a PC or Raspberry Pi, using the Due's [Native Serial USB](https://wiki-content.arduino.cc/en/Guide/ArduinoDue).

- To verify that the treadmill was successfully reprogrammed, spin the treadmill forward and backward (pitch) to see the computer mouse cursor move up and down; turn the treadmill CW/CCW (yaw) to move the cursor left and right, and spin the treadmill left and right (roll) to move a scroll wheel.
  
  ### Troubleshooting the motion detection system:
  
  The optical sensors used by the spherical treadmill require careful IR illumination of the spherical treadmill in order to successfully detect ball motion. To check the optical sensors' image quality of the treadmill, debugging code is available in the [ADNS3080 Debugging](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware/Spherical%20Treadmill/ADNS3080%20Debugging) folder. Follow the instructions below to use this debugging software:
  
  * Following the instructions above for uploading code to the Arduino, upload the `MouseCamImages.ino` code (`Tools>USB Type` does not need to be specified).
  
  * Using a Python IDE (Python can be downloaded [here]([Download Python | Python.org](https://www.python.org/downloads/))), open the `mousecam_images.py` script. Edit the `serial_port_name`for the COM port your Arduino is connected to (e.g. "COM5").
  
  * Run the python script in the editor. A window will pop up displaying raw images streamed from the optical sensors. Use these images to adjust your lighting/focus until the treadmill surface texture can be clearly detected.
  
  * After the image quality has been verified, open the `mousecam_motion.py` script, edit the COM port, and run the script. I window will pop up displaying the pattern of optical flow detected from treadmill motion. Use this information to verify that the sensors are successfully detecting motion of the treadmill.

# Linear Treadmill

The linear treadmill system used for MouseGoggles is the low-friction, small foorprint treadmill designed at the Janelia Research Campus described [here]([Low-Friction Rodent-Driven Belt Treadmill | Janelia Research Campus](https://www.janelia.org/open-science/low-friction-rodent-driven-belt-treadmill)). The system can be assembled using design files and instructions on [GitHub]([GitHub - janelia-experimental-technology/Rodent-Belt-Treadmill: Low friction belt treadmill for use in space constrained experimental rigs](https://github.com/janelia-experimental-technology/Rodent-Belt-Treadmill)), or can be purchased fully assembled from [LabMaker]([Mouse Treadmill with Encoder - LABmaker](https://www.labmaker.org/products/mouse-treadmill-with-encoder)). Out of the box, the linear treadmill calculates treadmill speed and direction and outputs their analog values which can be read from the SMA connectors from the attached microcontroller. To convert the microcontroller code to work with MouseGoggles (which reads treadmill motion over USB from computer mouse emulation), follow the instructions below to upload the [LinearTreadmill_Mouse_Controller_V2.ino](https://github.com/sn-lab/MouseGoggles/blob/main/Other%20Hardware/Linear%20Treadmill/LinearTreadmill_Mouse_Controller_V2/LinearTreadmill_Mouse_Controller_V2.ino) Arduino code to the treadmill's microcontroller and plug in the treadmill to the Raspberry Pi with a microUSB-to-USB cable (included from LabMaker).

- Download the latest [Arduino IDE](https://www.arduino.cc/en/software) on your PC/laptop.

- Open up the Arduino IDE, and click File > Preferences (on MacOS, click Arduino IDE > Settings). In "Additional boards manager URLs", copy this link:
  
  `https://www.pjrc.com/teensy/package_teensy_index.json`

- In the main Arduino window, open Boards Manager by clicking the left-side board icon. Search for "teensy", and click "Install".

- In the Arduino IDE, load the `LinearTreadmill_Mouse_Controller_V2.ino` script.

- Plug in the treadmill microcontroller to your PC with a microUSB-USB cable.

- In `Tools>Board`, select `Teensyduino>Teensy LC`.

- In `Tools>USB Type`, select `Keyboard+Mouse+Joystick`.

- In `Tools>Port`, select the serial port the microcontroller is connected to (if you're not sure, disconnect and reconnect the microcontroller to see which COM port changes).

- Click the check mark on the upper left side of the window to verify/compile the sketch, then click the arrow button next to it to upload the code to the microcontroller.

- The Teensyduino program window will automatically open. If Teensyduino prompts you to reset or put the microcontroller in programming mode, click the reset button using a paperclip through the small hole in the plastic microcontroller enclosure.

- To verify that the treadmill was successfully reprogrammed, move the treadmill forward and backward to see the computer mouse cursor move up and down.

# Headbars and Mounts

Using the spherical or linear treadmill requires securing a headbar to the mouse skull and attaching it to a stable mount above the treadmill. For compatability with MouseGoggles, the headbar and mount must leave adequate space around the mouse's eyes. In the [Headbars](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware/Headbars) folder, design files are supplied for a suitable headbar and mount for each of these treadmill systems. See the details below for instructions in how to obtain these parts. To secure a headbar to a mount, use [1/4" length 4-40 screws](https://www.mcmaster.com/93615A110/)).

### Headbar

The headbar (SN Headbar V1) should ideally be made from titanium to achieve the strength and stiffness neccessary to hold the mouse without breaking, so this part should be ordered from a manufacturer capable of creating titanium parts. To order this part through [emachineshop](), upload the SN Headbar V1.step file and specify the material as "Titanium Grade 2".

### Headbar Mount for the Spherical Treadmill

The headbar mount for the spherical treadmill (SN HeadbarMountBlock V2) can be 3D printed using a thermoplastic with relatively high strength and stiffness, such as PLA. To position this mount above the linear treadmill, the mount can be attached to a [Thorlabs construction cube](https://www.thorlabs.com/thorproduct.cfm?partnumber=RM1F), which can then be attached to [Thorlabs 1/2" optical posts](https://www.thorlabs.com/navigation.cfm?guide_id=52) and mounts.

### Headbar Mount for the Linear Treadmill

The headbar mount for the linear treadmill (SN HeadbarMount V2) should be machined from a relatively stiff metal material, such as stainless steel, which can be manufactured by many machine shops with the supplied SN HeadbarMount V2.ipt design file and SN HeadbarMount V2.dwg schematic file. To position this mount above the linear treadmill, the mount can be attached to [Thorlabs mini-series optical posts](https://www.thorlabs.com/navigation.cfm?guide_id=2249) positioned on either side of the treadmill. The mount position may be blocked by the removable walls of the linear treadmill, so a new design for a treadmill wall and is included in the folder (SN LinearTreadmillWall V4) that can be 3D printed to replace the standard treadmill walls. Walls may also be removed altogether, but can be helpful in training mice to maintain a centered walking position on the treadmill.

# Rotation Sensors

Since MouseGoggles is built in a small form-factor, it is possible to design rotating setups where the headset can rotate with a head-fixed mouse. In such setups, it may be desirable for the experiment to update the mouse's virtual position based on the current rotational position of the headset. To track the headset orientation in real time, an accelerometer can be used to track the roll and/or pitch tilt angles of the headset, while a magnetometer can track the yaw position. In the [Rotation Sensors](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware/Rotation%20Sensors) folder, two example Arduino programs (written to be run on a Teensy 4.0 microcontroller) are shown which can acquire signals from IIC-based magnetometer or acceleromater sensors, convert those signals to a rotational position, and send this position to a MouseGoggles headset. To build this system, follow the instructions below to purchase the required hardware, install the Arduino software, and test the system with MouseGoggles.

### Parts list

| Part Name                     | Description                                 | Link                                                | Est. Unit Cost | Quantity |
| ----------------------------- | ------------------------------------------- | --------------------------------------------------- | -------------- | -------- |
| (choose 1) LSM6DSOX           | 6 DoF Gyroscope and Accelerometer           | [Adafruit](https://www.adafruit.com/product/4438)   | $12            | 1        |
| (choose 1) LIS3MDL            | Triple-axis Magnetometer                    | [Adafruit](https://www.adafruit.com/product/4479)   | $10            | 1        |
| (choose 1) LSM6DSOX + LIS3MDL | 9 DoF Gyro, Accelerometer, and Magnetometer | [Adafruit](https://www.adafruit.com/product/4517)   | $20            | 1        |
| IIC cable                     | 100 mm length 4-pin Stemma QT cable         | [Adafruit](https://www.adafruit.com/product/4210)   | $1             | 1        |
| Qwiic adapter                 | IIC cable breakout                          | [Sparkfun](https://www.sparkfun.com/products/14495) | $1.6           | 1        |
| Teensy 4.0                    | High -speed microcontroller                 | [PJRC](https://www.pjrc.com/store/teensy40.html)    | $24            | 1        |
| Micro USB/USB A cable         | USB cable to Teensy 4.0                     | [Adafruit](https://www.adafruit.com/product/2185)   | $5             | 1        |
| Pin headers                   | Break-away pin headers (male, short)        | [Adafruit](https://www.adafruit.com/product/3009)   | $5             | 1        |
| Jumper wires                  | 3 inch length female-female jumper wires    | [Adafruit](https://www.adafruit.com/product/1951)   | $2             | 1        |

### Hardware installation

* Solder pin headers onto the Teensy 4.0 and the Qwiic adapter.

* Wire the Teensy to the Qwiic adapter using jumper wires, connecting the 3V and GND cables together, and connecting the SDA and SCL pins of the adapter to pins 18 and 19 of the Teensy, respectively.

* Connect the Sensor to the Qwiic adapter with the IIC cable.

### Software Installation

To install microcontroller code to read sensor signals and transmit rotation values to the MouseGoggles system, follow the instructions below to upload either the [MouseGoggles_Gyro.ino](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware/Rotation%20Sensors/MouseGoggles_Gyro) (for accelerometer-based roll or pitch control using the LSM6DSOX sensor) or the [MouseGoggles_Magnetometer.ino](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware/Rotation%20Sensors/MouseGoggles_Magnetometer) Arduino code (for yaw-based control using the LIS3MDL sensor) to the Teensy 4.0 microcontroller and plug the microcontroller into the Raspberry Pi with a microUSB-to-USB cable.

- Download the latest [Arduino IDE](https://www.arduino.cc/en/software) on your PC/laptop.

- Open up the Arduino IDE, and click File > Preferences (on MacOS, click Arduino IDE > Settings). In "Additional boards manager URLs", copy this link:
  
  `https://www.pjrc.com/teensy/package_teensy_index.json`

- In the main Arduino window, open Boards Manager by clicking the left-side board icon. Search for "teensy", and click "Install".

- In the Arduino IDE, load either the `MouseGoggles_Gyro.ino` or the `MouseGoggles_Magnetometer.ino`script.

- Plug in the microcontroller to your PC with a microUSB-USB cable.

- In `Tools>Board`, select `Teensyduino>Teensy LC`.

- In `Tools>USB Type`, select `Keyboard+Mouse+Joystick`.

- In `Tools>Port`, select the serial port the microcontroller is connected to (if you're not sure, disconnect and reconnect the microcontroller to see which COM port changes).

- Click the check mark on the upper left side of the window to verify/compile the sketch, then click the arrow button next to it to upload the code to the microcontroller.

- The Teensyduino program window will automatically open. If Teensyduino prompts you to reset or put the microcontroller in programming mode, click the reset button on the microcontroller.

- To verify that the Teensy was successfully reprogrammed, rotate the sensor in different directions to see the computer mouse cursor move.

### Testing

To verify that the sensor is operating correctly, open the `MouseVR Godot Project V1.6` project in the Godot editor and open the `rotations.gd` script. At the top of the script, specify the type of rotational sensor-control you will be using, defined by the `rotation_type` variable (for yaw, pitch, or roll control). Run the project by clicking the green "play" arrow on the top-right of the editor. Select the `rotations` scene in the scene select window, and verify that rotating the sensor results in a similar rotation in the virtual scene. 

note: you may need to determine through trial-and-error what is the best starting orientation of the sensor to produce the most accurate rotation detection.
