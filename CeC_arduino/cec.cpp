/* CEC library

MIT license
written by MrT sebastien.tack@ac-caen.fr
*/
#include "cec.h"

CEC::CEC(SoftwareSerial * ss) {
  octets_sortie = 0;
  txrx = ss;
  //piste a 20m par defaut
  configure_longueur_piste(200);
  //damier a 20m par defaut
  configure_longueur_damier(20);
  //roue a 600 dixieme de mm par defaut
  configure_roue(600);
  byte config_vehicule=ZERO;
  byte config_course=ZERO;
  byte periodicite_mesures=ZERO;
  byte couleurD=ZERO;
  byte couleur1=ZERO;
  byte couleur2=ZERO;
  byte couleurF=ZERO;
  byte duree_MSB=0x13;
  byte duree_LSB=0x88;
  byte vmin_MSB=ZERO;
  byte vmin_LSB=0x0A;
  byte vmax_MSB=0x03;
  byte vmax_LSB=0xE8;
  byte vzone1_MSB=0x03;
  byte vzone1_LSB=0xE8;
  byte tzone1_MSB=0x0F;
  byte tzone1_LSB=0xA0;
  
}
void CEC::lire_information(){

   byte tab_lire_conf[] = {
     IDCARD_NO_CRC,DEBUT_TRAME,ZERO,OCTETS_LIRE_CONF,CMD_GET_INFO,ZERO, ZERO, FIN_TRAME    
   };
   
   for (int i=0; i<=sizeof(tab_lire_conf); i++)
   {     
      txrx->write(tab_lire_conf[i]);
      Serial.println(tab_lire_conf[i],OCT);         
   }
   delay(10);
   Serial.println("---"); 
   //recevoir la reponse
   //recoit 23 octets
   if (txrx->available() > 22)
    {
      for (int i=0;i<=22;i++) {
      char c = txrx->read();
      Serial.println(c,OCT);
      }
    }
    delay(10);
    
}

void CEC::envoyer_conf(){
 
byte tab_conf[] = {
  IDCARD_NO_CRC,DEBUT_TRAME,ZERO,OCTETS_CONFIG,CMD_CONFIG,longueur_piste_MSB,longueur_piste_LSB,longueur_damier, roue_MSB,roue_LSB,DENTS_PIGNON1,DENTS_PIGNON2,
  config_vehicule,config_course,ZERO,periodicite_mesures,couleurD,ZERO,ZERO,couleurF,
  duree_MSB, duree_LSB, 
  vmin_MSB, vmin_LSB=0x0A,
  vmax_MSB=0x03,vmax_LSB=0xE8,
  vzone1_MSB=0x03,vzone1_LSB=0xE8,tzone1_MSB=0x0F,tzone1_LSB=0xA0};


for (int i=0; i<=sizeof(tab_conf); i++)
  {     
    txrx->write(tab_conf[i]);     
  }

for (int i=0; i<=42; i++)
  {
     txrx->write(ZERO);
  }
  
   txrx->write(ZERO); //crc MSB
   txrx->write(ZERO); //crc LSB
   txrx->write(FIN_TRAME); //fin de trame
    
   delay(1000);

}

void CEC::avancer(){

  //action ok :

  
  byte  HEURE = 0x00;
  byte  MINUTE = 0x00;
  byte  SECONDE = 0x00;
  byte  MILLIS_MSB = 0x00;
  byte  MILLIS_LSB = 0x00;
  byte tab_avancer[] = { IDCARD_NO_CRC,DEBUT_TRAME,ZERO,13,
  CMD_ACTION ,0x02 ,HEURE ,MINUTE ,SECONDE ,MILLIS_MSB ,MILLIS_LSB ,ZERO ,ZERO ,ZERO ,ZERO ,ZERO ,ZERO,
  ZERO,ZERO,FIN_TRAME};
  
  for (int i=0; i<sizeof(tab_avancer); i++)
  {     
      txrx->write(tab_avancer[i]);
   
  }

}

void CEC::configure_longueur_piste(unsigned int piste) {
  longueur_piste_MSB = (piste & 0xFF00) >> 8;
  longueur_piste_LSB = (piste & 0x00FF);
  
}

void CEC::configure_longueur_damier(byte damier) {
  longueur_damier = (damier & 0xFF);
}

void CEC::configure_roue(unsigned int diametre) {
  roue_MSB = (diametre & 0xFF00) >> 8;
  roue_LSB = (diametre & 0x00FF);
 

}

void CEC::begin() {
  
}

void CEC::oldbegin() {
  
 txrx->write(IDCARD_NO_CRC); //pas de crc
 txrx->write(DEBUT_TRAME); //début de trame
 txrx->write(ZERO); //nb octets de la configuration
 txrx->write(OCTETS_CONFIG);
 txrx->write(CMD_CONFIG); //commande configuration
 txrx->write(longueur_piste_MSB); //longueur piste = 20m (cm)
 txrx->write(longueur_piste_LSB);
 txrx->write(longueur_damier); //longueur damier = 10 (mm)
 txrx->write(roue_MSB); //diamètre roue = 8cm (dixième mm)
 txrx->write(roue_LSB);
 txrx->write(DENTS_PIGNON1); //nb dents pignon moteur
 txrx->write(DENTS_PIGNON2); //nb dents couronne axe roue
 txrx->write(ZERO); //config vehicule
 txrx->write(ZERO); //config course
 txrx->write(ZERO); //réservé
 txrx->write(ZERO); //périodicité des mesures
 txrx->write(ZERO); //couleur ligne départ
 txrx->write(ZERO); //couleur ligne intermédiaire 1
 txrx->write(ZERO); //couleur ligne intermédiaire 2
 txrx->write(ZERO); //couleur ligne arrivée

 txrx->write(0x13); //durée course = 5s (ms) 5000=0x1388
 txrx->write(0x88);
  
 txrx->write(ZERO); //seuil vitesse min = 10cm/s (cm/s)
 txrx->write(0x0A);
  
 txrx->write(0x03); //seuil vitesse max = 10m/s (cm/s)
 txrx->write(0xE8);
  
 txrx->write(0x03); //vitesse vehicule zone 1 = 10m/s (cm/s)
 txrx->write(0xE8);
  
 txrx->write(0x0F); //temps zone 1 = 4s (ms)
 txrx->write(0xA0);
  
  for (int i=0; i<=42; i++)
  {
     txrx->write(ZERO);
  }
  
   txrx->write(ZERO); //crc MSB
   txrx->write(ZERO); //crc LSB
   txrx->write(FIN_TRAME); //fin de trame
  
   delay(1000);
  
  //action ok :
  // txrx->println("ACTION");
  txrx->write(IDCARD_NO_CRC); //pas de crc
  txrx->write(DEBUT_TRAME); //début de trame
  txrx->write(ZERO); //nb octets de l'action
  txrx->write(13);
  txrx->write(CMD_ACTION); //commande action
  txrx->write(0x02); //actions véhicule
  txrx->write(ZERO); //heure start
  txrx->write(ZERO); //minute start
  txrx->write(ZERO); //seconde start
  txrx->write(ZERO); //milliseconde start
  txrx->write(ZERO);
  txrx->write(ZERO); //réservé
  txrx->write(ZERO);
  txrx->write(ZERO); //réservé
  txrx->write(ZERO);
  txrx->write(ZERO); //réservé
  txrx->write(ZERO);
  txrx->write(ZERO); //crc MSB
  txrx->write(ZERO); //crc LSB
  txrx->write(FIN_TRAME); //fin de trame

 
}
