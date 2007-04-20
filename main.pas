unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ClipBrd,
  ExtCtrls, ComCtrls, Menus, ShellAPI, Registry, Buttons,
  ToolWin, IniFiles, StdCtrls, FileCtrl, 
  BrowseDr, slider, Lang, MPlayer, mmsystem, ImgList, Htmlview;

type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    LeftPanel: TPanel;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitMenu: TMenuItem;
    TV: TTreeView;
    Splitter1: TSplitter;
    Panel2: TPanel;
    BrowserPopupMenu: TPopupMenu;
    CopyMenu: TMenuItem;
    ImageList1: TImageList;
    Timer1: TTimer;
    HelpMenu: TMenuItem;
    RefreshMenu: TMenuItem;
    ControlsMenu: TMenuItem;
    PrevMenu: TMenuItem;
    PlayMenu: TMenuItem;
    PauseMenu: TMenuItem;
    StopMenu: TMenuItem;
    NextMenu: TMenuItem;
    OpenAlbumMenu: TMenuItem;
    BrowseDir1: TBrowseDirectoryDlg;
    N2: TMenuItem;
    FontBiggerMenu: TMenuItem;
    FontSmallerMenu: TMenuItem;
    PlayModePopupMenu: TPopupMenu;
    PlayOneSongMenu: TMenuItem;
    PlayOneAlbumMenu: TMenuItem;
    PlayWholeDiscMenu: TMenuItem;
    PlayRandomMenu: TMenuItem;
    PlayOptionsMenu: TMenuItem;
    poTrackMenu: TMenuItem;
    poAlbumMenu: TMenuItem;
    poWholeDiscMenu: TMenuItem;
    poShuffleMenu: TMenuItem;
    N1: TMenuItem;
    poRepeatMenu: TMenuItem;
    DocMenu: TMenuItem;
    AboutMenu: TMenuItem;
    N3: TMenuItem;
    LocateMenu: TMenuItem;
    Panel4: TPanel;
    Slider: TSlider;
    RatingMenu: TMenuItem;
    Lang: TLanguage;
    LangMenu: TMenuItem;
    MPlayer1: TMediaPlayer;
    MainToolBar: TToolBar;
    OpenButton: TToolButton;
    LocateButton: TToolButton;
    RatingButton: TToolButton;
    ToolButton4: TToolButton;
    PrevButton: TToolButton;
    PlayButton: TToolButton;
    PauseButton: TToolButton;
    StopButton: TToolButton;
    NextButton: TToolButton;
    ToolButton10: TToolButton;
    RepeatButton: TToolButton;
    PlayModeButton: TToolButton;
    LengthPanel: TPanel;
    TimePanel: TPanel;
    ToolButton1: TToolButton;
    VolumeButton: TToolButton;
    VolumePopupMenu: TPopupMenu;
    VolumeDownMenu: TMenuItem;
    VolumeUpMenu: TMenuItem;
    Browser: THTMLViewer;
    procedure Splitter1Moved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TVChange(Sender: TObject; Node: TTreeNode);
    procedure CopyMenuClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure PrevButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure DocMenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefreshMenuClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PrevMenuClick(Sender: TObject);
    procedure PlayMenuClick(Sender: TObject);
    procedure PauseMenuClick(Sender: TObject);
    procedure StopMenuClick(Sender: TObject);
    procedure NextMenuClick(Sender: TObject);
    procedure OpenAlbumMenuClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure TVDblClick(Sender: TObject);
    procedure FontBiggerMenuClick(Sender: TObject);
    procedure FontSmallerMenuClick(Sender: TObject);
    procedure PlayModeButtonClick(Sender: TObject);
    procedure PlayOneSongMenuClick(Sender: TObject);
    procedure BrowserHotSpotClick(Sender: TObject; const SRC: String;
      var Handled: Boolean);
    procedure RepeatButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure poTrackMenuClick(Sender: TObject);
    procedure poAlbumMenuClick(Sender: TObject);
    procedure poWholeDiscMenuClick(Sender: TObject);
    procedure poShuffleMenuClick(Sender: TObject);
    procedure poRepeatMenuClick(Sender: TObject);
    procedure AboutMenuClick(Sender: TObject);
    procedure LocateButtonClick(Sender: TObject);
    procedure SliderStopTracking(Sender: TObject);
    procedure RatingButtonClick(Sender: TObject);
    procedure RatingMenuClick(Sender: TObject);
    procedure LangMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VolumeDownMenuClick(Sender: TObject);
    procedure VolumeUpMenuClick(Sender: TObject);
    procedure VolumeButtonClick(Sender: TObject);
    procedure BrowserMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    procedure PlayFile(name: string);
    procedure Initialize(path: string);
    procedure OldVersionInitialize(path: string);
    procedure LoadConfig(Beginning: boolean);
    procedure LoadRatings;
    procedure SaveConfig;
    procedure LangMenuInit;
    procedure LoadLangProperties(name: string);
    procedure TranslateAll(name: string);

    function GetNextRandomItem(previous: integer): integer;

    function ReadID3(name: string; var Title, Artist, Album, Year: string): boolean;
    function Speak(s: string): string;
    function RatingText(i: integer): string;

    procedure InstallWAVCodec;
    procedure SetVolume(i: Longint);

    function InitNode(path: string; TTNode: TTreeNode): integer; // рекурсивна€ обработка узла...
  public                            
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  ExePath, MainPath, MainURL: string;
  DefaultPage: TStrings;

  LastIndex: integer;

  PathNames: TStrings; // physical path names for albums and tracks;

  CurLength: integer; // length of currently playing file

  RandomPlay: boolean;

  IsPlaying: boolean;

  EscapePressed: boolean; // you can press ESC when PREV/NEXT buttons are cycled
  SongFound: boolean; // cycling of PREV/NEXT is during search

  UseRatings: boolean;
  MinimumRating: integer; // 1..5

  NumAlbums, NumTracks: integer;
  MainVolume, MainVolumeRatio: integer;

  LastLanguageFile: string;
  LangInitialized: boolean;

  AboutWWW, AboutEmail: string;

