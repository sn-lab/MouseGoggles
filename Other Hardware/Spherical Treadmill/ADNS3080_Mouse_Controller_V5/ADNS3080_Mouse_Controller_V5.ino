
/* 
 Original code: Copyright (C) 2015 Kristian Sloth Lauszus. All rights reserved.
 Based on the code by Randy Mackay. DIYDrones.com
 This code is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This code is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this code.  If not, see <http://www.gnu.org/licenses/>.
 Contact information
 -------------------
 Kristian Sloth Lauszus
 Web      :  http://www.lauszus.com
 e-mail   :  lauszus@gmail.com

 Modified 2024 for computer mouse emulation
 Matt Isaacson
 mdi22@cornell.edu
*/

#include <Mouse.h> //mouse emulation library
#include <SPI.h>

SPISettings spiSettings(2e6, MSBFIRST, SPI_MODE3); // 2 MHz, mode 3

// Register Map for the ADNS3080 Optical OpticalFlow Sensor
#define ADNS3080_PRODUCT_ID            0x00
#define ADNS3080_MOTION                0x02
#define ADNS3080_DELTA_X               0x03
#define ADNS3080_DELTA_Y               0x04
#define ADNS3080_SQUAL                 0x05
#define ADNS3080_CONFIGURATION_BITS    0x0A
#define ADNS3080_MOTION_CLEAR          0x12
#define ADNS3080_FRAME_CAPTURE         0x13
#define ADNS3080_MOTION_BURST          0x50

// ADNS3080 hardware config
#define ADNS3080_PIXELS_X              30
#define ADNS3080_PIXELS_Y              30

// Id returned by ADNS3080_PRODUCT_ID register
#define ADNS3080_PRODUCT_ID_VALUE      0x17

//declare variables
static const uint8_t RESET_PIN_top = 11;
static const uint8_t CS_PIN_top = 10; 
static const uint8_t RESET_PIN_bottom = 5;
static const uint8_t CS_PIN_bottom = 4; 
static int32_t x, y;
int motionOverflow = 0;
unsigned long t = millis();
unsigned long t_last = t;

struct MotionAndLickData 
{
  int32_t x_1;
  int32_t y_1;
  int32_t x_2;
  int32_t y_2;
  int32_t surface_quality_1;
  int32_t surface_quality_2;
};

struct Vector2 //struct to store ADNS3080 readings
{
  int x;
  int y;
  int surface_quality;
};

Vector2 v_top;
Vector2 v_bottom;

//new variables to convert x,y sensor readings into spherical treadmill motion estimates
int8_t yaw, pitch, roll;
float yawFloat, pitchFloat, rollFloat;
float back_scale = 1; //should be 0.1?
float scale_ratio = 1;
float bottom_scale = back_scale*scale_ratio;
float send_period;
float send_rate = 60; //Hz
unsigned long last_send_millis;
//end new variables

MotionAndLickData motionAndLickData;

//function to reset ADNS3080 sensor
void reset(int reset_pin) {
  digitalWrite(reset_pin, HIGH); // Set high
  delayMicroseconds(10);
  digitalWrite(reset_pin, LOW); // Set low
  delayMicroseconds(500); // Wait for sensor to get ready
}

//function to read new ADNS3080 sensor values
void updateSensor(int CS_pin, struct Vector2 *vector) {
  // Read sensor
  uint8_t buf[4];
  spiRead(CS_pin, ADNS3080_MOTION_BURST, buf, 4);
  uint8_t motion = buf[0];
  //Serial.print(motion & 0x01); // Resolution

  if (motion & 0x10){ // Check if we've had an overflow
    motionOverflow = 1;
  }
  else if (motion & 0x80) {
    int8_t dx = buf[1];
    int8_t dy = buf[2];
    uint8_t surfaceQuality = buf[3];

    vector->x += dx;
    vector->y += dy;
    vector->surface_quality = surfaceQuality;
  }
}

// Function to clear Delta_X, Delta_Y, and internal motion registers
void clearMotion() {
  spiWrite(CS_PIN_top, ADNS3080_MOTION_CLEAR, 0xFF); // Writing anything to this register will clear the sensor's motion registers
  delayMicroseconds(50); // Wait for sensor to get ready
  spiWrite(CS_PIN_bottom, ADNS3080_MOTION_CLEAR, 0xFF); // Writing anything to this register will clear the sensor's motion registers
  v_top.x = 0;
  v_top.y = 0;
  v_bottom.x = 0;
  v_bottom.y = 0;
}

//function to write data to SPI channel
void spiWrite(int CS_pin, uint8_t reg, uint8_t data) {
  spiWrite(CS_pin, reg, &data, 1);
}

//function to write data to SPI channel
void spiWrite(int CS_pin, uint8_t reg, uint8_t *data, uint8_t length) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(CS_pin, LOW);

  SPI.transfer(reg | 0x80); // Indicate write operation
  delayMicroseconds(75); // Wait minimum 75 us in case writing to Motion or Motion_Burst registers
  SPI.transfer(data, length); // Write data

  digitalWrite(CS_pin, HIGH);
  SPI.endTransaction();
}

