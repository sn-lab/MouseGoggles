# Parts List

---

##### Off-the-shelf parts

The table below lists all off-the-shelf parts required to build MouseGoggles Mono 1.0, the first official monocular display version of MouseGoggles. Follow the links below to purchase the parts in the quantities listed. In addition to these listed parts, you will also need a desktop monitor (with HDMI input or an HDMI-DVI adapter), a USB keyboard and mouse, and a MicroSD card reader, at least for the initial setup.

| Part Name                                                  | Description                                    | Link                                                                                            | Est. Unit Cost | Quantity |
| ---------------------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------- |:--------------:|:--------:|
| Teensy 4.0                                                 | High -speed microcontroller                    | [PJRC](https://www.pjrc.com/store/teensy40.html)                                                | $24            | 1        |
| Micro USB/USB A cable                                      | USB cable to Teensy 4.0                        | [Adafruit](https://www.adafruit.com/product/2185)                                               | $5             | 1        |
| Pin headers                                                | Break-away pin headers (male, short)           | [Adafruit](https://www.adafruit.com/product/3009)                                               | $5             | 1        |
| TT108RGN10A 1.08 inch 240x210 display (see **note** below) | Circular display for VR headset                | [Alibaba](https://www.alibaba.com/product-detail/Small-IPS-Round-LCD-Module-1_62550674738.html) | $8             | 1        |
| FRP0510 - Ø1/2" Fresnel Lens, f = 10 mm                    | Fresnel lens for VR headset                    | [Thorlabs](https://www.thorlabs.com/thorproduct.cfm?partnumber=FRP0510)                         | $21            | 1        |
| 4-40 thread, 1" length socket head screws                  | Hex screws to assemble 3D printed parts        | [McMaster](https://www.mcmaster.com/90044A111/)                                                 | $9             | 1        |
| 4-40 thread, 3/16" wide narrow hex nuts                    | Hex nuts to assemble 3D printed parts          | [McMaster](https://www.mcmaster.com/90760A160/)                                                 | $5             | 1        |
| Silicone glue                                              | Adhesive for securing lens and display holders | [McMaster](https://www.mcmaster.com/7587A2/)                                                    | $9             | 1        |

**note**: The circular display model listed in the parts list (TT108RGN10A) is just one of a family of similar displays listed on Alibaba, many of which may be compatible with MouseGoggles. Since specific display models are occasionally discontinued or difficult to find, listed below are the circular display model numbers we are aware of and our most up-to-date estimates of their compatibility:

- TT108RGN10A - tested, working
- TT108RRN11A - tested, working
- TT109RAN11A - untested, NOT compatible
- TT109RAN12A - untested, likely NOT compatible
- TT108RRN13A - tested, working
- TST108102 - untested, likely compatible
- TST108103 - untested, likely compatible 

##### 3D prints

The table below lists all custom 3D-printable parts required for MouseGoggles Mono 1.0. Follow the links below for .stl files to print these parts on your own high-resolution 3D printer (recommended layer resolution <0.2 mm) or to send to a 3D printing service such as [CraftCloud](https://craftcloud3d.com/). 

Notes on print quality: UV-cured resin-based SLA printers (e.g. [Photon Mono X](https://www.anycubic.com/products/photon-mono-x-resin-printer)) can produce adequate and cost-effective parts for MouseGoggles, though resin-based prints can become brittle over time and are often semi-transparent. To reduce stray light from semi-transparent headset prints, parts can be painted with an opaque paint (e.g. [Black 3.0](https://www.culturehustleusa.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml)). Thermoplastic polymers such as PLA, PETG, or ABS can produce tougher, longer-laster, and more opaque parts, though should only be used for MouseGoggles from high-resolution 3D printers (e.g. [Ultimaker S3]([UltiMaker S3: Easy-to-use 3D printing starts here](https://ultimaker.com/3d-printers/s-series/ultimaker-s3/))). If you are printing the parts yourself, a [needle file]([McMaster-Carr](https://www.mcmaster.com/4261A37/)) can be helpful in cleaning up any imperfections in the part.

| Part Name                                 | Description                                   | Link                                                                                                                                      | Quantity | Approx. Dimensions (mm) |
| ----------------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------- |
| MouseGoggles 1.0mono MouseEyepieceFrontV3 | Enclosure for eyepiece (front half)           | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/3D%20Prints/MouseGoggles%201.0mono%20MouseEyepieceFrontV3.stl) | 1        | 36x36x28                |
| MouseGoggles 1.0mono MouseEyepieceBackV3  | Enclosure for eyepiece (back half)            | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/3D%20Prints/MouseGoggles%201.0mono%20MouseEyepieceBackV3.stl)  | 1        | 43x36x21                |
| MouseGoggles 1.0 DisplayHolderV1          | Holder for eyepiece display slot              | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/3D%20Prints/MouseGoggles%201.0%20DisplayHolderV1.stl)          | 1        | 31x12x1.5               |
| MouseGoggles 1.0 LensHolderV1             | Holder for eyepiece lens slot                 | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/3D%20Prints/MouseGoggles%201.0%20LensHolderV1.stl)             | 1        | 11x8x1.5                |
| MouseGoggles 1.0mono 0.25-20AdapterV1     | Adapter for 1/4"-20 mounting screw (optional) | [stl](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/3D%20Prints/MouseGoggles%201.0mono%200.25-20AdapterV1.stl)     | 1        | 18x17x15                |

##### Custom PCBs

The table below lists all custom PCBs (printed circuit boards) used by MouseGoggles Mono 1.0. To order a bare custom PCB, you can use a PCB printing service such as [JLCPCB](https://cart.jlcpcb.com/quote?orderType=1&stencilLayer=2&stencilWidth=100&stencilLength=100&stencilCounts=5) or [seeedstudio](https://www.seeedstudio.com/fusion_pcb.html). JLCPCB-prints have been verified for all MouseGoggles PCBs. To order a PCB, follow the links in the table to download the zipper gerber files. Upload the zipped folder to the PCB printing service, set any required PCB parameters (e.g. layers=2, FR-4 board material, 1.6 mm board thickness, 0.0348 mm copper thickness, and HASL with lead surface finish), and choose your desired quantity.

| Part Name                | Description                                 | Link                                                                                                                                                  | Quantity |
| ------------------------ | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| MouseGoggles MonoHat-1-0 | zipped Gerber files of Teensy PCB connector | [zip](https://github.com/sn-lab/MouseGoggles/blob/main/Versions/Mono%201.0/PCBs/MouseGoggles%20MonoHat-1-0/MouseGoggles%20MonoHat-1-0_2023-12-21.zip) | 1        |

# 

# Hardware Assembly Instructions

---

##### Assemble the custom PCB

1. Solder a surface-mount ribbon cable connector onto the top "MonoHat" PCB.
   
   * note: Soldering these parts may require microsoldering equipment. For more details and options on microsoldering, see [this discussion]([PCB assembly/microsoldering options · sn-lab/MouseGoggles · Discussion #7 · GitHub](https://github.com/sn-lab/MouseGoggles/discussions/7).

2. Insert the pin headers onto the top of the MonoHat PCB and solder the headers in place.

##### Assemble the MouseGoggles Mono eyepiece

1. Install the circular display by sliding it into the display slot of the "EyepieceFront" 3D print, with the glass side facing out, ensuring it is pushed all the way in and the ribbon cable is centered in the slot.
   
   - Note: if during assembly anything is difficult to slide into place, check for imperfections or warping of the printed part and sand them down with the needle file until parts fit freely.

2. Slide the "DisplayHolder" 3D print into the slot following the display, with the cutout making space for the ribbon cable, until it is flush with the eyepiece edges.

3. Install the Fresnel lens into the lens slot of the EyepieceFront, with the ridged side facing the display and the flat side facing out.
   
   - Note: very gently sliding your finger or fingernail along each flat face of the lens will tell you which side is smooth and which side is ridged.

4. Slide the "LensHolder" 3D print into the slot following the lens, with the angled side facing to the side and matching the slope of the eyepiece, until it is flush with the eyepiece edges.

5. Add a dab of silicone adhesive to the edges of the holders and wipe it flat with a cloth or finger. Add more silicone to close all gaps if minimal light pollution is desired.

6. Leave the EyepieceFront untouched to allow the adhesive to set.

7. Solder the Teensy4.0 onto the custom PCB, so that the edges of the PCB line up with the edges of the Teensy (on the opposite side as the Teensy). The side of the PCB with the fpc connector should be facing toward the Teensy, while the side of the Teensy with the white reset button should be facing away from the PCB.
   
   Note: when soldering the PCB to the Teensy, make sure there is enough space between them to open and close the connector flap.

8. Using tweezers and/or careful handling, gently open the connecting flap on the fpc connector and slide the EyepieceFront display's ribbon cable into the slot. Close the flap to hold the cable in place.
   
   - Note: When a cable is properly inserted, the white horizontal line of the ribbon cable will be flush or nearly flush with the edge of the closed flap.

9. Holding the Teeny/PCB firmly in place with the Eyepiece Front, slide and shift the "EyepieceBack" 3D print" so that the Teensy's USB port is accesible through the EyepieceBack's port, the Teensy is tighly positioned in the rectangular space, and the screw holes line up across the EyepieceBack and EyepieceFront.

10. With the combined eyepiece set upside down (so the central mounting hole is facing up), slide two 4-40 nuts into each of the mounting hole slots on the sides and one in into the centeral mounting hole. Screw in 4-40 screws through the 2 side holes to hold the eyepiece together. Add a temporary 4-40 screw into the central mounting holw to ensure the central nut is properly positioned.

11. To further reduce light pollution from the display, paint the outside of the EyepieceFront with matte black acrylic paint.

# Software Installation Instructions

---

Follow the steps below to installing the monocular display software on the Teensy 4.0 microcontroller.

- Download the latest [Arduino IDE](https://www.arduino.cc/en/software) on your PC/laptop.

- Open up the Arduino IDE, and click File > Preferences (on MacOS, click Arduino IDE > Settings). In "Additional boards manager URLs", copy this link:
  
  `https://www.pjrc.com/teensy/package_teensy_index.json`
* In the main Arduino window, open Boards Manager by clicking the left-side board icon. Search for "teensy", and click "Install".
- In the main Arduino window, select Tools>Library Manager, and install the following libraries:
  
  ```
  Adafruit SPIflash
  Adafruit BusIO
  Adafruit GFX Library
  Adafruit TFT
  Adafruit ST7735 and ST7789 Library
  ```

- Plug in the Teensy 4.0 to your PC/laptop.

- In `Tools>board`, select `Teensyduino>Teensy 4.0`.

- In `Tools>port`, select the serial port the microcontroller is connected to (if you're not sure, disconnect and reconnect the microcontroller to see which COM port changes).

- In the Arduino IDE, load the [GC9307_teensy_GFX.ino](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display) script.

- Click the checkmark button ("verify") in the top-left of the IDE.

- The Teensyduino program window will automatically open. If Teensyduino prompts you to reset or put the microcontroller in programming mode, click the reset button on the Teensy to put it in programming mode and upload the code.

- If the monocular display is fully assembled, check the display to see that the code was successfully uploaded (it should be running a demo mode).

# Operating Instructions

---

##### Controlling the display from MATLAB

- Install https://www.mathworks.com/products/matlab.html (the display controller does not work with "Matlab Online").
- Copy the [Matlab code](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display/matlab) folder to your computer and open the monoDisplay_example.m file in Matlab.
- In Matlab, add the entire folder of files into Matlab's paths (Home>Set Path>Add with Subfolders>[select your downloaded Matlab folder]>Save>Close).
- At the top of the monoDisplay_example code, change`vs.port` to the COM port your display is connected to.
- Change `vs.directory` to your desired save folder.
- Run the script and watch the display to verify code and communication is working properly.

##### Controlling the display from Python

- Download the latest [Python release](https://www.python.org/downloads/).
- Open your preferred Python IDE (e.g. IDLE (installs with Python), [Visual Studio](https://visualstudio.microsoft.com/downloads/), [PyCharm](https://www.jetbrains.com/pycharm/), [Spyder](https://www.spyder-ide.org/)).
- Copy the [Python code](https://github.com/sn-lab/MouseGoggles/tree/main/Monocular%20Display/python) (not fully tested) to your desktop and open the monoDisplay_example.py file in your Python IDE.
- At the top of the monoDisplay_example code, change `ser = serial.Serial('/dev/cu.usbmodem14201',9600)` to the serial port the display is connect to. (e.g. `ser = serial.Serial('COM5',9600)`)
- Further down, change `cs = CS('directional_test_stimulus1','/Users/', 3, 0...` to your desired save directory
- Run the script and watch the display to verify code and communication is working properly

# List of commands

---

##### List of Matlab/Teensy commands

Both the Matlab and Python scripts above control the display by sending serial commands and data to the Teensy microcontroller code describing what function the display should perform next. Each command is defined by one or two bytes, and can be followed by additional data bytes. The table below lists all of the command bytes the Teensy code can recieve, what additional data bytes are expected to follow each command, and what bytes are returned from the Teensy (if any). To make this control system more user-friendly, in the Matlab control script (monoDisplay_example) commands are additionally defined by descriptive name strings (e.g. 'Connect' for command 0x___________), and associated data are contained in a parameter struct, to make it easier for the user to send the correct instructions. Some Matlab commands do not send any commands to the Teensy and serve only to simplify common MouseGoggles Mono functions, as described below.

| Matlab command   | Description                                                                                                                                      | Command byte(s) | Data byte(s)                                             | Data Byte(s) returned                             |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- | -------------------------------------------------------- | ------------------------------------------------- |
| Get-Version      | Get the version # of the program currently running on the Teensy                                                                                 | 0x00            | none                                                     | 4 bytes, defining a 'single/float' version #      |
| Get-Timestamp    | Get the current Teensy clock timestamp (measured in ms from program start)                                                                       | 0x79            | none                                                     | 4 bytes, defining a 'uint32' timestamp            |
| Connect          | Starts a serial connection to the Teensy COM port (defined by "vs.port") and creates fields in the "vs" struct to store command/data information | none            | none                                                     | none                                              |
| Find-Ports       | Checks available serial ports for connected MouseGoggles Mono and returns them in "vs.foundports"                                                | none            | none                                                     | none                                              |
| Disconnect       | Gets any remaining data returned from the Teensy (stored in "vs.data") and closes the serial connection                                          | none            | none                                                     | none                                              |
| Reset-Background | Resets the display to the pre-defined solid background color                                                                                     | 0x83            | none                                                     | none                                              |
| Send-Parameters  | Sends new pattern parameters to the Teensy to be displayed later                                                                                 | 0x65, 0x00      | 20 bytes  (listed in the Pattern Parameters table below) | 33 bytes (listed in the Display Data table below) |
| Start-Pattern    | Sends new pattern parameters to the Teensy to be displayed right away                                                                            | 0x65, 0x01      | 20 bytes  (listed in the Pattern Parameters table below) | 33 bytes (listed in the Display Data table below) |
| Get-Data         | Retrieves any available serial data previously sent by the Teensy                                                                                | none            | none                                                     | none                                              |
| Demo-On          | Turns the Teensy display demo mode on                                                                                                            | 0x6F            | none                                                     | none                                              |
| Demo-Off         | Turns the Teensy display demo mode off                                                                                                           | 0x6E            | none                                                     | none                                              |

##### List of Pattern Parameters

The table below lists all of the parameters necesary to define a pattern to be generated by the Teensy controller.

| Parameter name  | description                                                                                     | # of Bytes                           |
| --------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------ |
| patterntype     | type of pattern [1 = square-gratings, 2 = sine-gratings, 3 = flicker]                           | 1                                    |
| bar1color       | RGB color values of bar 1 in grating patterns, or ON in flickers [R=0-31, G=0-63, B=0-31]       | 3 (one each for R, G, B values)      |
| bar2color       | RGB color values of bar 2 in grating patterns, or OFF in flickers [R=0-31, G=0-63, B=0-31]      | 3 (one each for R, G, B values)      |
| backgroundcolor | RGB color values of background [R=0-31, G=0-63, B=0-31]                                         | 3 (one each for R, G, B values)      |
| barwidth        | width of each bar in pixels (for grating patterns)                                              | 1                                    |
| numgratings     | number of bright/dark bar repeats in grating pattern (i.e. multiplying overall size of pattern) | 1                                    |
| angle           | angle of grating pattern in degrees [0=drifting right, positive angles rotate clockwise]        | 2 (two uint8 values adding to angle) |
| frequency       | temporal frequency of grating in Hz [0.1-25 Hz]                                                 | 1                                    |
| position        | x,y position of grating relative to display center, in pixels                                   | 2 (one each for x, y)                |
| predelay        | delay after start command sent before grating pattern begins, in s [0 - 25.5 s]                 | 1                                    |
| duration        | duration that grating pattern is shown, in s [0.1-25.5]                                         | 1                                    |
| trigger         | whether to wait for an input trigger signal (TTL high) to start [1 = trigger, 0 = no trigger]   | 1                                    |

### List of Display Data

After the Teensy microcontroller displays a pattern, it returns data bytes back to the PC describing the pattern just displayed. The following table lists these bytes returned by the Teensy.

| Byte #        | Description                                                                                                                                                                                                                                                       |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| byte 1 (0xD2) | Host-side command byte, indicating to Matlab that the following 32 bytes will describe a recently displayed pattern                                                                                                                                               |
| bytes 6-9     | 4 bytes defining a 'uint32' timestamp when the pattern was displayed                                                                                                                                                                                              |
| bytes 10-29   | 20 bytes defining the parameters of the displayed pattern (identical to the pattern parameters table above)                                                                                                                                                       |
| bytes 30-33   | 4 bytes, defining a 'single/float' estimate of the maximum frequency that the recently displayed pattern could have been displayed (used to verify that the Teensy controller was fast enough to display the pattern -- a warning will be displayed if it wasn't) |
