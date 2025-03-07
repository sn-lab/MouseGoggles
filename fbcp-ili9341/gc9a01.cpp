#include "config.h"

#if defined(GC9A01)

#include "spi.h"
#include <memory.h>
#include <stdio.h>

void InitGC9A01()
{
  // If a Reset pin is defined, toggle it briefly high->low->high to enable the device. Some devices do not have a reset pin, in which case compile with GPIO_TFT_RESET_PIN left undefined.
#if defined(GPIO_TFT_RESET_PIN) && GPIO_TFT_RESET_PIN >= 0
  printf("Resetting display at reset GPIO pin %d\n", GPIO_TFT_RESET_PIN);
  SET_GPIO_MODE(GPIO_TFT_RESET_PIN, 1);
  SET_GPIO(GPIO_TFT_RESET_PIN);
  usleep(120 * 1000);
  CLEAR_GPIO(GPIO_TFT_RESET_PIN);
  usleep(120 * 1000);
  SET_GPIO(GPIO_TFT_RESET_PIN);
  usleep(120 * 1000);
#endif

  // Do the initialization with a very low SPI bus speed, so that it will succeed even if the bus speed chosen by the user is too high.
  spi->clk = 34;
  __sync_synchronize();
  
  bool SPI_CS_BIT = 0;
#if defined(DISPLAY_USES_CE1) && NUM_DISPLAY_LOOPS < 2
  SPI_CS_BIT = 1;
#endif

  for (uint8_t DISPLAY_LOOP = 0; DISPLAY_LOOP < NUM_DISPLAY_LOOPS; DISPLAY_LOOP++, SPI_CS_BIT = !SPI_CS_BIT)
  {
      BEGIN_SPI_COMMUNICATION(SPI_CS_BIT);
          //GC9A01 init sequence (from Adafruit)
          SPI_TRANSFER(SPI_CS_BIT, 0xEF); // inregen2
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0xEB, 0x14);
          SPI_TRANSFER(SPI_CS_BIT, 0xFE); // inregen1
          SPI_TRANSFER(SPI_CS_BIT, 0xEF); // inregen2
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0xEB, 0x14);
          SPI_TRANSFER(SPI_CS_BIT, 0x84, 0x40);
          SPI_TRANSFER(SPI_CS_BIT, 0x85, 0xFF);
          SPI_TRANSFER(SPI_CS_BIT, 0x86, 0xFF);
          SPI_TRANSFER(SPI_CS_BIT, 0x87, 0xFF);
          SPI_TRANSFER(SPI_CS_BIT, 0x88, 0x0A);
          SPI_TRANSFER(SPI_CS_BIT, 0x89, 0x21);
          SPI_TRANSFER(SPI_CS_BIT, 0x8A, 0x00);
          SPI_TRANSFER(SPI_CS_BIT, 0x8B, 0x80);
          SPI_TRANSFER(SPI_CS_BIT, 0x8C, 0x01);
          SPI_TRANSFER(SPI_CS_BIT, 0x8D, 0x01);
          SPI_TRANSFER(SPI_CS_BIT, 0x8E, 0xFF);
          SPI_TRANSFER(SPI_CS_BIT, 0x8F, 0xFF);
          SPI_TRANSFER(SPI_CS_BIT, 0xB6, 0x00, 0x20); //2nd param: source scan/gate scan (0,2,4,6) 0xB6 0x00 0x00 from adafruit, 0xB6 0x00 0x20 from waveshare
          SPI_TRANSFER(SPI_CS_BIT, 0x36, 0x08); //madctl 0x36, madctl_mx 0x40 | madctl_bgr 0x08 from adafruit, 0x36 0x08 sets as vertical from wave
          SPI_TRANSFER(SPI_CS_BIT, 0x3A, 0x05); //colmod
          SPI_TRANSFER(SPI_CS_BIT, 0x90, 0x08, 0x08, 0x08, 0x08);
          SPI_TRANSFER(SPI_CS_BIT, 0xBD, 0x06);
          SPI_TRANSFER(SPI_CS_BIT, 0xBC, 0x00);
          usleep(20 * 1000);
          
          SPI_TRANSFER(SPI_CS_BIT, 0xFF, 0x60, 0x01, 0x04);
          SPI_TRANSFER(SPI_CS_BIT, 0xC3, 0x13); //power2
          SPI_TRANSFER(SPI_CS_BIT, 0xC4, 0x13); //power3
          SPI_TRANSFER(SPI_CS_BIT, 0xC9, 0x22); //power4
          SPI_TRANSFER(SPI_CS_BIT, 0xBE, 0x11);
          SPI_TRANSFER(SPI_CS_BIT, 0xE1, 0x10, 0x0E);
          SPI_TRANSFER(SPI_CS_BIT, 0xDF, 0x21, 0x0C, 0x02);
          
          usleep(20 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0xF0, 0x45, 0x09, 0x08, 0x08, 0x26, 0x2A); //gamma1
          SPI_TRANSFER(SPI_CS_BIT, 0xF1, 0x43, 0x70, 0x72, 0x36, 0x37, 0x6F); //gamma2
          usleep(30 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0xF2, 0x45, 0x09, 0x08, 0x08, 0x26, 0x2A); //gamma3
          SPI_TRANSFER(SPI_CS_BIT, 0xF3, 0x43, 0x70, 0x72, 0x36, 0x37, 0x6F); //gamma4
          usleep(30 * 1000);
          
          SPI_TRANSFER(SPI_CS_BIT, 0xED, 0x1B, 0x0B);
          SPI_TRANSFER(SPI_CS_BIT, 0xAE, 0x77);
          SPI_TRANSFER(SPI_CS_BIT, 0xCD, 0x63);
          SPI_TRANSFER(SPI_CS_BIT, 0x70, 0x07, 0x07, 0x04, 0x0E, 0x0F, 0x09, 0x07, 0x08, 0x03); //skipped from adafruit, included from wave
          
          SPI_TRANSFER(SPI_CS_BIT, 0xE8, 0x04); //framerate; 0xE8, 0x34 from adafruit and wave, but it flickers. 0x04, 0x14, and 0x24 looks better
          SPI_TRANSFER(SPI_CS_BIT, 0x62, 0x18, 0x0D, 0x71, 0xED, 0x70, 0x70, 0x18, 0x0F, 0x71, 0xEF, 0x70, 0x70);
          SPI_TRANSFER(SPI_CS_BIT, 0x63, 0x18, 0x11, 0x71, 0xF1, 0x70, 0x70, 0x18, 0x13, 0x71, 0xF3, 0x70, 0x70);
          SPI_TRANSFER(SPI_CS_BIT, 0x64, 0x28, 0x29, 0xF1, 0x01, 0xF1, 0x00, 0x07);
          SPI_TRANSFER(SPI_CS_BIT, 0x66, 0x3C, 0x00, 0xCD, 0x67, 0x45, 0x45, 0x10, 0x00, 0x00, 0x00);
          SPI_TRANSFER(SPI_CS_BIT, 0x67, 0x00, 0x3C, 0x00, 0x00, 0x00, 0x01, 0x54, 0x10, 0x32, 0x98);
          SPI_TRANSFER(SPI_CS_BIT, 0x74, 0x10, 0x85, 0x80, 0x00, 0x00, 0x4E, 0x00);
          SPI_TRANSFER(SPI_CS_BIT, 0x98, 0x3E, 0x07);
          SPI_TRANSFER(SPI_CS_BIT, 0x35); //teon
          SPI_TRANSFER(SPI_CS_BIT, 0x21); //invon
          SPI_TRANSFER(SPI_CS_BIT, 0x11); //slpout; 0x11, 0x80 from adafruit
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0x29); //dispon; 0x29, 0x80 from adafruit
          usleep(120 * 1000);
          //SPI_TRANSFER(SPI_CS_BIT, 0x00); //included in adafruit, omitted from wave
          //usleep(120 * 1000);

