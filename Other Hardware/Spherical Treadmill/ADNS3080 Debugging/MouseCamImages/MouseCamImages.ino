#include <SPI.h>

//uncomment to read images from sensor 1
#define PIN_MOUSECAM_RESET             11
#define PIN_SS                         10

//uncomment to read images from sensor 2
//#define PIN_MOUSECAM_RESET             5
//#define PIN_SS                         4

#define PIN_MOUSECAM_CS                10

#define ADNS3080_PIXELS_X              30
#define ADNS3080_PIXELS_Y              30
#define SERIAL                         Serial

#define ADNS3080_PRODUCT_ID            0x00
#define ADNS3080_PRODUCT_ID_VAL        0x17
#define ADNS3080_CONFIGURATION_BITS    0x0a
#define ADNS3080_MOTION_BURST          0x50
#define ADNS3080_PIXEL_SUM             0x06
#define ADNS3080_FRAME_CAPTURE         0x13
#define ADNS3080_PIXEL_BURST           0x40

SPISettings spi_settings(24000000, MSBFIRST, SPI_MODE3);
byte frame[ADNS3080_PIXELS_X * ADNS3080_PIXELS_Y];

//struct to hold sensor motion data
struct MD
{
 byte motion;
 char dx, dy;
 byte squal;
 word shutter;
 byte max_pix;
};
//
//struct dxdy {
//  char dx, dy;
//}

//read data from sensor
int mousecam_read_reg(int reg)
{
  //digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(PIN_SS, reg, SPI_CONTINUE);
  delayMicroseconds(75);
  int ret = SPI.transfer(PIN_SS, 0xff);
  //digitalWrite(PIN_MOUSECAM_CS, HIGH);
  delayMicroseconds(1);
  return ret;
}

//write data to sensor
void mousecam_write_reg(int reg, int val)
{
  //digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(PIN_SS, reg | 0x80, SPI_CONTINUE);
  SPI.transfer(PIN_SS, val);
  //digitalWrite(PIN_MOUSECAM_CS,HIGH);
  delayMicroseconds(50);
}

//read image data from sensor
// pdata must point to an array of size ADNS3080_PIXELS_X x ADNS3080_PIXELS_Y
// you must call mousecam_reset() after this if you want to go back to normal operation
int mousecam_frame_capture(byte *pdata)
{
  mousecam_write_reg(ADNS3080_FRAME_CAPTURE,0x83);
  delayMicroseconds(20);
 
  //digitalWrite(PIN_MOUSECAM_CS, LOW);

  //command to read pixel data
  SPI.transfer(PIN_SS, ADNS3080_PIXEL_BURST, SPI_CONTINUE);
  delayMicroseconds(50);

  //read all pixel data
  int pix;
  byte started = 0;
  int count;
  int timeout = 0;
  int ret = 0;
  for(count = 0; count < ADNS3080_PIXELS_X * ADNS3080_PIXELS_Y; )
  {
    pix = SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
   
    delayMicroseconds(10);
    if(started==0)
    {
      if(pix&0x40)
        started = 1;
      else
      {
        timeout++;
        if(timeout==1000)
        {
          ret = -1;
          break;
        }
      }
    }
    if(started==1)
    {
      pdata[count++] = (pix & 0x3f)<<2; // scale to normal grayscale byte range
    }
  }

  SPI.transfer(PIN_SS, 0xff);

  //digitalWrite(PIN_MOUSECAM_CS, HIGH);
  delayMicroseconds(14);
 
  return ret;
}

//initialize sensor
int mousecam_init()
{
  pinMode(PIN_MOUSECAM_RESET,OUTPUT);
  pinMode(PIN_MOUSECAM_CS, OUTPUT);
  //digitalWrite(PIN_MOUSECAM_CS,HIGH);
  digitalWrite(PIN_MOUSECAM_RESET,LOW);
 
  delay(10);
 
  mousecam_reset();
 
  int pid = mousecam_read_reg(ADNS3080_PRODUCT_ID);
//  Serial.print("PRODUCT_ID: ");
//  Serial.println(pid);
//  Serial.print("PRODUCT_ID_VAL: ");
//  Serial.println(ADNS3080_PRODUCT_ID_VAL);
  if(pid != ADNS3080_PRODUCT_ID_VAL)
    return -1;

  // turn on sensitive mode
  mousecam_write_reg(ADNS3080_CONFIGURATION_BITS, 0x19);

  return 0;
}

//reset sensor
void mousecam_reset()
{
  digitalWrite(PIN_MOUSECAM_RESET,HIGH);
  delay(1); // reset pulse >10us
  digitalWrite(PIN_MOUSECAM_RESET,LOW);
  delay(35); // 35ms from reset to functional
}

//read sensor data
void mousecam_read_motion(struct MD *p)
{
  //digitalWrite(PIN_MOUSECAM_CS, LOW);
  SPI.transfer(PIN_SS, ADNS3080_MOTION_BURST, SPI_CONTINUE);
  delayMicroseconds(75);
  p->motion =  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
  p->dx =  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
  p->dy =  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
  p->squal =  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
  p->shutter =  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE)<<8;
  p->shutter |=  SPI.transfer(PIN_SS, 0xff, SPI_CONTINUE);
  p->max_pix =  SPI.transfer(PIN_SS, 0xff);
  //digitalWrite(PIN_MOUSECAM_CS,HIGH);
  delayMicroseconds(5);
}

char asciiart(int k)
{
  static char foo[] = "WX86*3I>!;~:,`.X";
  return foo[k>>4];
}

void setup() {
  SPI.begin(PIN_SS);
  SPI.setClockDivider(PIN_SS, SPI_CLOCK_DIV32);
  SPI.beginTransaction(spi_settings);

  SERIAL.begin(115200);
 
  while(mousecam_init() == -1){
    SERIAL.println("Mouse cam failed to init");
  }
}

void loop() {
  //wait for incoming serial command
  if(SERIAL.available()){
    byte a = SERIAL.read();
    if(a == 'h'){ //h = command to read image data
      mousecam_frame_capture(frame); //capture a new image
      SERIAL.write(frame, ADNS3080_PIXELS_X*ADNS3080_PIXELS_Y); //send image over serial
    }
  }
}
