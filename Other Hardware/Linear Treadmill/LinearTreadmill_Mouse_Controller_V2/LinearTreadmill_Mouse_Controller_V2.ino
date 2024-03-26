// EncoderInterfaceT3

//  Edited by Amanda Huang, Matthew Isaacson
//  07/13/2023

//  Read the encoder and translate to a distance and send over USB-Serial and DAC
//  Teensy LC Arduino 2.1.1 with Teensy Extensions
//
//  This designed to be easy to assemble. The cables are soldered directly to Teensy 3.2.
//  Encoder A - pin 0
//  Encoder B - pin 1
//  Encoder VCC - Vin
//  Encoder ground - GND
//  Analog Out - A12/DAC
//  Analog ground - AGND
//
// Steve Sawtelle
// jET
// Janelia
// HHMI 
// 



#define VERSION "20180207"
// ===== VERSIONS ======

//library for mouse movement
#include "Mouse.h"

#define MAXSPEED    1000.0f  // maximum speed for dac out (mm/sec)
#define MAXDACVOLTS 2.5f    // DAC ouput voltage at maximum speed
#define MAXDACCNTS  4095.0f // maximum dac value
#define maxMouseval 127.0f

float maxDACval = MAXDACVOLTS * MAXDACCNTS / 3.3; // limit dac output to max allowed
float mouseGain = 1.0;

#define encAPin 0
#define encBPin 1
#define dacPin  A12
//#define idxPin  2  // not used here

// counts per rotation of treadmill encoder wheel
// 200 counts per rev
// 1.03" per rev
// so - 1.03 * 25.4 * pi / 200 /1000 = microns/cnt

#define MM_PER_COUNT 410950  // actually 1/10^6mm per count since we divide by usecs
#define DIST_PER_COUNT ((float)MM_PER_COUNT/1000000.0)
//(float)0.41095

#define SPEED_TIMEOUT 50000  // if we don't move in this many microseconds assume we are stopped

static float runSpeed = 0;
volatile uint32_t lastUsecs;
volatile uint32_t thisUsecs;
volatile uint32_t encoderUsecs;
uint32_t now;
volatile float distance = 0;
bool oldencAState=0;
bool encAState;
bool encBState;
float dacval;

int dir = 1;

int8_t forwardSpeed = 0;

void setup()
{
  //Serial.begin(192000);
  //while( !Serial);   // if no serial USB is connected, may need to comment this out
  pinMode(encAPin, INPUT_PULLUP); // sets the digital pin as input
  pinMode(encBPin, INPUT_PULLUP); // sets the digital pin as input
  analogWriteResolution(12);
  Mouse.begin();
  //Serial.print("Treadmill Interface V: ");
  //Serial.println(VERSION);
  //Serial.println("distance,speed");
  //Serial.println(maxDACval);

  lastUsecs = micros();
}

void loop() 
{ 
  now = micros();
  //treadmill is stopped 
  if( (now > lastUsecs) && ((now - lastUsecs) > SPEED_TIMEOUT)  )
  {   // now should never be < lastUsecs, but sometiems it is
      // this is from the old code, necessary?
     runSpeed = 0;
     analogWrite(dacPin, maxDACval/2);
  }    

// Polling
// there are 3 cases 
// 1. enc A is on a rising edge and encA=encB=1
// This is backwards movement on the treadmill. It will result in an 
// output voltage on pin A12 to be between 0 and ~1551.
// faster motion is closer to 0

// 2. enc A is on a rising edge and encA!=enc B
// This is forward movement on the treadmill. It will result in an 
// output voltage on pin A12 to be between ~1551 and ~ 3102

// 3. enc A is not changing, dac val is ~1551. 

//Questions: what should the delay be?
//Question: does there need to be a buffer region around speed zero for fwd and bwd motion?

//check ENCA pin and ENCB pin 
  encAState = digitalRead(encAPin);
  encBState = digitalRead(encBPin);

//check if there is motion; rising of encApin; 
  if ((oldencAState ==0) && (encAState==1))
  {
    //figure out direction; change volt output based on the dir  
    //ENCA == ENCB: bwD motion,  ENCA != ENCB FWD motion
    dir= (encAState==encBState)*-2 +1;
    thisUsecs = micros();
    encoderUsecs = thisUsecs - lastUsecs;
    lastUsecs = thisUsecs;
    runSpeed = (float)MM_PER_COUNT / encoderUsecs;
    distance += DIST_PER_COUNT;

    dacval = (maxDACval/2)+ dir*(runSpeed/MAXSPEED * (maxDACval))/2; 
    forwardSpeed =  mouseGain*dir*(runSpeed/MAXSPEED * (maxMouseval));
    if( dacval < 0 ) dacval = 0;
    if( dacval > maxDACval) dacval = maxDACval;
    // Serial.print("distance:");
    // Serial.print(distance);
    // Serial.print(",speed:");
    // Serial.println(runSpeed);    
    // Serial.print("dac: ,");
    // Serial.print(dacval); 
    // Serial.print(",dir:");
    // Serial.print(dir);
    analogWrite(dacPin,(uint16_t) dacval);
    Mouse.move(0,forwardSpeed,0);
  }
//all cases 
  oldencAState= encAState;
  delay(0.5);
}
