# Parts List

---

### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles 1.5, the first version of MouseGoggles using easier-to-source, fully-circular 240x240 [Waveshare](https://www.waveshare.com/product/1.28inch-lcd-module.htm) displays and an easier to assemble design. Follow the links below to purchase the parts in the quantities listed. In addition to these listed parts, you will also need a desktop monitor (with HDMI input or an HDMI-DVI adapter), a USB keyboard and mouse, and a MicroSD card reader, at least for the initial setup.

| Part Name                                         | Description                                        | Link                                                                                                                                                            | Est. Unit Cost | Quantity |
| ------------------------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |:--------------:|:--------:|
| Raspberry Pi 4 Model B - 2 GB                     | Raspberry Pi 4 Single-board computer               | [PiShop.US](https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypihttps://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypi) | $45            | 1        |
| Raspberry Pi 15W USB-C Power Supply               | Power supply for Pi 4                              | [PiShop.US](https://www.pishop.us/product/raspberry-pi-15w-power-supply-us-black/)                                                                              | $8             | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB       | MicroSD card to install legacy Raspberry Pi OS     | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/)                                                                  | $13            | 1        |
| Micro-HDMI to HDMI cable for Pi 4, 3ft, Black     | HDMI adapter to connect Pi 4 to desktop monitor    | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)                                                                         | $5             | 1        |
| Waveshare 1.28 inch 240x240 display               | Circular display (with 8-pin cable) for VR headset | [Waveshare](https://www.waveshare.com/product/1.28inch-lcd-module.htm)                                                                                          | $15            | 2        |
| FRP0510 - Ø1/2" Fresnel Lens, f = 10 mm           | Fresnel lens for VR headset                        | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                                                                                         | $21            | 2        |
| 4-40 thread, 1/4" length socket head screws       | Pack of hex screws to assemble 3D printed parts    | [McMaster](https://www.mcmaster.com/91251A106/)                                                                                                                 | $12            | 1        |
| 4-40 thread, 3/16" wide narrow hex nuts           | Pack of hex nuts to assemble 3D printed parts      | [McMaster](https://www.mcmaster.com/90760A160/)                                                                                                                 | $5             | 1        |
| GPIO Header for Raspberry Pi - 2x20 Female Header | Pin header to connect custom PCB to Pi 4           | [Adafruit](https://www.adafruit.com/product/2222)                                                                                                               | $1.5           | 1        |
| Break-away 0.1" male header strip                 | Pin header to connect displays to custom PCB       | [Adafruit](https://www.adafruit.com/product/392)                                                                                                                | $5             | 1        |

### 3D prints

The table below lists all custom 3D-printable parts required for MouseGoggles 1.5. Follow the links below for .stl files to print these parts on your own high-resolution 3D printer (recommended layer resolution <=0.2 mm) or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

Notes on print quality: UV-cured resin-based SLA printers (e.g. [Photon Mono X](https://www.anycubic.com/products/photon-mono-x-resin-printer)) can produce adequate and cost-effective parts for MouseGoggles, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)). Thermoplastic polymers such as PLA, PETG, or ABS can produce tougher, longer-laster, and more opaque parts, though should only be used for MouseGoggles from high-resolution 3D printers (e.g. [Ultimaker S3](https://ultimaker.com/3d-printers/s-series/ultimaker-s3/)). If you are printing the parts yourself, a [needle file]([McMaster-Carr](https://www.mcmaster.com/4261A37/)) can be helpful in cleaning up any imperfections in the part.

| Part Name                                | Description                       | Link                                                                                                                                  | Quantity | Aprox. Dimensions (mm) |
| ---------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- |
| MouseGoggles 1.5 EyepieceEnclosureV2     | Enclosure for VR headset eyepiece | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.5/3D%20Prints/MouseGoggles%201.5%20EyepieceEnclosureV2.stl)     | 2        | 44x41x21               |
| MouseGoggles 1.5 EyepieceEnclosureBackV2 | Enclosure backing                 | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.5/3D%20Prints/MouseGoggles%201.5%20EyepieceEnclosureBackV2.stl) | 2        | 41x41x8                |
| MouseGoggles 1.5 EyepieceBackV2          | 50 deg angled mount               | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.5/3D%20Prints/MouseGoggles%201.5%20EyepieceBackV2.stl)          | 2        | 32x22x16               |
| MouseGoggles 1.5 SpacerV2                | Display-lens spacer for eyepiece  | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.5/3D%20Prints/MouseGoggles%201.5%20EyepieceSpacerV2.stl)        | 2        | 31x31x10               |

### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by MouseGoggles 1.5. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name                           | Description                                      | Link                                                                                                                                       | Quantity |
| ----------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| MouseGoggles Hat-1-5_2023-12-21.zip | zipped Gerber files of Rasberry Pi PCB connector | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Duo/1.5/PCBs/MouseGoggles%20Hat-1-5/MouseGoggles%20Hat-1-5_2023-12-21.zip) | 1        |

# 

# Hardware Assembly Instructions

---

### Assemble the custom PCB

