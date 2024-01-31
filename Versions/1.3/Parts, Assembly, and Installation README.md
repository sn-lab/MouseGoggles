# Parts List

---

##### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles 1.3, an updated version of the original MouseGoggles 1.0 but featuring the adjustable inter-eye distance of MouseGoggles 1.2. Follow the links below to purchase the parts in the quantities listed. In addition to these listed parts, you will also need a desktop monitor (with HDMI input or an HDMI-DVI adapter), a USB keyboard and mouse, and a MicroSD card reader, at least for the initial setup.

| Part Name                                                  | Description                                     | Link                                                                                                                                                            | Est. Unit Cost | Quantity |
| ---------------------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |:--------------:|:--------:|
| Raspberry Pi 4 Model B - 2 GB                              | Raspberry Pi 4 Single-board computer            | [PiShop.US](https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypihttps://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypi) | $45            | 1        |
| Raspberry Pi 15W USB-C Power Supply                        | Power supply for Pi 4                           | [PiShop.US](https://www.pishop.us/product/raspberry-pi-15w-power-supply-us-black/)                                                                              | $8             | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB                | MicroSD card to install legacy Raspberry Pi OS  | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/)                                                                  | $13            | 1        |
| Micro-HDMI to HDMI cable for Pi 4, 3ft, Black              | HDMI adapter to connect Pi 4 to desktop monitor | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)                                                                         | $5             | 1        |
| TT108RGN10A 1.08 inch 240x210 display (see **note** below) | Circular display for VR headset                 | [Alibaba](https://www.alibaba.com/product-detail/Small-IPS-Round-LCD-Module-1_62550674738.html)                                                                 | $8             | 2        |
| FRP0510 - Ø1/2" Fresnel Lens, f = 10 mm                    | Fresnel lens for VR headset                     | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                                                                                         | $21            | 2        |
| 4-40 thread, 1/4" length socket head screws                | 1/4" hex screws to assemble 3D printed parts    | [McMaster](https://www.mcmaster.com/91251A106/)                                                                                                                 | $12            | 1        |
| 4-40 thread, 1" length socket head screws                  | 1" hex screws to assemble 3D printed parts      | [McMaster](https://www.mcmaster.com/90044A111/)                                                                                                                 | $9             | 1        |
| 4-40 thread, 3/16" wide narrow hex nuts                    | Hex nuts to assemble 3D printed parts           | [McMaster](https://www.mcmaster.com/90760A160/)                                                                                                                 | $5             | 1        |
| GPIO Header for Raspberry Pi - 2x20 Female Header          | Pin header to connect custom PCB to Pi 4        | [Adafruit](https://www.adafruit.com/product/2222)                                                                                                               | $1.5           | 1        |
| 13 position surface-mount FPC connector                    | Ribbon cable connector for circular displays    | [TE](https://www.te.com/usa-en/product-1-2328724-3.html)                                                                                                        | $0.27          | 2        |
| Silicone glue                                              | Adhesive for securing lens and display holders  | [McMaster](https://www.mcmaster.com/7587A2/)                                                                                                                    | $9             | 1        |

**note**: The circular display model listed in the parts list (TT108RGN10A) is just one of a family of similar displays listed on Alibaba, many of which may be compatible with MouseGoggles. Since specific display models are occasionally discontinued or difficult to find, listed below are the circular display model numbers we are aware of and our most up-to-date estimates of their compatibility:

- TT108RGN10A - tested, working
- TT108RRN11A - tested, working
- TT109RAN11A - untested, NOT compatible
- TT109RAN12A - untested, likely NOT compatible
- TT108RRN13A - tested, working
- TST108102 - untested, likely compatible
- TST108103 - untested, likely compatible 

##### 3D prints

The table below lists all custom 3D-printable parts required for MouseGoggles 1.3. Follow the links below for .stl files to print these parts on your own high-resolution 3D printer (recommended layer resolution <0.2 mm) or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

Notes on print quality: UV-cured resin-based SLA printers (e.g. [Photon Mono X](https://www.anycubic.com/products/photon-mono-x-resin-printer)) can produce adequate and cost-effective parts for MouseGoggles, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)). Thermoplastic polymers such as PLA, PETG, or ABS can produce tougher, longer-laster, and more opaque parts, though should only be used for MouseGoggles from high-resolution 3D printers (e.g. [Ultimaker S3]([UltiMaker S3: Easy-to-use 3D printing starts here](https://ultimaker.com/3d-printers/s-series/ultimaker-s3/))). If you are printing the parts yourself, a [needle file]([McMaster-Carr](https://www.mcmaster.com/4261A37/)) can be helpful in cleaning up any imperfections in the part.

| Part Name                                    | Description                                  | Link  | Quantity | Approx. Dimensions (mm) |
| -------------------------------------------- | -------------------------------------------- | ----- | -------- | ----------------------- |
| MouseGoggles 1.3 RaspberryPiCaseBackV4       | Case for the Raspberry Pi                    | [stl] | 1        | 92x63x33                |
| MouseGoggles 1.3 RaspberryPiCaseFrontPanelV2 | Case top and mount for the headset eyepieces | [stl] | 1        | 92x63x9                 |
| MouseGoggles 1.2 EyepieceLeftV2              | Enclosure for the VR headset left eyepiece   | [stl] | 1        | 36x29x28                |
| MouseGoggles 1.2 EyepieceRightV2             | Enclosure for the VR headset right eyepiece  | [stl] | 1        |                         |
| MouseGoggles 1.0 DisplayHolderV1             | Holder for eyepiece display slot             | [stl] | 2        | 31x12x1.5               |
| MouseGoggles 1.0 LensHolderV1                | Holder for eyepiece lens slot                | [stl] | 2        | 11x8x1.5                |

##### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by MouseGoggles 1.3. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name               | Description                                      | Link  | Quantity |
| ----------------------- | ------------------------------------------------ | ----- | -------- |
| MouseGoggles HatBrd-1-3 | zipped Gerber files of Rasberry Pi PCB connector | [zip] | 1        |

# 

# Hardware Assembly Instructions

---

##### Assemble the custom PCB

1. Solder two surface-mount ribbon cable connectors and one SPI cable connector onto the top of the "MiniBrd" PCB.
   
   * note: Soldering these parts may require microsoldering equipment. For more details and options on microsoldering, see [this discussion]([PCB assembly/microsoldering options · sn-lab/MouseGoggles · Discussion #7 · GitHub](https://github.com/sn-lab/MouseGoggles/discussions/7)
     2* Solder one SPI cable connector onto the top of the "MiniHat" PCB.

2. Insert the 2x20 GPIO header onto the top of the "MiniHat" PCB and solder the header in place.

##### Assemble the MouseGoggles headset

1. Install the circular display by sliding it into the display slot of the "EyepieceLeft" 3D print, with the glass side facing out, ensuring it is pushed all the way in and the ribbon cable is centered in the slot.
   - Note: if during assembly anything is difficult to slide into place, check for imperfections or warping of the printed part and sand them down with the needle file until parts fit freely.
2. Slide the "DisplayHolder" 3D print into the slot following the display, with the cutout making space for the ribbon cable, until it is flush with the eyepiece edges.
3. Install the Fresnel lens into the lens slot of the eyepiece, with the ridged side facing the display and the flat side facing out.
   - Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.
4. Slide the "LensHolder" 3D print into the slot following the lens, with the angled side facing to the side and matching the slope of the eyepiece, until it is flush with the eyepiece edges.
5. Add a dab of silicone adhesive to the edges of the holders and wipe it flat with a cloth or finger. Add more silicone to close all gaps if minimal light pollution is desired.
6. Leave the eyepiece untouched to allow the adhesive to set.
7. Repeat steps 1-6 for the "EyepieceRight" 3D print.
8. Slide a 4-40 nut into the small mounting hole slot on the back of the EyepieceLeft and EyepieceRight parts.
9. Position the fully assembled "HatBrd" PCB to the back of the "CaseFrontPanel" 3D print, aligning the screw holes. Insert a hex screw through each hole to hold the parts in place.
10. Attach the EyepieceLeft and EyepieceRight parts to the Panel with the hex screws, with the the display ribbon cables passing through the cutouts in the center of the Panel and HatBrd PCB.
11. Using tweezers and/or careful handling, gently open the connecting flap on each fpc connector and slide each ribbon cable into their respective slots. Close the flaps to hold the cables in place.
    - Note: When a cable is properly inserted, the white horizontal line of the ribbon cable will be flush or nearly flush with the edge of the closed flap.
12. With the "CaseBack" 3D print set upside down (so the large central mounting hole is facing up), slide a 4-40 nut into each of the four small mounting hole slots. Temporarily screw in 4-40 screws through these holes to ensure the nuts are properly positioned.
13. Repeat step 10 with a 1/4-20 nut/screw and the large central mounting hole.
14. Place a Raspberry Pi inside the CaseBack, facing up and aligned to the mounting holes, with the USB ports pointing toward the open end.
15. Place the assembled CaseFront on top of the CaseBack, making sure the Raspberry Pi pins are aligned with the 2x20 sockets, and push down until the case is closed and the PCB is connected.
16. Add four 1" 4-40 screws into the screw holes of the CaseFront to hold the case and components securely in place.
- Note on assembly: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints. The edges of the custom PCB can also be sanded down, since there may also be imperfections in the PCB manufacturing/cutting process.

# Software Installation Instructions

---

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the MicroSD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the Godot game engine and custom display driver, as well as all dependencies listed in the instructions below. Software installation on the Raspberry Pi typically takes <10 minutes.

##### Installing the Legacy Raspberry Pi Operating System

- Insert the micro SD card into your PC
- Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Choose Device: "Raspiberry Pi 4""
- Choose OS: "Raspberry Pi OS (Legacy, 32-bit)"
- Choose Storage: -select your SD card-
- When asked if you would like to apply custom OS settings, click "Edit Settings"
- Set the hostname, username, password, WiFi, and localisation settings as desired, then click save and exit the settings window
- Select "yes" to install the OS with your custom settings
- After the image has finished writing, Insert the SD card into your Raspberry Pi and power it on

##### Install the Godot game engine

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  sudo apt update
  sudo apt install flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub org.godotengine.Godot
  ```

- note: When you are asked if you want to continue installing, answer yes

##### Install the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  sudo apt-get install cmake
  cd ~
  git clone https://github.com/sn-lab/MouseGoggles
  cd MouseGoggles/fbcp-ili9341
  mkdir build
  cd build
  cmake ..
  make -j
  sudo ./fbcp-ili9341
  ```

- note 1: Depending on which circular display you're using, the `cmake ..` line may have to be customized. If you're using a circular display with the GC9307 driver (e.g. TT108RGN10A), then the default `cmake ..` line is appropriate. If the display uses the ST7789V2 driver (e.g., TT108RRN13A), the line should be changed to `cmake -DST7789V2=ON ..`. 

- note 2: When you are asked if you want to continue installing, answer yes.

- note 3: See the error "vc_dispmanx_display_open failed!" on the last step? See [this issue](https://github.com/sn-lab/MouseGoggles/issues/23) for a quick fix.

This installation has been verified using the following software versions:

- flatpak: 1.14.1-4
- cmake: cmake-3.27.4
- godot: 3.2.3.stable.flathub

# Operating Instructions

---

##### Starting the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  cd MouseGoggles/fbcp-ili9341/build
  sudo ./fbcp-ili9341
  ```

##### Starting the game engine and running experiments

- Open up a Raspberry Pi command terminal and enter the following line:
  
  ```
  flatpak run org.godotengine.Godot
  ```

- Import the Godot game project located in MouseGoggles/Godot/MouseVR Godot Project V1.0/project.godot 

- When the game editor opens, reduce the window to a partial screen (running it in full screen may cause hang-ups)

- Click the small "play" button on the upper-right side of the menu bar

- Select an experiment (aka "scene")

- A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window

- By default, forward/backward movement and left/right turning in the VR scene can be controlled by a USB computer mouse or trackpad, which can be used to verify the VR system is correctly working

- Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project V1.0/logs/" in csv format (one row per frame, one column per data type)

- Click the `esc` button to exit an experiment early. Logs of completed experiment repetitions will have been saved, but the in-progress/unfinished repetition will not be saved by default

##### Stopping the display driver

(only needed for re-installing or updating the display driver)

- Open up the Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo pkill fbcp
  ```

- Check in `/etc/rc.local` and `/etc/init.d` to make sure fbcp does not start on system startup (delete any fbcp entries) 

##### Operating the system remotely with VNC

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

- On the PC from which you'd like to control the MouseGoggles system (and which is connected to the same network as the Raspberry Pi), download [RealVNC Viewer]([Download VNC Viewer | VNC® Connect](https://www.realvnc.com/en/connect/download/viewer/)). From the search bar, enter the Raspberry Pi's `inet` number. When prompted for a username and password, enter the information you set during the Raspberry Pi OS installation
