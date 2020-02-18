unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Spin, SdpoSerial, cec_crc;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    chkEtalonne: TCheckBox;
    cmbPorts: TComboBox;
    infos: TMemo;
    debug: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    lblConf: TLabel;
    lblConf1: TLabel;
    lblConf10: TLabel;
    lblConf11: TLabel;
    lblConf12: TLabel;
    lblConf2: TLabel;
    lblConf3: TLabel;
    lblConf4: TLabel;
    lblConf5: TLabel;
    lblConf6: TLabel;
    lblConf7: TLabel;
    lblConf8: TLabel;
    lblConf9: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    pg_batt: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    spinDuree: TSpinEdit;
    spinDents1: TSpinEdit;
    spinDents2: TSpinEdit;
    spinDiam: TSpinEdit;
    spinN0: TSpinEdit;
    spinVmax: TSpinEdit;
    spinPiste: TSpinEdit;
    spinDamier: TSpinEdit;
    spinVmin: TSpinEdit;
    test: TMemo;
    lblOctets: TLabel;
    serial: TSdpoSerial;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure chkEtalonneChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lblConf3Click(Sender: TObject);
    procedure serialRxData(Sender: TObject);
  private
    config_vehicule,config_course:byte;
    crc1,crc2:byte;
    //en ms
    periodicites_mesures:byte;
    octets, passe: integer;
    trame: array[0..127] of byte;
    procedure traiter_trame;
    procedure traiter_infos;
    procedure traiter_test;
  public

  end;
const
  battMax = 12025;
  battMin = 10000;


var
  Form1: TForm1;

implementation
 uses registry;
{$R *.lfm}

{ TForm1 }

function lire_com:Tstrings;
var
  reg: TRegistry;
  t:Tstringlist;
  st:Tstrings;

  i: Integer;
begin
  reg := TRegistry.Create;
  t:=Tstringlist.create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.OpenKeyReadOnly('hardware\devicemap\serialcomm');
    lire_com := TstringList.Create;
    st := TstringList.Create;

    try
      reg.GetValueNames(st);
      for i := 0 to st.Count - 1 do
        t.Add(reg.Readstring(st.strings[i]));
    finally
      st.Free;
      lire_com:=t;
    end;
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;


procedure TForm1.SerialRxData(Sender: TObject);
var a,b : byte;
    i:integer;
    flux:String;
begin

  flux := '';
  b :=  Serial.SynSer.RecvByte(500);

  case b of
  IDCARD_CRC:
        begin
          if passe = 0 then begin passe:=1; end;


        end;
  IDCARD_NO_CRC:
       begin
         if passe = 0 then begin passe:=1; end;

       end;
  DEBUT_TRAME:
       begin
         if passe = 1 then begin
         passe:=2;
         a :=  Serial.SynSer.RecvByte(500);
         b :=  Serial.SynSer.RecvByte(500);
         self.octets:=(a*256+b)+3;
         lblOctets.caption:='Octets: '+inttostr(self.octets-3);
         for i:=0 to self.octets-1 do begin
              trame[i]:=Serial.SynSer.RecvByte(500);
              debug.lines.add(inttoHex(trame[i],2));

          end;
        end;
      end;

  end;
  if (passe = 2) and (trame[self.octets-1]=FIN_TRAME) then begin
       //self.Caption:='trame ok';
       self.crc1:=trame[self.octets-3];
       self.crc2:=trame[self.octets-2];
       self.octets := self.octets -3;
       traiter_trame;
  end;

end;



procedure Tform1.traiter_test;
var batt_mv: real;
    batt_percent:integer;
begin

  self.test.clear;
  self.test.lines.add('Format test : '+inttostr(trame[1]));
  batt_mv:=(trame[2]*256+trame[3]);
  self.test.lines.add('Tension batterie: '+floattostr(batt_mv/1000.0));
  batt_percent:=round(100.0*((batt_mv - battMin) / (battMax - battMin)));
  if (batt_percent < 0) then batt_percent := 0 ;
  if (batt_percent > 100) then batt_percent := 100 ;
  self.pg_batt.Position:=batt_percent;
  self.test.lines.add('Batterie %: '+floattostr(batt_percent));
  self.test.lines.add('@MAC WIFI : '+inttohex(trame[4],2)+':'+inttohex(trame[5],2)+':'+inttohex(trame[6],2)+':'+inttohex(trame[7],2)+':'+inttohex(trame[8],2)+':'+inttohex(trame[9],2));
  self.test.lines.add('@MAC BLUET : '+inttohex(trame[10],2)+':'+inttohex(trame[11],2)+':'+inttohex(trame[12],2)+':'+inttohex(trame[13],2)+':'+inttohex(trame[14],2)+':'+inttohex(trame[15],2));
  self.test.lines.add('ID ADXL 344 : '+inttostr(trame[16]));
  self.test.lines.add('EEPROM : '+inttostr(trame[17]));
  self.test.lines.add('I/O Expander : '+inttostr(trame[26]));
  self.test.lines.add('ID LSM9D : '+inttostr(trame[27]));
  self.test.lines.add('HW - ATTiny: '+inttostr(trame[28])+'.'+inttostr(trame[29]));
  self.test.lines.add('SW - ATTiny: '+inttostr(trame[29])+'.'+inttostr(trame[30]));
  self.test.lines.add('Temp degC : '+floattostr((256*trame[40]+trame[41])/10.0));
  self.test.lines.add('Courant mA : '+floattostr((256*trame[42]+trame[43])/1000.0));
  self.test.lines.add('Moteur : '+inttostr(trame[48]));

