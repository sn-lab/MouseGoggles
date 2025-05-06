![(left) 3D render of assembled MouseGoggles EyeTrack 1.1. (right) Picture of assembled MouseGoggles EyeTrack 1.1](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/Images/EyeTrack_1-1_Assembled.png)

# Parts List

---

### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles EyeTrack 1.1, updated with newer IR-sensitive cameras, dual-camera-support with a Raspberry 5, and a simpler assembly! This system is also the first to use Godot Project 2.1, which enables control of the eye-tracking cameras from within the Godot VR game engine.

Follow the links below to purchase the parts in the quantities listed (though you may considering ordering spare parts as well). In addition to these listed parts, you will also need some basic computer peripherals (HDMI monitor, USB keyboard and mouse /touchpad, microSD card reader), at for the initial setup.

| Part Name                                         | Description                                         | Link                                                                                                                                                            | Est. Unit Cost | Quantity |
| ------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |:--------------:|:--------:|
| Raspberry Pi 4 Model B - 2 GB                     | Raspberry Pi 4 Single-board computer                | [PiShop.US](https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypihttps://www.pishop.us/product/raspberry-pi-4-model-b-2gb/?src=raspberrypi) | $45            | 1        |
| Raspberry Pi 5/4GB                                | Raspberry Pi 5 Single-board computer                | [PiShop.US](https://www.pishop.us/product/raspberry-pi-5-4gb/)                                                                                                  | $60            | 1        |
| Class 10 - MicroSD Card Extreme Pro - 32 GB       | MicroSD card to Raspberry Pi OS                     | [PiShop.US](https://www.pishop.us/product/class-10-microsd-card-extreme-pro-32-gb-blank-bulk/)                                                                  | $13            | 2        |
| Micro-HDMI to HDMI cable for Pi 4, 3ft, Black     | HDMI adapter to connect Raspberry Pi to monitor     | [PiShop.US](https://www.pishop.us/product/micro-hdmi-to-hdmi-cable-for-pi-4-3ft-black/)                                                                         | $5             | 2        |
| Waveshare 1.28 inch 240x240 display               | Circular display (with 8-pin cable) for VR eyepiece | [Waveshare](https://www.waveshare.com/product/1.28inch-lcd-module.htm)                                                                                          | $15            | 2        |
| FRP0510 - Ø1/2" Fresnel Lens, f = 10 mm           | Fresnel lens for VR headset                         | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                                                                                         | $21            | 2        |
| FM01 1" Hot mirror                                | Hot mirror for eye tracking camera                  | [Thorlabs](https://www.thorlabs.com/thorProduct.cfm?partNumber=FM01)                                                                                            | $39            | 2        |
| 12" female jumper wires                           | Wires to power IR LED circuit                       | [Adafruit](https://www.adafruit.com/product/793)                                                                                                                | $8             | 1        |
| GPIO Header for Raspberry Pi - 2x20 Female Header | Pin header to connect custom PCB to Pi 4            | [Adafruit](https://www.adafruit.com/product/2222)                                                                                                               | $1.5           | 1        |
| Break-away 0.1" male header strip                 | Pin header to connect wires to custom PCB           | [Adafruit](https://www.adafruit.com/product/392)                                                                                                                | $5             | 1        |
| Raspberry Pi 5 Power Supply                       | USB-C power supply                                  | [Adafruit](https://www.adafruit.com/product/5814)                                                                                                               | $12            | 2        |
| 4-40 thread, 1" length socket head screws         | Pack of 1" long screws to assemble parts            | [McMaster](https://www.mcmaster.com/90044A111/)                                                                                                                 | $9             | 1        |
| 4-40 thread, 1/4" length socket head screws       | Pack of 1/4" long screws to assemble parts          | [McMaster](https://www.mcmaster.com/91251A106/)                                                                                                                 | $12            | 1        |
| 4-40 thread, 3/16" wide narrow hex nuts           | Pack of hex nuts to assemble parts                  | [McMaster](https://www.mcmaster.com/90760A160/)                                                                                                                 | $5             | 1        |
| VSMB2943GX01 SMD 940 nm Infrared LED              | IR LED for eye tracking illumination                | [DigiKey](https://www.digikey.com/en/products/detail/vishay-semiconductor-opto-division/VSMB2943GX01/3984794)                                                   | $0.6           | 4        |
| 100 Ohm SMD Resistor, 0805 package                | Resistor for IR LED circuit                         | [DigiKey](https://www.digikey.com/en/products/detail/yageo/RC0805FR-07100RL/727543)                                                                             | $0.1           | 2        |
| IMX519 NoIR Camera Module for Raspberry Pi 5      | Mini IR-sensitive eye tracking camera               | [Arducam](https://www.arducam.com/product/arducam-mini-16mp-imx519-camera-module-for-raspberry-pi-zero-b0391/)                                                  | $33            | 2        |
| Ethernet CAT6 Cable - 30cm long                   | Ethernet cable for Pi-to-Pi communication           | [Adafruit](https://www.adafruit.com/product/5443)                                                                                                               | $2.50          | 1        |

### 3D prints

The table below lists all custom 3D-printable parts required for MouseGoggles EyeTrack 1.1. Follow the links below for .stl files to print these parts on your own high-resolution 3D printer (recommended layer resolution <=0.2 mm) or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

Notes on print quality: UV-cured resin-based SLA printers (e.g. [Photon Mono X](https://www.anycubic.com/products/photon-mono-x-resin-printer)) can produce adequate and cost-effective parts for MouseGoggles, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)). Thermoplastic polymers such as PLA, PETG, or ABS can produce tougher, longer-laster, and more opaque parts, though should only be used for MouseGoggles from high-resolution 3D printers (e.g. [Ultimaker S3](https://ultimaker.com/3d-printers/s-series/ultimaker-s3/)). If you are printing the parts yourself, a [needle file]([McMaster-Carr](https://www.mcmaster.com/4261A37/)) can be helpful in cleaning up any imperfections in the part.

| Part Name                           | Description                                     | Link                                                                                                                                | Quantity | Aprox. Dimensions (mm) |
| ----------------------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- |
| Eyepiece EyeTrack V8 AngleLeft.stl  | Angled-left eyepiece enclosure (for right eye)  | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Eyepiece%20EyeTrack%20V8%20AngleLeft.stl)  | 1        | 44x41x21               |
| Eyepiece EyeTrack V8 AngleRight.stl | Angled-right eyepiece enclosure (for left eye)  | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Eyepiece%20EyeTrack%20V8%20AngleRight.stl) | 1        | 44x41x21               |
| Enclosure Back V3.stl               | Eyepiece enclosure backing                      | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Enclosure%20Back%20V3.stl)                 | 2        | 41x41x8                |
| EyeTrack SpacerA V4.stl             | Mirror-lens spacer for eyepiece                 | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/EyeTrack%20SpacerA%20V4.stl)               | 2        | 32x32x10               |
| EyeTrack SpacerB V4.stl             | Display-mirror spacer for eyepiece              | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/EyeTrack%20SpacerB%20V4.stl)               | 2        | 32x30x6                |
| Pi5 Mount V1.stl                    | Eyepiece mount for Raspberry Pi 5               | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Pi5%20Mount%20V1.stl)                      | 1        | 79x55x29               |
| Pi Spacer V1                        | Spacer for Raspberry Pi 4 and 5                 | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Pi%20Spacer%20V1.stl)                      | 1        | 64x55x7                |
| Camera Clip V1.stl                  | Clip to secure IR camera and LED board          | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/Camera%20Clip%20V1.stl)                    | 2        | 27x9x2                 |
| IMX519 Key V1.stl                   | Adjustment key for changing focus of IR cameras | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/3D%20Prints/IMX519%20Key%20V1.stl)                     | 1        | 15x15x9                |

### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by MouseGoggles EyeTrack 1.1. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name                                    | Description                                      | Link                                                                                                                                                                  | Quantity |
| -------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| MouseGoggles EyeTrack Hat-1-1_2025-02-03.zip | zipped Gerber files of Rasberry Pi PCB connector | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/PCBs/MouseGoggles%20EyeTrack%20Hat-1-1/MouseGoggles%20EyeTrack%20Hat-1-1_2025-02-03.zip) | 1        |
| MouseGoggles IRLED-1-5_2023-12-21.zip        | zipped Gerber files of IR LED PCB mount          | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/PCBs/MouseGoggles%20IRLED-1-5/MouseGoggles%20IRLED-1-5_2025-02-12.zip)                   | 2        |

# 

# Hardware Assembly Instructions

![Image series of MouseGoggles EyeTrack 1.1 assembly process](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/EyeTrack/1.1/Images/EyeTrack_1-1_Assembly.png)

---

### Assemble the custom PCBs

1. Insert the 2x20 GPIO header onto the back of the "Hat" PCB (the side without any text) and solder the header in place.

2. Break away two 8-pin sections and two 6-pin sections of male headers and insert them onto the front of the custom PCB (the side with text) and solder them in place.

3. Solder a 100 ohm resistor to the central solder pad on each "IRLED" PCB.

4. Solder two IR LEDs onto each IRLED PCB, with the polarity of both LEDs orientated in the same direction.

5. Detach four female jumper wires into two pairs, and strip one end of each to expose one side of the jumper wire pairs. Solder each exposed wire to the corner through-holes of the IRLED PCBs.

### Assemble the MouseGoggles headset

1. With the small end of an "Eyepiece" 3D print facing down, insert a Fresnel lens straight down into the bottom, with the ridged side facing up and the smooth side facing down. 
   
   * Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.

2. Insert the "SpacerA" 3D print into the eyepiece, ensuring it is sitting tight up against the lens and the small tabs in the Eyepiece positioned inside the notches of the Spacer.

3. Place the Hotmirror on top of the SpacerA part, so that it sits firmly in the cutout of the part.

4. Insert the "SpacerB" 3D print in top of the hotmirror, ensuring it is sitting tight up against the hot mirror and the small tabs in the SpacerA part are positioned inside the notches of the Spacer.

5. Insert the Waveshare display into the Eyepiece so that it fits snugly inside the enclosure and sits tight up against SpacerB.

6. Slide the "Enclosure Back" 3D print into the back of the Eyepiece, angling it so that the tabs of the Enclosure Back fit inside the notches of the Eyepiece and the screw holes of both parts are lined up.

7. Insert two hex nuts inside the slots of the Eyepiece, and screw two hex screws through the Enclosure Back to secure the eyepiece together.

8. Repeat steps 1-5 to create a second eyepiece.

9. Before inserting the NoIR cameras into the eyepieces, remove the dab of glue on the side of the lens (just inside the square outer case) which prevents adjustment of the camera focus. Dig out the glue using a small tool such as a needle or small pair of scissors, until the lens can be rotated smoothly using the "IMX519 Key" 3D print. After the glue is removed, use the key to unscrew the lens until it protrudes from its square case by ~2 mm.

10. On each eyepiece, place the assembled IRLED PCB into the cutout on the side of the eyepiece enclosure, and insert a NoIR camera into the camera slot. Holding the IRLED PCB and camera in place, slide the "Clip" 3D print over the camera and LED board, bending the clip so that it grabs the ledges of the eyepiece next to the LED boad, securing the camera board in place. 

11. Attach the "Pi5 Mount" 3D print to the top of a Raspberry Pi 5 (the side with the connectors) by lining up the mounting holes and inserting three 1" long screws from the top of the Pi5 Mount. Do not add nuts to the bottom of the Raspberry Pi yet.

12. Connect the "Pi Spacer" 3D print to the bottom of th Raspberry Pi 5, threading the screws through the mounting holes.

13. Connect a Raspberry Pi 4 below the Pi Spacer, so that the bottom of the Pi 4 is next to the bottom of the Pi 5.

14. Add 3 hex nuts to the screws, tightening them to the top of the Pi 4. You may add a 4th screw to the empty through hole if desired.

15. On each eyepiece, insert two hex nuts into the slots of the Enclosure Back, and secure the eyepiece to the Pi 5 mount using hex screws. Orient the eyepieces so that the cameras are nearer the open side of the Pi 5 mount which exposes the pair of CSI camera ports. Repeat for the other eyepiece.
    
    * Note: If any part is too difficult to slide into place, use a needle file to sand down any warped areas or imperfections of the 3D prints. The edges of the custom PCBs can also be sanded down, since there may also be imperfections in the PCB manufacturing/cutting process.

### Wire up the displays and cameras

1. Attach the custom PCB to the Raspberry Pi's 40-pin header, so that the custom PCB hangs over the Pi (rather than hanging off the side).

2. Attach the 8-pin cables to the circular display of each eyepiece.

3. Attach each wire of the 8-pin cable to the matching header on the custom PCB, attaching the right eye to the display0 header and the left-eye to the display1 header. 

4. Attach the camera ribbon cables to the pair of CSI ports on a Raspberry Pi 5.

5. Insert each IRLED PCB's female jumpers into the ground and 5V pins of the Raspberry Pi headers.

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
- Open up the githib page for the [Unofficial Godot Engine for the Raspberry Pi](https://github.com/hiulit/Unofficial-Godot-Engine-Raspberry-Pi/tree/main?tab=readme-ov-file#compiling).
- In the "Downloads" section, download the zip file for 3.5.2 - Raspberry Pi 4
- After the zip file has been downloaded, navigate to your "downloads" folder, right-click on the zip file, and click "extract here"
- Inside the unzipped folder, find the "...editor_Ito.bin" file. This is the executable file for running the godot game engine. To run the engine, double-click this file and select "Execute".

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

- Open up the command terminal and enter each line, one at a time: (scroll to see the full line)
  
  ```
  wget -O install_pivariety_pkgs.sh https://github.com/ArduCAM/Arducam-Pivariety-V4L2-Driver/releases/download/install_script/install_pivariety_pkgs.sh
  chmod +x install_pivariety_pkgs.sh
  ./install_pivariety_pkgs.sh -p libcamera_dev
  ./install_pivariety_pkgs.sh -p libcamera_apps
  ```

### Add dual-camera support in the configuration file

* Open up the Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo nano /boot/firmware/config.txt
  ```

* After the config file opens, scroll down to the bottom to find the [all] section. Add the following 2 lines under it:
  
  ```
  dtoverlay=imx519,cam0
  dtoverlay=imx519,cam1
  ```

* Hit ctrl-s to save the file

* Reboot the Raspberry Pi
  
  
  

### (Optional) Set up TCP/UDP connection to the Pi 4

- To create a static IP address for direct ethernet connection to the Pi 4, open up the Raspberry Pi command terminal and enter the following lines (feel free to change the IP address to anything between `169.254.0.1/16` and`169.254.255.254/16`): (scroll to see the full line)
  
  ```
  sudo nmcli connection modify "Wired connection 1" ipv4.addresses 169.254.123.1/16 ipv4.method manual
  sudo nmcli connection up "Wired connection 1"
  
  
  ```

- To enable the Pi 4 to control the eye-tracking cameras on the Pi 5, download the "pi5cam_udp.py" and "pi5cam_udp.service" files from the python folder and place them in a folder named "Cam" on the Pi 5 desktop.

- To automatically start the pi5cam_udp.py script whenever the Pi 5 boots up (recommended), open up a command terminal and enter each line one at a time to copy the service file into the systemd folder and enable/start the service: (scroll to see the full line)
  
  ```
  sudo cp /home/MG5/Desktop/Cam/pi5cam_udp.service /etc/systemd/system/pi5cam_udp.service
  sudo systemctl daemon-reload
  sudo systemctl enable pi5cam_udp.service
  sudo systemctl start pi5cam_udp.service
  ```
  
  

# Operating Instructions

---

### Starting the display driver

- Open up the Raspberry Pi command terminal and enter each line, one at a time:
  
  ```
  cd MouseGoggles/fbcp-ili9341/build
  sudo ./fbcp-ili9341
  ```

### Starting the game engine and running experiments

- Navigate to the "godot_3.5.2-stable_rpi4_editor_Ito.bin" file. Double-click this file and select "Execute".

- Import the Godot game project located in MouseGoggles/Godot/MouseVR Godot Project V2.1/project.godot

- When the game editor opens, reduce the window to a partial screen (running it in full screen may cause hang-ups)

- Click the small "play" button on the upper-right side of the menu bar

- Select an experiment (aka "scene")

- A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window

- By default, forward/backward movement and left/right turning in the VR scene can be controlled by a USB computer mouse or trackpad, which can be used to verify the VR system is correctly working

- Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project V2.1/logs/" in csv format (one row per frame, one column per data type)

- Click the `esc` button to exit an experiment early. Logs of completed experiment repetitions will have been saved, but the in-progress/unfinished repetition will not be saved by default

### Stopping the display driver

(only needed for re-installing or updating the display driver)

- Open up the Raspberry Pi command terminal and enter the following line:
  
  ```
  sudo pkill fbcp
  ```

- Check in `/etc/rc.local` and `/etc/init.d` to make sure fbcp does not start on system startup (delete any fbcp entries) 

### Manually recording video from the eye-tracking cameras

* Copy the `pi5cam.py` script from the `Python` folder to the Raspberry Pi 5.

* Run the `pi5cam.py` script, which will open camera preview windows and start recording. A .mjpg file will be saved for each video once the recording has finished.

* (Optional) To convert the .mjpg file to a .mkv file that can be viewed with vlc, open the command terminal and enter the following line, changing the input and output filenames as desired:

* Note 1: The focus of the cameras will likely need to be manually adjusted for high-quality eye imaging. Use the IMX519 key to adjust each camera's focus (i.e. unscrew the lens) until an object (e.g. a piece of paper with small text) positioned ~0.5-1 mm away from the center of the Fresnel lens of the eyepiece is in sharp focus. 

* Note 2: Since the camera is IR sensitive but still strongly detects red, green, and blue light from the displays, the best eye imaging during VR presentation can be achieved by using the latest godot project which only presents images using the blue and green LEDs of the display, and by performing eye-imaging using only the red channel of the NoIR cameras.
  
  ```
  ffmpeg -framerate 25 -i input.mjpg -c:v copy -metadata fps=25 output.mkv
  
  ```

### Automatically recording video from the eye-tracking cameras from a VR experiment

- Make sure that you followed the final installation step above for setting up a TCP/UDP connection.

- Ensure that both Raspberry Pis are turned on.

- On the Pi 4, navigate to the "godot_3.5.2-stable_rpi4_editor_Ito.bin" file. Double-click this file and select "Execute".

- Open/edit the MouseVR Godot Project V2.1.

- Find the "commonSettings.gd" script and open it in the "script" tab.

- Scroll down to find the the "var destination_ip" line and ensure that the IP address listed here is the same you selected during the TCP/UDP installation step above.

- To verify that the UDP connection is working, run the project (play button on the upper-right) and select the "camera viewer" scene. A window should show images from the eye-tracking cameras, updated at 2 Hz. This scene can be used to ensure accurate placement of the headset for eye-trakcing

- To see an example VR experiment which automatically records eye-tracking video, run the "rotating grating" scene and/or open up the rotatingGratingScene.gd script.

- To enable automatic eye-tracking camera recording for other experiments, copy the following code blocks into their respective locations in the experiment .gd script file:

- Copy the following block of code into the experiment's "_ready()" function: (change the recording_duration to be just greater than the maximum duration of the experiment)
  
  ```
  #UDP handshake
  var recording_duration = 100 #seconds of video to record, if not stopped sooner
  assert(udp.listen(listen_port) == OK, "UDP listen failed")
  verify_connection()
  start_video(experimentName, recording_duration)
  OS.delay_msec(1000)
  ```

* Copy the following block of code into two locations: 1) at the end of the "_process(delta)" function, just before the experiment exits back to the sceneSelect scene (get_tree().change_scene("res://sceneSelect.tscn")), and 2) in the "_input(ev)" function when "KEY_ESCAPE" is pressed, just before the experiment exits back to the sceneSelect scene:
  
  ```
  stop_video() #stops the video recording early (earlier than the duration set above)
  transfer_video(experimentName) #transfers recorded video from the Pi 5 into the log folder of this experiment
  ```
  
  

### Operating the systems remotely with VNC

- Make sure that the reaspberry Pi(s) you want to operate are connected to the internet or your local network.

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
