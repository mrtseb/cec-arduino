/*
 * CEC library
written by MrT sebastien.tack@ac-caen.fr
*/

#include "cec.h"

SoftwareSerial serial(11,10);
CEC course(&serial);

void setup() {
    
  serial.begin(115200);
  //on lance les serials
 

  // on configure la course
  course.configure_longueur_piste(200);
  course.configure_roue(600);
  

  
}

void loop() {

  //course.oldbegin();
  //version lourde qui part de la doc originelle
  //sert pour le deboguage pour s'assurer que le moteur est ok
  //a eviter
  
  course.envoyer_conf();
  course.avancer();
  
  while(1);
   
  
}