//function to read data from SPI channel
uint8_t spiRead(int CS_pin, uint8_t reg) {
  uint8_t buf;
  spiRead(CS_pin, reg, &buf, 1);
  return buf;
}

//function to read data from SPI channel
void spiRead(int CS_pin, uint8_t reg, uint8_t *data, uint8_t length) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(CS_pin, LOW);

  SPI.transfer(reg); // Send register address
  delayMicroseconds(75); // Wait minimum 75 us in case writing to Motion or Motion_Burst registers
  memset(data, 0, length); // Make sure data buffer is 0
  SPI.transfer(data, length); // Write data

  digitalWrite(CS_pin, HIGH);
  SPI.endTransaction();
}


void setup() {

  //new code to set update rate
  last_send_millis = millis();
  send_period = (1000/send_rate);
  //end new

  motionAndLickData.x_1 = 0;
  motionAndLickData.x_2 = 0;
  motionAndLickData.y_1 = 0;
  motionAndLickData.y_2 = 0;
  motionAndLickData.surface_quality_1 = 0;
  motionAndLickData.surface_quality_2 = 0;

  v_top.x = 0;
  v_top.y = 0;
  v_bottom.x = 0;
  v_bottom.y = 0;
  
  Serial.begin(115200); // Serial.begin(9600) for mouse library? Or no Serial.begin at all?
  while (!Serial); // Wait for serial port to open

  SPI.begin();

  // Set CS and reset pin as output
  pinMode(CS_PIN_top, OUTPUT);
  pinMode(RESET_PIN_top, OUTPUT);

  pinMode(CS_PIN_bottom, OUTPUT);
  pinMode(RESET_PIN_bottom, OUTPUT);

  digitalWrite(CS_PIN_top, HIGH);
  digitalWrite(CS_PIN_bottom, HIGH);

  reset(RESET_PIN_top);
  delayMicroseconds(500); // Wait for sensor to get ready
  reset(RESET_PIN_bottom);
  delayMicroseconds(500); // Wait for sensor to get ready

  
  uint8_t id = spiRead(CS_PIN_top, ADNS3080_PRODUCT_ID);
  while(id != ADNS3080_PRODUCT_ID_VALUE){
    id = spiRead(CS_PIN_top, ADNS3080_PRODUCT_ID);
  }

  delayMicroseconds(500); // Wait for sensor to get ready

  id = spiRead(CS_PIN_bottom, ADNS3080_PRODUCT_ID);
  while(id != ADNS3080_PRODUCT_ID_VALUE){
    id = spiRead(CS_PIN_bottom, ADNS3080_PRODUCT_ID);
  }
  
  delayMicroseconds(500); // Wait for sensor to get ready

  uint8_t config = spiRead(CS_PIN_top, ADNS3080_CONFIGURATION_BITS);
  spiWrite(CS_PIN_top, ADNS3080_CONFIGURATION_BITS, config | 0x10); // Set resolution to 1600 counts per inch
  
  delayMicroseconds(500); // Wait for sensor to get ready
  
  config = spiRead(CS_PIN_bottom, ADNS3080_CONFIGURATION_BITS);
  spiWrite(CS_PIN_bottom, ADNS3080_CONFIGURATION_BITS, config | 0x10); // Set resolution to 1600 counts per inch

}


void loop() {

  //read new motion sensor values
  updateSensor(CS_PIN_top, &v_top);
  delayMicroseconds(50); // Wait for sensor to get ready
  updateSensor(CS_PIN_bottom, &v_bottom);

  //wait for update rate
  if ((millis()-last_send_millis) >= send_period) {
    last_send_millis += send_period;

    //convert x,y motion to rotational motion
    yawFloat = float(v_bottom.x) * bottom_scale;
    pitchFloat = float(v_top.x) * back_scale;
    rollFloat = 0.5 * (float(v_bottom.y) * bottom_scale + float(v_top.y) * back_scale);
    yaw = int8_t(yawFloat);
    pitch= int8_t(pitchFloat);
    roll = int8_t(rollFloat);

    //transmit rotation motion estimates through mouse emulation 
    //(pitch = mouse_x, yaw = mouse_y, roll = scroll wheel)
    Mouse.move(pitch, yaw, roll);

    //print values over serial (for debugging):
    /*
    Serial.print("v_bottom.x: " );
    Serial.print(v_bottom.x);
    Serial.print(", v_top.x: " );
    Serial.print(v_top.x);
    Serial.print(", v_bottom.y: " );
    Serial.print(v_bottom.y);
    Serial.print(", top.y: " );
    Serial.println(v_top.y);
    
    Serial.print("yaw: " );
    Serial.print(yawFloat);
    Serial.print(", pitch: " );
    Serial.print(pitchFloat);
    Serial.print(", roll: " );
    Serial.print(rollFloat);
    Serial.print(",   chars-- yaw: " );
    Serial.print(yaw);
    Serial.print(", pitch: " );
    Serial.print(pitch);
    Serial.print(", roll: " );
    Serial.println(roll);
    Serial.println();
    */

    //reset sensor values
    v_top.x = 0;
    v_top.y = 0;
    v_bottom.x = 0;
    v_bottom.y = 0;
  }  
}