#if defined(GPIO_TFT_BACKLIGHT) && defined(BACKLIGHT_CONTROL)
          printf("Setting TFT backlight on at pin %d\n", GPIO_TFT_BACKLIGHT);
          SET_GPIO_MODE(GPIO_TFT_BACKLIGHT, 0x01); // Set backlight pin to digital 0/1 output mode (0x01) in case it had been PWM controlled
          SET_GPIO(GPIO_TFT_BACKLIGHT); // And turn the backlight on.
#endif
          printf("Initialized GC9A01 on CS %d\n", SPI_CS_BIT);
          
          usleep(120 * 1000);
          ClearScreen(SPI_CS_BIT);
          usleep(120 * 1000);
          
#ifndef USE_DMA_TRANSFERS // For DMA transfers, keep SPI CS & TA active.
      END_SPI_COMMUNICATION(SPI_CS_BIT);
#else
      if (NUM_DISPLAY_LOOPS==2 && DISPLAY_LOOP==0)
      {
        END_SPI_COMMUNICATION(SPI_CS_BIT);
      }
#endif

  } //end DISPLAY_LOOP

  // And speed up to the desired operation speed finally after init is done.
  usleep(10 * 1000); // Delay a bit before restoring CLK, or otherwise this has been observed to cause the display not init if done back to back after the clear operation above.
  spi->clk = SPI_BUS_CLOCK_DIVISOR;
}

