unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ElSounds,
  StdCtrls, slider, ExtCtrls, MPegDefs, ComCtrls, Db, DBTables
{$IFDEF WMAMP}
  , WMADefs
{$ENDIF}
  ;

type
  TPlayForm = class(TForm)
    OpenBtn: TButton;
    Slider: TSlider;
    OpenDlg: TOpenDialog;
    PauseBtn: TButton;
    StopBtn: TButton;
    PlayBtn: TButton;
    Timer: TTimer;
    Slider1: TSlider;
    Label1: TLabel;
    AboutBtn: TButton;
    InfoBtn: TButton;
    ID3Btn: TButton;
    Slider2: TSlider;
    PlayerMan: TElPlayerMan;
    DirectXCB: TCheckBox;
    WaveCB: TCheckBox;
    SaveDlg: TSaveDialog;
    LeftVU: TProgressBar;
    RightVU: TProgressBar;
    Table1: TTable;
    procedure OpenBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PauseBtnClick(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure SliderStopTracking(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Slider1StopTracking(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure InfoBtnClick(Sender: TObject);
    procedure ID3BtnClick(Sender: TObject);
    procedure Slider2Change(Sender: TObject);
    procedure PlayerManPlayers0InputClose(Sender: TObject;
      UserData: Integer; var Success: Boolean);
    procedure PlayerManPlayers0InputOpen(Sender: TObject;
       var UserData: Integer; var CanSetPos : boolean; var Success: Boolean);
    procedure PlayerManPlayers0InputGetSize(Sender: TObject;
      UserData: Integer; var Size: Integer; var Success: Boolean);
    procedure PlayerManPlayers0InputSeek(Sender: TObject; UserData : integer; var NewPos : integer;
      SeekMode: Integer; var Success: Boolean);
    procedure PlayerManPlayers0InputRead(Sender: TObject;
      UserData: Integer; Buffer: Pointer; BytesToRead: Integer;
      var BytesRead: Integer; var Success: Boolean);
    procedure FormShow(Sender: TObject);
    procedure PlayerManPlayers0OutputInit(Sender: TObject;
      var Success: Boolean);
    procedure PlayerManPlayers0OutputDone(Sender: TObject;
      var Success: Boolean);
    procedure PlayerManPlayers0Output(Sender: TObject; SampleData: Pointer;
      SBits, Channels, SampleRate, Size: Integer; var success: Boolean);
    procedure DirectXCBClick(Sender: TObject);
    procedure WaveCBClick(Sender: TObject);
  private
    LeftVUValue : integer;
    RightVUValue: integer;
    LeftVUMax   : integer;
    RightVUMax  : integer;

  public
    { Public declarations }
    Count  : integer;
    Player : TElPlayer;
    procedure UpdateVU(var Msg : TMessage); message WM_USER + 123;
  end;

var
  PlayForm: TPlayForm;

implementation

{$R *.DFM}

procedure TPlayForm.OpenBtnClick(Sender: TObject);
begin
  OpenDlg.Filter := Player.ModuleName + '|' + Player.Extensions;
  if OpenDlg.Execute then
  begin
    if (Player.PlayerMode > pmClosed) then
    begin
      Timer.Enabled := false;
      Slider.Enabled := false;
      Player.Close;
    end;
    Player.InputName := OpenDlg.FileName;
    Player.BuffersCount := 4;
    Player.BufferSize := 16000;
    Player.Open;
    Player.InitStream;
  end;
end;

procedure TPlayForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Player.Deinit;
end;

procedure TPlayForm.PauseBtnClick(Sender: TObject);
begin
  if Player.Paused
     then
     begin
       Player.Resume;
       if not Player.Paused then PauseBtn.Caption := 'Pause';
     end else
     begin
       Player.Pause;
       if Player.Paused then PauseBtn.Caption := 'Resume';
     end;
end;

procedure TPlayForm.PlayBtnClick(Sender: TObject);
begin
  Slider.MaxValue := Player.Size div 1000;
  Player.Play;
  Timer.Enabled := true;
  Slider.Enabled := true;
end;

procedure TPlayForm.StopBtnClick(Sender: TObject);
begin
  StopBtn.Enabled := false;
  Player.Stop;
  StopBtn.Enabled := true;
  Player.InitStream;
  Slider.Value := 0;
  Timer.Enabled := false;
  Slider.Enabled := false;
end;

procedure TPlayForm.SliderStopTracking(Sender: TObject);
begin
  Player.Position := Slider.Value * 1000;
  Slider.Value := Player.Position div 1000;
end;

procedure TPlayForm.TimerTimer(Sender: TObject);
begin
  if Player.PlayerMode = pmStopped then
  begin
    Slider.Value := 0;
    Timer.Enabled := false;
    Slider.Enabled := false;
    Player.InitStream;
  end else
  if (Player.PlayerMode = pmPlaying) or (Player.PlayerMode = pmPaused) then  
  begin
    Slider.Value := Player.Position div 1000;
    Slider2.Value := (Player.LeftVolume + Player.RightVolume) div 2;
  end;
end;

procedure TPlayForm.Slider1StopTracking(Sender: TObject);
var x : integer;
begin
  x := Slider1.Value;
  Player.Priority := ThreadPriorities[Slider1.Value];
  Slider1.Value := x;
end;

procedure TPlayForm.AboutBtnClick(Sender: TObject);
begin
  MessageDlg(Player.About, mtInformation, [mbOk], 0);
end;

procedure TPlayForm.InfoBtnClick(Sender: TObject);
var i : integer;
    p : Pointer;
    Layer,
    Bitrate,
    Frequency : integer;
    StereoMode : TElSStereoMode;
const stereomodes : array[TElSStereoMode] of string = ('Stereo', 'Joint Stereo', 'Dual Channel', 'Mono');
begin
  if player.Version div 100 = 1 then
  begin
    Player.GetInfo1(nil, i);
    inc(i);
    GetMem(P, i);
    if Player.GetInfo1(P, i) then
    begin
      MPegDefs.DecodeMPEGInfo1(p, Layer, Bitrate, Frequency, StereoMode);
      MessageDlg(Format('Stream info:'#13#10'Layer: %d'#13#10'Bitrate: %d'#13#10'Frequency: %d'#13#10'StereoMode: %s', [Layer, Bitrate, Frequency, StereoModes[StereoMode]]), mtInformation, [mbOk], 0);
    end else
    begin
      MessageDlg('Failed to get stream info', mtError, [mbOk], 0);
    end;
  end
{$IFDEF WMAMP}
  else
  if player.Version div 100 = 2 then
  begin
    Player.GetInfo1(nil, i);
    inc(i);
    GetMem(P, i);
    if Player.GetInfo1(P, i) then
    begin
      WMADefs.DecodeWMAInfo1(P, Bitrate, Frequency, StereoMode);
      MessageDlg(Format('Stream info:'#13#10'Bitrate: %d'#13#10'Frequency: %d'#13#10'StereoMode: %s', [Bitrate, Frequency, StereoModes[StereoMode]]), mtInformation, [mbOk], 0);
    end else
    begin
      MessageDlg('Failed to get stream info', mtError, [mbOk], 0);
    end;
  end;
{$ENDIF}
end;

procedure TPlayForm.ID3BtnClick(Sender: TObject);
var p : pointer;
    genre : byte;
    Title,
    Artist,
    Album,
    Year,
{$IFDEF WMAMP}
    CopyrightS,
    GenreS,
{$ENDIF}
    Comment : string;
begin
  if player.Version div 100 = 1 then
  begin
    p := Player.GetInfo2;
    if Assigned(p) then
    begin
      MPegDefs.DecodeMPEGInfo2(p, title, Artist, Album, Year, Comment, Genre);
      MessageDlg(Format('Stream ID3 info:'#13#10'Title: %s'#13#10'Artist: %s'#13#10'Album: %s'#13#10'Year: %s'#13#10'Comment: %s', [title, Artist, Album, Year, Comment]), mtInformation, [mbOk], 0);
    end else
    begin
      MessageDlg('Failed to get stream ID3 info', mtError, [mbOk], 0);
    end;
  end
{$IFDEF WMAMP}
  else
  if player.Version div 100 = 2 then
  begin
    p := Player.GetInfo2;
    if Assigned(p) then
    begin
      WMADefs.DecodeWMAInfo2(p, title, Artist, Album, CopyRightS, Comment, GenreS, Year);
      MessageDlg(Format('Stream main tags info:'#13#10'Title: %s'#13#10'Artist: %s'#13#10'Album: %s'#13#10'Year: %s'#13#10'Comment: %s', [title, Artist, Album, Year, Comment]), mtInformation, [mbOk], 0);
    end else
    begin
      MessageDlg('Failed to get stream ID3 info', mtError, [mbOk], 0);
    end;
  end;
{$ENDIF}
end;

procedure TPlayForm.Slider2Change(Sender: TObject);
begin
  Player.LeftVolume  := Slider2.Value;
  Player.RightVolume := Slider2.Value;
end;

procedure TPlayForm.PlayerManPlayers0InputClose(Sender: TObject;
  UserData: Integer; var Success: Boolean);
begin
  If (TObject(UserData) is TFileStream) then TFileStream(UserData).Free;
end;               

procedure TPlayForm.PlayerManPlayers0InputOpen;
var Stream : TFileStream;
begin
  try
    Stream := TFileStream.Create(Player.InputName, fmOpenRead or fmShareDenyWrite);
    UserData := Integer(Stream);
    CanSetPos := true;
    Success := true;
  except
    Success := false;
  end;
end;

procedure TPlayForm.PlayerManPlayers0InputGetSize(Sender: TObject;
  UserData: Integer; var Size: Integer; var Success: Boolean);
begin
  if (TObject(UserData) is TFileStream) then
  begin
    Size := TFileStream(UserData).Size;
    Success := true;
  end else Success := false;
end;
                              
procedure TPlayForm.PlayerManPlayers0InputSeek;
var Poss: integer;
begin
  if (TObject(UserData) is TFileStream) then
  begin
    try
      if SeekMode = soFromBeginning
         then Poss := NewPos
         else Poss := TFileStream(UserData).Size + NewPos;
      NewPos := TFileStream(UserData).Seek(NewPos, SeekMode);
      Success := NewPos = Poss;
    except
      Success := false;
    end;
  end else Success := false;
end;

procedure TPlayForm.PlayerManPlayers0InputRead(Sender: TObject;
  UserData: Integer; Buffer: Pointer; BytesToRead: Integer;
  var BytesRead: Integer; var Success: Boolean);
var P : PChar;
begin
  if (TObject(UserData) is TFileStream) then
  begin
    P := PChar(Buffer);
    try
      BytesRead := TFileStream(UserData).Read(P^, BytesToRead);
      Success   := true;
    except
      Success := false;
    end;
  end else Success := false;
end;

procedure TPlayForm.FormShow(Sender: TObject);
begin
  Player := PlayerMan.Players[0];
{$IFDEF WMAMP}
  Player.PathToDLL := 'd:\wmamp.esp';
{$ENDIF}
  //Player.PathToDLL := 'D:\Programming\MP3\MPegDLL_\elamp.esp';
  Player.Init;
  Slider2.Value := (Player.LeftVolume + Player.RightVolume) div 2;
end;

procedure TPlayForm.UpdateVU(var Msg : TMessage);
begin
  LeftVU.Max := LeftVUMax;
  RightVU.Max := RightVUMax;
  LeftVU.Position := LeftVUValue;
  RightVU.Position := RightVUValue;
end;

procedure TPlayForm.PlayerManPlayers0OutputInit(Sender: TObject;
  var Success: Boolean);
begin
  LeftVUValue := 0;
  RightVUValue := 0;
  Count := 0;
  PostMessage(Handle, WM_USER + 123, 0, 0);
  Success := true;
end;

procedure TPlayForm.PlayerManPlayers0OutputDone(Sender: TObject;
  var Success: Boolean);
begin
  LeftVUValue := 0;
  RightVUValue := 0;
  Count := 0;
  PostMessage(Handle, WM_USER + 123, 0, 0);
  Success := true;
end;

procedure TPlayForm.PlayerManPlayers0Output(Sender: TObject;
  SampleData: Pointer; SBits, Channels, SampleRate, Size: Integer;
  var success: Boolean);

type PWordArray = ^TWordArray;
     TWordArray = array [0 .. MaxInt div 2 - 4] of word;
     PByteArray = ^TByteArray;
     TByteArray = array [0 .. MaxInt - 2] of Byte;

var i, j, la, ra, lm, rm : integer;
    pb : PByteArray;
    pw : PWordArray;

begin
  inc(Count);
  if (Count mod 2 <> 0) then exit;
  j := Trunc(size / Channels);

  if SBits = 16 then
  begin
    j := j div 2;
    LeftVUMax := 65535;
    RightVUMax := 65535;
    pw := PWordArray(SampleData);
  end else
  begin
    LeftVUMax := 255;
    RightVUMax := 255;
    pb := PByteArray(SampleData);
  end;
  lm := 0; rm := 0;
  la := 0; ra := 0;
  i := 0;
  while i < j do
  begin
    if SBits = 16 then
    begin
      if Channels = 2 then
      begin
        la := la + pw^[i];
        ra := ra + pw^[i + 1];
        if lm < pw^[i] then lm := pw^[i];
        if rm < pw^[i + 1] then rm := pw^[i + 1];
        inc(i, 2);
      end else
      begin
        if lm < pw^[i] then lm := pw^[i];
        la := la + pw^[i];
        rm := lm;
        ra := la;
        inc(i);
      end;
    end else
    begin
      if Channels = 2 then
      begin
        la := la + pb^[i];
        ra := ra + pb^[i + 1];

        if lm < pb^[i] then lm := pb^[i];
        if rm < pb^[i + 1] then rm := pb^[i + 1];
        inc(i, 2);
      end else
      begin
        la := la + pb^[i];
        if lm < pb^[i] then lm := pb^[i];
        rm := lm;
        ra := la;
        inc(i);
      end;
    end;
  end;
  la := la div j;
  ra := ra div j;
  lm := (lm - la);
  rm := (rm - ra);
  LeftVUValue := lm;
  RightVUValue := rm;
  PostMessage(Handle, WM_USER + 123, 0, 0);
  Success := true;
end;

procedure TPlayForm.DirectXCBClick(Sender: TObject);
begin
  if DirectXCB.Checked then
  begin
    try
      Player.OutputMode := omDirectSound;
    except
      begin
        DirectXCB.Checked := false;
        raise;
      end;
    end;
  end else Player.OutputMode := omMMSystem;
end;

procedure TPlayForm.WaveCBClick(Sender: TObject);
begin
  Player.OutputMode := omMMSystem;
  if WaveCB.Checked then
  begin
    if SaveDlg.Execute then
    begin
      Player.OutputName := SaveDlg.FileName;
      Player.OutputMode := omFile;
    end;
  end;
end;

end.

