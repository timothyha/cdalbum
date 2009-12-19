unit WAVDefs;

interface

uses ElSounds;

procedure DecodeWAVInfo1(Info : pointer; var BitsPerSample : integer; var Frequency : integer; var StereoMode : TElSStereoMode);

implementation

uses SysUtils;

type TWAVInfo1 = record
        channels,
        frequency,
        BPS : integer; // wBitsPerSample
     end;
     PWAVInfo1 = ^TWAVInfo1;


procedure DecodeWAVInfo1;
begin
  BitsPerSample := PWAVInfo1(Info).BPS;
  Frequency := PWAVInfo1(Info).Frequency;
  if PWAVInfo1(Info).Channels = 1 then StereoMode := MPG_MD_MONO else StereoMode := MPG_MD_STEREO;
end;

end.