void TurnDisplayOff()
{
#if defined(GPIO_TFT_BACKLIGHT) && defined(BACKLIGHT_CONTROL)
  SET_GPIO_MODE(GPIO_TFT_BACKLIGHT, 0x01); // Set backlight pin to digital 0/1 output mode (0x01) in case it had been PWM controlled
  CLEAR_GPIO(GPIO_TFT_BACKLIGHT); // And turn the backlight off.
#endif
#if 0
  bool SPI_CS_BIT = 0
#if defined(DISPLAY_USES_CE1) && NUM_DISPLAY_LOOPS < 2
  SPI_CS_BIT = 1;
#endif
  for (uint8_t DISPLAY_LOOP = 0; DISPLAY_LOOP < NUM_DISPLAY_LOOPS; DISPLAY_LOOP++, SPI_CS_BIT = !SPI_CS_BIT)
    QUEUE_SPI_TRANSFER(SPI_CS_BIT, 0x28/*Display OFF*/);
    QUEUE_SPI_TRANSFER(SPI_CS_BIT, 0x10/*Enter Sleep Mode*/);
  } //end DISPLAY_LOOP
  usleep(120*1000); // Sleep off can be sent 120msecs after entering sleep mode the earliest, so synchronously sleep here for that duration to be safe.
#endif
//  printf("Turned display OFF\n");
}

void TurnDisplayOn()
{
#if 0
  bool SPI_CS_BIT = 0
#if defined(DISPLAY_USES_CE1) && NUM_DISPLAY_LOOPS < 2
  SPI_CS_BIT = 1;
#endif
  for (uint8_t DISPLAY_LOOP = 0; DISPLAY_LOOP < NUM_DISPLAY_LOOPS; DISPLAY_LOOP++, SPI_CS_BIT = !SPI_CS_BIT)
    QUEUE_SPI_TRANSFER(SPI_CS_BIT, 0x11/*Sleep Out*/);
    usleep(120 * 1000);
    QUEUE_SPI_TRANSFER(SPI_CS_BIT, 0x29/*Display ON*/);
  } //end DISPLAY_LOOP
#endif
#if defined(GPIO_TFT_BACKLIGHT) && defined(BACKLIGHT_CONTROL)
  SET_GPIO_MODE(GPIO_TFT_BACKLIGHT, 0x01); // Set backlight pin to digital 0/1 output mode (0x01) in case it had been PWM controlled
  SET_GPIO(GPIO_TFT_BACKLIGHT); // And turn the backlight on.
#endif
//  printf("Turned display ON\n");
}

void DeinitSPIDisplay()
{
  bool SPI_CS_BIT = 0;
#if defined(DISPLAY_USES_CE1) && NUM_DISPLAY_LOOPS < 2
  SPI_CS_BIT = 1;
#endif
  for (uint8_t DISPLAY_LOOP = 0; DISPLAY_LOOP < NUM_DISPLAY_LOOPS; DISPLAY_LOOP++, SPI_CS_BIT = !SPI_CS_BIT)
  {
    ClearScreen(SPI_CS_BIT);
  } //end DISPLAY_LOOP
}

#endif
