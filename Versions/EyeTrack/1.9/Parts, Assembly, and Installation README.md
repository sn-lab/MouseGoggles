![(left) 3D render of assembled MouseGoggles EyeTrack 1.1. (right) Picture of assembled MouseGoggles EyeTrack 1.1](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/Images/EyeTrack_1-1_Assembled.png)

# 

**NOTE:** This version is currently in development and is subject to change; if you proceed with building this version and notice any mistakes or problems, raise an issue on Github!

# Parts List

---

### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles EyeTrack 1.9, a complete re-design of the EyeTrack headset featuring newer, longer-lasting parts,   improved eye imaging, and a simpler assembly and installation process! 

Follow the links below to purchase the parts in the quantities listed (though you may consider ordering spare parts as well). In addition to these listed parts, you will also need some basic computer peripherals (HDMI monitor, USB keyboard and mouse /touchpad, microSD card reader), at least for the initial setup.

| Part Name                                           | Description                                     | Link                                                                                                                                                            | Est. Unit Cost (USD) | Quantity |
| --------------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |:--------------------:|:--------:|
| Raspberry Pi 4 Model B - 2 GB                       | Raspberry Pi 4 Single-board computer            | [PiShop.US](https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypihttps://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypi) | $45                  | 1        |
| Raspberry Pi 5 - 4GB                                | Raspberry Pi 5 Single-board computer            | [PiShop.US](https://www.pishop.us/product/raspberry-pi-5-4gb/)                                                                                                  | $60                  | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB         | MicroSD card to Raspberry Pi OS                 | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/)                                                                  | $13                  | 2        |
| Micro-HDMI to HDMI cable for Pi 4 - 3ft, Black      | HDMI adapter to connect Raspberry Pi to monitor | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)                                                                         | $5                   | 2        |
| FM02 1" Red Hot mirror                              | Hot mirror for eye tracking camera              | [Thorlabs](https://www.thorlabs.com/thorProduct.cfm?partNumber=FM02)                                                                                            | $57                  | 2+spare  |
| FRP0510 1/2" Fresnel Lens - f = 10 mm               | Fresnel lens for VR headset                     | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                                                                                         | $21                  | 2        |
| Raspberry Pi 5 Power Supply                         | USB-C power supply                              | [Adafruit](https://www.adafruit.com/product/5814)                                                                                                               | $12                  | 2        |
| Ethernet CAT6 Cable - 30cm                          | Ethernet cable for Pi-to-Pi communication       | [Adafruit](https://www.adafruit.com/product/5443)                                                                                                               | $2.5                 | 1        |
| GPIO Header for Raspberry Pi - 2x20 Female Header   | Pin header to connect custom PCB to Pi 4        | [Adafruit](https://www.adafruit.com/product/2222)                                                                                                               | $1.5                 | 1        |
| Break-away 0.1" male header strip                   | Pin header to connect wires to custom PCB       | [Adafruit](https://www.adafruit.com/product/392)                                                                                                                | $5                   | 1        |
| Raspberry Pi Camera Module 3 - 12MP, 75 Degree Lens | Mini  eye tracking camera                       | [Adafruit](https://www.adafruit.com/product/5659)                                                                                                               | $25                  | 2        |
| FPC Camera Cable - 22-pin to 15-pin, 300mm long     | Cable to connect camera modules                 | [Adafruit](https://www.adafruit.com/product/5659)                                                                                                               | $3                   | 2        |
| 1.28" 240x240 Round TFT LCD                         | Display for VR headset                          | [Adafruit](https://www.adafruit.com/product/6178)                                                                                                               | $17.5                | 2        |
| EYESPI BFF - 18 Pin FPC Connector                   | Connector board for display                     | [Adafruit](https://www.adafruit.com/product/5772)                                                                                                               | $4                   | 2        |
| EYESPI Cable - 18 Pin 200mm long                    | Cable to connect displays                       | [Adafruit](https://www.adafruit.com/product/5240)                                                                                                               | $1                   | 2        |
| 2-56 thread, 1/2" length socket head screws         | Pack of 1/2" long screws to assemble parts      | [McMaster](https://www.mcmaster.com/91251A081/)                                                                                                                 | $10                  | 1        |
| 2-56 thread, 3/16" wide narrow hex nuts             | Pack of hex nuts to assemble parts              | [McMaster](https://www.mcmaster.com/90730A003/)                                                                                                                 | $4.5                 | 1        |
| 2-56 thread, 1" length socket head screws           | Pack of 1" long screws to assemble parts        | [McMaster](https://www.mcmaster.com/91251A109/)                                                                                                                 | $15                  | 1        |
| (option A) 1/4-20 nut                               | Nut for mounting headset with 1/4-20 screw      | [McMaster](https://www.mcmaster.com/95479A111/)                                                                                                                 | $7                   | 1        |
| (option B) M6 nut                                   | Nut for mounting headset with M6 screw          | [McMaster](https://www.mcmaster.com/90593A005/)                                                                                                                 | $12                  | 1        |

### Recommended tools

| Part Name       | Description                                         | Link                                           | Est. Unit Cost (USD) |
| --------------- | --------------------------------------------------- | ---------------------------------------------- | -------------------- |
| Needle file     | File for sanding/smoothing 3D prints                | [McMaster](https://www.mcmaster.com/4261a37/)  | $17                  |
| Hex wrench      | Wrench for assembling headset                       | [McMaster](https://www.mcmaster.com/7122A15/)  | $1                   |
| Glass cutter    | Simple glass cutter for trimming hot mirror to size | [McMaster](https://www.mcmaster.com/4977N11/)  | $5.5                 |
| Electrical tape | Tape for additional securing of parts/wires         | [McMaster](https://www.mcmaster.com/76455A21/) | $4                   |

### 3D prints

The table below lists all custom 3D-printable parts required for this version of MouseGoggles. Follow the links below for .stl files to print these parts on your own 3D printer or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

For EyepieceCam parts, a z-resolution of <=0.1 mm is recommended, while for all other parts, <=0.3 mm z-resolution is adequate. For the "Bracket" and "Mount" parts, greater material strength is preferred.

For strong, long-lasting parts, an FDM-based printer using PLA is a good choice, such as the [Original Prusa MK4S](https://www.prusa3d.com/product/original-prusa-mk4s-3d-printer-5/) or the [Elegoo Neptune 4](https://us.elegoo.com/collections/fdm-printers/products/elegoo-neptune-4-fdm-3d-printer). For higher resolution parts, UV-cured resin-based SLA printers such as the [Photon Mono M7](https://store.anycubic.com/products/photon-mono-m7) can also produce adequate and cost-effective parts, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)).

| Part Name                                      | Description                                  | Link                                                                                                                     | Quantity | Aprox. Dimensions (mm) |
| ---------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | -------- | ---------------------- |
| [issues identified] EyepieceCam 2.0 V1.stl     | Eyepiece                                     | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/EyepieceCam%202.0%20V1.stl)     | 2        | 45x36x15               |
| LensClip 2.0 V1.stl                            | Clip for securing Fresnel lens               | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/LensClip%202.0%20V1.stl)        | 2        | 17x12x1.6              |
| [issues identified] EyepieceCamBack 2.0 V1.stl | Eyepiece enclosure backing                   | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/EyepieceCamBack%202.0%20V1.stl) | 2        | 56x30x20               |
| (option A) BracketA 2.0 V1.stl                 | Headset frame (vertical mount)               | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/BracketA%202.0%20V1.stl)        | 1        | 66x30x44               |
| (option B) BracketB 2.0 V1.stl                 | Headset frame (horizontal mount)             | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/BracketB%202.0%20V1.stl)        | 1        | 81x48x27               |
| PiMount 2.0 V1.stl                             | Eyepiece mount for Raspberry Pi 5            | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/PiMount%202.0%20V1.stl)         | 1        | 64x55x16               |
| PiSpacer 2.0 V1.stl                            | Spacer for Raspberry Pi 4 and 5              | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/PiSpacer%202.0%20V1.stl)        | 1        | 64x55x7                |
| EnclosureBack 2.0 V1.stl                       | Enclosure and mount for Raspberry Pi 4 and 5 | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/3D%20Prints/EnclosureBack%202.0%20V1.stl)   | 1        | 96x77x34               |

### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by this version of MouseGoggles. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name                           | Description                                      | Link                                                                                                                                                       | Quantity |
| ----------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| MouseGoggles Hat-1-9_2025-09-25.zip | zipped Gerber files of Rasberry Pi PCB connector | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.9/PCBs/MouseGoggles%20EyeTrack%20Hat-1-9/MouseGoggles%20Hat-1-9_2025-09-25.zip) | 1        |

# 

# Hardware Assembly Instructions

---

### Assemble the custom PCBs

1. Insert the 2x20 GPIO header onto the back of the "Hat" PCB (the side without any text) and solder the header in place.

2. Break away four 7-pin sections and one 6-pin section of male headers and insert them onto the front of the custom PCB (the side with text) and solder them in place.

3. Position the two "EYESPI BFF" boards onto each pair of the 7-pin headers, with the ribbon cable connectors facing opposite of the Hat PCB, and oriented so that the ribbon cable will be directed away from the 6-pin header.

### Assemble the MouseGoggles headset

1. Insert a Fresnel lens into an eyepiece (in the smaller slot), with the ridged side of the lens facing up into the eyepiece and the smooth side facing out of the eyepiece. 
   
   * Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.

2. Insert a hot mirror into each eyepiece (in the larger slot) as far is it will go. Using a felt tip pen, trace the area of the mirror which extrudes from the eyepiece -- this is the part of the hot mirror that should be cut away.
   
   - Note: It is possible to use a single hot mirror for both eyepieces, by first cutting a hot mirror in half and using one half in each eyepiece. In this case, the mirror will not completely fill the slot, but will still enable a complete view of the eye for eye-tracking (though it is still recommended to purchase multiple hot mirrors in case any break during glass cutting)

3. Using a glass cutter, score the hot mirror along the lines you drew. Position the mirror along a sharp edge of a surface (e.g. the edge of a desk) so that the score line follows the edge as closely as possible; then, with gentle pressure, hold the mirror tight against the surface while pushing down on the overhanging part of the mirror to snap the mirror along the score line.
   
   - Note: It is possible to break up the glass-cutting process into smaller straight-line cuts, which may be easier

4. Slide the hot mirror back into the slot (uncut-side first), and secure it with tape or glue

5. Stack the circular display on top of the eyepiece, with the screw-holes aligned (the holes will only align to one pair of screw holes)

6. Holding a camera module 3, gently separate the camera from the board (do not disconnect the small ribbon cable) which is attached by a small square foam adhesive. Leave the adhesive attached to the board, not the camera

7. Slide the camera board and camera into the "EyepieceBack" part so that the camera is supported and held upright by the arch, facing toward the center of the part, and the camera board is positioned along the 4 screw holes. From the camera board-side, insert two 1/2" screws into the outermost screw holes and secure them with nuts on the other side

8. Stack the assembled EyepieceBack and camera onto the display/eyepiece, with all four open screw holes aligned and the camera snugly positioned inside the square port of the eyepiece. From the eyepiece-side, Insert four 1/2" screws through the holes, but don't secure them with nuts yet

9. Repeat steps 1-7 for a second eyepiece

10. Selecting the desired bracket (A, which mounts the eyepieces vertically; or B, which mounts them horizontally), position the two eyepieces onto the bracket so that all four screws of each eyepiece extend through the bracket slots. Secure all four screws of each eyepiece with nuts

11. Attach the "PiMount" 3D print to the top of a Raspberry Pi 5 (the side with the connectors) by lining up the mounting holes and inserting four 1" long screws from the top of the Pi5 Mount (only three of the screws will be passing through the mount). Do not add nuts to the bottom of the Raspberry Pi yet

12. Connect the "Pi Spacer" 3D print to the bottom of th Raspberry Pi 5, threading the screws through the mounting holes.

13. Connect a Raspberry Pi 4 below the Pi Spacer, so that the bottom of the Pi 4 is next to the bottom of the Pi 5.

14. Connect the "EnclosureBack" below the Pi 4, threading the screws through the mounting holes

15. Add four hex nuts to the screws to secure the enclosure
    
    * Note: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints.

### Wire up the displays and cameras

1. Attach the custom PCB to the Raspberry Pi's 40-pin header, so that the custom PCB hangs over the Pi (rather than hanging off the side).

2. Attach the display ribbon cables to the circular display of each eyepiece and to the custom PCB.

3. Attach the camera ribbon cables to the pair of CSI ports on a Raspberry Pi 5.

# Software Installation Instructions

---

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the MicroSD cards that will be installed in the Raspberry Pis. Next, you'll need to start up the Raspberry Pis and install the necessary software. For the Raspberry Pi 4, you will install the Godot game engine and custom display driver, as well as all dependencies listed in the instructions below. For the Raspberry Pi 5, you will install the camera driver and software. Software installation on each Raspberry Pi typically takes <10 minutes.

## Installing software for the Raspberry Pi 4

### Install the Legacy Raspberry Pi 4 Operating System

- Insert a blank micro SD card into your PC
- Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Choose Device: "Raspiberry Pi 4""
- Choose OS: "Raspberry Pi OS (Legacy, 32-bit)"
- Choose Storage: -select your SD card-
- When asked if you would like to apply custom OS settings, click "Edit Settings"
- Set the hostname, username, password, WiFi, and localisation settings as desired, then click save and exit the settings window
- Select "yes" to install the OS with your custom settings
- After the image has finished writing, Insert the SD card into your Raspberry Pi and power it on

### Install the Godot game engine

- Start the Raspberry Pi and connect to the internet.
  - to connect to a wireless internet network, you will first be asked to set your wireless LAN country
- Open up the githib page for the [Unofficial Godot Engine for the Raspberry Pi](https://github.com/hiulit/Unofficial-Godot-Engine-Raspberry-Pi/tree/main?tab=readme-ov-file#compiling).
- In the "Downloads" section, download the zip file for 3.5.2 - Raspberry Pi 4
- After the zip file has been downloaded, navigate to your "downloads" folder, right-click on the zip file, and click "extract here"
- Inside the unzipped folder, find the "...editor_Ito.bin" file. This is the executable file for running the godot game engine. To run the engine, double-click this file and select "Execute" (you do not need to run the engine yet).

### Install the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  cd ~
  git clone https://github.com/sn-lab/MouseGoggles
  ```

- After it the MouseGoggles repository has been downloaded, navigate to the folder `MouseGoggles/Versions/EyeTrack/1.9/Bash`

- Double-click on `DriverSetup.sh` and select "Execute in terminal"

- When the driver installation is complete, restart the PC.
  
  - note: this installation has been verified using the following software versions:
    
    - flatpak: 1.14.1-4
    
    - cmake: cmake-3.27.4
    
    - unofficial godot: 3.5.2-stable

## Installing Software for the Raspberry Pi 5

### Install the Raspberry Pi 5 Operating System

- Insert a blank micro SD card into your PC
- Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Choose Device: "Raspiberry Pi 5""
- Choose OS: "Raspberry Pi OS (64-bit)"
- Choose Storage: -select your SD card-
- When asked if you would like to apply custom OS settings, click "Edit Settings"
- Set the hostname, username, password, WiFi, and localisation settings as desired, then click save and exit the settings window
- Select "yes" to install the OS with your custom settings
- After the image has finished writing, Insert the SD card into your Raspberry Pi and power it on

### Install the camera driver and software

- Start the Raspberry Pi and connect to the internet.
  
  - to connect to a wireless internet network, you will first be asked to set your wireless LAN country

- Open up the command terminal and enter each line, one at a time: (scroll to see the full line)
  
  ```
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt install python3-opencv
  ```
  
  - note: If you are asked if you want to continue installing, answer yes.
* Reboot the Raspberry Pi

### (Optional) Set up TCP/UDP connection to the Pi 4

- To create a static IP address for direct ethernet connection to the Pi 4, open up the Raspberry Pi command terminal and enter the following lines (feel free to change the IP address to anything between `169.254.0.1/16` and`169.254.255.254/16`): (scroll to see the full line)
  
  ```
  sudo nmcli connection modify "Wired connection 1" ipv4.addresses 169.254.123.1/16 ipv4.method manual
  sudo nmcli connection up "Wired connection 1"  
  ```

- To enable the Pi 4 to control the eye-tracking cameras on the Pi 5, download the "pi5cam_udp.py" and "pi5cam_udp.service" files from the python folder and place them in a folder named "Cam" on the Pi 5 desktop

- To automatically start the pi5cam_udp.py script whenever the Pi 5 boots up (recommended), open the pi5cam_udp.service in a text editor, and change all instances of the user name "MG5" to the user name you selected for this device. Save and exit the file

- Open up a command terminal and enter each line one at a time to copy the service file into the systemd folder and enable/start the service:
  
  ```
  sudo cp Desktop/Cam/pi5cam_udp.service /etc/systemd/system/pi5cam_udp.service
  sudo systemctl daemon-reload
  sudo systemctl enable pi5cam_udp.service
  sudo systemctl start pi5cam_udp.service
  ```

# Operating Instructions

---

### Starting the display driver

- Navigate to the folder `MouseGoggles/Versions/EyeTrack/1.9/Bash`

- Right-click on `StartDriver.sh` and select "Execute in terminal". **Feel free to move this file to the desktop to make it easier to start the displays**

- Manually verify that the displays are updating based on what is displayed in the center of the screen

### Starting the game engine and running experiments

- Navigate to the "godot_3.5.2-stable_rpi4_editor_Ito.bin" file in your downloads folder. Double-click this file and select "Execute". **Feel free to move this file to the desktop to make it easier to start experiments**

- Import the Godot game project located in MouseGoggles/Godot/MouseVR Godot Project V2.1/project.godot

- With the project highlighted, click "Run"

- Select an experiment (aka "scene")

- A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window

- By default, forward/backward movement and left/right turning in the VR scene can be controlled by a USB computer mouse or trackpad, which can be used to verify the VR system is correctly working

- Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project V2.1/logs/" in csv format (one row per frame, one column per data type)

- Click the `esc` button to exit an experiment early; the in-progress/unfinished repetition be saved in the final log file

### Stopping the display driver

(only needed for re-installing or updating the display driver)

- Open up the Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo pkill fbcp
  ```

- Check in `/etc/rc.local` and `/etc/init.d` to make sure fbcp does not start on system startup (delete any fbcp entries)

### Manually recording video from the eye-tracking cameras

* Make sure the `pi5cam.py` script from the `Python` folder is copied to the Raspberry Pi 5, in a folder named "Cam" on the desktop.

* Open the `pi5cam.py` script, which contains two blocks of code, one of which is commented out with the symbols `"""`. Running the script with the 1st block only will open camera preview windows. Running the script with the 2nd block only will record video from both cameras and save them to a binary file on the desktop. To view this video, open the `pi5cam_binaryviewer.py` script, set the filename of the video you would like to view, and run it.

### Automatically recording video from the eye-tracking cameras from a VR experiment

- Make sure that you followed the final installation step above for setting up a TCP/UDP connection

- Ensure that both Raspberry Pis are turned on

- On the Pi 4, navigate to the "godot_3.5.2-stable_rpi4_editor_Ito.bin" file. Double-click this file and select "Execute"

- Edit the MouseVR Godot Project V2.1

- Find the "commonSettings.gd" script and open it in the "script" tab in the Godot editor

- Alternatively, if the editor window is running too slowly on the Pi 4, you can navigate the the Godot Project 2.1 folder and edit the .gd scripts in a basic text editor

- Scroll down to find the the "var destination_ip" line and ensure that the IP address listed here is the same you selected during the TCP/UDP installation step above

- To verify that the UDP connection is working, run the project (play button on the upper-right) and select the "eye-tracking test" function. A window should show images from the eye-tracking cameras, updated at 1 Hz. This scene can be used to ensure accurate placement of the headset for eye-tracking

- To enable automatic eye-tracking camera recording during an experiment, open the commonSettings.gd page (viewing it in the "Script" tab) and set the `record_eyes` variable to `True`. To disable eye recording during experiments, set this variable to `False`

- After an eye-tracking experiment, a binary video file of the eye-tracking cameras will be saved on the Raspberry Pi 5, in the "Cam" folder on the desktop. Since this file type is uncompressed video, it can take up a large amount of space, so this folder should be emptied often (e.g. after every ~45 minutes of recorded experiments)

- To view a video, open the `pi5cam_binaryviewer.py` script, set the filename of the video you would like to view, and run it.

### Operating the systems remotely with VNC

- Make sure that the reaspberry Pi(s) you want to operate are connected to the internet or your local network
* Open up a Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo raspi-config
  ```
- Click on `Interface Options`, then `VNC`, and click `enable`. Save and exit the raspi-config window

- Open up another Raspberry Pi command terminal and enter the following line:
  
  ```
  ifconfig
  ```

- Scroll down and look for the `inet` field. Find the number to the right and write it down for later (e.g. `10.192.168.1`)

- On the PC from which you'd like to control the MouseGoggles system (and which is connected to the same network as the Raspberry Pi), download [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/). From the search bar, enter the Raspberry Pi's `inet` number. When prompted for a username and password, enter the information you set during the Raspberry Pi OS installation
