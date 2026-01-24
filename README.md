**MouseGoggles**: A dual-SPI-display mouse-sized VR headset for mouse neuroscience and behavior research, powered by Raspberry Pi and the Godot game engine. Check out the paper at Nature Methods! https://www.nature.com/articles/s41592-024-02540-y

![(left) A Raspberry Pi 4 uniquely controlling 2 circular displays. (right) Render of a head-fixed mouse on a treadmill with a VR headset](https://github.com/sn-lab/MouseGoggles/blob/main/Images/mouseVRheadsetIntro.png)

- Find a bug, have a suggestion, or want to make a feature request? Submit an [issue](https://github.com/sn-lab/MouseGoggles/issues) or start a [discussion](https://github.com/sn-lab/MouseGoggles/discussions)!

**Work in progess**

* Updating and improving [MouseGoggles EyeTrack 2.0](https://github.com/sn-lab/MouseGoggles/tree/main/Versions/EyeTrack/2.0) software!

**Previous Updates**

* (Jan 2026) Added intial files for [MouseGoggles EyeTrack 2.0](https://github.com/sn-lab/MouseGoggles/tree/main/Versions/EyeTrack/2.0)! The hardware design is complete, now built around a single Raspberry Pi 5, and features improved eye-tracking quality and an overall simpler assembly process. Some outstanding software issues are still being resolved for this version but will be updated shortly!
  
* (May 2025) Big software updates to EyeTrack 1.1, including the first Godot project (2.1) which enables controlling and viewing the eye-tracking cameras from within the game engine! TCP/UDP communication between the Pis enable TTL outputs and eye-tracking videos to be controlled directly from VR experiment scripts.

* (Mar 2024) Added the [MouseGoggles EyeTrack](https://github.com/sn-lab/MouseGoggles/tree/main/Versions/EyeTrack/1.0) headset, for binocular eye/pupil tracking cameras integrated into the headset

# Building a MouseGoggles System

All versions of MouseGoggles were designed using as many readily available, off-the-shelf parts as possible, with only a minimal number of custom parts required to make assembly as simple as possible. To build a MouseGoggles system, navigate to the folder of the version you'd like to build in the [Versions](https://github.com/sn-lab/MouseGoggles/tree/main/Versions) folder and follow the included README for a comprehensive parts list, assembly guide, and software installation instructions. Since some parts included in earlier versions of the system have since been discontinued by the manufacturers, [Eyetrack version 2.0](https://github.com/sn-lab/MouseGoggles/tree/main/Versions/EyeTrack/2.0) is what we recommend building for all use-cases. Version 2.0 is built on an entirely new display platform (Raspberry Pi 5; mipi-dbi-spi) that future versions will be developed from. 


# About MouseGoggles

### The Raspberry Pi and Godot game engine

![Godot game engine running on a Raspberry Pi 4](https://github.com/sn-lab/MouseGoggles/blob/main/Images/RaspberryPiGodot.png)

The heart of the MouseGoggles system is a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) running the [Godot](https://godotengine.org/) video game engine. Since the displays are relatively low resolution (240x240), an inexpensive single-board computer like a Raspberry Pi 4 is all that's needed to effectively render visual scenes at high (>=60 fps) framerates. The multiplatform game engine Godot makes it easy to create virtual scenes and develop experimental protocols. Examples included in this repo are experiments for visual cliff avoidance, reactions to looming stimuli of various size/velocity ratios, and the syndirectional rotational optomotor response to gratings of various spatial wavelengths. The views rendered for each display are controlled by separate in-game cameras which can be tied together to match the inter-eye distance and angle of a typical mouse. Custom display shaders warp the view from each camera to match the spherical distortion of the Fresnel lenses, intended to create a realistic and immersive experience for the mouse.

### The display driver

![dual-SPI-display driver streams different frame subsets to two displays](https://github.com/sn-lab/MouseGoggles/blob/main/Images/DisplaySubsets2.png)

Based on a ["blazing fast" display driver](https://github.com/juj/fbcp-ili9341) for SPI-based displays, the driver included in this repository works by copying the HDMI framebuffer and streaming the image data to the connected displays connected on the Raspberry Pi's SPI port. This means that the headset displays are not limited to displaying what is rendered by Godot; in fact, whatever is displayed on the central 240x420 (WxH) pixel region of the screen is going to be streamed to the displays. If you want to create images or video with some other program, you just have to position it in the center of the display for it to be sent to the displays -- the top 240x210 sent to display 0 (on SPI0 chip-select 0) and the bottom 240x210 to display 1 (on SPI0 chip-select 1).

### The MouseGoggles 1.0 headset

![Render of a fully assembled MouseGoggles headset positioned for a head-fixed mouse](https://github.com/sn-lab/MouseGoggles/blob/main/Images/VRHeadsetRender.png)

To create an immersive, wide field-of-view (FOV) VR headset from the dual-display Raspberry Pi, a 3D-printed headset case angles the displays inwards and sets them behind Fresnel lenses. These lenses serve two functions: to allow the displays to be positioned very close (<15 mm) to the mouse's eyes while still maintaining a comfortable infinity focal distance, and to spherically distort the displays to cover a wide FOV around each eye. Viewing angles from 0-70 degrees (0-52.5 degrees on the chipped side of the circular display) are linearly mapped onto the 240x210 circular display, resulting in an angular resolution of ~0.64 deg/pixel. With the 2 displays angled 45 degrees inward from straight ahead, the binocular headset covers a wide FOV: 140 degrees vertical and 230 degrees horizontal, with ~25 degrees of binocular overlap. Even greater horizontal FOVs are possible with greater display angles. This headset is the first official version of MouseGoggles (1.0), but newer versions have been developed which add new functionality, such as a smaller form-factor headset detached from the Raspberry Pi (1.1-1.2, 1.5), adjustable inter-eye distance (1.2-1.5), and an easier to assemble design (1.5). For more details on each MouseGoggles version, see the [Versions](https://github.com/sn-lab/MouseGoggles/tree/main/Versions) folder.

### MouseGoggles Mono 1.0

![Monocular display for basic visual stimuli (e.g. drifting gratings)](https://github.com/sn-lab/MouseGoggles/blob/main/Images/MonocularDisplay.png)

In addition to the binocular MouseGoggles system, a monocular eyepiece version can be built using a single display, lens, and microcontroller. Where the headset is ideal for complex virtual reality experiments and behavioral research, the monocular display is ideal for simple visual stimulation for basic visual neuroscience applications. The fast microcontroller [Teensy4.0](https://www.pjrc.com/store/teensy40.html) and [Adafruit graphics library](https://learn.adafruit.com/adafruit-gfx-graphics-library/overview) is used to display simple shapes and moving patterns such as drifting gratings and flickers. For more details, see [Versions/Mono/1.0]().

### Treadmills

![Render of a spherical treadmill system with a head mount, air-suspended Styrofoam ball, motion sensors, and microcontroller](https://github.com/sn-lab/MouseGoggles/blob/main/Images/SphericalTreadmillRender.png)

The MouseGoggles VR headset was developed and tested using a two different treadmills for simulated walking: the spherical treadmill setup as described [here](https://pubmed.ncbi.nlm.nih.gov/19829374/) and the linear treadmill described [here](https://github.com/janelia-experimental-technology/Rodent-Belt-Treadmill/tree/main). These treadmills use sensors to detect treadmill motion and a microcontroller to transmit this movement information to external devices. By modifying the microcontroller code, we can adapt these systems to send treadmill motion to the Raspberry Pi over USB through computer mouse emulation. Forward movement (i.e. "pitch" of the spherical treadmill, or any movement of the linear treadmill) is mapped as mouse y movement, turning (i.e. "yaw" of the spherical treadmill) is mapped as x movement, and sideways motion (i.e. "roll" of the spherical treadmill) is mapped as mouse scroll wheel movement. The Godot game engine converts these detected mouse movement events into the corresponding camera movements in the virtual scene. This setup allows the human user to test the game environments and experiments using a standard computer mouse or touchpad, and to use this VR system with any type of treadmill control system that can be translated through the standard USB mouse communication protocol. To set up one of these treadmill systems with MouseGoggles (including adding a headbar and mount to head-fix a mouse above the treadmill), see the [README](https://github.com/sn-lab/MouseGoggles/blob/main/Other%20Hardware/Installation%20README.md) in the [Other Hardware](https://github.com/sn-lab/MouseGoggles/tree/main/Other%20Hardware) folder.

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
