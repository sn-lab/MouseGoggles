#include <Adafruit_MMC56x3.h> //library for magnetometer
#include <Mouse.h> //library for mouse movement
//#include "Mouse.h"

double cur_ang, prev_ang;
char cur_ang_char;
bool debug = false;

/* Assign a unique ID to this sensor at the same time */
Adafruit_MMC5603 mmc = Adafruit_MMC5603(12345);
sensors_event_t event;

void setup(void) {

  if (debug){
    Serial.begin(115200);
    while (!Serial)
      delay(10); // will pause Zero, Leonardo, etc until serial console opens
  
    Serial.println("Adafruit_MMC5603 Magnetometer Test");
    Serial.println("");
  }

  /* Initialise the sensor */
  if (!mmc.begin(MMC56X3_DEFAULT_ADDRESS, &Wire)) {  // I2C mode
    /* There was a problem detecting the MMC5603 ... check your connections */
    //Serial.println("Ooops, no MMC5603 detected ... Check your wiring!");
    while (1) delay(10);
  }

  /* Display some basic information on this sensor */
  mmc.printSensorDetails();

}

void loop(void) {
  // Get a new sensor event 
  mmc.getEvent(&event);

  // Display the results (magnetic vector values are in micro-Tesla (uT))
  cur_ang = atan2(event.magnetic.y,event.magnetic.x); //double angle in radians
  cur_ang = round(180*cur_ang/3.14); // rounded to nearest degree
  cur_ang = cur_ang/2; //angle divided by half (reducing range to -90:90 deg

  if (!debug){
    if (prev_ang != cur_ang){
      prev_ang = cur_ang;
      cur_ang_char = cur_ang;
      Mouse.move(cur_ang_char,0,0);
    }
  } else {
    //debugging
    Serial.print("X: ");
    Serial.print(event.magnetic.x);
    Serial.print("  ");
    Serial.print("Y: ");
    Serial.print(event.magnetic.y);
    Serial.print("  ");
    Serial.print("Z: ");
    Serial.print(event.magnetic.z);
    Serial.print("  ");
    Serial.println("uT");
  }

  // Delay before the next sample
  delay(20);
}
