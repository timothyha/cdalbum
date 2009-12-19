unit WMADefs;

interface

uses ElSounds;

procedure DecodeWMAInfo1(Info : pointer; var Bitrate : integer; var Frequency : integer; var StereoMode : TElSStereoMode);

procedure DecodeWMAInfo2(Info : Pointer; var Title, Artist, Album, Copyright, Comment, Genre, Year : string);

implementation

uses SysUtils;

type TWMAInfo1 = record
        channels,
        bitrate,
        frequency,
        AudioBits : integer; // wBitsPerSample
     end;
     PWMAInfo1 = ^TWMAInfo1;

type PWMAInfo2 = ^TWMAInfo2;
     TWMAInfo2 = record
       Title,
       Artist,
       Album,
       Copyright,
       Comment,
       Genre,
       Year : array[0..512] of char;
     end;


procedure DecodeWMAInfo1(Info : pointer; var Bitrate : integer;
                          var Frequency : integer; var StereoMode : TElSStereoMode);
begin
  Bitrate := PWMAInfo1(Info).bitrate;
  Frequency := PWMAInfo1(Info).Frequency;
  if PWMAInfo1(Info).Channels = 1 then StereoMode := MPG_MD_MONO else StereoMode := MPG_MD_STEREO;
end;

procedure DecodeWMAInfo2(Info : Pointer; var Title, Artist, Album, Copyright, Comment, Genre, Year : string);
var P : PWMAInfo2;
begin
  P := PWMAInfo2(Info);
  Title := StrPas(P.Title);
  Artist := Strpas(P.Artist);
  Album := StrPas(P.Album);
  Copyright := Strpas(P.CopyRight);
  Comment := Strpas(P.Comment);
  Genre := StrPas(P.Genre);
  Year := StrPas(P.Year);
end;

end.

