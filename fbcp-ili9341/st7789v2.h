#pragma once

#if defined(ST7789V2)

// Data specific to the ILI9341 controller (unsure if needed for ST7789V2)
#define DISPLAY_SET_CURSOR_X 0x2A
#define DISPLAY_SET_CURSOR_Y 0x2B
#define DISPLAY_WRITE_PIXELS 0x2C

// set width and height (might experience some incorrect offset)
#define DISPLAY_NATIVE_WIDTH 240
#define DISPLAY_NATIVE_HEIGHT 420
#define DISPLAY_ACTUAL_HEIGHT 210
#define DOUBLE_HEIGHT

// I believe this reduces the effective screen size
#define DISPLAY_NATIVE_COVERED_LEFT_SIDE 0
#define DISPLAY_NATIVE_COVERED_TOP_SIDE 0

//definine init function
#define InitSPIDisplay InitST7789V2
void InitST7789V2(void);

void TurnDisplayOn(void);
void TurnDisplayOff(void);

// Defined in config file
//#define DISPLAY_NEEDS_CHIP_SELECT_SIGNAL

#endif
