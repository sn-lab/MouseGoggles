# mouseVRheadset
A dual-SPI display mouse VR headset, powered by Raspberry Pi and the Godot game engine

### Feedback
This system is a work in progress. Find a bug, have a suggestion, or want to make a feature request? Click on the [issues](https://github.com/sn-lab/mouseVRheadset/issues) tab and submit a new issue. For more general questions/inquiries, email mdi22@cornell.edu with "mouseVRheadset" included in the subject line.

## About the System
The mouseVRheadset is a VR system for mouse neuroscience and behavior research. By positioning the headset to the eyes of a head-fixed mouse running on a treadmill, virtual scenes can be displayed to the mouse in both closed-loop (treadmill motion controls the visual scene) and open-loop (visual scenes unaffected by movement) modes. The headset is powered by a Raspberry Pi 4, Godot video game engine, and a custom display driver for controlling each eye's display. A 3D printed case holds the Raspberry Pi and display eyepieces -- each eyepiece containing a circular display and Fresnel lens to 

### The Raspberry Pi and Godot game engine
The heart of the mouseVRheadset is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. 

### The display driver
Importantly, the headset displays are not limited to displaying what is rendered by Godot. In fact, whatever is displayed on the central 240x420 (WxH) pixel region of the display is going to be streamed to the displays -- the top half 240x210 going to display 0, and the bottom 240x210 to display 1. This means if you want to create images or video with some other program, you just have to position it in the center of the display for it to be streamed.

## Build Instructions
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
TBD

### 3D-printed Case
TBD

### Software Installation
TBD