1. Insert the 2x20 GPIO header onto the back of the custom PCB (the side without any text) and solder the header in place.

2. Break away two 8-pin sections and one 6-pin section of male headers and insert them onto the front of the custom PCB (the side with text) and solder them in place.

### Assemble the MouseGoggles headset

1. With the small end of the "EyepieceEnclosure" 3D print facing down, insert a Fresnel lens straight down into the bottom, with the ridged side facing up and the smooth side facing down. 
   
   * Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.

2. Insert the "Spacer" 3D print into the eyepiece, ensuring it is sitting tight up against the lens and the small tabs in the EyePieceEnclosure a positioned inside the notches of the Spacer.

3. Insert the Waveshare display into the enclosure so that it fits snugly inside the enclosure and sits tight up against the Spacer.

4. Slide the "EyepieceEnclosureBack" 3D print into the back of the Eyepiece Enclosure, angling it so that the tabs of the EnclosureBack fit inside the notches of the Enclosure and the screw holes of both parts are lined up.

5. Insert two hex nuts inside the slots of the EyepieceEnclosure, and screw two hex screws through the EnclosureBack to secure the eyepiece together.

6. Repeat steps 1-5 to create a second eyepiece.

7. On each eyepiece, insert two hex nuts into the slots of the EnclosureBack and use two hex screws to attach the "EyepieceBack" 3D print to the eyepiece.

8. With each eyepiece and attached EyepieceBack, slide the two EyepieceBack parts together and secure with two additional hex nuts and screws to your desired inter-eye spacing.
   
   * Note: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints. The edges of the custom PCB can also be sanded down, since there may also be imperfections in the PCB manufacturing/cutting process.

### Wire up the displays

1. Attach the custom PCB to the Raspberry Pi's 40-pin header, so that the custom PCB hangs over the Pi (rather than hanging off the side).

2. Attach the 8-pin cables to the circular display of each eyepiece.

3. Attach each wire of the 8-pin cable to the matching header on the custom PCB, attaching the right eye to the display0 header and the left-eye to the display1 header. 

# Software Installation Instructions

---

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the MicroSD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the Godot game engine and custom display driver, as well as all dependencies listed in the instructions below. Software installation on the Raspberry Pi typically takes <10 minutes.

### Installing the Legacy Raspberry Pi Operating System

- Insert the micro SD card into your PC
- Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Choose Device: "Raspiberry Pi 4""
- Choose OS: "Raspberry Pi OS (Legacy, 32-bit)"
- Choose Storage: -select your SD card-
- When asked if you would like to apply custom OS settings, click "Edit Settings"
- Set the hostname, username, password, WiFi, and localisation settings as desired, then click save and exit the settings window
- Select "yes" to install the OS with your custom settings
- After the image has finished writing, Insert the SD card into your Raspberry Pi and power it on

### Install the Godot game engine

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  sudo apt update
  sudo apt install flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub org.godotengine.Godot
  ```

- note: When you are asked if you want to continue installing, answer yes

### Install the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  sudo apt-get install cmake
  cd ~
  git clone https://github.com/sn-lab/MouseGoggles
  cd MouseGoggles/fbcp-ili9341
  mkdir build
  cd build
  cmake -DGC9A01=ON ..
  make -j
  sudo ./fbcp-ili9341
  ```

- note 1: When you are asked if you want to continue installing, answer yes.

- note 2: See the error "vc_dispmanx_display_open failed!" on the last step? See [this issue](https://github.com/sn-lab/MouseGoggles/issues/23) for a quick fix.

This installation has been verified using the following software versions:

- flatpak: 1.14.1-4
- cmake: cmake-3.27.4
- godot: 3.2.3.stable.flathub

# Operating Instructions

---

### Starting the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  cd MouseGoggles/fbcp-ili9341/build
  sudo ./fbcp-ili9341
  ```

### Starting the game engine and running experiments

- Open up a Raspberry Pi command terminal and enter the following line:
  
  ```
  flatpak run org.godotengine.Godot
  ```

- Import the Godot game project located in MouseGoggles/Godot/MouseVR Godot Project V1.5/project.godot

- When the game editor opens, reduce the window to a partial screen (running it in full screen may cause hang-ups)

- Click the small "play" button on the upper-right side of the menu bar

- Select an experiment (aka "scene")

- A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window

- By default, forward/backward movement and left/right turning in the VR scene can be controlled by a USB computer mouse or trackpad, which can be used to verify the VR system is correctly working

- Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project V1.5/logs/" in csv format (one row per frame, one column per data type)

- Click the `esc` button to exit an experiment early. Logs of completed experiment repetitions will have been saved, but the in-progress/unfinished repetition will not be saved by default

### Stopping the display driver

(only needed for re-installing or updating the display driver)

- Open up the Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo pkill fbcp
  ```

- Check in `/etc/rc.local` and `/etc/init.d` to make sure fbcp does not start on system startup (delete any fbcp entries) 

### Operating the system remotely with VNC

- Open up a Raspberry Pi command terminal and enter the following line:
  
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