end;

procedure Tform1.traiter_infos;
var batt_mv: real;
    batt_percent:integer;
begin

  //
  self.infos.clear;
  self.infos.lines.add('Version HW - Carte mere: '+inttostr(trame[1])+'.'+inttostr(trame[2]));
  self.infos.lines.add('Version SW - Carte mere: '+inttostr(trame[3])+'.'+inttostr(trame[4]));
  self.infos.lines.add('Version HW - Carte moteur: '+inttostr(trame[5])+'.'+inttostr(trame[6]));
  self.infos.lines.add('Version SW - Carte moteur: '+inttostr(trame[7])+'.'+inttostr(trame[8]));
  self.infos.lines.add('Version HW - Carte capteur: '+inttostr(trame[9])+'.'+inttostr(trame[10]));
  self.infos.lines.add('Version SW - Carte capteur: '+inttostr(trame[11])+'.'+inttostr(trame[12]));
  self.infos.lines.add('Version trame: '+inttostr(trame[13]));
  self.infos.lines.add('Horloge: '+inttostr(trame[14])+':'+inttostr(trame[15])+':'+inttostr(trame[16])+' et '+inttostr(trame[17]*256+trame[18])+' ms');
  self.infos.lines.add('Connexion système: '+inttostr(trame[19]));
  self.infos.lines.add('Connexion extérieur: '+inttostr(trame[20]));
  batt_mv:=(trame[21]*256+trame[22]);
  self.infos.lines.add('Tension batterie: '+floattostr(batt_mv));
  batt_percent:=round(100.0*((batt_mv - battMin) / (battMax - battMin)));
  if (batt_percent < 0) then batt_percent := 0 ;
  if (batt_percent > 100) then batt_percent := 100 ;
  self.pg_batt.Position:=batt_percent;
  self.infos.lines.add('Batterie %: '+floattostr(batt_percent));
  self.infos.lines.add('Erreur: '+inttostr(trame[23]));
end;


procedure Tform1.traiter_trame;

begin
  case  trame[0]  of
        CMD_GET_INFO: traiter_infos;
        CMD_TEST: traiter_test;

  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then
        serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr(OCTETS_LIRE_CONF)+chr(CMD_GET_INFO)+chr($00)+chr($00)+chr(FIN_TRAME));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then
         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr($02)+chr(CMD_TEST)+chr($01)+chr($00)+chr($00)+chr(FIN_TRAME));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then
         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr($02)+chr(CMD_TEST)+chr($02)+chr($00)+chr($00)+chr(FIN_TRAME));
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  serial.Close;
  serial.Active:=false;
  self.cmbPorts.text:='';
  self.cmbPorts.Items:=lire_com;
 if self.cmbPorts.Items.count>=1 then begin self.cmbPorts.ItemIndex:=self.cmbPorts.Items.count-1;  end;
 if (self.cmbPorts.Text <> '') then begin
    serial.BaudRate:=br115200;
    serial.Device:=self.cmbPorts.Text;
    serial.Open;
    serial.Active:=true;

  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var Heure, Minute, Seconde, milliSec : word;
