unit cec_crc;

{$mode objfpc}{$H+}

interface

const

ZERO              = $00;
OCTETS_CONFIG      =69 ;
OCTETS_LIRE_CONF  = 1 ;
IDCARD_NO_CRC     = $A4;
IDCARD_CRC        = $A3;
DEBUT_TRAME       = $02;
FIN_TRAME         = $03;
CMD_ACTION        = $30;
CMD_CONFIG        = $21;
DENTS_PIGNON1     = $0C;
DENTS_PIGNON2     = $22;
CMD_GET_INFO      = 16 ;
CMD_TEST          = $50;
CMD_TEST_1        = $01;
CMD_TEST_2        = $02;
CMD_MOUVEMENT     = $30;
CMD_MESURE        = $40;
CMD_LAST_MESURE   = $41;
CMD_BILAN         = $42;

procedure CRC_init();
procedure CRC_Calc(ucOctet: byte );
function VerifCRC(Trame: array of byte):boolean;



      {
    public bool VerifCRC(byte[] TrameRecu) ==> fonction permettant la verification de la trame reçu
    {

    }

      11
}


implementation


uses
  Classes, SysUtils;

const




   auchCRCHi : array[0..255] of byte = (
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
          $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40 );

auchCRCLo: array[0..255] of byte  = (
           $00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06, $07, $C7, $05, $C5, $C4, $04,
           $CC, $0C, $0D, $CD, $0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09, $08, $C8,
           $D8, $18, $19, $D9, $1B, $DB, $DA, $1A, $1E, $DE, $DF, $1F, $DD, $1D, $1C, $DC,
           $14, $D4, $D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3, $11, $D1, $D0, $10,
           $F0, $30, $31, $F1, $33, $F3, $F2, $32, $36, $F6, $F7, $37, $F5, $35, $34, $F4,
           $3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A, $3B, $FB, $39, $F9, $F8, $38,
           $28, $E8, $E9, $29, $EB, $2B, $2A, $EA, $EE, $2E, $2F, $EF, $2D, $ED, $EC, $2C,
           $E4, $24, $25, $E5, $27, $E7, $E6, $26, $22, $E2, $E3, $23, $E1, $21, $20, $E0,
           $A0, $60, $61, $A1, $63, $A3, $A2, $62, $66, $A6, $A7, $67, $A5, $65, $64, $A4,
           $6C, $AC, $AD, $6D, $AF, $6F, $6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68,
           $78, $B8, $B9, $79, $BB, $7B, $7A, $BA, $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C,
           $B4, $74, $75, $B5, $77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71, $70, $B0,
           $50, $90, $91, $51, $93, $53, $52, $92, $96, $56, $57, $97, $55, $95, $94, $54,
           $9C, $5C, $5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B, $99, $59, $58, $98,
           $88, $48, $49, $89, $4B, $8B, $8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
           $44, $84, $85, $45, $87, $47, $46, $86, $82, $42, $43, $83, $41, $81, $80, $40 );

var

  ucCrcHigh, ucCrcLow: byte;

  procedure CRC_init();
begin
  ucCrcHigh := $FF;
  ucCrcLow := $FF;
end;

  function VerifCRC(Trame: array of byte):boolean;
  var OKpass: boolean;
    i:integer;
      bt,ucCrcHighRecu,ucCrcLowRecu:byte;
     TrameRecue: Tlist;
     p :  ^byte;
  begin
        OKPass := false;

        TrameRecue:=Tlist.create;

        for i:=0 to length(Trame)-1 do begin
            new(p);
            p^ := Trame[i];
            TrameRecue.Add(p);
        end;
        p:= TrameRecue[TrameRecue.Count - 3];
        ucCrcHighRecu := p^;
        p:= TrameRecue[TrameRecue.Count - 2];
        ucCrcLowRecu := p^;


        CRC_Init();
        CRC_Calc(Trame[2]);
        CRC_Calc(byte(Trame[3] and $ff));

        for i:=0 to length(Trame)-4 do begin
            p:=TrameRecue[i];
            CRC_Calc(p^);

        end;


        if(ucCrcHigh = ucCrcHighRecu) and (ucCrcLow = ucCrcLowRecu) then
            OKPass := true
        else
            OKPass := false;


        result:= OKPass;
  end;

procedure CRC_Calc(ucOctet: byte );

var ucIndex:byte;

begin
        ucIndex := byte(ucCrcHigh xor ucOctet);
        ucCrcHigh := byte(ucCrcLow xor auchCRCHi[ucIndex]);
        ucCrcLow := auchCRCLo[ucIndex];
end;



end.

