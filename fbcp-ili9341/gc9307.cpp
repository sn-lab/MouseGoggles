#include "config.h"

#if defined(GC9307)

#include "spi.h"
#include <memory.h>
#include <stdio.h>

void InitGC9307()
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
      

          //GC9307 init sequence (for more info: "LCD-DST-3015 GC9307 DataSheet V1 5_20191213.pdf")
          SPI_TRANSFER(SPI_CS_BIT, 0xFE);
          SPI_TRANSFER(SPI_CS_BIT, 0xEF);
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0x36, 0x48);
          SPI_TRANSFER(SPI_CS_BIT, 0x3A, 0x05);
          SPI_TRANSFER(SPI_CS_BIT, 0x86, 0x98);
          SPI_TRANSFER(SPI_CS_BIT, 0x89, 0x03);
          SPI_TRANSFER(SPI_CS_BIT, 0x8B, 0x80);
          SPI_TRANSFER(SPI_CS_BIT, 0x8D, 0x33);
          SPI_TRANSFER(SPI_CS_BIT, 0x8E, 0x8F);
          SPI_TRANSFER(SPI_CS_BIT, 0xE8, 0x12, 0x00);
          SPI_TRANSFER(SPI_CS_BIT, 0xC3, 0x20);
          SPI_TRANSFER(SPI_CS_BIT, 0xC4, 0x30);
          SPI_TRANSFER(SPI_CS_BIT, 0xC9, 0x08);
          usleep(20 * 1000);

          SPI_TRANSFER(SPI_CS_BIT, 0xFF, 0x62);
          SPI_TRANSFER(SPI_CS_BIT, 0x99, 0x3E);
          SPI_TRANSFER(SPI_CS_BIT, 0x9D, 0x4B);
          SPI_TRANSFER(SPI_CS_BIT, 0x98, 0x3E);
          SPI_TRANSFER(SPI_CS_BIT, 0x9C, 0x4B);
          usleep(20 * 1000);

          SPI_TRANSFER(SPI_CS_BIT, 0xF0, 0x13, 0x14, 0x07, 0x05, 0xF0, 0x29);
          SPI_TRANSFER(SPI_CS_BIT, 0xF1, 0x3E, 0x92, 0x90, 0x21, 0x23, 0x9F);
          usleep(30 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0xF2, 0x13, 0x14, 0x07, 0x05, 0xF0, 0x29);
          SPI_TRANSFER(SPI_CS_BIT, 0xF3, 0x3E, 0x92, 0x90, 0x21, 0x23, 0x9F);
          usleep(30 * 1000);

          SPI_TRANSFER(SPI_CS_BIT, 0x11);
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0x29);
          usleep(120 * 1000);
          SPI_TRANSFER(SPI_CS_BIT, 0x2C);
          usleep(120 * 1000);

#if defined(GPIO_TFT_BACKLIGHT) && defined(BACKLIGHT_CONTROL)
          printf("Setting TFT backlight on at pin %d\n", GPIO_TFT_BACKLIGHT);
          SET_GPIO_MODE(GPIO_TFT_BACKLIGHT, 0x01); // Set backlight pin to digital 0/1 output mode (0x01) in case it had been PWM controlled
          SET_GPIO(GPIO_TFT_BACKLIGHT); // And turn the backlight on.
#endif
          printf("Initialized GC9307 on CS %d\n", SPI_CS_BIT);
          
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
