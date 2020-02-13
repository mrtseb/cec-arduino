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
  Serial.begin(115200);
  while (!Serial);
  
  //on lit les infos de la carte
  course.lire_information();
  delay(50);
  //Serial.println("test");
  //course.test();  
  //delay(50);
  //Serial.println("mesures");
  //course.lire_mesures();  
  //delay(50);
  
  
  
}

void loop() {

  //course.oldbegin();
  //delay(2000);
  //version lourde qui part de la doc originelle
  //sert pour le deboguage pour s'assurer que le moteur est ok
  //a eviter

 // on configure la course
  //course.configure_longueur_piste(200);
  //course.configure_roue(600);
  //course.envoyer_conf();
  //delay(1000);
  //course.avancer();
  while(1);
   
  
}