begin

     passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

      {rappel
 0 - 1	Longueur piste	Longueur de la piste 	hex	cm	0 à 65535
2	Taille damier	Longueur du damier	hex	mm	0 à 255
3 - 4	Diamètre roue	Diamètre roue	hex	dixième mm	0 à 65535
5	Nombre de dents pignon moteur	Nombre de dents pignon moteur	hex	NA	1 à 255
6	Nombre de dents couronne axe roue	Nombre de dents couronne axe roue	hex	NA	1 à 255
7	Configuration véhicule	Voir tableau	hex	NA	0 à 255
8	Configuration course	Voir tableau	hex	NA
9	Réservé	NC
10	Périodicité des mesures	Périodicité des mesures	hex	ms	10 à 250
11	Couleur ligne de départ	Code couleur 	hex	NA
12	Couleur ligne intermédiaire N°1	Code couleur 	hex	NA
13	Couleur ligne intermédiaire N°2	Code couleur 	hex	NA
14	Couleur ligne d'arrivée	Code couleur 	hex	NA
15 - 16	Durée de la course	Temps maximum (sécurité)	hex	ms	0 à 65535
17 - 18	Vitesse moteur initial	Vitesse moteur à t0 (Pour démarrer)	hex	tr/min	0 à 65535
19 - 20	Seuil vitesse max	Correspond au max autorisé. Soit 100%	hex	cm/sec	NA
21 - 22	Vitesse vehicule zone 1	Vitesse vehicule zone 1	hex	cm/sec
23 - 24	Temps zone 1	Temps zone 1	hex	ms
25 - 26	Vitesse vehicule zone 2		hex	cm/sec
27 - 28	Temps zone 2		hex	ms
29 - 30	Vitesse vehicule zone 3		hex	cm/sec
31 -32	Temps zone 3		hex	ms
33 - 34	Vitesse vehicule zone 4		hex	cm/sec
35 - 36	Temps zone 4		hex	ms
37 - 38	Vitesse vehicule zone 5		hex	cm/sec
39 - 40	Temps zone 5		hex	ms
41 - 42	Vitesse vehicule zone 6		hex	cm/sec
43 - 44	Temps zone 6		hex	ms
45 - 46	Vitesse vehicule zone 7		hex	cm/sec
47 - 48	Temps zone 7		hex	ms
49 - 50	Vitesse vehicule zone 8		hex	cm/sec
51 - 52	Temps zone 8		hex	ms
53 - 54	Vitesse vehicule zone 9		hex	cm/sec
55 - 56	Temps zone 9		hex	ms
57 - 58	Vitesse vehicule zone 10		hex	cm/sec
59 - 60	Temps zone 10		hex	ms
61 - 62	Vitesse lente	Vitesse déplacement pour positionnement AR AV	hex	cm/sec
63	Horloge - Heures	Heure	hex	hex
64	Horloge - Minutes	Heure	hex	hex
65	Horloge - secondes	Heure	hex	hex
66 - 67	Horloge - milliseconde 	Heure	hex	hex
}






     DecodeTime(Now,Heure, Minute, Seconde, milliSec);

     if serial.Active  then
         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr(OCTETS_CONFIG)+chr(CMD_CONFIG)

         +chr(spinPiste.value and $FF00 >> 8)+chr(spinPiste.value and $00FF)
         +chr(spinDamier.value)
         +chr(spinDiam.value*10 and $FF00 >> 8)+chr(spinDiam.value*10 and $00FF)
         +chr(spinDents1.value)+chr(spinDents2.value)
         +chr(self.config_vehicule)+chr(config_course)
         +chr(ZERO)
         +chr(periodicites_mesures)
         //couleurs
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(spinDuree.value and $FF00 >> 8)+chr(spinDuree.value and $00FF)
         +chr(spinN0.value and $FF00 >> 8)+chr(spinN0.value and $00FF)
         +chr(spinVmax.value and $FF00 >> 8)+chr(spinVmax.value and $00FF)

         //zone1
         +chr($03)+chr($E8)+chr($0F)+chr($A0)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)

         +chr(spinVmin.value and $F0 >> 8)+chr(spinVmin.value and $0F)
         +chr(Heure)+chr(Minute)+chr(Seconde)
         +chr(milliSec and $F0 >> 8)+chr(milliSec and $0F)

         +chr(ZERO)+chr(ZERO)+chr(FIN_TRAME));
  //


end;

procedure TForm1.Button6Click(Sender: TObject);
begin
   passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then
         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr($01)+chr(CMD_MESURE)+chr($00)+chr($00)+chr(FIN_TRAME));
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then

         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr(13)
         +chr(CMD_MOUVEMENT)+chr(START_IMMEDIAT)
         //heure
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)+chr(ZERO)
         +chr(ZERO)+chr(ZERO)+chr(FIN_TRAME));
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  passe:=0;
     lblOctets.caption:='Octets: ...';
     debug.clear;

     if serial.Active  then
         serial.WriteData(chr(IDCARD_NO_CRC)+chr(DEBUT_TRAME)+chr(ZERO)+chr($01)+chr(CMD_LAST_MESURE)+chr($00)+chr($00)+chr(FIN_TRAME));
end;

procedure TForm1.chkEtalonneChange(Sender: TObject);
begin
  self.config_vehicule:=self.config_vehicule xor $18;
  //debug.lines.add(inttoHex(self.config_vehicule,2));
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  periodicites_mesures:=10;
  config_vehicule:=ZERO;
  config_course:=ZERO;
  self.pg_batt.Min:=0;
  self.pg_batt.Max:=100;
  self.Button4Click(sender);


end;



end.

