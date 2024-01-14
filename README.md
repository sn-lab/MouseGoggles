# About MouseGoggles

A dual-SPI-display mouse-sized VR headset, powered by Raspberry Pi and the Godot game engine. Check out our preprint on Research Square! https://doi.org/10.21203/rs.3.rs-3301474/v1

![(left) A Raspberry Pi 4 uniquely controlling 2 circular displays. (right) Render of a head-fixed mouse on a treadmill with a VR headset](https://github.com/sn-lab/MouseGoggles/blob/main/Images/mouseVRheadsetIntro.png)

MouseGoggles is a headset VR system for mouse neuroscience and behavior research. By positioning the headset to the eyes of a head-fixed mouse running on a treadmill, virtual scenes can be displayed to the mouse in both closed-loop (treadmill motion controls the visual scene) and open-loop (visual scenes unaffected by movement) modes. The headset is powered by a Raspberry Pi 4, Godot video game engine, and a custom display driver for controlling each eye's display. A 3D printed case holds the Raspberry Pi and display eyepieces -- each eyepiece containing a circular display and Fresnel lens to cover a wide field-of-view (~70 deg solid angle) of the mouse eye and put the visual scene at a focal length of [approximately] infinity.

- This system is a work in progress. Find a bug, have a suggestion, or want to make a feature request? Submit an [issue](https://github.com/sn-lab/MouseGoggles/issues) or start a [discussion](https://github.com/sn-lab/MouseGoggles/discussions).

### The Raspberry Pi and Godot game engine

![Godot game engine running on a Raspberry Pi 4](https://github.com/sn-lab/MouseGoggles/blob/main/Images/RaspberryPiGodot.png)

The heart of the MouseGoggles is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. Since the displays are relatively low resolution (240x210), an inexpensive single-board computer like a Raspberry Pi 4 is all that's needed to effectively render visual scenes at high (>60 fps) framerates. The multiplatform game engine Godot makes it easy to create virtual scenes and develop experimental protocols. Examples included in this repo are experiments for visual cliff avoidance, reactions to looming stimuli of various size/velocity ratios, and the syndirectional rotational optomotor response to gratings of various spatial wavelengths. The views rendered for each display are controlled by separate in-game cameras which can be tied together to match the inter-eye distance and angle of a typical mouse. Custom display shaders warp the view from each camera to match the spherical distortion of the Fresnel lenses, intended to create a realistic and immersive experience for the mouse.

### The display driver

![dual-SPI-display driver streams different frame subsets to two displays](https://github.com/sn-lab/MouseGoggles/blob/main/Images/DisplaySubsets2.png)

Based on a ["blazing fast" display driver](https://github.com/juj/fbcp-ili9341) for SPI-based displays, the driver included in this repository works by copying the HDMI framebuffer and streaming the image data to the connected displays connected on the Raspberry Pi's SPI port. This means that the headset displays are not limited to displaying what is rendered by Godot; in fact, whatever is displayed on the central 240x420 (WxH) pixel region of the screen is going to be streamed to the displays. If you want to create images or video with some other program, you just have to position it in the center of the display for it to be sent to the displays -- the top 240x210 sent to display 0 (on SPI0 chip-select 0) and the bottom 240x210 to display 1 (on SPI0 chip-select 1).

### The headset assembly

![Render of a fully assembled VR headset positioned for a head-fixed mouse](https://github.com/sn-lab/MouseGoggles/blob/main/Images/VRHeadsetRender.png)

To create an immersive, wide field-of-view (FOV) VR headset from the dual-display Raspberry Pi, a 3D-printed headset case angles the displays inwards and sets them behind Fresnel lenses. These lenses serve two functions: to allow the displays to be positioned very close (<15 mm) to the mouse's eyes while still maintaining a comfortable infinity focal distance, and to spherically distort the displays to cover a wide FOV around each eye. Viewing angles from 0-70 degrees (0-52.5 degrees on the chipped side of the circular display) are linearly mapped onto the 240x210 circular display, resulting in an angular resolution of ~0.64 deg/pixel. With the 2 displays angled 45 degrees inward from straight ahead, the binocular headset covers a wide FOV: 140 degrees vertical and 230 degrees horizontal, with ~25 degrees of binocular overlap. Even greater horizontal FOVs are possible with greater display angles.

### The spherical treadmill

![Render of a spherical treadmill system with a head mount, air-suspended Styrofoam ball, motion sensors, and microcontroller](https://github.com/sn-lab/MouseGoggles/blob/main/Images/SphericalTreadmillRender.png)

Our VR headset was developed and tested using a spherical treadmill setup as described [here](https://pubmed.ncbi.nlm.nih.gov/19829374/) for closed-loop VR experiments. This treadmill simulates 2D navigation to a head-fixed mouse, allowing ground translation and yaw rotation. The treadmill motion is measured using optical sensors pointed at the treadmill along axes that are orthogonal to each other, acquired by a microcontroller (in our case, an Arduino Due). The microcontroller then converts these two sources of horizontal and vertical optic flow into treadmill spherical rotations: yaw, pitch, and roll. These rotation values are then sent to the Raspberry Pi over USB through computer mouse emulation: yaw rotations mapped as mouse x movement, pitch as mouse y movement, and roll as mouse scroll wheel movement. The Godot game engine converts these detected mouse movement events into the appropriate camera movements in the virtual scene. This setup allows the human user to test the game environments and experiments using a standard computer mouse or touchpad, and to use this VR system with any type of treadmill controll system that can be translated through a mouse emulator. See [here](https://github.com/sn-lab/MouseGoggles/tree/main/Hardware/mouseVRheadset_controller_V4) for our Arduino Due code for measuring ball motion and mouse emulation.

### The monocular display

![Monocular display for basic visual stimuli (e.g. drifting gratings)](https://github.com/sn-lab/MouseGoggles/blob/main/Images/MonocularDisplay.png)

In addition to the VR headset system, a monocular display can be built using a single display, lens, and microcontroller. Where the headset is ideal for complex virtual reality experiments and behavioral research, the monocular display is ideal for simple visual stimulation for basic visual neuroscience applications. The fast microcontroller [Teensy4.0](https://www.pjrc.com/store/teensy40.html) and [Adafruit graphics library](https://learn.adafruit.com/adafruit-gfx-graphics-library/overview) is used to display simple shapes and moving patterns such as flickers, edges, and drifting gratings.

# Headset Build Instructions

To build a mouse VR headset, follow this general outline:

1. Purhcase the parts
2. Order and assemble the custom PCB
3. 3D print the case
4. Assemble the components
5. Install software on the Raspberry Pi

### Parts

For a complete list of parts for the monocular display, binocular headset, as well as a small form factor headset, see the [Parts List](https://github.com/sn-lab/MouseGoggles/blob/main/Hardware/Parts%20Lists.xlsx).

The circular display model listed in the parts list (TT108RGN10A) is just one of a family of similar displays, many of which may be compatible with MouseGoggles. Since specific display models are occasionally discontinued, listed below are the circular display model numbers we are aware of and our most up-to-date estimates of their compatibility:

* [TT108RGN10A](https://www.alibaba.com/product-detail/Small-IPS-Round-LCD-Module-1_62550674738.html) - tested, working
* TT108RRN11A  - tested, working
* TT109RAN11A - untested, NOT compatible
* TT109RAN12A - untested, likely NOT compatible
* TT108RRN13A - tested, working
* TST108102 - untested, likely compatible
* TST108103 - untested, likely compatible
* [Waveshare 240x240](https://www.waveshare.com/product/1.28inch-lcd-module.htm) - tested, working (requires different 3D prints and PCB, coming soon!)

### custom PCB

To order a custom PCB, use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html).
Upload the zipped Gerber files for the PCB(s) you want, as listed in the [Parts List](https://github.com/sn-lab/MouseGoggles/blob/main/Hardware/Parts%20Lists.xlsx). Choose your desired quantity to order and hit order. 

To assemble components onto the PCB (headers and connectors), see the options in this [discussion](https://github.com/sn-lab/MouseGoggles/discussions/7) for either using a professional assembly service or for manual microsoldering.

### 3D-printed Case

To 3D print the monocular display or headset enclosure, download the [.stl files](https://github.com/sn-lab/MouseGoggles/tree/main/Hardware/3D%20Prints) listed in the [Parts List](https://github.com/sn-lab/MouseGoggles/blob/main/Hardware/Parts%20Lists.xlsx) and print them using a high-resolution 3D printer (we used the [Photon Mono X](https://www.anycubic.com/collections/anycubic-photon-3d-printers/products/photon-mono-x-resin-printer)) or order it through an 3D printing service such as [CraftCloud](https://craftcloud3d.com/upload).

### Headset Assembly

![(left) Hardware for assembling a MouseGoggles system. (middle) Assembly photo, step 1. (right) Assembly photo, step 5](https://github.com/sn-lab/MouseGoggles/blob/main/Images/MouseGoggles%20assembly%20combined%201.png)
![(left)  Assembly photo, step 9. (middle) Assembly photo, step 13. (right) Assembly photo, step 15](https://github.com/sn-lab/MouseGoggles/blob/main/Images/MouseGoggles%20Assembly%20combined%202.png)
After all components (including off-the-shelf parts and tools, 3D prints, and the custom PCB) have been obtained:

1. Install the circular display by sliding it into the display slot of the eyepiece, with the glass side facing out, ensuring it is pushed all the way in and the ribbon cable is centered in the slot.
   * Note: if during assembly anything is difficult to slide into place, check for imperfections or warping of the printed part and sand them down with the needle file until parts fit freely.
2. Slide the "DisplayHolder" 3D print into the slot following the display, with the cutout making space for the ribbon cable, until it is flush with the eyepiece edges.
3. Install the Fresnel lens into the lens slot of the eyepiece, with the ridged side facing the display and the flat side facing out.
   * Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.
4. Slide the "LensHolder" 3D print into the slot following the lens, with the angled side facing to the side and matching the slope of the eyepiece, until it is flush with the eyepiece edges.
5. Add a dab of silicone adhesive to the edges of the holders and wipe it flat with a cloth or finger. Add more silicone to close all gaps if minimal light pollution is desired. 
6. Leave the eyepiece untouched to allow the adhesive to set.
7. Repeat steps 1-6 for the 2nd eyepiece.
8. Attach the fully assembled PCB (with 2x20 socket header and FPC connectors soldered) to the bottom of the "CaseFront" 3D print with double-sided tape or a loop of regular tape. The 2x20 header should be toward the edge of the CaseFront, with the the display ribbon cables passing through the hole in the center.
9. Using tweezers and/or careful handling, gently open the connecting flap on each fpc connector and slide each ribbon cable into their respective slots. Close the flaps to hold the cables in place. 
   * Note: When a cable is properly inserted, the white horizontal line of the ribbon cable will be flush or nearly flush with the edge of the closed flap.
10. With the "CaseBack" 3D print set upside down (so the large central mounting hole is facing up), slide a 4-40 nut into each of the four small mounting hole slots. Temporarily screw in 4-40 screws through these holes to ensure the nuts are properly positioned. 
11. Add a dab of instant-bond adhesive to the edge of the nuts, inside the slot but not near the threads of the nuts, to permanently fix the nuts in place. Remove the screws after the adhesive has set.
12. Repeat steps 10-11 with a 1/4-20 nut/screw and the large central mounting hole.
13. Place a raspberry pi 4 inside the CaseBack, facing up and aligned to the mounting holes, with the USB ports pointing toward the open end.
14. Place the assembled CaseFront on top of the CaseBack, making sure the Raspberry Pi pins are aligned with the 2x20 sockets, and push down until the case is closed and the PCB is connected.
15. Add four 1" 4-40 screws into the screw holes of the CaseFront to hold the case and components securely in place.
16. To further reduce light pollution from the headset, paint the outside of the eyepieces with matte black acrylic paint.

The headset is assembled! Now you can simply connect the Raspberry Pi to a monitor (using the hdmi 0 port), a USB keyboard and mouse, and a 5 v power supply, and proceed to the software installation steps.

* Note on disassembly: when opening up the assembled case, take special care not to pull on or twist the display ribbon cables as they can easily break, rendering the displays broken and unfixable. To safely open the case, hold the PCB firmly against the CaseFront before attempting to separate the PCB from the Raspberry Pi and CaseBack. Only after the ribbon cables are disconnected can you let go of and remove the PCB from the CaseFont. This complication (and a few others) have been eliminated in newer versions of the headset design, coming soon!

### Software Installation

To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the SD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the Godot game engine and custom display driver, as well as all dependencies listed in the instructions below. Software installation on the Raspberry Pi typically takes <10 minutes.

1. Installing the Legacy Raspberry Pi Operating System
   
   * Insert the micro SD card into your PC
   * Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
   * Choose OS: "Raspberry Pi OS (Legacy)"
   * Choose Storage: -select your SD card-
   * Write
   * Insert the SD card into your Raspberry Pi and power it on

2. Install the Godot game engine
   
   * Open up the Raspberry Pi command terminal and enter each line, one at a time:
     
     ```
     sudo apt update
     sudo apt install flatpak
     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
     flatpak install flathub org.godotengine.Godot
     ```
   
   * note: When you are asked if you want to continue installing, answer yes

3. Install the display driver
   
   * Open up the Raspberry Pi command terminal and enter each line, one at a time:
     
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
   
   * note 1: Depending on which circular display you're using, the `cmake ..` line may have to be customized. If you're using a circular display with the GC9307 driver (e.g. TT108RGN10A), then the default `cmake ..` line is appropriate. If the display uses the         ST7789V2 driver (e.g., TT108RRN13A), the line should be changed to `cmake -DST7789V2=ON ..`. And if you're using a display with the GC9A01 driver (e.g., waveshare 240x240), use `cmake -DGC9A01=ON ..`.
     
     * note 2: When you are asked if you want to continue installing, answer yes.
   
   * note 3: See the error "vc_dispmanx_display_open failed!" on the last step? See [this issue](https://github.com/sn-lab/MouseGoggles/issues/23) for a quick fix.

This installation has been verified using the following software versions: 

* flatpak: 1.14.1-4
* cmake: cmake-3.27.4
* godot: 3.2.3.stable.flathub

### Operating the system

1. To start the display driver, if it is not already running (i.e. if the displays are not updating)
   
   * Open up the Raspberry Pi command terminal and enter each line, one at a time:
     
     ```
     cd MouseGoggles/fbcp-ili9341/build
     sudo ./fbcp-ili9341
     ```

2. To start the game engine and run experiments
   
   * Open up the Raspberry Pi command terminal and enter the following line:
     
     ```
     flatpak run org.godotengine.Godot
     ```
   
   * Import the Godot game project located in mouseVRheadset/Godot/MouseVR Godot Project VX.X/project.godot (recommended to select the newest available version)
   
   * When the game editor opens, reduce the window to a partial screen (running it in full screen may cause hang-ups)
   
   * In Project>Project Settings>Display>Window, change `Width` to 240 and `Height` to 420
   
   * In Project>Project Settings>Debug>Settings, change `Force FPS` to 60 (higher fps may be possible)
   
   * Click the small "play" button on the upper-right side of the menu bar
   
   * Select an experiment (aka "scene")
   
   * A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window
   
   * Upon the completion of each repetition of an experiment (typically 30 - 60 s duration), logs of the mouse movement and important experiment parameters will be saved in "MouseVR Godot Project VX.X/logs/" in csv format (one row per frame, one column per data type)
   
   * Click the `esc` button to exit an experiment early (logs of completed experiment repetitions will have been saved, but the in-progress/unfinished repetition will not be saved)

3. To customize Godot experiments on the Raspberry Pi
   
   * Use the Godot editor, following [official documentation](https://docs.godotengine.org/en/stable/) or numerous online tutorials (e.g. [GDQuest](https://www.youtube.com/channel/UCxboW7x0jZqFdvMdCFKTMsQ/playlists))
   * 3D environments can be edited in .tscn files in the "3D" tab
   * Experiment code can be edited in .gd files in the "Script" tab
   * In .gd files, pay special attention to "movement sensitivities" variables -- these will need to be calibrated to your specific behavior measurement system

4. To customize Godot experiments on a Windows or Mac PC to be later transferred to the Raspberry Pi headset (Godot Project V1.0 and later)
   
   * Install the latest [Godot editor](https://godotengine.org/) on your PC
   * Run Godot and import the Godot project
   * For rendered views that are easier to see and work with, in each .tscn experiment file, delete the `HeadKinBody` node (under the parent `spatial` node) and drag the "HeadKinBody_monitor.tscn" resource (from the FileSystem panel) to the `spatial` node. (the screen layout in "HeadKinBody_monitor" is easy to work with on a desktop monitor, while the screen layout in "HeadKinBody_headset" is required for the Raspberry Pi headset)
   * for the "HeadKinBody_monitor" layout, change with window dimensions to 420x240 (WxH) (in Project>Project Settings>Display>Window)
   * for the "HeadKinBody_headset" layout, change with window dimensions to 240x420 (WxH)
   * In the .gd files for each experiment, optimize the movement sensitivities for your desired input (e.g. computer mouse, trackpad)
   * Follow [official documentation](https://docs.godotengine.org/en/stable/) or numerous online tutorials to edit the experiments
   * Save any changes and rename your project
   * To transfer the project to the headset, copy the Project folder and transfer to the Raspberry Pi
   * On the Raspberry Pi, run Godot (`flatpak run org.godotengine.Godot`) and import/edit the new project
   * Reduce the window size from full screen
   * In Project>Project Settings>Display>Window, change `Width` to 240 and `Height` to 420
   * If you were working with "HeadKinBody_monitor" on your PC, in each experiment .tscn file, replace the `HeadKinBody` node with the "HeadKinBody_headset" file
   * In .gd files, adjust "movement sensitivities" for your specific behavior measurement system

5. To stop the display driver on the Raspberry Pi (only needed for re-installation or updating the display driver)
   
   * Open up the Raspberry Pi command terminal and enter the following line:
     
     ```
     sudo pkill fbcp
     ```
   
   * Check in `/etc/rc.local` and `/etc/init.d` to make sure fbcp does not start on system startup (delete any fbcp entries)

# Monocular Display Build Instructions

To build a monocular display system, follow this general outline:

1. Purhcase the parts
2. Order and assemble the custom PCB
3. 3D print the case
4. Assemble the components
5. Install software on the Teensy microcontroller

### Parts, PCB, and 3D printed case

See [headset build instructions](#Headset-Build-Instructions) for details on how to order/print the parts for the monocular display.

### Monocular Headset Assembly

After all components (including off-the-shelf parts and tools, 3D prints, and the custom PCB) have been obtained:

1. Install the circular display by sliding it into the display slot of the EyepieceFront, with the glass side facing out, ensuring it is pushed all the way in and the ribbon cable is centered in the slot.
   
   * Note: if during assembly anything is difficult to slide into place, check for imperfections or warping of the printed part and sand them down with the needle file until parts fit freely.

2. Slide the "DisplayHolder" 3D print into the slot following the display, with the cutout making space for the ribbon cable, until it is flush with the eyepiece edges.

3. Install the Fresnel lens into the lens slot of the EyepieceFront, with the ridged side facing the display and the flat side facing out.
   
   * Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.

4. Slide the "LensHolder" 3D print into the slot following the lens, with the angled side facing to the side and matching the slope of the eyepiece, until it is flush with the eyepiece edges.

5. Add a dab of silicone adhesive to the edges of the holders and wipe it flat with a cloth or finger. Add more silicone to close all gaps if minimal light pollution is desired. 

6. Leave the EyepieceFront untouched to allow the adhesive to set.

7. Solder the Teensy4.0 onto the custom PCB, so that the edges of the PCB line up with the edges of the Teensy (on the opposite side as the Teensy). The side of the PCB with the fpc connector should be facing toward the Teensy, while the side of the Teensy with the white reset button should be facing away from the PCB.
   
       * Note: when soldering the PCB to the Teensy, make sure there is enough space between them to open and close the fpc connector flap.

8. Using tweezers and/or careful handling, gently open the connecting flap on the fpc connector and slide the EyepieceFront display's ribbon cable into the slot. Close the flap to hold the cable in place. 
   
   * Note: When a cable is properly inserted, the white horizontal line of the ribbon cable will be flush or nearly flush with the edge of the closed flap.

9. Holding the Teeny/PCB firmly in place with the Eyepiece Front, slide and shift the EyepieceBack so that the Teensy's USB port is accesible through the EyepieceBack's port, the Teensy is tighly positioned in the rectangular space, and the screw holes line up across the EyepieceBack and EyepieceFront.

10. With the combined eyepiece set upside down (so the central mounting hole is facing up), slide two 4-40 nuts into each of the mounting hole slots on the sides and one in into the centeral mounting hole. Screw in 4-40 screws through the 2 side holes to hold the eyepiece together. Add a temporary 4-40 screw into the central mounting holw to ensure the central nut is properly positioned. 

11. Add a dab of instant-bond adhesive to the edge of all 3 nuts, inside the slot but not near the threads of the nuts, to permanently fix the nuts in place. Remove the temporary screw in the central mounting hole.

12. To further reduce light pollution from the display, paint the outside of the EyepieceFront with matte black acrylic paint.

The monocular display is assembled! Now you can and proceed to the software installation steps below.

### Software Installation

1. Installing display software on the Teensy 4.0 microcontroller
   
   * Download the latest [Arduino IDE](https://www.arduino.cc/en/software) on your PC/laptop
   
   * Download [Teensyduino](https://www.pjrc.com/teensy/td_download.html)
   
   * Open up the Arduino IDE, select Tools>Library Manager, and install the following libraries:
     
     ```
     Adafruit SPIflash
     Adafruit BusIO
     Adafruit GFX Library
     Adafruit TFT
     Adafruit ST7735 and ST7789 Library
     ```
   
   * Plug in the Teensy 4.0 to your PC/laptop
   
   * In the Arduino IDE, select Tools>board>Teensyduino>Teensy 4.0
   
   * Select Tools>port>[the port your teensy is plugged into] (if you don't know which port this is, unplug the teensy and check the available ports again to see which disappeared
   
   * Copy the [GC9307_teensy_GFX](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display) folder to your desktop, and open the .ino file with the Arduino IDE
   
   * Click the checkmark button ("verify") in the top-left of the IDE
   
   * The Teensyduino program window will open and prompt you to click the reset button on the Teensy to put it in programming mode and upload the code
   
   * If the monocular display is fully assembled, check the display to see that the code was successfully uploaded (it should be running a demo mode)

2. Controlling the display from MATLAB
   
   * Install [Matlab](https://www.mathworks.com/products/matlab.html) (display controller does not work with "Matlab Online")
   * Copy the [Matlab code](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display/matlab) folder to your desktop and open the monoDisplay_example.m file in Matlab
   * In Matlab, add the entire folder of files into Matlab's paths (Home>Set Path>Add with Subfolders>[select your downloaded Matlab folder]>Save>Close)
   * At the top of the monoDisplay_example code, change`vs.port` to the port your display is connected
   * Change `vs.directory` to your desired save folder
   * Run the script and watch the display to verify code and communication is working properly

3. Controlling the display from Python
   
   * Download the latest [Python release](https://www.python.org/downloads/)
   * Open your preferred Python IDE (e.g. IDLE (installs with Python), [Visual Studio](https://visualstudio.microsoft.com/downloads/), [PyCharm](https://www.jetbrains.com/pycharm/), [Spyder](https://www.spyder-ide.org/))
   * Copy the [Python code](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display/python) (not fully tested) to your desktop and open the monoDisplay_example.py file in your Python IDE
   * At the top of the monoDisplay_example code, change `ser = serial.Serial('/dev/cu.usbmodem14201',9600)`
   * Further down, change `cs = CS('directional_test_stimulus1','/Users/', 3, 0...` to your desired save directory
   * Run the script and watch the display to verify code and communication is working properly

# Published Data

Multiple datasets have been collected for validating and testing different aspects of the MouseGoggles system for neuroscience applications, including 2-photon imaging for visual stimulation, hippocampal electrophysiology for place cell activity during virtual navigation, and video recordings of mouse behaviors during looming stimulus presentation. Check out our [preprint on Research Square](https://doi.org/10.21203/rs.3.rs-3301474/v1) for explanation and visualization of these datasets. Data, metadata, and code to process and analyze these datasets are included in the [Published Data](https://github.com/sn-lab/MouseGoggles/tree/main/Published%20Data) folder of this repository; large raw data files unsuitable for github are hosted on [Figshare](https://figshare.com/articles/dataset/Raw_image_files/24039021). 
To reproduce the published results from each of these datasets, follow the instructions in the [Description of Contents](https://github.com/sn-lab/MouseGoggles/blob/main/Published%20Data/Description%20of%20Contents.md) file, noting the software dependencies listed here:

```
* Matlab 2022b
* Python 2.8.8
* suite2p (suite2p.org)
* https://github.com/misaacson01/NoRMCorre
* https://github.com/lolaBerkowitz/SNLab_ephys
* https://github.com/nelpy/nelpy
* https://github.com/ryanharvey1/neuro_py
* https://github.com/ryanharvey1/ripple_heterogeneity
```

# Future Development

* An easier to assemble headset, with adjustable inter-eye distance is in the final stages of testing!
* A new liquid reward delivery system and optical lick sensor (ephys compatible)
* A simpler spherical treadmill?
