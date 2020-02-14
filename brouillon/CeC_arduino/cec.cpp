/* CEC library

MIT license
written by MrT sebastien.tack@ac-caen.fr
*/
#include "cec.h"

CEC::CEC(SoftwareSerial * ss) {
  
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


void CEC::lire_mesures(){

  txrx->flush();
  
   byte tab_mesure[] = {
     IDCARD_NO_CRC,DEBUT_TRAME,ZERO,1,CMD_MESURE, ZERO, ZERO, FIN_TRAME    
   };

   
   for (int i=0; i<=sizeof(tab_mesure); i++)
   {     
      txrx->write(tab_mesure[i]);
               
   }
   delay(10);

   while (txrx->available())
    {
      
      byte c = txrx->read();
      Serial.println(c,HEX);
     
  
    }
    
  
}
void CEC::test(){
  
  //txrx->flush();
  
   byte tab_test[] = {
     IDCARD_NO_CRC,DEBUT_TRAME,ZERO,2,CMD_TEST,CMD_TEST_1, ZERO, ZERO, FIN_TRAME    
   };

   byte tab_test2[] = {
     IDCARD_NO_CRC,DEBUT_TRAME,ZERO,2,CMD_TEST,CMD_TEST_2, ZERO, ZERO, FIN_TRAME    
   };
   
   for (int i=0; i<=sizeof(tab_test); i++)
   {     
      txrx->write(tab_test[i]);
      //Serial.println(tab_test[i],HEX);         
   }
   
   if (txrx->available()) {
     byte c = caractere_suivant();
     //Serial.println(c,HEX);    
   }
      
   for (int i=0; i<=sizeof(tab_test2); i++)
   {     
      txrx->write(tab_test2[i]);
      //Serial.println(tab_test2[i],HEX);         
   }
   delay(10);
   /*
   while (txrx->available()) {
     byte c = caractere_suivant();
     Serial.println(c,HEX);    
   }*/
    
 
    int montest = decode_trame("--TEST--",62);
        
    if (montest == 3) {
      Serial.println("Test ok");
      /*
      N° octet  Nom du paramétres Description Format  Unité Plage
      0 Format "test" Numéro de format de la trame réponse  hex NA  NA
      1 - 2 Tension   Tension batterie  hex mV  NA
      3 - 8 Adresse MAC Wifi  Adresse MAC Wifi  hex NA  NA
      9 - 14  Adresse MAC Bluetooth Adresse MAC Bluetooth hex NA  NA
      15  ID accelerometre ADXL344    hex NA  NA
      16  Etat EEPROM   hex 0 ou 1  NA
      17 - 24 Reservé   NA  NA  NA
      25  Etat I/O Expander   hex 0 ou 1  NA
      26  ID accelerometre LSM9D    hex NA  NA
      27 - 30 Version HW et SW ATtiny   hex NA  NA
      31 - 38 Reservé   NA  NA  NA
      39 - 40 Capteur temperature   hex diziéme de °C NA
      41 - 42 Courant actuel    hex mA  NA
      43 - 46 Version STM32   NA  NA  NA
      47  Etat moteur   hex 0 ou 1  NA

      */
       Serial.print("MAC Wifi: ");Serial.print(trame[4],HEX);
       Serial.print(":");Serial.print(trame[5],HEX);
       Serial.print(":");Serial.print(trame[6],HEX);
       Serial.print(":");Serial.print(trame[7],HEX);
       Serial.print(":");Serial.print(trame[8],HEX);
       Serial.print(":");Serial.print(trame[9],HEX);
       Serial.println();
       Serial.print("MAC Bluetooth: ");Serial.print(trame[10],HEX);
       Serial.print(":");Serial.print(trame[11],HEX);
       Serial.print(":");Serial.print(trame[12],HEX);
       Serial.print(":");Serial.print(trame[13],HEX);
       Serial.print(":");Serial.print(trame[14],HEX);
       Serial.print(":");Serial.print(trame[15],HEX);
       Serial.println();
       float millisV = (long)(trame[2]*256 + trame[3])/1000.0;
       Serial.println("Tension: "+String(millisV));
       float temp = (long)(trame[40]*256 + trame[41])/10.0;
       Serial.println("Temp: "+String(temp));
    
    }
 
}

byte CEC::caractere_suivant(bool debug=false){
      int c = txrx->read(); 
      if (debug) {
        Serial.println(byte(c),HEX);
      }
      return((byte) c);
}

int CEC::decode_trame(String s, int n, bool debug=false){
   //recevoir la reponse
   //recoit N octets
   byte c,d;
   int passe = 0;
   Serial.println(s);
   if (txrx->available() > n)
    {
      //recevoir entete
        c = caractere_suivant(debug);
        if (c==IDCARD_CRC or c==IDCARD_NO_CRC) {
           passe = 1;
           
           c = caractere_suivant(debug);
           if (c==DEBUT_TRAME) {
             passe = 2;
             
             c = caractere_suivant(debug);
             d = caractere_suivant(debug);
             nb_octets = (int)((c*256) + d);
             Serial.println("TRAME:"+String(nb_octets)+" OCTETS");
             
             for (int i=0; i<=nb_octets-1; i++){
               
               c = caractere_suivant(debug);
               trame[i] = c;
             
             }
             //lecture CRC
             c = caractere_suivant(debug); c = caractere_suivant(debug);
             
             c = caractere_suivant(debug);
             if (c == FIN_TRAME) {
               passe = 3; 
             }
             
           }
         }
     }
     return passe;  
}

void CEC::lire_information(){

   byte c,d;
   
   txrx->flush();

   byte tab_lire_conf[] = {
     IDCARD_NO_CRC,DEBUT_TRAME,ZERO,OCTETS_LIRE_CONF,CMD_GET_INFO,ZERO, ZERO, FIN_TRAME    
   };
   
   for (int i=0; i<=sizeof(tab_lire_conf); i++)
   {     
      txrx->write(tab_lire_conf[i]);
      //Serial.println(tab_lire_conf[i],OCT);         
   }
   delay(10);
   int montest;
    montest = decode_trame("--CONF--",30);
    //teste la trame et affecte les variables trame[] et nb_octets
    
    
     
    if (montest == 3) {
       //la reception est ok a ce stade
       //a faire creer des variables pour memoriser toutes ces infos
       
       Serial.println("Version HW - Carte mere:"+String(trame[1])+"."+String(trame[2]));
       Serial.println("Version SW - Carte mere:"+String(trame[3])+"."+String(trame[4]));
       Serial.println("Version HW - Carte capteur:"+String(trame[9])+"."+String(trame[10]));
       Serial.println("Version SW - Carte capteur:"+String(trame[11])+"."+String(trame[12]));
       Serial.println("Version trame:"+String(trame[13]));
       Serial.print("Heure "+String(trame[14]));
       Serial.print(":"+String(trame[15]));
       Serial.print(":"+String(trame[16]));
       long millis = (long)(trame[17]*256 + trame[18]);
       Serial.println("."+String(millis));
       Serial.println("Etat des connexions:"+String(trame[19]));
       Serial.println("Etat des connexions extérieures:"+String(trame[20]));
       float millisV = (long)(trame[21]*256 + trame[22])/1000;
       Serial.println("Tension: "+String(millisV)+" Volts");
       Serial.println("Erreur: "+String(trame[23]));
       
       //for (int i=0; i<nb_octets; i++){
          //Serial.println(trame[i],HEX);
       //}
       
    }
   
   
    
    
    
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
