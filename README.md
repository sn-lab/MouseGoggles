# mouseVRheadset
A dual-SPI display mouse-sized VR headset, powered by Raspberry Pi and the Godot game engine

![Raspberry Pi 4 with 2 circular displays](https://github.com/sn-lab/mouseVRheadset/blob/main/Images/RaspberryPi2Displays.png)

- This system is a work in progress. Find a bug, have a suggestion, or want to make a feature request? Click on the [issues](https://github.com/sn-lab/mouseVRheadset/issues) tab and submit a new issue. For more general questions/inquiries, email mdi22@cornell.edu with "mouseVRheadset" included in the subject line.

## About the System
The mouseVRheadset is a VR system for mouse neuroscience and behavior research. By positioning the headset to the eyes of a head-fixed mouse running on a treadmill, virtual scenes can be displayed to the mouse in both closed-loop (treadmill motion controls the visual scene) and open-loop (visual scenes unaffected by movement) modes. The headset is powered by a Raspberry Pi 4, Godot video game engine, and a custom display driver for controlling each eye's display. A 3D printed case holds the Raspberry Pi and display eyepieces -- each eyepiece containing a circular display and Fresnel lens to 

### The Raspberry Pi and Godot game engine
The heart of the mouseVRheadset is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. 

### The display driver
Based on a ["blazing fast" display driver](https://github.com/juj/fbcp-ili9341) for SPI-based displays, the driver included in this repository works by copying the HDMI framebuffer and streaming the image data to the connected displays connected on the Raspberry Pi's SPI0 port. This means that the headset displays are not limited to displaying what is rendered by Godot; in fact, whatever is displayed on the central 240x420 (WxH) pixel region of the screen is going to be streamed to the displays. This means if you want to create images or video with some other program, you just have to position it in the center of the display for it to be streamed. The top 240x210 will be sent to display 0 (on SPI0 chip-select 0), and the bottom 240x210 to display 1 (on SPI0 chip-select 1).

## Headset Build Instructions
To build your own mouseVRheadset (or monocular display), follow these steps:
1. Purhcase the parts
2. Order and assemble the custom PCB
3. 3D print the case
4. Assemble the components
5. Install software on the Raspberry Pi

### Parts
For a complete parts list for both the VR headser and monocular display, see PartsList.xls.
3D printed parts can either be printed yourself or ordered through an online 3D print service, such as [Craftcloud](https://craftcloud3d.com/).

### custom PCB
To order a custom PCB, use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html).
Add the zipped Gerber files for the PCB you want to print (for the Monocular display or the binocular headset). Choose your desired quantity to order and hit order.

### 3D-printed Case
To 3D print the eyepiece or headset case, download the .stl files and print them using a high-resolution 3D printer (we used the [Photon Mono X](https://www.anycubic.com/collections/anycubic-photon-3d-printers/products/photon-mono-x-resin-printer)) or order it through an 3D printing service such as [CraftCloud](https://craftcloud3d.com/upload).

### Software Installation
To install all necessary software, you'll first need a PC to install the Raspberry Pi OS to the SD card that will be installed in the Raspberry Pi. Next, you'll need to start up the Raspberry Pi and install the Godot game engine and custom display driver on it.

1. Installing the Raspberry Pi Operating System
	* Insert the micro SD card into your PC
	* Download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
	* Choose OS: "Raspberry Pi OS (32-bit)"
	* Choose Storage: -select your SD card-
	* Write
	* Insert the SD card into your Raspberry Pi, and power it on
	
2. Install the Godot game engine
	* Coming soon...

3. Install the display driver
	* Coming soon...


## Monocular Display Build Instructions
Coming soon...
