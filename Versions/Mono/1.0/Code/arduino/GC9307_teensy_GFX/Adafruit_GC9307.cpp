#include "Adafruit_GC9307.h"
#include "Adafruit_ST77xx.h"

// CONSTRUCTORS ************************************************************

/*!
    @brief  Instantiate Adafruit GC9307 driver with software SPI
    @param  cs    Chip select pin #
    @param  dc    Data/Command pin #
    @param  mosi  SPI MOSI pin #
    @param  sclk  SPI Clock pin #
    @param  rst   Reset pin # (optional, pass -1 if unused)
*/
Adafruit_GC9307::Adafruit_GC9307(int8_t cs, int8_t dc, int8_t mosi, int8_t sclk,
                                 int8_t rst)
    : Adafruit_ST77xx(240, 210, cs, dc, mosi, sclk, rst) {}

/*!
    @brief  Instantiate Adafruit GC9307 driver with hardware SPI
    @param  cs   Chip select pin #
    @param  dc   Data/Command pin #
    @param  rst  Reset pin # (optional, pass -1 if unused)
*/
Adafruit_GC9307::Adafruit_GC9307(int8_t cs, int8_t dc, int8_t rst)
    : Adafruit_ST77xx(240, 210, cs, dc, rst) {}

#if !defined(ESP8266)
/*!
    @brief  Instantiate Adafruit GC9307 driver with selectable hardware SPI
    @param  spiClass  Pointer to an SPI device to use (e.g. &SPI1)
    @param  cs        Chip select pin #
    @param  dc        Data/Command pin #
    @param  rst       Reset pin # (optional, pass -1 if unused)
*/
Adafruit_GC9307::Adafruit_GC9307(SPIClass *spiClass, int8_t cs, int8_t dc,
                                 int8_t rst)
    : Adafruit_ST77xx(240, 210, spiClass, cs, dc, rst) {}
#endif // end !ESP8266

// SCREEN INITIALIZATION ***************************************************

// Rather than a bazillion writecommand() and writedata() calls, screen
// initialization commands and arguments are organized in these tables
// stored in PROGMEM.  The table may look bulky, but that's mostly the
// formatting -- storage-wise this is hundreds of bytes more compact
// than the equivalent code.  Companion function follows.

// clang-format off

static const uint8_t PROGMEM
  GC9307[] =  {                  // Init commands for GC9307
    25,                             //  number of commands in list
    0xfe,   ST_CMD_DELAY,          //  command 1: inner register enable 1
      10,                          //   ~10 ms delay
    0xef,   ST_CMD_DELAY,          //  2: inner register enable 2
      120,                          //   
    0x36, 1+ST_CMD_DELAY,          //  3: memory access control
      0x48,                        //  
      10,
    0x3a, 1+ST_CMD_DELAY,          //  4 color mode ("colmod")
      0x05,                        //  
      10,                          //  
    0x86, 1+ST_CMD_DELAY,          //  5: ??
      0x98,
      10,
    0x89, 1+ST_CMD_DELAY,          //  6: ??
      0x03,
      10,                          //  
    0x8b, 1+ST_CMD_DELAY,          //  7: ??
      0x80,
      10,
    0x8d, 1+ST_CMD_DELAY,          //  8: ??
      0x33,
      10,
    0x8e, 1+ST_CMD_DELAY,          //  9: ??
      0x8f,
      10, 
    0xe8, 2+ST_CMD_DELAY,          //  10: frame rate
      0x12, 0x00,                  
      10,
    0xc3, 1+ST_CMD_DELAY,          //  11: Vreg1a voltage control
      0x20,
      10,
    0xc4, 1+ST_CMD_DELAY,          //  12: Vreg1b voltage control
      0x30,
      10,
    0xc9, 1+ST_CMD_DELAY,          //  13: Vreg2a voltage control
      0x08,
      20,
    0xff, 1+ST_CMD_DELAY,          //  14: ??
      0x62,
      10,
    0x99, 1+ST_CMD_DELAY,          //  15: ??
      0x3e,
      10,
    0x9d, 1+ST_CMD_DELAY,          //  16: ??
      0x4b,
      10,
    0x98, 1+ST_CMD_DELAY,          //  17: ??
      0x3e,
      10,
    0x9c, 1+ST_CMD_DELAY,          //  18: ??
      0x4b,
      20,
    0xf0, 6+ST_CMD_DELAY,          //  19: set gamma 1
      0x13, 0x14, 0x07, 0x05,
      0xf0, 0x29,
      10,
    0xf1, 6+ST_CMD_DELAY,          //  20: set gamma 2
      0x3e, 0x92, 0x90, 0x21,
      0x23, 0x9f,
      30,
    0xf2, 6+ST_CMD_DELAY,          //  21: set gamma 3
      0x13, 0x14, 0x07, 0x05,
      0xf0, 0x29,
      10,
    0xf3, 6+ST_CMD_DELAY,          //  22: set gamma 4
      0x3e, 0x92, 0x90, 0x21,
      0x23, 0x9f,
      30,
    0x11, ST_CMD_DELAY,            //  23: sleep out
      120,
    0x29, ST_CMD_DELAY,            //  24: display ON
      120,
    0x2c, ST_CMD_DELAY,            //  25: memory write
      120
    };

