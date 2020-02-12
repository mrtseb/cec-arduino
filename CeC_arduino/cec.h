/* CEC library

MIT license
written by MrT sebastien.tack@ac-caen.fr
*/
#include <SoftwareSerial.h>
#include "cec_definitions.h"
#ifndef CEC_H
#define CEC_H
#endif

#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

// Define constants.
#include "cec_definitions.h"

class CEC {
  public:
    CEC(SoftwareSerial * ss);
    void begin();
    
    void oldbegin();
    void test();
    void avancer();
    void envoyer_conf();
    void lire_information();
    void configure_longueur_piste(unsigned int piste);
    void configure_longueur_damier(byte damier);
    void configure_roue(unsigned int diametre);
    byte longueur_piste_MSB;
    byte longueur_piste_LSB;
    byte roue_MSB;
    byte roue_LSB;
    byte longueur_piste;
    byte longueur_damier;
    byte config_vehicule;
    byte config_course;
    
    byte periodicite_mesures;
    
    byte couleurD;
    byte couleur1;
    byte couleur2;
    byte couleurF;
    
    byte duree_MSB;
    byte duree_LSB;
    byte vmin_MSB;
    byte vmin_LSB;
    byte vmax_MSB;
    byte vmax_LSB;
    byte vzone1_MSB;
    byte vzone1_LSB;
    byte tzone1_MSB;
    byte tzone1_LSB;
    int octets_sortie;
   
  private:
    SoftwareSerial * txrx;
    
 
   
      

};
