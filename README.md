# mouseVRheadset
A dual-SPI-display mouse-sized VR headset, powered by Raspberry Pi and the Godot game engine.

![A Raspberry Pi 4 uniquely controlling 2 circular displays](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/RaspberryPi2Displays.png)

The mouseVRheadset is a VR system for mouse neuroscience and behavior research. By positioning the headset to the eyes of a head-fixed mouse running on a treadmill, virtual scenes can be displayed to the mouse in both closed-loop (treadmill motion controls the visual scene) and open-loop (visual scenes unaffected by movement) modes. The headset is powered by a Raspberry Pi 4, Godot video game engine, and a custom display driver for controlling each eye's display. A 3D printed case holds the Raspberry Pi and display eyepieces -- each eyepiece containing a circular display and Fresnel lens to cover a wide field-of-view (~70 deg solid angle) of the mouse eye and put the visual scene at a focal length of [approximately] infnity.

- This system is a work in progress. Find a bug, have a suggestion, or want to make a feature request? Click [here](https://github.com/sn-lab/mouseVRheadset/issues) to submit an issue or [here](https://github.com/sn-lab/mouseVRheadset/discussions) to start a discussion. 

### The Raspberry Pi and Godot game engine
The heart of the mouseVRheadset is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. Since the displays are relatively low resolution (240x210), an inexpensive single-board computer like a Raspberry Pi 4 is all that's needed to effectively render visual scenes at high (>60 fps) framerates. The multiplatform game engine Godot makes it easy to create virtual scenes and develop experimental protocols. Examples included in this repo are experiments for visual cliff avoidance, reactions to looming stimuli of various size/velocity ratios, and the syndirectional rotational optomotor response to gratings of various spatial wavelengths. The views rendered for each display are controlled by sepearate in-game cameras which can be tied together to match the inter-eye distance and angle of a typical mouse. Custom display shaders warp the view from each camera to match the spherical distortion of the Fresnel lenses, intended to create a realistic and immersive experience for the mouse.

### The display driver
Based on a ["blazing fast" display driver](https://github.com/juj/fbcp-ili9341) for SPI-based displays, the driver included in this repository works by copying the HDMI framebuffer and streaming the image data to the connected displays connected on the Raspberry Pi's SPI port. This means that the headset displays are not limited to displaying what is rendered by Godot; in fact, whatever is displayed on the central 240x420 (WxH) pixel region of the screen is going to be streamed to the displays. This means if you want to create images or video with some other program, you just have to position it in the center of the display for it to be sent to the displays -- the top 240x210 sent to display 0 (on SPI0 chip-select 0) and the bottom 240x210 to display 1 (on SPI0 chip-select 1).

### Spherical Treadmill
This system was developed and tested using a spherical treadmill setup as described [here](https://pubmed.ncbi.nlm.nih.gov/19829374/) for closed-loop VR experiments. This treadmill simulates 2D navigation to a head-fixed mouse, allowing ground translation and yaw rotation. The treadmill motion is measured using optical sensors pointed at the treadmill along axes that are orthogonal to each other, acquired by a microcontroller (in our case, an Arduino Due). The microcontroller then converts these two sources of horizontal optic flow into treadmill spherical rotations: yaw, pitch, and roll. These rotation values are then sent to the Raspberry Pi over USB through computer mouse emulation: yaw rotations mapped as mouse x movement, pitch as mouse y movement, and roll as mouse scroll wheel movement. The Godot game engine converts these detected mouse movement events into the appropriate camera movements in the virtual scene. This setup allows the human user to test the game environments and experiments using a standard computer mouse or touchpad, and to use this VR system with any type of treadmill controll system that can be translated through a mouse emulator. See [here](https://github.com/sn-lab/mouseVRheadset/tree/main/Hardware/mouseVRheadset_controller_V4) for our Arduino Due code for measuring ball motion and mouse emulation.

### Monocular display
In addition to the VR headset, a monocular display can be built using a single display, lens, and microcontroller. Where the headset is ideal for complex virtual reality experiments and behavioral research, the simple monocular display is ideal for simple visual stimulation for basic visual neuroscience applications. The fast microcontroller Teensy4.0 and Adafruit graphics library is used to display simple shapes and moving pattern such as flickers, edges, and drifting grating stimuli.


# Headset Build Instructions
To build your own mouse VR headset, follow this general outline:
1. Purhcase the parts
2. Order and assemble the custom PCB
3. 3D print the case
4. Assemble the components
5. Install software on the Raspberry Pi

### Parts
For a complete parts list for both the VR headser and monocular display, see [PartsList.xls](https://github.com/sn-lab/mouseVRheadset/blob/main/Hardware/Parts%20Lists.xlsx).

### custom PCB
To order a custom PCB, use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html).
Upload [these] zipped Gerber files for the PCB you want to print (for the Monocular display or the binocular headset). Choose your desired quantity to order and hit order.

### 3D-printed Case
To 3D print the eyepiece or headset case, download the .stl files and print them using a high-resolution 3D printer (we used the [Photon Mono X](https://www.anycubic.com/collections/anycubic-photon-3d-printers/products/photon-mono-x-resin-printer)) or order it through an 3D printing service such as [CraftCloud](https://craftcloud3d.com/upload).

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
	
### Running the system
To start the display driver (if it is not already running, i.e. if the displays are not updating)
	* Open up the Raspberry Pi command terminal and enter each line, one at a time:
	```
	cd mouseVRheadset/fbcp-ili9341/build
	sudo ./fbcp- ili9341
	```
	
To start the game engine and run experiments
	* Open up the Raspberry Pi command terminal and enter the following line:
	```
	flatpak run org.godotengine.Godot
	```
	
To stop the display driver (e.g. for re-installation or installing a new version)
	* Open up the Raspberry Pi command terminal and enter the following line:
	```
	sudo pkill fbcp
	```
	

# Monocular Display Build Instructions
Details coming soon!


# Future Development
Details coming soon!
