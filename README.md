# About mouseVRheadset
A dual-SPI-display mouse-sized VR headset, powered by Raspberry Pi and the Godot game engine.

![(left) A Raspberry Pi 4 uniquely controlling 2 circular displays. (right) Render of a head-fixed mouse on a treadmill with a VR headset](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/mouseVRheadsetIntro.png)

The mouseVRheadset is a VR system for mouse neuroscience and behavior research. By positioning the headset to the eyes of a head-fixed mouse running on a treadmill, virtual scenes can be displayed to the mouse in both closed-loop (treadmill motion controls the visual scene) and open-loop (visual scenes unaffected by movement) modes. The headset is powered by a Raspberry Pi 4, Godot video game engine, and a custom display driver for controlling each eye's display. A 3D printed case holds the Raspberry Pi and display eyepieces -- each eyepiece containing a circular display and Fresnel lens to cover a wide field-of-view (~70 deg solid angle) of the mouse eye and put the visual scene at a focal length of [approximately] infinity.

- This system is a work in progress. Find a bug, have a suggestion, or want to make a feature request? Submit an [issue](https://github.com/sn-lab/mouseVRheadset/issues) or start a [discussion](https://github.com/sn-lab/mouseVRheadset/discussions).

### The Raspberry Pi and Godot game engine

![Godot game engine running on a Raspberry Pi 4](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/RaspberryPiGodot.png)

The heart of the mouseVRheadset is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. Since the displays are relatively low resolution (240x210), an inexpensive single-board computer like a Raspberry Pi 4 is all that's needed to effectively render visual scenes at high (>60 fps) framerates. The multiplatform game engine Godot makes it easy to create virtual scenes and develop experimental protocols. Examples included in this repo are experiments for visual cliff avoidance, reactions to looming stimuli of various size/velocity ratios, and the syndirectional rotational optomotor response to gratings of various spatial wavelengths. The views rendered for each display are controlled by separate in-game cameras which can be tied together to match the inter-eye distance and angle of a typical mouse. Custom display shaders warp the view from each camera to match the spherical distortion of the Fresnel lenses, intended to create a realistic and immersive experience for the mouse.

### The display driver

![dual-SPI-display driver streams different frame subsets to two displays](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/DisplaySubsets2.png)

Based on a ["blazing fast" display driver](https://github.com/juj/fbcp-ili9341) for SPI-based displays, the driver included in this repository works by copying the HDMI framebuffer and streaming the image data to the connected displays connected on the Raspberry Pi's SPI port. This means that the headset displays are not limited to displaying what is rendered by Godot; in fact, whatever is displayed on the central 240x420 (WxH) pixel region of the screen is going to be streamed to the displays. This means if you want to create images or video with some other program, you just have to position it in the center of the display for it to be sent to the displays -- the top 240x210 sent to display 0 (on SPI0 chip-select 0) and the bottom 240x210 to display 1 (on SPI0 chip-select 1).

### The headset assembly

![Render of a fully assembled VR headset positioned for a head-fixed mouse](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/VRHeadsetRender.png)

To create an immersive, wide field-of-view (FOV) VR headset from the dual-display Raspberry Pi, a 3D-printed headset case angles the displays inwards and sets them behind Fresnel lenses. These lenses serve two functions: to allow the displays to be positioned very close (<15 mm) to the mouse's eyes while still maintaining a comfortable infinity focal distance, and to spherically distort the displays to cover a wide FOV around each eye. Viewing angles from 0-70 degrees (0-52.5 degrees on the chipped side of the circular display) are linearly mapped onto the 240x210 circular display, resulting in an angular resolution of ~0.58 deg/pixel. With the 2 displays angled 45 degrees inward from straight ahead, the binocular headset covers a wide FOV: 140 degrees vertical and 230 degrees horizontal, with ~15 degrees of binocular overlap. Even greater horizontal FOVs are possible with greater display angles.

### The spherical treadmill

![Render of a spherical treadmill system with a head mount, air-suspended Styrofoam ball, motion sensors, and microcontroller](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/SphericalTreadmillRender.png)

Our VR headset was developed and tested using a spherical treadmill setup as described [here](https://pubmed.ncbi.nlm.nih.gov/19829374/) for closed-loop VR experiments. This treadmill simulates 2D navigation to a head-fixed mouse, allowing ground translation and yaw rotation. The treadmill motion is measured using optical sensors pointed at the treadmill along axes that are orthogonal to each other, acquired by a microcontroller (in our case, an Arduino Due). The microcontroller then converts these two sources of horizontal and vertical optic flow into treadmill spherical rotations: yaw, pitch, and roll. These rotation values are then sent to the Raspberry Pi over USB through computer mouse emulation: yaw rotations mapped as mouse x movement, pitch as mouse y movement, and roll as mouse scroll wheel movement. The Godot game engine converts these detected mouse movement events into the appropriate camera movements in the virtual scene. This setup allows the human user to test the game environments and experiments using a standard computer mouse or touchpad, and to use this VR system with any type of treadmill controll system that can be translated through a mouse emulator. See [here](https://github.com/sn-lab/mouseVRheadset/tree/main/Hardware/mouseVRheadset_controller_V4) for our Arduino Due code for measuring ball motion and mouse emulation.

### The monocular display

![Monocular display for basic visual stimuli (e.g. drifting gratings)](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/MonocularDisplay.png)

In addition to the VR headset system, a monocular display can be built using a single display, lens, and microcontroller. Where the headset is ideal for complex virtual reality experiments and behavioral research, the monocular display is ideal for simple visual stimulation for basic visual neuroscience applications. The fast microcontroller [Teensy4.0](https://www.pjrc.com/store/teensy40.html) and [Adafruit graphics library](https://learn.adafruit.com/adafruit-gfx-graphics-library/overview) is used to display simple shapes and moving patterns such as flickers, edges, and drifting gratings.


# Headset Build Instructions
To build a mouse VR headset, follow this general outline:
1. Purhcase the parts
2. Order and assemble the custom PCB
3. 3D print the case
4. Assemble the components
5. Install software on the Raspberry Pi

### Parts
For a complete parts list for both the VR headset and monocular display, see [PartsList.xls](https://github.com/sn-lab/mouseVRheadset/blob/main/Hardware/Parts%20Lists.xlsx).

### custom PCB
To order a custom PCB, use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html).
Upload the zipped Gerber files for the PCB you want to print ([TeensyGC9307](https://github.com/sn-lab/mouseVRheadset/tree/main/Hardware/PCBs) for the Monocular display or [RaspbyGC9307](https://github.com/sn-lab/mouseVRheadset/tree/main/Hardware/PCBs) for the binocular headset). Choose your desired quantity to order and hit order.

### 3D-printed Case
To 3D print the eyepiece or headset case, download the [.stl files](https://github.com/sn-lab/mouseVRheadset/tree/main/Hardware/3D%20Prints) and print them using a high-resolution 3D printer (we used the [Photon Mono X](https://www.anycubic.com/collections/anycubic-photon-3d-printers/products/photon-mono-x-resin-printer)) or order it through an 3D printing service such as [CraftCloud](https://craftcloud3d.com/upload).

### Headset Assembly
Tutorial pictures coming soon!

### Software Installation
To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the SD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the Godot game engine and custom display driver.

1. Installing the Raspberry Pi Operating System
	* Insert the micro SD card into your PC
	* Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
	* Choose OS: "Raspberry Pi OS (32-bit)"
	* Choose Storage: -select your SD card-
	* Write
	* Insert the SD card into your Raspberry Pi and power it on
	
2. Install the Godot game engine
	* Open up the Raspberry Pi command terminal and enter each line, one at a time:
	```
	sudo apt update
	sudo apt install flatpack
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.godotengine.Godot
	```

3. Install the display driver
	* Open up the Raspberry Pi command terminal and enter each line, one at a time:
	```
	sudo apt-get install cmake
	cd ~
	git clone https://github.com/sn-lab/mouseVRheadset
	cd mouseVRheadset/fbcp-ili9341
	mkdir build
	cd build
	cmake ..
	make -j
	sudo ./fbcp- ili9341
	```
	
### Operating the system
1. To start the display driver, if it is not already running (i.e. if the displays are not updating)
	* Open up the Raspberry Pi command terminal and enter each line, one at a time:
	```
	cd mouseVRheadset/fbcp-ili9341/build
	sudo ./fbcp- ili9341
	```
	
2. To start the game engine and run experiments
	* Open up the Raspberry Pi command terminal and enter the following line:
	```
	flatpak run org.godotengine.Godot
	```
	* Import the Godot game project located in mouseVRheadset/MouseVR Godot Project V0.X/project.godot
	* When the game editor opens, reduce the window to a partial screen (running it in full screen may cause hang-ups)
	* In Project>Project Settings>Display>Window, change `Width` to 240 and `Height` to 420
	* In Project>Project Settings>Debug>Settings, change `Force FPS` to 80
	* Click the small "play" button on the upper-right side of the menu bar
	* Select an experiment (i.e. "scene")
	* A game window will appear with views rendered for each of the two eyepiece displays -- these are rotated to match the rotations of each display and are positioned in the center of the screen -- do not move this window
	* Upon the completion of each repetition of an experiment, logs of the mouse movement and experiment details will be saved in "MouseVR Godot Project/logs/" in csv format (one line per frame)
	* Click the `esc` button to exit an experiment early (logs of completed experiment repetitions will still have been saved)
	
3. To customize Godot experiments on the Raspberry Pi
	* Use the Godot editor, following [official documentation](https://docs.godotengine.org/en/stable/) or numerous online tutorials
	* 3D environments can be edited in .tscn files in the "3D" tab
	* Experiment code can be edited in .gd files in the "Script" tab
	* In .gd files, pay special attention to "movement sensitivities" variables -- these will need to be calibrated to your specific behavior measurement system
	
4. To customize Godot experiments on a Windows or Mac PC (to be later transferred to the Raspberry Pi headset)
	* Install the latest [Godot editor](https://godotengine.org/) on your PC
	* Run Godot and import the Godot project
	* For rendered views that are easier to see and work with, in each .tscn experiment file, delete the `HeadKinBody` node (under the parent `spatial` node) and drag the "HeadKinBody.tscn" resource (from the FileSystem panel) to the `spatial` node. (the screen layout in "HeadKinBody" is easy to work with, while the screen layout in "HeadKinBody_headset" is needed for the Raspberry Pi headset)
	* for the "HeadKinBody" layout, change with window dimensions to 420x240 (WxH) (in Project>Project Settings>Display>Window)
	* for the "HeadKinBody_headset" layout, change with window dimensions to 240x242 (WxH)
	* In the .gd files for each experiment, optimize the movement sensitivities for your desired input (e.g. computer mouse, trackpad)
	* Try running an experiment (hit "play" button), do you see a dependecy error for the shaders? If so, resolve them by selecting the .gdshader files for both "eyes" (e.g. for the lefteye, select lefteye.gdshader file for PCs, lefteye.shader for Raspberry Pi)
	* Follow [official documentation](https://docs.godotengine.org/en/stable/) or numerous online tutorials to edit the experiments
	* Save any changes and rename your project
	* To transfer the project to the headset, copy the Project folder and transfer to the Raspberry Pi
	* On the Raspberry Pi, run Godot (`flatpak run org.godotengine.Godot`) and import/edit the new project
	* Reduce the window size from full screen
	* In Project>Project Settings>Display>Window, change `Width` to 240 and `Height` to 420
	* In each experiment .tscn file, replace the `HeadKinBody` node with the "HeadKinBody_headset" file
	* Resolve shader dependency errors by selecting ".shader" files (.gdshader is used on PCs)
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

### Monocular Headset Assmebly
Tutorial pictures coming soon!

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
	* Copy the [GC9307_teensy_GFX](https://github.com/sn-lab/mouseVRheadset/tree/main/Monocular%20Display) folder to your desktop, and open the .ino file with the Arduino IDE
	* Click the checkmark button ("verify") in the top-left of the IDE
	* The Teensyduino program window will open and prompt you to click the reset button on the Teensy to put it in programming mode and upload the code
	* If the monocular display is fully assembled, check the display to see that the code was successfully uploaded (it should be running a demo mode)
	
2. Controlling the display from MATLAB
	* Install [Matlab](https://www.mathworks.com/products/matlab.html) (display controller does not work with "Matlab Online")
	* Copy the [Matlab code](https://github.com/sn-lab/mouseVRheadset/tree/main/Monocular%20Display/matlab) folder to your desktop and open the monoDisplay_example.m file in Matlab
	* In Matlab, add the entire folder of files into Matlab's paths (Home>Set Path>Add with Subfolders>[select your downloaded Matlab folder]>Save>Close)
	* At the top of the monoDisplay_example code, change`vs.port` to the port your display is connected
	* Change `vs.directory` to your desired save folder
	* Run the script and watch the display to verify code and communication is working properly
	
3. Controlling the display from Python
	* Download the latest [Python release](https://www.python.org/downloads/)
	* Open your preferred Python IDE (e.g. IDLE (installs with Python), [Visual Studio](https://visualstudio.microsoft.com/downloads/), [PyCharm](https://www.jetbrains.com/pycharm/), [Spyder](https://www.spyder-ide.org/))
	* Copy the [Python code](https://github.com/sn-lab/mouseVRheadset/tree/main/Monocular%20Display/python) (not fully tested) to your desktop and open the monoDisplay_example.py file in your Python IDE
	* At the top of the monoDisplay_example code, change `ser = serial.Serial('/dev/cu.usbmodem14201',9600)`
	* Further down, change `cs = CS('directional_test_stimulus1','/Users/', 3, 0...` to your desired save directory
	* Run the script and watch the display to verify code and communication is working properly

# Future Development
Details coming soon!
