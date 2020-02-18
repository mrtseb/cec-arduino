/*
 * CEC library
written by MrT sebastien.tack@ac-caen.fr
*/

#include "cec.h"

SoftwareSerial serial(11,10);
CEC course(&serial);

void setup() {
 
  serial.begin(115200);
  Serial.begin(115200);
  while (!Serial);
    
  
}

void loop() {

  if (serial.available()) {
	  Serial.write(serial.read());
  }
  
  if (Serial.available()) {
	  serial.write(Serial.read());
  }
   
  
}