const // imagelist indexes
  PlayOneSong = 10;
  PlayOneAlbum =11;
  PlayAllSongs = 12;
  PlayRandom = 13;
  PlayForever = 14;
  PlayOnce = 15;

  // about --


implementation

uses rating;

{$R *.DFM}

function RotateStr(s: string): string;
var
  i: integer;
begin
  Result := '';

  for i:=1 to Length(s) do
  begin
    if (s[i] >= 'a') and (s[i] <= 'z') then
      Result := Result + Chr(Ord('a') + ((Ord(s[i]) - Ord('a') + 13) mod 26))
    else
      Result := Result + s[i];
  end;
end;

function TMainForm.RatingText(i: integer): string;
begin
  case i of
    1: Result := Speak('BadRating');
    2: Result := Speak('NotBadRating');
    4: Result := Speak('VeryGoodRating');
    5: Result := Speak('BestRating');
    else
      Result := Speak('GoodRating') + ' (' + Speak('DefaultRating') + ')';
  end;
end;

procedure TMainForm.SaveConfig;
var
  ini: TIniFile;
  i: integer;
  TTN: TTreeNode;
begin
  ini := TIniFile.Create('cd_album.ini');

  if LastLanguageFile <> '' then
    ini.WriteString('general', 'LastLanguageFile', LastLanguageFile);

  if not UseRatings then
  begin
    ini.Free;
    Exit;
  end;

  ShowMessage(Format(Speak('SavingRatings'), [NumTracks]));

  Screen.Cursor := crHourGlass;

  for i:=0 to TV.Items.Count-1 do
  begin
    TTN := TV.Items[i];
    if TTN.Level = 0 then continue;

    ini.WriteInteger('ratings',
      'ALBUM: ' + TTN.Parent.Text + ' TRACK: ' + TTN.Text,
      Integer(TTN.Data));
  end;

  Screen.Cursor := crDefault;

  ini.Free;
end;

procedure TMainForm.LoadConfig(Beginning: boolean);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create('cd_album.ini');

  LastLanguageFile := ini.ReadString('general', 'LastLanguageFile', 'english.lng');

  ini.Free;
end;

procedure TMainForm.LoadRatings;
var
  i, rating: integer;
  TTN: TTreeNode;
  ini: TIniFile;
  oldstr: string;
begin
  ini := TIniFile.Create('cd_album.ini');

  oldstr := StatusBar1.SimpleText;

  StatusBar1.SimpleText := Speak('LoadingRatings');

  Application.ProcessMessages;

  Screen.Cursor := crHourGlass;

  for i:=0 to TV.Items.Count-1 do
  begin
    TTN := TV.Items[i];

    if TTN.Level = 0 then
      TTN.Data := nil
    else begin
      rating := ini.ReadInteger('ratings',
        'ALBUM: ' + TTN.Parent.Text + ' TRACK: ' + TTN.Text, 3);

      TTN.Data := Pointer(rating);
    end;
  end;

  Screen.Cursor := crDefault;

  StatusBar1.SimpleText := oldstr;

  ini.Free;
end;

{
   The ID3 Information is stored in the last 128 bytes of an MP3 file.
   The ID3 has the following fields, and the offsets given here, are from 0-127

   Field       Length            offsets
   -------------------------------------
   Tag           3                0-2
   Songname     30                3-32
   Artist       30                33-62
   Album        30                63-92
   Year          4                93-96
   Comment      30                97-126
   Genre         1                127
}

function TMainForm.ReadID3(name: string; var Title, Artist, Album, Year: string): boolean;
var
  id3: array[0..127] of char;
  handle: integer;
begin
  Result := false;

  handle := FileOpen(name, fmOpenRead or fmShareDenyNone);
  if handle = -1 then Exit;

  FileSeek(handle, -128, 2);
  if FileRead(handle, id3, 128) <> 128 then
  begin
    FileClose(handle);
    Exit;
  end;
  FileClose(handle);

  if Copy(id3,1,3) <> 'TAG' then
  begin
    Title := Speak('tagNoInfo');
    Artist := Speak('tagNoInfo');
    Album := Speak('tagNoInfo');
    Year := Speak('tagNoInfo');
  end
  else begin
    Title:=Trim(copy(id3, 4, 30));
    Artist:=Trim(copy(id3, 34, 30));
    Album:=Trim(copy(id3, 64, 30));
    //  Comment:=Trim(copy(id3, 98, 30));
    Year:=Trim(copy(id3, 94, 4));
  end;

  Result := true;
end;

function TMainForm.GetNextRandomItem(previous: integer): integer;
var
  i: integer;
begin
  Randseed := Slider.Value + Random(Round(Now));

  i := Random(TV.Items.Count);
  if (TV.Items[i].Level = 0) or (i = previous)
  then Result := GetNextRandomItem(i) // once again
  else Result := i;
end;

procedure TMainForm.Splitter1Moved(Sender: TObject);
begin
  ActiveControl := Browser;
end;

procedure TMainForm.OldVersionInitialize(path: string);
var
  F, F1: TSearchRec;
  TTN, child: TTreeNode;
  ini: TIniFile;
  albums, tracks, i, j: integer;
  id, title, albumname, albumpath, trackname, trackpath: string;
  lastpath: string;
