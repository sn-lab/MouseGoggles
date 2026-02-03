![(left) 3D render of assembled MouseGoggles EyeTrack 2.0. (right) Picture of assembled MouseGoggles EyeTrack 2.0](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/Images/E2_Assembled.png)

# 

**NOTE:** This version is currently in development and is subject to change; if you proceed with building this version and notice any mistakes or problems, please raise an issue on Github!

# Parts List

---

### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles EyeTrack 2.0, a re-design of the EyeTrack headset built entirely around a single Raspberry Pi 5! This version features newer parts, improved eye imaging, and a simpler assembly and installation process with no custom circuitboards required.

Follow the links below to purchase the parts in the quantities listed (though you may consider ordering spare parts as well). If any parts are out of stock at the links below, other suppliers are often available (e.g. Digikey stocks many Adafruit parts). In addition to these listed parts, you will also need some basic computer peripherals (HDMI monitor, USB keyboard and mouse /touchpad, microSD card reader), at least for the initial setup.

* Note: if you intend on frequently acquiring eye-tracking videos, consider purchasing a MicroSD card with more storage space (e.g. 512 GB)

| Part Name                                       | Description                                     | Link                                                                                           | Est. Unit Cost (USD) | Quantity |
| ----------------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------- |:--------------------:|:--------:|
| Raspberry Pi 5 - 4GB                            | Raspberry Pi 5 Single-board computer            | [PiShop.US](https://www.pishop.us/product/raspberry-pi-5-4gb/)                                 | $85                  | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB     | MicroSD card to Raspberry Pi OS                 | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/) | $23                  | 1        |
| Micro-HDMI to HDMI cable for Pi 4 - 3ft, Black  | HDMI adapter to connect Raspberry Pi to monitor | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)        | $6                   | 1        |
| FM02 1" Red Hot mirror                          | Hot mirror for eye tracking camera              | [Thorlabs](https://www.thorlabs.com/thorProduct.cfm?partNumber=FM02)                           | $57                  | 1+spare  |
| FRP0510 1/2" Fresnel Lens - f = 10 mm           | Fresnel lens for VR headset                     | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                        | $22                  | 2        |
| Raspberry Pi 5 Power Supply                     | USB-C power supply                              | [Adafruit](https://www.adafruit.com/product/5814)                                              | $14                  | 1        |
| Female/Female Jumper Wires                      | 20x12" Jumper wires                             | [Adafruit](https://www.adafruit.com/product/1949)                                              | $4                   | 1        |
| Spy camera for Raspberry Pi                     | Mini  eye tracking camera                       | [Adafruit](https://www.adafruit.com/product/1937)                                              | $40                  | 2        |
| FPC Camera Cable - 22-pin to 15-pin, 200mm long | Cable to connect camera modules                 | [Adafruit](https://www.adafruit.com/product/5818)                                              | $3                   | 2        |
| CSI or DSI Cable Extender                       | 15 pin cable extender                           | [Adafruit](https://www.adafruit.com/product/3671)                                              | $3                   | 2        |
| 1.28" 240x240 Round TFT LCD                     | Display for VR headset                          | [Adafruit](https://www.adafruit.com/product/6178)                                              | $18                  | 2        |
| 2-56 thread, 3/16" wide narrow hex nuts         | Pack of hex nuts to assemble parts              | [McMaster](https://www.mcmaster.com/90730A003/)                                                | $4                   | 1        |
| 2-56 thread, 1/2" length socket head screws     | Pack of 1/2" long screws to assemble parts      | [McMaster](https://www.mcmaster.com/91251A081/)                                                | $10                  | 1        |
| **Total (est.)**                                |                                                 |                                                                                                | $375                 |          |

### Recommended tools

| Part Name         | Description                                                 | Link                                                                                    | Est. Unit Cost (USD) |
| ----------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------------------- | -------------------- |
| Needle file       | File for sanding/smoothing 3D prints                        | [McMaster](https://www.mcmaster.com/4261a37/)                                           | $19                  |
| Hex wrench        | Wrench for assembling headset                               | [McMaster](https://www.mcmaster.com/7122A15/)                                           | $1                   |
| Glass scribe      | Simple glass scribe for cutting hot mirror to size          | [Grainger](https://www.grainger.com/product/GENERAL-TOOLS-Scriber-Straight-3ZZP6)       | $12                  |
| Silicone adhesive | Electronics grade adhesive for extra support of parts/wires | [Digikey](https://www.digikey.com/en/products/detail/chip-quik-inc/EGS10C-20G/10059587) | $5                   |
| Soldering iron    | Soldering iron for attaching jumper wires to displays       | [Adafruit](https://www.adafruit.com/product/4921)                                       | $60                  |
| Soldering wire    | for soldering jumper wires                                  | [Adafruit](https://www.adafruit.com/product/1930)                                       | $18                  |
| Wire strippers    | for stripping jumper wires                                  | [Adafruit](https://www.adafruit.com/product/527)                                        | $18                  |
| Flush cutters     | for trimming ends of soldered wire                          | [Adafruit](https://www.adafruit.com/product/152)                                        | $7                   |

### 3D prints

The table below lists all custom 3D-printable parts required for this version of MouseGoggles. Follow the links below for .stl files to print these parts on your own 3D printer or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

For most parts, a z-resolution of <=0.1 mm is recommended, while for the "Bracket" and "Mount" parts, greater material strength is preferred and <=0.3 mm z-resolution is adequate.

For strong, long-lasting parts, an FDM-based printer using PLA is a good choice, such as the [Original Prusa MK4S](https://www.prusa3d.com/product/original-prusa-mk4s-3d-printer-5/) or the [Elegoo Neptune 4](https://us.elegoo.com/collections/fdm-printers/products/elegoo-neptune-4-fdm-3d-printer). For higher resolution parts, UV-cured resin-based SLA printers such as the [Photon Mono M7](https://store.anycubic.com/products/photon-mono-m7) can also produce adequate and cost-effective parts, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)).

| Part Name                | Description                           | Link                                                                                                                  | Quantity | Aprox. Dimensions (mm) |
| ------------------------ | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- |
| Eyepiece V1.stl          | Main eyepiece enclosure               | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/Eyepiece%202.0%20V1.stl)     | 2        | 41x36x12.5             |
| LensClip V1.stl          | Clip for securing Fresnel lens        | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/LensClip%20V1.stl)           | 2        | 17x12x4                |
| CameraClip V1.stl        | Clip for securing Camera              | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/CameraClip%20V1.stl)         | 2        | 13x7x6                 |
| EyepieceBack V1          | Backing of eyepiece                   | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/EyepieceBack%202.0%20V1.stl) | 2        | 40x28x6                |
| Bracket50 V1.stl         | Headset frame (50 deg eyepiece angle) | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/Bracket50%20V1.stl)          | 1        | 79x52x43               |
| MirrorStencilBase V1.stl | Base of glass cutting stencil         | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/MirrorStencilBase%20V1.stl)  | 1        | 40x30x3                |
| MirrorStencil V1.stl     | Stencil for glass cutting             | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/3D%20Prints/MirrorStencil%20V1.stl)      | 1        | 44x34x4.5              |

# Hardware Assembly Instructions

---

### Assemble the MouseGoggles headset

![Select steps of MouseGoggles EyeTrack 2.0 assembly](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/Images/E2_Assembly.png)

1. Separate a group of 7 jumper wires from the bundle. Cut the sockets off of one end of the wires and strip the cut end of the wire. Solder the 7 exposed wires into the back of a circular display to the following pins: 3Vo, Gnd, SCK, MOSI, TFTCS, RST, DC. (it is not necessary to connect Vin, MISO, SDCS, Lite). Repeat with a 2nd display.

2. Cover the soldered pins and base of the wires with silicone glue, to give extra support to the junction and prevent wires breaking when bent. (the glue may take up to 24 hours to fully cure)

3. Insert a hot mirror into the MirrorStencilBase, and set the MirrorStencil on top. Holding the mirror and stencil stable with one hand, gently scratch the mirror using the glass scribe along the 3 lines in the stencil, going over each line multiple times. After the glass has been scored, flip the MirrorStencil parts inside out and sandwich the mirror in between the two flat surfaces of the part, so that the mirror is sticking halfway out and the score line follows the straight edge of the MirrorStencil as closely as possible. Clamping the mirror between the stencil, gently press the exposed half of the mirror to snap the mirror along the central score line. Then, for each half of the mirror, expose the other sections and break along the smaller score lines to finish roughly shaping the mirror (these smaller score lines to not need to bread as cleanly since they will be largely out of the mouse's view). Slide each mirror all the way into the mirror slot of the eyepieces to check the fit - ideally it should roughly follow the shape of the eyepiece without extruding too much.
   
   * Tips: Adding a drop of liquid to the score line can help ensure that the glass snaps along the line. To chip away smaller pieces of glass, you can use the metal back end of the scribe to press and break the glass edge. This broken edge does not need to be a clean edge since it is not visible inside the eyepiece.
4* Slide each hot mirror into the angled mirror slot of the eyepieces (uncut-side first), and secure the edge of the cut side to the eyepiece with silicone glue. (the glue may take up to 24 hours to fully cure)

5. Insert a camera into the camera port, with the ribbon cable oriented in the direction opposite of the eyepiece front. Press a CameraClip onto the back of the camera to clip it to the eyepiece.
   
   * Note: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints.

6. Stack the circular display on top of the eyepiece, with the display screw-holes aligned to the screw holes on the side of the eyepiece opposite of the camera port.

7. Stack the EyepieceBack onto the display/eyepiece, with all four open screw holes aligned to the four screw holes of the eyepiece, and with the camera ribbon cable sitting between the EyepieceBack and the display so that it is protected, secured, and lines up with the soldered jumper wires. From the eyepiece-side, Insert four 1/2" screws through the holes, but don't secure them with nuts yet.

8. Repeat steps 5-7 with a second eyepiece.

9. (for horizontally-mounted eyepieces) Position the two eyepieces onto the bracket so that 3 of the 4 screws of each eyepiece extend through the inner bracket slots. Then add nuts to all four screws to secure the eyepiece together and to the bracket.

10. Insert a Fresnel lens into each slot on the front of the eyepieces, with the ridged side of the lens facing into the eyepiece and the smooth side facing out of the eyepiece (very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged). Attach a LensClip to each eyepiece to hold the lens in place. (the thicker end of the LensClip should be oriented so that it will sit above the mouse's eye, not below it.

### Wire up the displays and cameras

![(left) Wired connections of a MouseGoggles EyeTrack 2.0 to a Raspberry Pi 5. (right) Pin names and numbers of the Raspberry Pi 5 40-pin header.](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/2.0/Images/E2_Wiring.png)

Follow the mapping table below to wire up each display to the pins of the Raspberry Pi 5 (refer to Pi 5 pin names [here](https://pinouthub.com/rpi-5-gpio-pinout/)):

| Display pin       | Raspberry Pi 5 pin         |
| ----------------- | -------------------------- |
| Display 1 - 3Vo   | pin 1 (3V3 power)          |
| Display 1 - GND   | pin 6 (Ground)             |
| Display 1 - SCK   | pin 23 (GPIO 11, SCLK)     |
| Display 1 - MOSI  | pin 19 (GPIO 10, MOSI)     |
| Display 1 - TFTCS | pin 24 (GPIO 8, CE0)       |
| Display 1 - RST   | pin 11 (GPIO 17)           |
| Display 1 - DC    | pin 22 (GPIO 25)           |
| Display 2 - 3Vo   | pin 17 (3V3 power)         |
| Display 2 - GND   | pin 9 (Ground)             |
| Display 2 - SCK   | pin 40 (GPIO 21, PCM_DOUT)  |
| Display 2 - MOSI  | pin 38 (GPIO 20, PCM_DIN) |
| Display 2 - TFTCS | pin 12 (GPIO 18, PCM_CLK)  |
| Display 2 - RST   | pin 37 (GPIO 26)           |
| Display 2 - DC    | pin 36 (GPIO 16)           |

# Software Installation Instructions

---

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the MicroSD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the necessary software (Godot game engine, display settings, camera software).

## Installing software

### Install the Raspberry Pi 5 Operating System

- Insert a blank micro SD card into your PC
- Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Choose Device: "Raspiberry Pi 5""
- Choose OS: "Raspberry Pi OS (64-bit)"
- Choose Storage: -select your SD card-
- When asked if you would like to apply custom OS settings, click "Edit Settings"
- Set the hostname, username, password, WiFi, and localisation settings as desired, then click save and exit the settings window (where applicable in the following instructions, the hostname will be assumed to be "MG2")
- Select "write" to install the OS with your custom settings
- After the image has finished writing, Insert the SD card into your Raspberry Pi and power it on

### Download the MouseGoggles repository

- Start the Raspberry Pi and connect to the internet.
  
  - to connect to a wireless internet network, you may first be asked to set your wireless LAN country

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt install python3-opencv
  cd ~
  git clone https://github.com/sn-lab/MouseGoggles
  ```

- Note: If you are asked if you want to continue installing, answer yes.

### Set up the displays

- Open up the Raspberry Pi command terminal enter each line, one at a time, to copy the display driver and to edit the Raspberry Pi configuration file: (scroll to see the full line).
  
  ```
  sudo cp ~/MouseGoggles/Versions/EyeTrack/2.0/Install/gc9a01.bin /lib/firmware/
  sudo nano /boot/firmware/config.txt
  ```

- In a separate window (leave the command terminal open), open the file located in:`MouseGoggles/Versions/EyeTrack/2.0/Install/configtxt.txt`.

- Copy the entire configtxt contents into the bottom of the config file (just below the `[all]`section).

- Restart the PC.

- When the computer reboots, right-click on the desktop and select `Desktop Preferences`.

- Scroll down the menu on the left to select the `Screens` tab.

- Drag the screens so that the SPI-1 screen is on the top-left corner and the SPI-2 screen is just to the right of SPI-1 (the screens should snap so that they are linked on their edges). If there is an HDMI screen, drag that so it is also aligned to the top-left corner, sitting underneath both SPI screens.

- If you have mounted the eyepieces on the bracket vertically (i.e. with the jumper wires extending upwards above the bracket), you can skip the next line.

- If you have mounted the eyepieces on the bracket horizontally (i.e. with the jumper wires extending towards the center of the bracket), right-click on the SPI-1 screen and set "Orientation" to "Right", then right-click on the SPI-2 screen and set "Orientation" to "Left".

- Apply and click "ok" to accept the changes.

# Operating Instructions

---

### Starting the game engine and running experiments

- Navigate to the "pi5cam_udp.py" file in the MouseGoggles/Versions/EyeTrack/2.0/Python folder. Double-click this file to open it into a code editor, then click the "run" (arrow) button to start the camera controller. (If you do not wish to perform eye-tracking, you can skip this step.) **Feel free to move this file to the desktop to make it easier to start experiments**

- Navigate to the "godot_3.5.2-stable_rpi4_editor.arm64" file in the MouseGoggles/Godot folder. Double-click this file and select "Execute". **Feel free to move this file to the desktop to make it easier to start experiments**

- Import the Godot game project located in MouseGoggles/Godot/MouseVR Godot Project V2.2/project.godot

- With the project highlighted, click "Run"

- Select an experiment (aka "scene")

- A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window

- By default, forward/backward movement and left/right turning in the VR scene can be controlled by a USB computer mouse or trackpad, which can be used to verify the VR system is correctly working

- Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project V2.2/logs/" in csv format (one row per frame, one column per data type)

- Click the `esc` button to exit an experiment early; the in-progress/unfinished repetition be saved in the final log file

### Operating the system remotely with VNC

- Make sure that the reaspberry Pi is connected to the internet or your local network
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
