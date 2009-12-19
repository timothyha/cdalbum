unit MPegDefs;

interface

uses ElSounds;

procedure DecodeMPEGInfo1(Info : pointer; var Layer : integer; var Bitrate : integer;
                          var Frequency : integer; var StereoMode : TElSStereoMode);

procedure DecodeMPEGInfo2(Info : Pointer; var Title, Artist, Album, Year, Comment : string; var Genre : byte);

implementation

uses SysUtils;

type
     PMPegInfo1 = ^TMPegInfo1;
     TMPegInfo1 = record
       Astereo_mode,
       Alayer,
       Abitrate,
       Afrequency : integer;
     end;

     PMPegInfo2 = ^TMPegInfo2;
     TMPegInfo2 = record
       TagHeader : array[0..2] of char;
       Title     : array[0..29] of char;
       Artist    : array[0..29] of char;
       Album     : array[0..29] of char;
       Year      : array[0..3] of char;
       Comment   : array[0..29] of char;
       Genre     : Byte;
     end;

procedure DecodeMPEGInfo2(Info : Pointer; var Title, Artist, Album, Year, Comment : string; var Genre : byte);
var P : PChar;
begin
  P := @(PMPegInfo2(Info).Title);
  Title := Trim(StrPas(P));
  P := @(PMPegInfo2(Info).Artist);
  Artist := Trim(StrPas(P));
  P := @(PMPegInfo2(Info).Album);
  Album := Trim(StrPas(P));
  P := @(PMPegInfo2(Info).Year);
  Year := Trim(StrPas(P));
  P := @(PMPegInfo2(Info).Comment);
  Comment := Trim(StrPas(P));
  Genre := PMPegInfo2(Info).Genre;
end;

procedure DecodeMPEGInfo1(Info : pointer; var Layer : integer; var Bitrate : integer;
                          var Frequency : integer; var StereoMode : TElSStereoMode);
begin
  with PMPegInfo1(Info)^ do
  begin
    Layer := Alayer;
    StereoMode := TElSStereoMode(AStereo_Mode);
    Bitrate := ABitrate;
    Frequency := AFrequency;
  end;    // with
end;


end.