begin
  TV.Items.BeginUpdate;
  TV.Items.Clear;

  PathNames.Clear;

  NumAlbums := 0;
  NumTracks := 0;

  lastpath := ''; // stores last album path to support adding file paths

  if FileExists(path + 'album.ini') then
  begin
    ini := TIniFile.Create(path + 'album.ini');

    albums := ini.ReadInteger('general', 'albums', 0);
    title := ini.ReadString('general', 'name', '');

    TV.Font.CharSet := ini.ReadInteger('general', 'charset', 204);
    Browser.CharSet := TV.Font.CharSet;

    for i:=1 to albums do
    begin
      id := ini.ReadString('general', 'id' + IntToStr(i), '');

      albumname := ini.ReadString(id, 'name', '???');
      albumpath := ini.ReadString(id, 'path', '???');
      tracks := ini.ReadInteger(id, 'tracks', 0);

      TTN := TV.Items.Add(nil, albumname);
      TTN.ImageIndex := 0;
      TTN.SelectedIndex := 0;
      TTN.Data := Pointer(100);

      Inc(NumAlbums);

      lastpath := path + albumpath + '\';
      PathNames.Add(lastpath);

      for j:=1 to tracks do
      begin
        trackname := ini.ReadString(id + '_' + IntToStr(j), 'name', '???');
        trackpath := ini.ReadString(id + '_' + IntToStr(j), 'path', '???');

        child := TV.Items.AddChild(TTN, trackname);
        child.ImageIndex := 1;
        child.SelectedIndex := 1;
        child.Data := Pointer(3);

        Inc(NumTracks);

        PathNames.Add(lastpath + trackpath);
      end;
    end;

    ini.Free;
  end else
  begin
    if FindFirst(path + '*.*', faAnyFile, F) <> 0 then Exit;

    title := path;

    repeat
      if (F.Attr and faDirectory <> faDirectory) or (F.Name = '.')
         or (F.Name = '..') then continue;

      if (FindFirst(path + F.Name + '\*.mp3', faAnyFile, F1) <> 0)
      and (FindFirst(path + F.Name + '\*.wav', faAnyFile, F1) <> 0)
      and (FindFirst(path + F.Name + '\*.wma', faAnyFile, F1) <> 0)
      then continue;
      // if there is no MP3 or WAV file in directory, then skip it

      TTN := TV.Items.Add(nil, F.Name);
      TTN.ImageIndex := 0;
      TTN.SelectedIndex := 0;
      TTN.Data := Pointer(100);

      lastpath := path + F.Name + '\';
      PathNames.Add(lastpath);

      if FindFirst(path + F.Name + '\*.mp3', faAnyFile, F1) = 0 then
      begin
        repeat
          child := TV.Items.AddChild(TTN,
            Copy(F1.Name, 1, Length(F1.Name)-4)); // name without .mp3
          child.ImageIndex := 1;
          child.SelectedIndex := 1;
          child.Data := Pointer(3);

          PathNames.Add(lastpath + F1.Name);

        until FindNext(F1) <> 0;
      end;

      if FindFirst(path + F.Name + '\*.wav', faAnyFile, F1) = 0 then
      begin
        repeat
          child := TV.Items.AddChild(TTN,
            Copy(F1.Name, 1, Length(F1.Name)-4)); // name without .mp3
          child.ImageIndex := 1;
          child.SelectedIndex := 1;
          child.Data := Pointer(3);

          PathNames.Add(lastpath + F1.Name);

        until FindNext(F1) <> 0;
      end;

      if FindFirst(path + F.Name + '\*.wma', faAnyFile, F1) = 0 then
      begin
        repeat
          child := TV.Items.AddChild(TTN,
            Copy(F1.Name, 1, Length(F1.Name)-4)); // name without .wma
          child.ImageIndex := 1;
          child.SelectedIndex := 1;
          child.Data := Pointer(3);

          PathNames.Add(lastpath + F1.Name);

        until FindNext(F1) <> 0;
      end;

    until FindNext(F) <> 0;
  end;

  TV.Items.EndUpdate;

  MainForm.Caption := title + ' - CD Album 2.1';
  Application.Title := MainForm.Caption;
end;

// рекурсивна€ функци€ дл€ отрисовки узла по содержимому папки с музыкой
function TMainForm.InitNode(path: string; TTNode: TTreeNode): integer;
var
  F: TSearchRec;
  TTN, child: TTreeNode;
  ini: TIniFile;
  tracks, volume, i: integer;
  title, albumname, trackname, trackpath: string;
  lastpath: string;
  subnodecount: integer;
