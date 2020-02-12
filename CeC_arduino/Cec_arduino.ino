/*
 * CEC library
written by MrT sebastien.tack@ac-caen.fr
*/

#include "cec.h"

SoftwareSerial serial(11,10);
CEC course(&serial);

void setup() {
  //on lance les serials 
  serial.begin(115200);
  Serial.begin(9600);
  delay(50);
  
  //on lit les infos de la carte
  course.test();  
  delay (50);
  
  // on configure la course
  course.configure_longueur_piste(200);
  course.configure_roue(600);
  course.envoyer_conf();
  delay(100);
  
  
}

void loop() {

  //course.oldbegin();
  //version lourde qui part de la doc originelle
  //sert pour le deboguage pour s'assurer que le moteur est ok
  //a eviter
  
  course.avancer();
  delay(50);
 
  
  while(1);
   
  
}