// clang-format on

/**************************************************************************/
/*!
    @brief  Initialization code specific to GC9307
    @param  width  Display width
    @param  height Display height
    @param  mode   SPI data mode; one of SPI_MODE0, SPI_MODE1, SPI_MODE2
                   or SPI_MODE3 (do NOT pass the numbers 0,1,2 or 3 -- use
                   the defines only, the values are NOT the same!)
*/
/**************************************************************************/
void Adafruit_GC9307::init(uint16_t width, uint16_t height, uint8_t mode) {
  // Save SPI data mode. commonInit() calls begin() (in Adafruit_ST77xx.cpp),
  // which in turn calls initSPI() (in Adafruit_SPITFT.cpp), passing it the
  // value of spiMode. It's done this way because begin() really should not
  // be modified at this point to accept an SPI mode -- it's a virtual
  // function required in every Adafruit_SPITFT subclass and would require
  // updating EVERY such library...whereas, at the moment, we know that
  // certain ST7789 displays are the only thing that may need a non-default
  // SPI mode, hence this roundabout approach...
  spiMode = mode;
  // (Might get added similarly to other display types as needed on a
  // case-by-case basis.)

  commonInit(NULL);

  _colstart = 0;
  _rowstart = 110;

  windowWidth = width;
  windowHeight = height;

  displayInit(GC9307);
  setRotation(0);

}

/**************************************************************************/
/*!
    @brief  Set origin of (0,0) and orientation of TFT display
    @param  m  The index for rotation, from 0-3 inclusive
*/
/**************************************************************************/
void Adafruit_GC9307::setRotation(uint8_t m) {
  uint8_t madctl = 0;

  rotation = m & 3; // can't be higher than 3

  switch (rotation) {
  case 0:
    madctl = ST77XX_MADCTL_MX | ST77XX_MADCTL_MY | ST77XX_MADCTL_RGB;
    _xstart = _colstart;
    _ystart = _rowstart;
    _width = windowWidth;
    _height = windowHeight;
    break;
  case 1:
    madctl = ST77XX_MADCTL_MY | ST77XX_MADCTL_MV | ST77XX_MADCTL_RGB;
    _xstart = _rowstart;
    _ystart = _colstart;
    _height = windowWidth;
    _width = windowHeight;
    break;
  case 2:
    madctl = ST77XX_MADCTL_RGB;
    _xstart = 0;
    _ystart = 0;
    _width = windowWidth;
    _height = windowHeight;
    break;
  case 3:
    madctl = ST77XX_MADCTL_MX | ST77XX_MADCTL_MV | ST77XX_MADCTL_RGB;
    _xstart = 0;
    _ystart = 0;
    _height = windowWidth;
    _width = windowHeight;
    break;
  }

  sendCommand(ST77XX_MADCTL, &madctl, 1);
}