begin
  Result := 0;
  if FindFirst(path + '*.*', faAnyFile, F) <> 0 then Exit;

  repeat
    if (F.Name = '.') or (F.Name = '..') then continue;
    if (F.Attr and faDirectory = faDirectory) then
    begin // если папка, то делаем рекурсию...
      TTN := TV.Items.AddChild(TTNode, F.Name);
      subnodecount := InitNode(path + F.Name + '\', TTN);
      if subnodecount = 0 then
        TTN.Delete
      else
        Result := Result + subnodecount;
    end
    else // если файл, то добавл€ем в дерево
    begin
      //ShowMessage(path + ' ' + F.Name);
      TTN := TV.Items.AddChild(TTNode, F.Name);
      Inc(Result);
    end;
  until FindNext(F) <> 0; // пока есть файлы
end;

procedure TMainForm.Initialize(path: string);
var
  F: TSearchRec;
  TTN, child: TTreeNode;
  ini: TIniFile;
  tracks, volume, i: integer;
  title, albumname, trackname, trackpath: string;
  lastpath: string;
begin

//  TTN := TV.Items.Add(nil, 'root');
//  InitNode(path, TTN);
//  Exit;

  if FindFirst(path + '*.*', faAnyFile, F) <> 0 then Exit;

  if FileExists(path + 'album.ini') then
  begin
    ini := TIniFile.Create(path + 'album.ini');

    title := ini.ReadString('general', 'name', path);

    MainForm.Font.Charset := ini.ReadInteger('general', 'charset', 204);

    if ini.ReadInteger('general', 'albums', -1) > 0 then
    begin
      ini.Free;
      OldVersionInitialize(path);
      Exit;
    end;

    ini.Free;
  end
  else begin
    OldVersionInitialize(path);
    Exit;
  end;

  TV.OnChange := nil;

  TV.Items.BeginUpdate;
  TV.Items.Clear;

  PathNames.Clear;

  NumAlbums := 0;
  NumTracks := 0;

  lastpath := ''; // stores last album path to support adding file paths

  repeat
    if (F.Attr and faDirectory <> faDirectory) or (F.Name = '.')
      or (F.Name = '..') then continue;
    // we are looking only for subdirs

    if not FileExists(path + F.Name + '\album.ini')
      then continue; // not initialized album

    ini := TIniFile.Create(path + F.Name + '\album.ini');

    lastpath := path + F.Name + '\';
    PathNames.Add(lastpath);

    albumname := ini.ReadString('general', 'name', F.Name);
    volume := ini.ReadInteger('general', 'volume', 100);
    tracks := ini.ReadInteger('general', 'tracks', 0);

    TTN := TV.Items.Add(nil, albumname);
    TTN.ImageIndex := 0;
    TTN.SelectedIndex := 0;
    TTN.Data := Pointer(volume);

    Inc(NumAlbums);

    for i:=1 to tracks do
    begin
      trackname := ini.ReadString('track_' + IntToStr(i), 'name', '???');
      trackpath := ini.ReadString('track_' + IntToStr(i), 'path', '???');

      if not FileExists(lastpath + trackpath) then continue;

      Inc(NumTracks);

      child := TV.Items.AddChild(TTN, trackname);
      child.ImageIndex := 1;
      child.SelectedIndex := 1;
      child.Data := Pointer(3);

      PathNames.Add(lastpath + trackpath);
    end;

    ini.Free;

  until FindNext(F) <> 0;

  TV.Items.EndUpdate;

  if NumAlbums = 1 then TV.Items[0].Expand(false);

  TV.OnChange := TVChange;

  StatusBar1.SimpleText := Format(Speak('Statistics'), [NumTracks, NumAlbums]);

  MainForm.Caption := title + ' - CD Album 2.1';
  Application.Title := MainForm.Caption;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MPlayer1.Visible := false;
  MPlayer1.TimeFormat := tfMilliseconds;

//  Browser.Align := alClient; // hide system images;

  // this trick is a preparation for event of clicking the RESTORE/MAXIMIZE button
  with MainForm do
  begin
    Left := (Screen.Width - Width) div 2;
    Top := (Screen.Height - Height) div 2;

    WindowState := wsMaximized;
  end;

  LeftPanel.Width := (MainForm.Width * 2) div 7;

  ExePath := ExtractFilePath(Application.ExeName);
  MainPath := ExePath;
  MainURL := '';

  DefaultPage := TStringList.Create;
  PathNames := TStringList.Create;

//  Initialize(MainPath);
//  LoadConfig; // default = good

  LangInitialized := false;

  // set volume value

  SetVolume(32768);

  MainVolume := 32768;
  MainVolumeRatio := 100;

  RandomPlay := false;
  IsPlaying := false;
  EscapePressed := false;
  SongFound := true;

  UseRatings := false;
  MinimumRating := 1;

  ActivateKeyboardLayout(LoadKeyboardLayout('00000409', 0), KLF_ACTIVATE);

  Timer1.Enabled := true;

  LangMenuInit;

  AboutWWW := 'uggc://wrfhfpuevfg.eh';
  AboutEmail := 'gvzu@wrfhfpuevfg.eh';
end;

procedure TMainForm.TVChange(Sender: TObject; Node: TTreeNode);
var
  AlbumName, AlbumPath, SongPath, SongText, tmpstr: string;
  Title, Artist, Album, Year: string;
  offset, i: integer;
  TextOfSong: TStrings;
begin
  if (TV.Selected = nil) or (TV.Selected <> Node) then Exit;

  if Node.Level = 1 then begin
    AlbumName := Node.Parent.Text;
    AlbumPath := PathNames[Node.Parent.AbsoluteIndex];
  end
  else begin
    AlbumName := Node.Text;
    AlbumPath := PathNames[Node.AbsoluteIndex];
  end;

  with DefaultPage do
  begin
    Clear;
    Add('<html>');
    Add('<body background="' + ExePath + 'help\bgpaper.gif">');
    Add('<h1>' + AlbumName + '</h1>');

    if Node.Level =1 then
    begin
      Add('<h2><i>' + Node.Text + '</i></h2>');

      Title := '';
      Artist := '';
      Album := '';
      Year := '';

      SongPath := PathNames[Node.AbsoluteIndex];

      if ReadID3(SongPath, Title, Artist, Album, Year) then
      begin
        Add(Format(
        '<table border=0 cellpadding=2>' +
        '<tr><td><img width=16 height=16 src="%s"></td><td>%s</td></tr>' +
        '<tr><td><img width=16 height=16 src="%s"></td><td>%s</td></tr>' +
        '<tr><td><img width=16 height=16 src="%s"></td><td>%s</td></tr>' +
        '<tr><td>&nbsp;</td><td>%s<br>%s<br>%s<br>%s</td></tr>' +
        '</table>',
        [
        ExePath + 'help\folder.gif', AlbumPath,
        ExePath + 'help\song.gif', ExtractFileName(SongPath),
        ExePath + 'help\info.gif',
        Speak('tagInfoText'),
        Speak('tagTitleText') + ': ' + Title,
        Speak('tagArtistText') + ': ' + Artist,
        Speak('tagAlbumText') + ': ' + Album,
        Speak('tagYearText') + ': ' + Year
        ]));
      end;

      SongText := Copy(SongPath,1,Length(SongPath)-4) + '.txt';

      if FileExists(SongText) then
      begin
        TextOfSong := TStringList.Create;
        TextOfSong.LoadFromFile(SongText);
        Add('<hr><blockquote><pre>');
        for i:=0 to TextOfSong.Count-1 do
        begin
          tmpstr := TextOfSong[i];
          if Copy(Trim(tmpstr),1,50) = '--------------------------------------------------'
          then tmpstr := '  ';
          Add(tmpstr);
        end;
        Add('</pre><br><br>');
        TextOfSong.Free;
      end;
    end
    else begin
      Add('<P><img transp width=16 height=16 src="'
        + ExePath + 'help\folder.gif"> '
        + AlbumPath);
    end;
  end;

  if FileExists(AlbumPath + 'html\index.htm') then
  begin
    if MainURL <> (AlbumPath + 'html\index.htm') then
    begin
      MainURL := AlbumPath + 'html\index.htm';

      Browser.Base := AlbumPath + 'html\';
      Browser.LoadFromFile(MainURL);
    end;

    if Node.Level = 1 then
    begin
      offset := Node.AbsoluteIndex - Node.Parent.AbsoluteIndex;
      Browser.PositionTo(IntToStr(offset));
      MainURL := AlbumPath + 'html\index.htm#' + IntToStr(offset);
    end else
      Browser.Position := 0;
  end else
  begin
    Browser.LoadStrings(DefaultPage);
    MainURL := '...';
  end;

  if OpenButton.Enabled then LastIndex := Node.AbsoluteIndex; // not playing;
end;

procedure TMainForm.CopyMenuClick(Sender: TObject);
begin
  if BrowserPopupMenu.PopupComponent = Browser then
  begin
    if Browser.SelLength <> 0 then
    begin
      Clipboard.AsText := Browser.SelText;
      Browser.SelLength := 0;
    end;
  end;
end;

procedure TMainForm.PlayFile(name: string);
begin
  try
    MPlayer1.FileName := name;
    MPlayer1.Open;
    MPlayer1.Play;
  except
    ShowMessage(Format(Speak('ErrorPlayingFile'), [name]));
    StopButtonClick(Self);
    Exit;
  end;

  Slider.MaxValue := MPlayer1.Length div 1000;
  Slider.Enabled := true;

//  VolumeSlider.Value := (Player.LeftVolume + Player.RightVolume) div 2;
//  VolumePanel.Caption := IntToStr((VolumeSlider.Value * 100) div 65535) + '%';

  IsPlaying := true;

  OpenButton.Enabled := false;
  OpenAlbumMenu.Enabled := false;
end;

procedure TMainForm.PauseButtonClick(Sender: TObject);
begin
  if (MPlayer1.Mode <> mpPlaying) and (MPlayer1.Mode <> mpPaused)
  then Exit;

  if PlayButton.Enabled then // not paused
  begin
    MPlayer1.Pause;
    IsPlaying := false;
    PrevButton.Enabled := false;
    PlayButton.Enabled := false;
    StopButton.Enabled := false;
    NextButton.Enabled := false;
    RatingButton.Enabled := false;

    Slider.Enabled := false;
  end else
  begin
    MPlayer1.Resume;
    IsPlaying := true;
    PrevButton.Enabled := true;
    PlayButton.Enabled := true;
    StopButton.Enabled := true;
    NextButton.Enabled := true;
    RatingButton.Enabled := true;

    Slider.Enabled := true;
  end;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  IsPlaying := false;

  if (MPlayer1.Mode > mpNotReady) and (MPlayer1.Mode <= mpOpen) then
    MPlayer1.Stop;

  Slider.Value := 0;
  Slider.Enabled := false;

  TimePanel.Caption := '0:00';

  LocateButton.Enabled := false;
  LocateMenu.Enabled := false;

  OpenButton.Enabled := true;
  OpenAlbumMenu.Enabled := true;
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
var
  TTN: TTreeNode;
  newVolumeRatio: integer;
begin
  if TV.Selected = nil then TV.Selected := TV.Items[0];

  TTN := TV.Selected;
  LastIndex := TTN.AbsoluteIndex;

  SongFound := false;

  if UseRatings and (TTN.Level <> 0) and (Integer(TTN.Data) < MinimumRating) then
  begin
    NextButtonClick(Sender);
    Exit;
  end;

  if TTN.Level = 0 then
  begin
    TTN.Expand(false);
    NextButtonClick(Sender);
    Exit;
  end;

  StopButtonClick(Sender);

  EscapePressed := false;
  SongFound := true;

  if (MainURL = ExePath + Speak('HelpFile')) then LocateButtonClick(Sender);

  StatusBar1.SimpleText := Format(
    Speak('AlbumText') + ': %s Ч ' +
    Speak('TrackText') + ': %s Ч ' +
    Speak('RatingText') + ': %s',
    [TTN.Parent.Text, TTN.Text, RatingText(Integer(TTN.Data))]);

  newVolumeRatio := Integer(TTN.Parent.Data);

  if newVolumeRatio <> MainVolumeRatio then
  begin
    SetVolume((MainVolume * newVolumeRatio) div MainVolumeRatio);
    MainVolumeRatio := newVolumeRatio;
  end;

  PlayFile(PathNames[LastIndex]);

  LocateButton.Enabled := true;
  LocateMenu.Enabled := true;
  ActiveControl := Browser;
end;

procedure TMainForm.PrevButtonClick(Sender: TObject);
var
  TTN: TTreeNode;
begin
  if EscapePressed and (not SongFound) then
  begin
    EscapePressed := false;
    StopButtonClick(Sender);
    Exit;
  end;

  if TV.Selected = nil then Exit;

  StopButtonClick(Sender);

  TTN := TV.Selected;

  // if user clicked on something else during playback, program must return
  // to the original point
  if TTN.AbsoluteIndex <> LastIndex then
  begin
    TV.Selected := TV.Items[LastIndex];
    TTN := TV.Selected;
  end;

  if PlayModeButton.ImageIndex = PlayOneSong then
  begin
    if RepeatButton.ImageIndex <> PlayForever then
    begin
      StopButtonClick(Sender);
      Exit;
    end;

    PlayButtonClick(Sender);
  end;

  if not RandomPlay then
  begin
    repeat
      TTN := TTN.GetPrev;
      if TTN = nil then
      begin
        StopButtonClick(Sender);
        Exit; // you're on the top
      end;
    until not TTN.HasChildren; // go up to first available song

    TV.Selected := TTN;
  end
  else TV.Selected := TV.Items[GetNextRandomItem(TTN.AbsoluteIndex)];

  if UseRatings and (Integer(TV.Selected.Data) < MinimumRating) then
  begin
    LastIndex := TV.Selected.AbsoluteIndex;
    PrevButtonClick(Sender);
    Exit;
  end;

  PlayButtonClick(Sender);
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
var
  TTN: TTreeNode;
begin
  if EscapePressed and (not SongFound) then
  begin
    EscapePressed := false;
    StopButtonClick(Sender);
    Exit;
  end;

  if TV.Selected = nil then Exit;

  StopButtonClick(Sender);

  TTN := TV.Selected;

  // if user clicked on something else during playback, program must return
  // to the original point
  if TTN.AbsoluteIndex <> LastIndex then
  begin
    TV.Selected := TV.Items[LastIndex];
    TTN := TV.Selected;
  end;

  Application.ProcessMessages;

  if (TTN.Level > 0) and (PlayModeButton.ImageIndex = PlayOneSong) then
  begin
    if RepeatButton.ImageIndex <> PlayForever then Exit;

    PlayButtonClick(Sender);
    Exit;
  end;

  if not RandomPlay then
  begin
    if TTN.HasChildren then
      TTN := TTN.GetNext // go to first song...
    else begin
      if PlayModeButton.ImageIndex = PlayAllSongs then
        TTN := TTN.GetNext // play all songs
      else
        TTN := TTN.GetNextSibling; // play one album only
    end;

    if (TTN = nil) then begin
      if PlayModeButton.ImageIndex = PlayAllSongs then
      begin
        if RepeatButton.ImageIndex <> PlayForever
        then begin // this means it's the end of ALL songs
          StopButtonClick(Sender);
          Exit;
        end
        else TTN := TV.Items[0];
      end else
      begin // continuous play in ONE ALBUM
        if RepeatButton.ImageIndex <> PlayForever
        then begin
          StopButtonClick(Sender);
          Exit  // this means it's the end of ALL songs in ALBUM
        end else TTN := ((TV.Selected).Parent).Item[0];
      end;
    end;

    TV.Selected := TTN;
  end
  else TV.Selected := TV.Items[GetNextRandomItem(TTN.AbsoluteIndex)];

  PlayButtonClick(Sender);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  pos, i, len: integer;
  status: TMPModes;
begin
  status := MPlayer1.Mode;

  if status = mpPlaying then
  begin
    pos := MPlayer1.Position div 1000;
    len := MPlayer1.TrackLength[1] div 1000;

    Slider.Value := pos;

    TimePanel.Caption := Format('%d:%.2d', [pos div 60, pos mod 60]);
    LengthPanel.Caption := Format('%d:%.2d', [len div 60, len mod 60]);
  end;

  if (status = mpStopped) and IsPlaying then
  begin
    StatusBar1.SimpleText := RotateStr(AboutWWW);

    if not RandomPlay then
    begin
      if NextButton.Enabled then
        NextButtonClick(Sender)
      else begin
        PauseButtonClick(Sender); // paused at THE END of file!!! - unlock!!!
        NextButtonClick(Sender);
      end;
    end else begin
      repeat
        i := GetNextRandomItem(TV.Selected.AbsoluteIndex);
        TV.Selected := TV.Items[i];
      until (not UseRatings) or (Integer(TV.Selected.Data) >= MinimumRating);

      PlayButtonClick(Sender);
    end;
  end;
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.DocMenuClick(Sender: TObject);
var
  lines,s: TStrings;
  i: integer;
  msg: string;
begin
  MainURL := ExePath + 'help\' + Speak('HelpFile');

  if not FileExists(MainURL) then
  begin
    ShowMessage(Format(Speak('CouldNotFind'), [MainURL]));
    Exit;
  end;

  lines := TStringList.Create;
  lines.Clear;
  lines.LoadFromFile(MainURL);

  s := TStringList.Create;
  s.Clear;

  if FileExists(ExePath + 'postcard\index.htm') then
  begin
    s.LoadFromFile(ExePath + 'postcard\index.htm');

    msg := '';
    for i:=0 to s.Count-1 do msg := msg + s[i] + ' ';

    i := lines.IndexOf('<!-- greeting -->');
    if i <> -1 then lines[i] := msg;
  end;

  Browser.Base := ExePath + 'postcard\';

  Browser.LoadStrings(lines);
  ActiveControl := Browser;

  s.Free;
  lines.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopButtonClick(Sender);
  SaveConfig;
end;

procedure TMainForm.RefreshMenuClick(Sender: TObject);
begin
  Browser.Reload;
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  canMove: boolean;
begin
  canMove := PlayButton.Enabled;

  case Key of
  '+': if ActiveControl = Browser then FontBiggerMenu.Click;
  '-': if ActiveControl = Browser then FontSmallerMenu.Click;
  '/': if RatingButton.Enabled then RatingButtonClick(Sender);

  'O','o': if OpenButton.Enabled then OpenButtonClick(Sender);
  'L','l': if LocateButton.Enabled then LocateButtonClick(Sender);
  'Z','z': if canMove then PrevButtonClick(Sender);
  'X','x',#13: if canMove then PlayButtonClick(Sender);
        // SPACE and ENTER also play the songs - SPACE toggles play/pause
  ' ':     if not isPlaying then
           begin
             if canMove
             then PlayButtonClick(Sender) // start playing
             else PauseButtonClick(Sender); // resume
           end
           else PauseButtonClick(Sender); // pause
  'C','c': PauseButtonClick(Sender);
  'V','v': if canMove then StopButtonClick(Sender);
  'B','b': if canMove then NextButtonClick(Sender);

  '>' : VolumeUpMenuClick(Sender);
  '<' : VolumeDownMenuClick(Sender);

  #27: if not SongFound then EscapePressed := true;

  '1','T','t': PlayOneSongMenu.Click; // track
  '2','A','a': PlayOneAlbumMenu.Click; // album
  '3','D','d': PlayWholeDiscMenu.Click; // disc
  '4','S','s': PlayRandomMenu.Click; // shuffle
  '5','R','r': RepeatButtonClick(Sender); // repeat
  end;

  Key := #0;
end;

procedure TMainForm.PrevMenuClick(Sender: TObject);
begin
  if PlayButton.Enabled then PrevButtonClick(Sender);
end;

procedure TMainForm.PlayMenuClick(Sender: TObject);
begin
  if PlayButton.Enabled then PlayButtonClick(Sender);
end;

procedure TMainForm.PauseMenuClick(Sender: TObject);
begin
  PauseButtonClick(Sender);
end;

procedure TMainForm.StopMenuClick(Sender: TObject);
begin
  if PlayButton.Enabled then StopButtonClick(Sender);
end;

procedure TMainForm.NextMenuClick(Sender: TObject);
begin
  if PlayButton.Enabled then NextButtonClick(Sender);
end;

procedure TMainForm.OpenAlbumMenuClick(Sender: TObject);
begin
  if OpenButton.Enabled then OpenButtonClick(Sender);
end;

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  BrowseDir1.Caption := Speak('BrowseDirCaption');
  BrowseDir1.Title := Speak('BrowseDirTitle');

  BrowseDir1.Selection := MainPath;

  if BrowseDir1.Execute then
  begin
    MainPath := BrowseDir1.Selection;
    if MainPath[Length(MainPath)] <> '\' then
      MainPath := MainPath + '\';
    Initialize(MainPath);

    TV.Selected := TV.Items[0];
    ActiveControl := Browser;
  end;

  if UseRatings then LoadConfig(false);

  Browser.Reload;
end;

procedure TMainForm.TVDblClick(Sender: TObject);
begin
  if TV.Selected = nil then Exit;
  if not PlayButton.Enabled then Exit;

  if not (TV.Selected).HasChildren then
  begin
    StopButtonClick(Sender);
    PlayButtonClick(Sender);
  end;
end;

procedure TMainForm.FontBiggerMenuClick(Sender: TObject);
begin
  Browser.DefFontSize := Browser.DefFontSize + 1;
  Browser.Reload;

  if MainURL = ExePath + Speak('HelpFile') then
    DocMenu.Click; // help file needs to be reloaded;
end;

procedure TMainForm.FontSmallerMenuClick(Sender: TObject);
begin
  Browser.DefFontSize := Browser.DefFontSize - 1;
  Browser.Reload;

  if MainURL = ExePath + Speak('HelpFile') then
    DocMenu.Click; // help file needs to be reloaded;
end;

procedure TMainForm.PlayModeButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  P.X := Splitter1.Left + PlayModeButton.Left + 5;
  P.Y := MainToolbar.Top + PlayModeButton.Top + PlayModeButton.Height;

  P := ClientToScreen(P);

  PlayModePopupMenu.Popup(P.X, P.Y);
end;

procedure TMainForm.PlayOneSongMenuClick(Sender: TObject);
var
  s: string;
begin
  s := (Sender as TMenuItem).Caption;
  s := Copy(s, 5, Length(s)); // "1 - play one song" needs to delete 4 chars
//  PlayModeLabel.Caption := ' ( ' + s + ' )';
  PlayModeButton.ImageIndex := PlayOneSong + (Sender as TMenuItem).MenuIndex;

  RandomPlay := (PlayModeButton.ImageIndex = PlayRandom);
end;

procedure TMainForm.BrowserHotSpotClick(Sender: TObject; const SRC: String;
  var Handled: Boolean);
begin
  MainURL := ExtractFilePath(MainURL) + SRC; //Browser.URL;
end;

procedure TMainForm.RepeatButtonClick(Sender: TObject);
begin
  if RepeatButton.ImageIndex = PlayForever then
    RepeatButton.ImageIndex := PlayOnce
  else
    RepeatButton.ImageIndex := PlayForever;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Key := 0;
    RefreshMenu.Click;
  end;

//  if Key = VK_F1 then
//  begin
//    Key := 0;
//    DocMenu.Click;
//  end;
end;

procedure TMainForm.poTrackMenuClick(Sender: TObject);
begin
  PlayOneSongMenu.Click;
end;

procedure TMainForm.poAlbumMenuClick(Sender: TObject);
begin
  PlayOneAlbumMenu.Click;
end;

procedure TMainForm.poWholeDiscMenuClick(Sender: TObject);
begin
  PlayWholeDiscMenu.Click;
end;

procedure TMainForm.poShuffleMenuClick(Sender: TObject);
begin
  PlayRandomMenu.Click;
end;

procedure TMainForm.poRepeatMenuClick(Sender: TObject);
begin
  RepeatButtonClick(Sender);
end;

// -------------- ABOUT BEGIN

procedure TMainForm.AboutMenuClick(Sender: TObject);
begin
  ShowMessage('CD Album 2.1, Christmas 1999/2000' + #13#10#13#10
    + 'Homepage: ' + RotateStr(AboutWWW) + #13#10
    + 'Authors: Timothy, Natasha and Ruth Ha' + #13#10
    + 'Email: ' + RotateStr(AboutEmail));
end;

// ----------------- ABOUT END

procedure TMainForm.LocateButtonClick(Sender: TObject);
begin
//  if TV.Selected = nil then Exit;
  
  if TV.Selected <> TV.Items[LastIndex] then
    TV.Selected := TV.Items[LastIndex]
  else begin
    TV.Selected := nil;
    TV.Selected := TV.Items[LastIndex];
  end;
end;

procedure TMainForm.SliderStopTracking(Sender: TObject);
begin
  try
    MPlayer1.Stop;
    MPlayer1.Position := Slider.Value * 1000;
  finally
    Slider.Value := MPlayer1.Position div 1000;
    MPlayer1.Play;
  end;

  ActiveControl := Browser;
end;

procedure TMainForm.RatingButtonClick(Sender: TObject);
var
  i: integer;
  wasUsingRatings: boolean;
begin
  StopButtonClick(Sender);

  wasUsingRatings := UseRatings;

  if TV.Selected = nil then TV.Selected := TV.Items[0];

  if TV.Selected.Level = 0 then
    RatingForm.Rating := Integer((TV.Selected.Item[0]).Data)
  else
    RatingForm.Rating := Integer(TV.Selected.Data);

  RatingForm.MinimumRating := MinimumRating;
  RatingForm.UseRatings := UseRatings;
  RatingForm.Caption := TV.Selected.Text;

  if RatingForm.ShowModal = mrCancel then Exit;

  UseRatings := RatingForm.RatingsCheckBox.Checked;

  if not UseRatings then Exit;

  Application.ProcessMessages;

  if wasUsingRatings <> UseRatings then LoadRatings;

  if TV.Selected.Level > 0 then
    TV.Selected.Data := Pointer(RatingForm.Rating)
  else begin // set a rating for the whole album;
    for i:=0 to TV.Selected.Count-1 do
    (TV.Selected.Item[i]).Data := Pointer(RatingForm.Rating);
  end;

  MinimumRating := RatingForm.RatingsComboBox.ItemIndex + 1;
end;

procedure TMainForm.RatingMenuClick(Sender: TObject);
begin
  RatingButtonClick(Sender);
end;

procedure TMainForm.LangMenuInit;
var
  MI: TMenuItem;
  FRec: TSearchRec;
  s: string;
begin

  if FindFirst(ExePath + '*.lng', faAnyFile, FRec) <> 0 then
  begin
    LangMenu.Enabled := false;
    Exit;
  end;

  repeat
    s := Copy(FRec.Name, 1, Pos('.',FRec.Name)-1);
    s := AnsiUpperCase(Copy(s,1,1)) + AnsiLowerCase(Copy(s,2,Length(s)));

    MI := TMenuItem.Create(Self);
    MI.Caption := s;
    MI.OnClick := LangMenuClick;

    LangMenu.Add(MI);
  until FindNext(FRec) <> 0;
end;

procedure TMainForm.LoadLangProperties(name: string);
var
  s: TStrings;
  substr: string;
  i: integer;
begin
  Lang.Properties.Clear;

  s := TStringList.Create;
  s.LoadFromFile(name);

  for i:=0 to s.Count-1 do
  begin
    if (Trim(s[i]) <> '') and (s[i][1] <> ';') and (s[i][1] <> '[')
    then begin
      substr := Copy(s[i], 1, Pos('=', s[i])-1); // MainForm.Caption = BibleQuote
      Lang.Properties.Add(Trim(substr));
    end;
  end;

  s.Free;
end;

function TMainForm.Speak(s: string): string;
begin
  Result := MainForm.Lang.TranslateUserMessage(s);
end;

procedure TMainForm.TranslateAll(name: string);
var
  s: string;
  wasHelp: boolean;
begin
  wasHelp := (MainURL = ExePath + Speak('HelpFile'));

  Lang.LanguageFile := name;
  LoadLangProperties(Lang.LanguageFile);
  Lang.Translate;

  StatusBar1.SimpleText := Format(Speak('Statistics'), [NumTracks, NumAlbums]);

  if (TV.Selected <> nil) and (TV.Selected.Level > 0)
  then
  with TV.Selected do
    StatusBar1.SimpleText := Format(
      Speak('AlbumText') + ': %s Ч ' +
      Speak('TrackText') + ': %s Ч ' +
      Speak('RatingText') + ': %s',
      [Parent.Text, Text, RatingText(Integer(Data))]);

  with RatingForm do
  begin
    RatingsRadioGroup.Items[0] := Speak('BadRating');
    RatingsRadioGroup.Items[1] := Speak('NotBadRating');
    RatingsRadioGroup.Items[2] := Speak('GoodRating');
    RatingsRadioGroup.Items[3] := Speak('VeryGoodRating');
    RatingsRadioGroup.Items[4] := Speak('BestRating');

    RatingsComboBox.Items[0] := Speak('PlayFromBadRating');
    RatingsComboBox.Items[1] := Speak('PlayFromNotBadRating');
    RatingsComboBox.Items[2] := Speak('PlayFromGoodRating');
    RatingsComboBox.Items[3] := Speak('PlayFromVeryGoodRating');
    RatingsComboBox.Items[4] := Speak('PlayFromBestRating');
  end;

  case PlayModeButton.ImageIndex of
    PlayOneSong: s := PlayOneSongMenu.Caption;
    PlayOneAlbum: s := PlayOneAlbumMenu.Caption;
    PlayAllSongs: s := PlayWholeDiscMenu.Caption;
  else
    s := PlayRandomMenu.Caption;
  end;

  s := Copy(s, 5, Length(s)); // "1 - play one song" needs to delete 4 chars
//  PlayModeLabel.Caption := ' ( ' + s + ' )';

  LastLanguageFile := name;

  if wasHelp then DocMenu.Click else LocateButton.Click;
end;

procedure TMainForm.LangMenuClick(Sender: TObject);
begin
  if (Sender as TMenuItem).Caption = LangMenu.Caption then Exit;

  TranslateAll(ExePath + (Sender as TMenuItem).Caption + '.lng');
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  dir: string;
begin
  if LangInitialized then Exit;

  dir := ParamStr(1) + ' ' + ParamStr(2)  + ' ' + ParamStr(3)
          + ' ' + ParamStr(4) ;
  dir := Trim(dir);

  if (dir <> '') and (dir[Length(dir)] <> '\') then
  begin
    dir := dir + '\';
    MainPath := dir;
  end;

  Initialize(MainPath);

  LoadConfig(true); // default = good

  if LastLanguageFile <> ''
  then TranslateAll(ExePath + ExtractFileName(LastLanguageFile))
  else TranslateAll(ExePath + 'English.lng');

  PlayWholeDiscMenu.Click;
  DocMenu.Click;

  TV.Selected := nil; // TranslateAll has set Selected to Items[0]

  InstallWAVCodec;

  LangInitialized := true;
end;

procedure TMainForm.SetVolume(i: Longint);
begin
  if i > 65535 then i := 65535;
  if i <= 0 then i := 0;

  //i := i and 65535;

  MainVolume := i;
  WaveOutSetVolume(0, i shl 16 + i);

//  VolumePanel.Caption := ' (' + IntToStr(100*MainVolume div 65535) + '%)';

  ActiveControl := Browser;
end;

procedure TMainForm.InstallWAVCodec;
var
  Reg: TRegistry;
  Ini: TIniFile;
  found: boolean;
begin
  found := false;

  Ini := TIniFile.Create('system.ini');

  if Ini.ReadString('drivers32', 'msacm.l3codec', '') = 'l3codecp.acm'
  then found := true;

  Ini.Free;

  if not found then
  begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Drivers32', false) then
    try
      found := Reg.ReadString('msacm.l3codec') = 'l3codecp.acm';
    except
      found := false;
    end;

    Reg.Free;
  end;

  if not found then
  begin
    ShowMessage('Installing Windows codec for *.WAV files in MPEG Layer 3.');

    ShellExecute(Application.Handle, nil, PChar(ExePath + 'setup\wav_mp3.exe'),
    nil, nil, SW_NORMAL);
  end;
end;

procedure TMainForm.VolumeDownMenuClick(Sender: TObject);
begin
  SetVolume(MainVolume - MainVolume div 10);
end;

procedure TMainForm.VolumeUpMenuClick(Sender: TObject);
begin
  SetVolume(MainVolume + MainVolume div 10);
end;

procedure TMainForm.VolumeButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  P.X := Splitter1.Left + VolumeButton.Left + 5;
  P.Y := MainToolbar.Top + VolumeButton.Top + VolumeButton.Height;

  P := ClientToScreen(P);

  VolumePopupMenu.Popup(P.X, P.Y);
end;

procedure TMainForm.BrowserMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Sender = Browser then ActiveControl := Browser;
end;

end.

