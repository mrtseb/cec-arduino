unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  SdpoSerial, cec_crc;




type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cmbPorts: TComboBox;
    infos: TMemo;
    debug: TMemo;
    Label1: TLabel;
    Panel1: TPanel;
    test: TMemo;
    lblOctets: TLabel;
    serial: TSdpoSerial;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure infosChange(Sender: TObject);
    procedure serialRxData(Sender: TObject);
  private
    crc1,crc2:byte;
    octets, passe: integer;
    trame: array[0..127] of byte;
    procedure traiter_trame;
    procedure traiter_infos;
    procedure traiter_test;
  public

  end;

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
              debug.lines.add(inttostr(trame[i]));

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

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.infosChange(Sender: TObject);
begin

end;

procedure Tform1.traiter_test;
begin
 //

  self.test.clear;
  self.test.lines.add('Format test : '+inttostr(trame[1]));
  self.test.lines.add('Tension batt : '+floattostr((256*trame[2]+trame[3])/1000.0));
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
  self.infos.lines.add('Tension batterie: '+floattostr((trame[21]*256+trame[22])/1000.0));
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

procedure TForm1.FormActivate(Sender: TObject);
begin

  self.Button4Click(sender);


end;

end.

