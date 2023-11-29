#pragma once

#if defined(GC9A01)

// Data specific to the ILI9341 controller (unsure if needed for GC9307)
#define DISPLAY_SET_CURSOR_X 0x2A
#define DISPLAY_SET_CURSOR_Y 0x2B
#define DISPLAY_WRITE_PIXELS 0x2C

// set width and height (might experience some incorrect offset)
#define DISPLAY_NATIVE_WIDTH 240
#define DISPLAY_NATIVE_HEIGHT 480
#define DISPLAY_ACTUAL_HEIGHT 240
#define DOUBLE_HEIGHT

// I believe this reduces the effective screen size
#define DISPLAY_NATIVE_COVERED_LEFT_SIDE 0
#define DISPLAY_NATIVE_COVERED_TOP_SIDE 0

//definine init function
#define InitSPIDisplay InitGC9A01
void InitGC9A01(void);

void TurnDisplayOn(void);
void TurnDisplayOff(void);

// Defined in config file
//#define DISPLAY_NEEDS_CHIP_SELECT_SIGNAL

#endif
