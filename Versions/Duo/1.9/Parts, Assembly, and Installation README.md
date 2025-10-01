![(left) 3D render of assembled MouseGoggles EyeTrack 1.1. (right) Picture of assembled MouseGoggles EyeTrack 1.1](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/Images/EyeTrack_1-1_Assembled.png)

# 

**NOTE:** This version is currently in development and is subject to change; if you proceed with building this version and notice any mistakes or problems, raise an issue on Github!

# Parts List

---

### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles Duo 1.9, a complete re-design of the Duo headset featuring newer, longer-lasting parts and a simpler assembly and installation process! 

Follow the links below to purchase the parts in the quantities listed (though you may consider ordering spare parts as well). In addition to these listed parts, you will also need some basic computer peripherals (HDMI monitor, USB keyboard and mouse /touchpad, microSD card reader), at least for the initial setup.

| Part Name                                         | Description                                     | Link                                                                                                                                                            | Est. Unit Cost (USD) | Quantity |
| ------------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |:--------------------:|:--------:|
| Raspberry Pi 4 Model B - 2 GB                     | Raspberry Pi 4 Single-board computer            | [PiShop.US](https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypihttps://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypi) | $45                  | 1        |
| Micro-HDMI to HDMI cable for Pi 4 - 3ft, Black    | HDMI adapter to connect Raspberry Pi to monitor | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)                                                                         | $5                   | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB       | MicroSD card to Raspberry Pi OS                 | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/)                                                                  | $13                  | 1        |
| FRP0510 1/2" Fresnel Lens - f = 10 mm             | Fresnel lens for VR headset                     | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                                                                                         | $21                  | 2        |
| Raspberry Pi 5 Power Supply                       | USB-C power supply                              | [Adafruit](https://www.adafruit.com/product/5814)                                                                                                               | $12                  | 1        |
| 1.28" 240x240 Round TFT LCD                       | Display for VR headset                          | [Adafruit](https://www.adafruit.com/product/6178)                                                                                                               | $17.5                | 2        |
| EYESPI BFF - 18 Pin FPC Connector                 | Connector board for display                     | [Adafruit](https://www.adafruit.com/product/5772)                                                                                                               | $4                   | 2        |
| EYESPI Cable - 18 Pin 200mm long                  | Cable to connect displays                       | [Adafruit](https://www.adafruit.com/product/5240)                                                                                                               | $1                   | 2        |
| GPIO Header for Raspberry Pi - 2x20 Female Header | Pin header to connect custom PCB to Pi 4        | [Adafruit](https://www.adafruit.com/product/2222)                                                                                                               | $1.5                 | 1        |
| Break-away 0.1" male header strip                 | Pin header to connect wires to custom PCB       | [Adafruit](https://www.adafruit.com/product/392)                                                                                                                | $5                   | 1        |
| 2-56 thread, 1/2" length socket head screws       | Pack of 1/2" long screws to assemble parts      | [McMaster](https://www.mcmaster.com/91251A081/)                                                                                                                 | $10                  | 1        |
| 2-56 thread, 3/16" wide narrow hex nuts           | Pack of hex nuts to assemble parts              | [McMaster](https://www.mcmaster.com/90730A003/)                                                                                                                 | $4.5                 | 1        |
| 2-56 thread, 1" length socket head screws         | Pack of 1" long screws to assemble parts        | [McMaster](https://www.mcmaster.com/91251A109/)                                                                                                                 | $15                  | 1        |
| (option A) 1/4-20 nut                             | Nut for mounting headset with 1/4-20 screw      | [McMaster](https://www.mcmaster.com/95479A111/)                                                                                                                 | $7                   | 1        |
| (option B) M6 nut                                 | Nut for mounting headset with M6 screw          | [McMaster](https://www.mcmaster.com/90593A005/)                                                                                                                 | $12                  | 1        |

### Recommended tools

| Part Name       | Description                                 | Link                                           | Est. Unit Cost (USD) |
| --------------- | ------------------------------------------- | ---------------------------------------------- | -------------------- |
| Needle file     | File for sanding/smoothing 3D prints        | [McMaster](https://www.mcmaster.com/4261a37/)  | $17                  |
| Hex wrench      | Wrench for assembling headset               | [McMaster](https://www.mcmaster.com/7122A15/)  | $1                   |
| Electrical tape | Tape for additional securing of parts/wires | [McMaster](https://www.mcmaster.com/76455A21/) | $4                   |

### 3D prints

The table below lists all custom 3D-printable parts required for this version of MouseGoggles. Follow the links below for .stl files to print these parts on your own 3D printer or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

For Eyepiece and LensClip parts, a z-resolution of <=0.1 mm is recommended, while for all other parts, <=0.3 mm z-resolution is adequate. For the "Bracket" and "Mount" parts, greater material strength is preferred.

For strong, long-lasting parts, an FDM-based printer using PLA is a good choice, such as the [Original Prusa MK4S](https://www.prusa3d.com/product/original-prusa-mk4s-3d-printer-5/) or the [Elegoo Neptune 4](https://us.elegoo.com/collections/fdm-printers/products/elegoo-neptune-4-fdm-3d-printer). For higher resolution parts, UV-cured resin-based SLA printers such as the [Photon Mono M7](https://store.anycubic.com/products/photon-mono-m7) can also produce adequate and cost-effective parts, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)).

| Part Name                      | Description                          | Link                                                                                                              | Quantity | Aprox. Dimensions (mm) |
| ------------------------------ | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- |
| Eyepiece 2.0 V1.stl            | Eyepiece                             | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/EyepieceCam%202.0%20V1.stl)   | 2        | 45x36x15               |
| LensClip 2.0 V1.stl            | Clip for securing Fresnel lens       | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/LensClip%202.0%20V1.stl)      | 2        | 17x12x1.6              |
| EyepieceBack 2.0 V1.stl        | Eyepiece enclosure backing           | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/EyepieceBack%202.0%20V1.stl)  | 2        | 56x30x20               |
| (option A) BracketA 2.0 V1.stl | Headset frame (vertical mount)       | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/BracketA%202.0%20V1.stl)      | 1        | 66x30x44               |
| (option B) BracketB 2.0 V1.stl | Headset frame (horizontal mount)     | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/BracketB%202.0%20V1.stl)      | 1        | 81x48x27               |
| PiMount 2.0 V1.stl             | Eyepiece mount for Raspberry Pi 5    | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/PiMount%202.0%20V1.stl)       | 1        | 64x55x16               |
| EnclosureBack 2.0 V1.stl       | Enclosure and mount for Raspberry Pi | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/3D%20Prints/EnclosureBack%202.0%20V1.stl) | 1        | 96x77x34               |

### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by this version of MouseGoggles. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name                           | Description                                      | Link                                                                                                                                       | Quantity |
| ----------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| MouseGoggles Hat-1-9_2025-09-25.zip | zipped Gerber files of Rasberry Pi PCB connector | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.9/PCBs/MouseGoggles%20Hat-1-9/MouseGoggles%20Hat-1-9_2025-09-25.zip) | 1        |

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
2* Insert a LensClip to secure the lens in place

3. Stack the circular display on top of the eyepiece, with the screw-holes aligned (the holes will only align to one pair of screw holes)

4. Stack the EyepieceBack onto the display/eyepiece, with all four open screw holes aligned. From the eyepiece-side, Insert four 1/2" screws through the holes, but don't secure them with nuts yet

5. Repeat steps 1-4 for a second eyepiece

6. Selecting the desired bracket (A, which mounts the eyepieces vertically; or B, which mounts them horizontally), position the two eyepieces onto the bracket so that all four screws of each eyepiece extend through the bracket slots. Secure all four screws of each eyepiece with nuts

7. Attach the "PiMount" 3D print to the top of the Raspberry Pi (the side with the connectors) by lining up the mounting holes and inserting four 1" long screws from the top of the PiMount (only three of the screws will be passing through the mount). Do not add nuts to the bottom of the Raspberry Pi yet

8. Connect the "EnclosureBack" below the Pi, threading the screws through the mounting holes

9. Add four hex nuts to the screws to secure the enclosure
   
   * Note: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints.

### Wire up the displays

1. Attach the custom PCB to the Raspberry Pi's 40-pin header, so that the custom PCB hangs over the Pi (rather than hanging off the side).

2. Attach the display ribbon cables to the circular display of each eyepiece and to the custom PCB.

# Software Installation Instructions

---

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the MicroSD cards that will be installed in the Raspberry Pis. Next, you'll need to start up the Raspberry Pi and install the necessary software. For the Raspberry Pi 4, you will install the Godot game engine and custom display driver, as well as all dependencies listed in the instructions below. Software installation typically takes <10 minutes.

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

# Operating Instructions

---

### Starting the display driver

- Navigate to the folder `MouseGoggles/Versions/Duo/1.9/Bash`

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

# 

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
