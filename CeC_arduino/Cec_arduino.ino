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
  
  course.configure_longueur_piste(200);
  course.configure_roue(600);
  course.etalonner_capteurs();
  delay(10);
  
  //on lit les infos du moteur
  course.lire_information();
  delay(10);
  course.test();  
  delay(10);
  
 
  
  
  
}

void loop() {

  //course.oldbegin();
  //delay(2000);
  //version lourde qui part de la doc originelle
  //sert pour le deboguage pour s'assurer que le moteur est ok
  //a eviter

  // on configure la cour
  //course.configure_longueur_piste(200);
  //course.configure_roue(600);
  //course.envoyer_conf();
  //delay(500);
  
  course.lancer();
  delay(3000);
  course.lire_mesures();
  delay(5000);  
  

  while(1);
   
  
}
