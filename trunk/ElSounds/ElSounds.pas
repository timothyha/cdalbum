unit ElSounds;

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus,
  StdCtrls,
  ExtCtrls;

type
  TInputOpenEvent = procedure(Sender : TObject; var UserData : integer; var CanSetPos : boolean; var Success : boolean) of object;
  TInputCloseEvent = procedure(Sender : TObject; UserData : integer; var Success : boolean) of object;
  TInputGetSizeEvent = procedure(Sender : TObject; UserData : integer; var Size : integer; var Success : boolean) of object;
  TInputSeekEvent = procedure(Sender : TObject; UserData : integer; var NewPos : integer; SeekMode : integer; var Success : boolean) of object;
  TInputReadEvent = procedure(Sender : TObject; UserData : integer; Buffer : pointer; BytesToRead : integer; var BytesRead : integer; var Success : boolean) of object;

const ThreadPriorities : array [0..6] of  integer
                       = (THREAD_PRIORITY_IDLE,
                          THREAD_PRIORITY_LOWEST,
                          THREAD_PRIORITY_BELOW_NORMAL,
                          THREAD_PRIORITY_NORMAL,
                          THREAD_PRIORITY_ABOVE_NORMAL,
                          THREAD_PRIORITY_HIGHEST,
                          THREAD_PRIORITY_TIME_CRITICAL);

type
  TElSOutputEvent = procedure(Sender: TObject; SampleData : pointer;
                    SBits, Channels, SampleRate, Size : integer; var success : boolean) of object;

  TElSOutputActionEvent = procedure (Sender: TObject; var Success : boolean) of object;

type TElSError = (
       peNoError,
       peNotImplemented,
       peIncorrectMode, // not correct mode for performing an operation
       peInternalError, // failed to allocate memory/resources
       peInvalidHandle, // Invalid player object handle
       peInputError,
       peOutputError,
       peNoMemory,
       peNoResources,
       peNoCallback,
       peNotLoaded,
       peNotInitialized
    );

type ErrString = array[TElSError] of string[100];

const  ErrStr : ErrString = ('No error',
                             'Requested operation is not implemented in the decoder',
                             'Incorrect decoder mode',
                             'Internal decoder error',
                             'Invalid object handle passed to decoder',
                             'Input stream failure',
                             'Output device failure',
                             'Not enough memory to perform an operation',
                             'Decoder failed to allocate resources',
                             'One of callback functions needed to perform an operation not defined',
                             'Failed to load or initialize decoder module',
                             'Module not initialized'
                             );

type
  TElSException = class (Exception)
                  public
                    ErrCode : TElSError;
                    Constructor CreateErr(Err:TElSError);
                  end;

type
  TElSInputMode  = (imFile, imCallback);
  TElSOutputMode = (omMMSystem, omFile, omDirectSound, omCallback);
  TElSPlayerMode = (pmClosed, pmOpened, pmReady, pmStopped, pmPlaying, pmPaused);
  TElSStereoMode = (MPG_MD_STEREO, MPG_MD_JOINT_STEREO, MPG_MD_DUAL_CHANNEL, MPG_MD_MONO);
   
type

  InitModuleProc = function : THandle; stdcall;
  BoolHanProc = function (Handle : THandle) : boolean; stdcall;
  LongHanProc = function (Handle : THandle) : integer; stdcall;
  BoolHanLongProc = function(Handle : THandle; Param1 : integer) : boolean; stdcall;
  BoolHanPLongProc = function(Handle : THandle; var Param1 : integer) : boolean; stdcall;
  BoolHanPBoolProc = function(Handle : THandle; var Param1 : boolean) : boolean; stdcall;
  LongProc = function : integer; stdcall;
  BoolStrLongProc = function (buffer : PChar; var Len : integer) : boolean; stdcall;
  BoolHanStrProc = function (Handle : THandle; buffer : PChar) : boolean; stdcall;
  BoolHanStrLongProc = function (Handle : THandle; buffer : PChar; var Len : integer) : boolean; stdcall;
  BoolHanLongLongProc = function(Handle : THandle; Param1, Param2 : integer) : boolean; stdcall;
  BoolHanLong3Proc = function(Handle : THandle; Param1, Param2 : pointer; Data : integer) : boolean; stdcall;
  BoolHanPtr6LongProc = function(Handle : THandle; Param1, Param2, Param3, Param4, Param5 : pointer; UserData : integer) : boolean; stdcall;
  BoolHanBoolProc = function(Handle : THandle; Param1 : boolean) : boolean; stdcall;
  BoolHanPtrPLong2Proc = function (Handle : THandle; var EQData : pointer; var Channels : integer; var Bands : integer) : boolean; stdcall;

  TElPlayerMan = class;

  TElPlayer = class (TCollectionItem)
  private
    FModuleName : string;
    FLeftVolume : Word;
    FRightVolume : Word;
    FOutputDevNum : Integer;
    FPathToDLL : String;
    FLE : integer;
    DLLHandle,
    ModuleHandle : THandle;
    HWindow : HWND;
    FDLLInitModule : InitModuleProc;
    FDLLDeInitModule : BoolHanProc;
    FDLLOpen     : BoolHanProc;
    FDLLClose    : BoolHanProc;
    FDLLInitStream : BoolHanProc;
    FDLLPlay     : BoolHanProc;
    FDLLPause    : BoolHanProc;
    FDLLResume   :BoolHanProc;
    FDLLStop     : BoolHanProc;
    FDLLGetPos   : LongHanProc;
    FDLLSetPos   : BoolHanLongProc;
    FDLLAbout    : BoolStrLongProc;
    FDLLName     : BoolStrLongProc;
    FDLLVersion  : LongProc;
    FDLLInMode   : BoolHanLongProc;
    FDLLOutMode  : BoolHanLongProc;
    FDLLInName   : BoolHanStrProc;
    FDLLOutName  : BoolHanStrProc;
    FDLLDevNum   : BoolHanLongProc;
    FDLLGetMode  : LongHanProc;
    FDLLGetSize  : LongHanProc;
    FDLLGetErr   : LongHanProc;
    FDLLSetBufs  : BoolHanLongLongProc;
    FDLLSetPri   : BoolHanLongProc;
    FDLLSetLimits: BoolHanLongLongProc;
    FDLLSetOutCB : BoolHanLong3Proc;
    FDLLGetExts  : BoolStrLongProc;
    FDLLGetInfo1 : BoolHanStrLongProc;
    FDLLGetInfo2 : BoolHanPLongProc;
    FDLLGetVolume: BoolHanPLongProc;
    FDLLSetVolume: BoolHanLongProc;
    FDLLCanSetVol: BoolHanPBoolProc;
    FDLLSetDevNum: BoolHanLongProc;
    FDLLSetInCB  : BoolHanPtr6LongProc;
    FDLLCanSeek  : BoolHanProc;
    FDLLCanPause : BoolHanProc;
    FDLLSetWindow: BoolHanLongProc;
    FDLLUseOutCB : BoolHanBoolProc;
    FDLLHasEQ    : BoolHanPBoolProc;
    FDLLUseEQ    : BoolHanBoolProc;
    FDLLEQ       : BoolHanPtrPLong2Proc;
    FPaused    : boolean;
    FStartPos,
    FEndPos    : integer;
    FPriority  : integer;
    FBufferSize: integer;
    FInputMode : TElSInputMode;
    FInputName : String;
    FOutputMode: TElSOutputMode;
    FOutputName: String;
    FBuffersCount: Integer;
    FOnInitOutput: TElSOutputActionEvent;
    FOnDoneOutput: TElSOutputActionEvent;
    FOnOutput: TElSOutputEvent;
    FOnInputOpen : TInputOpenEvent;
    FOnInputClose : TInputCloseEvent;
    FOnInputGetSize : TInputGetSizeEvent;
    FOnInputSeek : TInputSeekEvent;
    FOnInputRead : TInputReadEvent;
    FInitialized : Boolean;
    FUseEQ: Boolean;
    procedure SetUseEQ(newValue: Boolean);
    procedure SetInitialized(newValue : Boolean);
    procedure SetOutputDevNum(newValue : Integer);
    function GetLeftVolume : Word;
    procedure SetLeftVolume(newValue : Word);
    function GetRightVolume : Word;
    procedure SetRightVolume(newValue : Word);
    function GetExtensions : String;
    procedure SetExtensions(newValue : String);
    procedure SetStartPos(newValue: Integer);
    procedure SetEndPos(newValue: Integer);
    procedure SetBuffersCount(newValue: Integer);
    procedure SetBufferSize(newValue: Integer);
    procedure SetInputMode(newValue: TElSInputMode);
    procedure SetInputName(newValue: String);
    procedure SetOutputMode(newValue: TElSOutputMode);
    procedure SetOutputName(newValue: String);
    function GetPaused: Boolean;
    function GetPlayerMode: TElSPlayerMode;
    function GetAbout: string;
    procedure SetAbout(newValue: string);
    function GetVersion: Integer;
    procedure SetVersion(newValue: Integer);
    function GetPosition: Integer;
    procedure SetPosition(newValue: Integer);
    function GetSize: Integer;
    function GetModuleName: String;
    procedure SetPriority(newValue : integer);
    function GetHasEQ: Boolean;
  protected
    destructor Destroy; override;
    procedure WndProc(var Message: TMessage); virtual;
    procedure TriggerInitOutputEvent(var Success : boolean); virtual;
    procedure TriggerDoneOutputEvent(var Success : boolean); virtual;
    procedure TriggerOutputEvent(SampleData : pointer;
              SBits, Channels, SampleRate, Size : integer; var success : boolean); virtual;
    procedure TriggerInputOpenEvent(var UserData : integer; var CanSetPos : boolean; var Success : boolean); virtual;
    procedure TriggerInputCloseEvent(UserData : integer; var Success : boolean); virtual;
    procedure TriggerInputGetSizeEvent(UserData : integer; var Size : integer; var Success : boolean); virtual;
    procedure TriggerInputSeekEvent(UserData : integer; var NewPos : integer; SeekMode : integer; var Success : boolean); virtual;
    procedure TriggerInputReadEvent(UserData : integer; Buffer : pointer; BytesToRead : integer; var BytesRead : integer; var Success : boolean); virtual;
  public
    constructor Create(AOwner : TCollection); override;
    procedure Init;
    procedure Deinit;
    procedure Open;
    procedure InitStream;
    procedure Play;
    procedure Pause;
    procedure Resume;
    procedure Stop;
    procedure Close;
    function GetInfo1(Buffer : pointer; var BufLen : integer) : Boolean;
    function GetInfo2 : pointer;
    function CanSetVolume(var SeparateChannels : boolean) : Boolean;
    function CanSetPosition : Boolean;
    function CanPause : boolean;

    (*
       Equalizer returns the pointer of array [1 .. channels, 1 .. bands] of double
       You should not dispose the memory, referenced by this pointer
    *)
    procedure Equalizer(var EQData : pointer; var EQDataLen, channels, bands : integer);

    property Position: Integer read GetPosition write SetPosition;
    property Size: Integer read GetSize;
    property Paused: Boolean read GetPaused;
    property PlayerMode: TElSPlayerMode read GetPlayerMode;
    property LeftVolume : Word read GetLeftVolume write SetLeftVolume;
    property RightVolume : Word read GetRightVolume write SetRightVolume;
    property HasEqualizer: Boolean read GetHasEQ;
  published
    property InputMode: TElSInputMode read FInputMode write SetInputMode;
    property InputName: String read FInputName write SetInputName;
    property OutputMode: TElSOutputMode read FOutputMode write SetOutputMode;
    property OutputName: String read FOutputName write SetOutputName;
    property PathToDLL: String read FPathToDLL write FPathToDLL;
    property ModuleName: string read GetModuleName write FModuleName;
    property About: string read GetAbout write SetAbout stored false;
    property Version: Integer read GetVersion write SetVersion stored false;
    property StartPos: Integer read FStartPos write SetStartPos;
    property EndPos: Integer read FEndPos write SetEndPos;
    property Priority: Integer read FPriority write SetPriority;
    property BuffersCount: Integer read FBuffersCount write SetBuffersCount;
    property BufferSize: Integer read FBufferSize write SetBufferSize;
    property Extensions : String read GetExtensions write SetExtensions stored false;
    property OutputDevNum : Integer read FOutputDevNum write SetOutputDevNum;
    property Initialized : Boolean read FInitialized write SetInitialized stored false;
    property UseEqualizer: Boolean read FUseEQ write SetUseEQ;

    property OnOutputInit: TElSOutputActionEvent read FOnInitOutput write FOnInitOutput;
    property OnOutputDone: TElSOutputActionEvent read FOnDoneOutput write FOnDoneOutput;
    property OnOutput: TElSOutputEvent read FOnOutput write FOnOutput;
    property OnInputOpen : TInputOpenEvent read FOnInputOpen write FOnInputOpen;
    property OnInputClose : TInputCloseEvent read FOnInputClose write FOnInputClose;
    property OnInputGetSize : TInputGetSizeEvent read FOnInputGetSize write FOnInputGetSize;
    property OnInputSeek : TInputSeekEvent read FOnInputSeek write FOnInputSeek;
    property OnInputRead : TInputReadEvent read FOnInputRead write FOnInputRead;
  end;

  TElPlayers = class (TCollection)
    FManager : TElPlayerMan;
    function GetItems(Index : integer): TElPlayer;
    procedure SetItems(Index : integer; newValue: TElPlayer);
  protected
{$ifndef ver90}
    function GetOwner: TPersistent; override;
{$endif}
  public
    constructor Create(Manager : TElPlayerMan);
    function Add: TElPlayer;
    property Items[Index : integer]: TElPlayer read GetItems write SetItems; default;
  end;

  TElPlayerMan = class(TComponent)
  private
    FPlayers: TElPlayers;
    procedure SetPlayers(newValue: TElPlayers);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function WhoseType(Extension : string) : TElPlayer;
  published
    property Players: TElPlayers read FPlayers write SetPlayers;
  end;

procedure Register;

implementation

function OutCallback(SampleData : pointer;
         SBits, Channels, SampleRate, Size : integer; userdata : integer) : boolean; stdcall;
begin
  result := true;
  TElPlayer(userdata).TriggerOutputEvent(SampleData, SBits, Channels, SampleRate, Size, result);
end;

function OutActionCallback(Init : boolean; userdata : integer) : boolean; stdcall;
begin
  result := true;
  if Init
     then TElPlayer(userdata).TriggerInitOutputEvent(result)
     else TElPlayer(userdata).TriggerDoneOutputEvent(result);
end;

function InOpenCallback(UserData1 : integer; var UserData2 : integer; var CanSetPos : boolean) : boolean; stdcall;
begin
  result := false;
  TElPlayer(userdata1).TriggerInputOpenEvent(UserData2, CanSetPos, Result);
end;

function InCloseCallback(UserData1 : integer; UserData2 : integer) : boolean; stdcall;
begin
  result := true;
  TElPlayer(userdata1).TriggerInputCloseEvent(UserData2, result);
end;

function InGetSizeCallback(UserData1 : integer; UserData2 : integer; var Size : integer) : boolean; stdcall;
begin
  result := false;
  TElPlayer(userdata1).TriggerInputGetSizeEvent(UserData2, Size, result);
end;

function InSeekCallback(UserData1 : integer; UserData2 : integer; var NewPos : integer; SeekMode : integer) : boolean; stdcall;
begin
  result := false;
  TElPlayer(userdata1).TriggerInputSeekEvent(UserData2, NewPos, SeekMode, result);
end;

function InReadCallback(UserData1 : integer; UserData2 : integer; Buffer : pointer; BytesToRead : integer; var BytesRead : integer) : boolean; stdcall;
begin
  result := false;
  TElPlayer(userdata1).TriggerInputReadEvent(UserData2, Buffer, BytesToRead, BytesRead, result);
end;

Constructor TElSException.CreateErr;
begin
  ErrCode := Err;
  inherited Create(ErrStr[Err]);
end;

function TElPlayer.GetPaused: Boolean;
begin
  result := FPaused;
end;

function TElPlayer.GetPlayerMode: TElSPlayerMode;
begin
  if ModuleHandle <> 0 then
  begin
    result := TElSPlayerMode(FDLLGetMode(ModuleHandle));
  end else
  begin
    raise TElSException.CreateErr(peNotInitialized);
  end;
end;

function TElPlayer.GetAbout: string;
var P : PChar;
    i : integer;
begin
  if ModuleHandle <> 0 then
  begin
    FDLLAbout(nil, i);
    inc(i);
    GetMem(P, i);
    if not FDLLAbout(P, i) then result := 'Unknown module ... ' else result := StrPas(P);
    if Assigned (P) then FreeMem(P);
  end else
  begin
    result := '(Module not initialized)';
  end;
end;

procedure TElPlayer.SetAbout(newValue: string);
begin
end;

function TElPlayer.GetVersion: Integer;
begin
  if ModuleHandle <> 0 then result := FDLLVersion() else result := -1;
end;

procedure TElPlayer.SetVersion(newValue: Integer);
begin
end;

procedure TElPlayer.Open;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    InputMode := InputMode;
    InputName := InputName;
    OutputMode := OutputMode;
    OutputName := OutputName;
    try
      SetPriority(FPriority);
    except
    end;
    if FDLLOpen(ModuleHandle) = false then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end;
  end;
end;

procedure TElPlayer.InitStream;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    SetOutputDevNum(FOutputDevNum);
    if FDLLInitStream(ModuleHandle) = false then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end;
  end;
end;

procedure TElPlayer.Play;
var b : boolean;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    StartPos   := StartPos;
    EndPos     := EndPos;
    FDLLSetWindow(ModuleHandle, HWindow);
    FDLLUseOutCB(ModuleHandle, Assigned(OnOutput) and Assigned (OnOutputInit) and Assigned(OnOutputDone));
    if FDLLPlay(ModuleHandle) = false then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end else
    begin
      if not CanSetVolume(b) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
      end else if b then
      begin
        GetLeftVolume;
        FDLLSetVolume(ModuleHandle, (FLeftVolume shl 16) or (FRightVolume));
      end;
    end;
  end;
end;

procedure TElPlayer.Pause;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLPause(ModuleHandle) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end else FPaused := true;
  end;
end;

procedure TElPlayer.Resume;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLResume(ModuleHandle) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end else FPaused := false;
  end;
end;

procedure TElPlayer.Stop;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLStop(ModuleHandle) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end else FPaused := false;
  end;
end;

procedure TElPlayer.Close;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLClose(ModuleHandle) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end else FPaused := false;
  end;
end;

procedure TElPlayer.Init;
begin
  DllHandle := LoadLibrary(PChar(FPathToDLL));
  if DllHandle <> 0 then
  begin
    try
      FDLLInitModule := GetProcAddress(DLLHandle, 'ESInitModule');
      if (@FDLLInitModule= nil) then raise Exception.Create('');
      FDLLDeInitModule:= GetProcAddress(DLLHandle, 'ESDeInitModule');
      if (@FDLLDeInitModule= nil) then raise Exception.Create('');
      FDLLOpen   := GetProcAddress(DLLHandle, 'ESOpen');
      if (@FDLLOpen = nil) then raise Exception.Create('');
      FDLLClose  := GetProcAddress(DLLHandle, 'ESClose');
      if (@FDLLClose = nil) then raise Exception.Create('');
      FDLLPlay   := GetProcAddress(DLLHandle, 'ESPlay');
      if (@FDLLPlay = nil) then raise Exception.Create('');
      FDLLCanPause:= GetProcAddress(DLLHandle, 'ESCanPause');
      if (@FDLLCanPause = nil) then raise Exception.Create('');
      FDLLPause  := GetProcAddress(DLLHandle, 'ESPause');
      if (@FDLLPause = nil) then raise Exception.Create('');
      FDLLResume := GetProcAddress(DLLHandle, 'ESResume');
      if (@FDLLResume = nil) then raise Exception.Create('');
      FDLLStop   := GetProcAddress(DLLHandle, 'ESStop');
      if (@FDLLStop = nil) then raise Exception.Create('');
      FDLLCanSeek:= GetProcAddress(DLLHandle, 'ESCanSetPos');
      if (@FDLLCanSeek = nil) then raise Exception.Create('');
      FDLLGetPos := GetProcAddress(DLLHandle, 'ESGetPos');
      if (@FDLLGetPos = nil) then raise Exception.Create('');
      FDLLSetPos := GetProcAddress(DLLHandle, 'ESSetPos');
      if (@FDLLSetPos = nil) then raise Exception.Create('');
      FDLLAbout  := GetProcAddress(DLLHandle, 'ESGetAbout');
      if (@FDLLAbout = nil) then raise Exception.Create('');
      FDLLName   := GetProcAddress(DLLHandle, 'ESGetName');
      if (@FDLLName = nil) then raise Exception.Create('');
      FDLLGetSize:= GetProcAddress(DLLHandle, 'ESGetSize');
      if (@FDLLGetSize = nil) then raise Exception.Create('');
      FDLLInMode := GetProcAddress(DLLHandle, 'ESSetInputMode');
      if (@FDLLInMode = nil) then raise Exception.Create('');
      FDLLOutMode:= GetProcAddress(DLLHandle, 'ESSetOutputMode');
      if (@FDLLOutMode = nil) then raise Exception.Create('');
      FDLLInName := GetProcAddress(DLLHandle, 'ESSetInputName');
      if (@FDLLInName = nil) then raise Exception.Create('');
      FDLLOutName:= GetProcAddress(DLLHandle, 'ESSetOutputName');
      if (@FDLLOutName = nil) then raise Exception.Create('');
      FDLLDevNum := GetProcAddress(DLLHandle, 'ESSetOutputDev');
      if (@FDLLDevNum = nil) then raise Exception.Create('');
      FDLLGetMode:= GetProcAddress(DLLHandle, 'ESGetPlayerMode');
      if (@FDLLGetMode = nil) then raise Exception.Create('');
      FDLLGetErr := GetProcAddress(DLLHandle, 'ESLastError');
      if (@FDLLGetErr = nil) then raise Exception.Create('');
      FDLLVersion:= GetProcAddress(DLLHandle, 'ESGetVersion');
      if (@FDLLVersion = nil) then raise Exception.Create('');
      FDLLSetBufs:= GetProcAddress(DLLHandle, 'ESSetBuffers');
      if (@FDLLSetBufs = nil) then raise Exception.Create('');
      FDLLSetPri := GetProcAddress(DLLHandle, 'ESSetPriority');
      if (@FDLLSetPri = nil) then raise Exception.Create('');
      FDLLSetLimits:= GetProcAddress(DLLHandle, 'ESSetLimits');
      if (@FDLLSetLimits = nil) then raise Exception.Create('');
      FDLLSetOutCB := GetProcAddress(DLLHandle, 'ESSetOutCB');
      if (@FDLLSetOutCB = nil) then raise Exception.Create('');
      FDLLGetVolume:= GetProcAddress(DLLHandle, 'ESGetVolume');
      if (@FDLLGetVolume = nil) then raise Exception.Create('');
      FDLLSetVolume:= GetProcAddress(DLLHandle, 'ESSetVolume');
      if (@FDLLSetVolume = nil) then raise Exception.Create('');
      FDLLCanSetVol:= GetProcAddress(DLLHandle, 'ESCanSetVolume');
      if (@FDLLCanSetVol = nil) then raise Exception.Create('');
      FDLLGetExts  := GetProcAddress(DLLHandle, 'ESGetExts');
      if (@FDLLGetExts = nil) then raise Exception.Create('');
      FDLLGetInfo1 := GetProcAddress(DLLHandle, 'ESGetInfo1');
      if (@FDLLGetInfo1 = nil) then raise Exception.Create('');
      FDLLGetInfo2 := GetProcAddress(DLLHandle, 'ESGetInfo2');
      if (@FDLLGetInfo2 = nil) then raise Exception.Create('');
      FDLLInitStream := GetProcAddress(DLLHandle, 'ESInitStream');
      if (@FDLLInitStream = nil) then raise Exception.Create('');
      FDLLSetDevNum := GetProcAddress(DLLHandle, 'ESSetDevNum');
      if (@FDLLSetDevNum = nil) then raise Exception.Create('');
      FDLLSetInCB := GetProcAddress(DLLHandle, 'ESSetInCB');
      if (@FDLLSetInCB = nil) then raise Exception.Create('');
      FDLLSetWindow := GetProcAddress(DLLHandle, 'ESSetWindow');
      if (@FDLLSetWindow = nil) then raise Exception.Create('');
      FDLLUseOutCB := GetProcAddress(DLLHandle, 'ESUseOutCB');
      if (@FDLLUseOutCB = nil) then raise Exception.Create('');
      FDLLUseEQ := GetProcAddress(DLLHandle, 'ESUseEQ');
      if (@FDLLUseEQ = nil) then raise Exception.Create('');
      FDLLHasEQ := GetProcAddress(DLLHandle, 'ESHasEQ');
      if (@FDLLHasEQ = nil) then raise Exception.Create('');
      FDLLEQ := GetProcAddress(DLLHandle, 'ESEQ');
      if (@FDLLEQ = nil) then raise Exception.Create('');

    except
      raise TElSException.CreateErr(peNotLoaded);
    end;
    (*if
    (@FDLLDeInitModule = nil) or
    (@FDLLOpen      = nil) or
    (@FDLLClose     = nil) or
    (@FDLLPlay      = nil) or
    (@FDLLResume    = nil) or
    (@FDLLStop      = nil) or
    (@FDLLGetSize   = nil) or
    (@FDLLGetPos    = nil) or
    (@FDLLSetPos    = nil) or
    (@FDLLAbout     = nil) or
    (@FDLLName      = nil) or
    (@FDLLInMode    = nil) or
    (@FDLLOutMode   = nil) or
    (@FDLLInName    = nil) or
    (@FDLLOutName   = nil) or
    (@FDLLDevNum    = nil) or
    (@FDLLGetErr    = nil) or
    (@FDLLVersion   = nil) or
    (@FDLLSetLimits = nil) or
    (@FDLLSetBufs   = nil) or
    (@FDLLSetPri    = nil) or
    (@FDLLSetOutCB  = nil) or
    (@FDLLGetExts   = nil) or
    (@FDLLGetInfo1  = nil) or
    (@FDLLGetInfo2  = nil) or
    (@FDLLInitStream= nil) or
    (@FDLLSetVolume = nil) or
    (@FDLLGetVolume = nil) or
    (@FDLLCanSetVol = nil) or
    (@FDLLSetDevNum = nil) or
    (@FDLLSetInCB   = nil) or
    (@FDLLSetWindow = nil) or
    (@FDLLUseOutCB  = nil) or
    (@FDLLGetMode   = nil) then
    begin
      raise TElSException.CreateErr(peNotLoaded);
    end;*)
    ModuleHandle := FDllInitModule;
    if (ModuleHandle = 0) then raise TElSException.CreateErr(peNotInitialized);
    FDLLSetOutCB(ModuleHandle, @OutCallback, @OutActionCallback, integer(self));
    FDLLSetInCB(ModuleHandle, @InOpenCallback, @InCloseCallback, @InGetSizeCallback, @InSeekCallback, @InReadCallback, integer(self));
    FInitialized := true;
  end else raise TElSException.CreateErr(peNotLoaded);
end;

procedure TElPlayer.Deinit;
begin
  if ModuleHandle <> 0 then
  begin
    FDllDeInitModule(ModuleHandle);
    ModuleHandle := 0;
  end;
  if DllHandle <> 0 then FreeLibrary(DLLHandle);
  FInitialized := false;
end;

procedure TElPlayer.SetPriority(newValue : integer);
begin
  if ModuleHandle = 0 then FPriority := newValue else
  begin
    if not FDLLSetPri(ModuleHandle, newValue) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      raise TElSException.CreateErr(TElSError(FLE));
    end;
    FPriority := newValue;
  end;
end;

procedure TElPlayer.SetInputMode(newValue: TElSInputMode);
begin
    if (ModuleHandle <> 0) then
    begin
      if FDLLInMode(ModuleHandle, integer(newValue)) then FInputMode := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FInputMode := newValue;
end;

procedure TElPlayer.SetInputName(newValue: String);
begin
    if ModuleHandle <> 0 then
    begin
      if FDLLInName(ModuleHandle, pchar(newValue)) then FInputName := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FInputName := newValue;
end;

procedure TElPlayer.SetOutputMode(newValue: TElSOutputMode);
begin
    if (ModuleHandle <> 0) then
    begin
      if FDLLOutMode(ModuleHandle, integer(newValue)) then FOutputMode := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FOutputMode := newValue;
end;

procedure TElPlayer.SetOutputName(newValue: String);
begin
    if ModuleHandle <> 0 then
    begin
      if FDLLOutName(ModuleHandle, pchar(newValue)) then FOutputName := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FOutputName := newValue;
end;

function TElPlayer.GetPosition: Integer;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    result := FDLLGetPos(ModuleHandle);
    if Result = -1 then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end;
  end;
end;

procedure TElPlayer.SetPosition(newValue: Integer);
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLSetPos(ModuleHandle, newValue) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end;
  end;
end;

function TElPlayer.GetSize: Integer;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    result := FDLLGetSize(ModuleHandle);
    if Result = -1 then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      if FLE > 0 then raise TElSException.CreateErr(TElSError(FLE));
    end;
  end;
end;

procedure TElPlayer.SetStartPos(newValue: Integer);
begin
    if ModuleHandle <> 0 then
    begin
      if FDLLSetLimits(ModuleHandle, newValue, EndPos) then FStartPos := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FStartPos := newValue;
end;

procedure TElPlayer.SetEndPos(newValue: Integer);
begin
    if ModuleHandle <> 0 then
    begin
      if FDLLSetLimits(ModuleHandle, StartPos, newValue) then FEndPos := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FEndPos := newValue;
end;

procedure TElPlayer.SetBuffersCount(newValue: Integer);
begin
    if ModuleHandle <> 0 then
    begin
      if FDLLSetBufs(ModuleHandle, newValue, BufferSize) then FBuffersCount := newValue else
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FBuffersCount := newValue;
end;

procedure TElPlayer.SetBufferSize(newValue: Integer);
begin
  if ModuleHandle <> 0 then
  begin
    if FDLLSetBufs(ModuleHandle, FBuffersCount, newValue) then FBufferSize := newValue else
    begin
      FLE := FDLLGetErr(ModuleHandle);
      raise TElSException.CreateErr(TElSError(FLE));
    end;
  end else FBufferSize := newValue;
end;

procedure TElPlayer.TriggerInitOutputEvent;
begin
  if (assigned(FOnInitOutput)) then FOnInitOutput(Self, Success) else Success := false;
end;

procedure TElPlayer.TriggerDoneOutputEvent;
begin
  if (assigned(FOnDoneOutput)) then FOnDoneOutput(Self, Success) else Success := false;
end;

procedure TElPlayer.TriggerOutputEvent;
begin
  if (assigned(FOnOutput)) then
    FOnOutput(Self, SampleData, SBits, Channels, SampleRate, Size, Success) else Success := false;
end;

function TElPlayer.GetInfo1(Buffer : pointer; var BufLen : integer) : Boolean;
begin
  if ModuleHandle <> 0 then result := FDLLGetInfo1(ModuleHandle, Buffer, BufLen) else
  begin
    BufLen := -1;
    result := false;
  end;
end;  {GetInfo}

function TElPlayer.GetInfo2 : Pointer;
var i : integer;
begin
  if ModuleHandle <> 0 then
  begin
    if not FDLLGetInfo2(ModuleHandle, i) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      raise TElSException.CreateErr(TElSError(FLE));
    end else result := Pointer(i);
  end else result := nil;
end;  {GetInfo}

function TElPlayer.GetExtensions : string;
var i : integer;
    p : PChar;
begin
  if ModuleHandle = 0 then result := '' else
  begin
    FDLLGetExts(nil, i);
    inc(i);
    GetMem(P, i);
    if not FDLLGetExts(P, i) then result := '' else result := StrPas(P);
    if Assigned (P) then FreeMem(P);
  end;
end;  {GetExtensions}

procedure TElPlayer.SetExtensions(newValue : string);
begin
end;  {SetExtensions}

function TElPlayer.GetModuleName: String;
var P : PChar;
    i : integer;
begin
  if ModuleHandle <> 0 then
  begin
    FDLLName(nil, i);
    inc(i);
    GetMem(P, i);
    if not FDLLName(P, i) then result := 'Unknown module' else result := StrPas(P);
    if Assigned (P) then FreeMem(P);
  end else
  begin
    result := '(Module not initialized)';
  end;
end;

function TElPlayer.GetLeftVolume : Word;
var i : integer;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLGetVolume(ModuleHandle, i) then
    begin
      if OutputMode = omMMSystem then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end else result := 0; 
    end else
    begin
      FLeftVolume  := LoWord(i);
      FRightVolume := HiWord(i);
      result := FLeftVolume;
    end;
  end;
end;  {GetLeftVolume}

procedure TElPlayer.SetLeftVolume(newValue : Word);
var b : boolean;
begin
  if (FLeftVolume <> newValue) then
  begin
    FLeftVolume := newValue;
    if ModuleHandle <> 0 then
    begin
      if not (CanSetVolume(b)) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end else if not b then FRightVolume := newValue;
      if not FDLLSetVolume(ModuleHandle, (FLeftVolume shl 16) or (FRightVolume)) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end;
  end;  {if}
end;  {SetLeftVolume}

function TElPlayer.GetRightVolume : Word;
var i : integer;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else
  begin
    if not FDLLGetVolume(ModuleHandle, i) then
    begin
      if OutputMode = omMMSystem then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end else result := 0;
    end else
    begin
      FLeftVolume  := LoWord(i);
      FRightVolume := HiWord(i);
      result := FRightVolume;
    end;
  end;
end;  {GetRightVolume}

procedure TElPlayer.SetRightVolume(newValue : Word);
var b: boolean;
begin
  if (FRightVolume <> newValue) then
  begin
    FRightVolume := newValue;
    if ModuleHandle <> 0 then
    begin
      if not (CanSetVolume(b)) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end else if not b then FLeftVolume := newValue;
      if not FDLLSetVolume(ModuleHandle, (FLeftVolume shl 16) or (newValue)) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end;
  end;  {if}
end;  {SetRightVolume}

procedure TElPlayer.SetOutputDevNum(newValue : Integer);
begin
  if ModuleHandle = 0 then FOutputDevNum := newValue else
  begin
    if not FDLLSetDevNum(ModuleHandle, newValue) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      raise TElSException.CreateErr(TElSError(FLE));
    end
    else FOutputDevNum := newValue;
  end;  {if}
end;  {SetOutputDevNum}

function TElPlayer.CanSetVolume(var SeparateChannels : boolean) : Boolean;
begin
  if ModuleHandle = 0 then raise TElSException.CreateErr(peNotInitialized) else result := FDLLCanSetVol(ModuleHandle, SeparateChannels);
end;  {CanSetVolume}

procedure TElPlayer.TriggerInputOpenEvent;
begin
  if (assigned(FOnInputOpen)) then
    FOnInputOpen(Self, UserData, CanSetPos, Success) else Success := false;
end;  {TriggerInputOpenEvent}

procedure TElPlayer.TriggerInputCloseEvent;
begin
  if (assigned(FOnInputClose)) then
    FOnInputClose(Self, UserData, Success )else Success := false;
end;  {TriggerInputCloseEvent}

procedure TElPlayer.TriggerInputGetSizeEvent;
begin
  if (assigned(FOnInputGetSize)) then
    FOnInputGetSize(Self, UserData , Size, Success ) else Success := false;
end;  {TriggerInputGetSizeEvent}

procedure TElPlayer.TriggerInputSeekEvent;
begin
  if (assigned(FOnInputSeek)) then
    FOnInputSeek(Self, UserData, NewPos , SeekMode , Success )else Success := false;
end;  {TriggerInputSeekEvent}

procedure TElPlayer.TriggerInputReadEvent;
begin
  if (assigned(FOnInputRead)) then
    FOnInputRead(Self, UserData , Buffer , BytesToRead , BytesRead , Success )else Success := false;
end;  {TriggerInputReadEvent}

procedure TElPlayer.SetInitialized(newValue : Boolean);
begin
  if (FInitialized <> newValue) then
  begin
    if NewValue then Init else DeInit;
  end;  {if}
end;  {SetInitialized}

function TElPlayer.CanPause : boolean;
begin
  if FInitialized
     then result := FDLLCanPause(ModuleHandle)
     else raise TElSException.CreateErr(peNotInitialized);
end;

function TElPlayer.CanSetPosition : Boolean;
begin
  if FInitialized
     then result := FDLLCanSeek(ModuleHandle)
     else raise TElSException.CreateErr(peNotInitialized);
end;  {CanSetPosition}

constructor TElPlayer.Create;
begin
  inherited;
  HWindow := AllocateHWND(WndProc);
  FBuffersCount := 8;
  FBufferSize := 16384;
end;

destructor TElPlayer.Destroy;
begin
  if (ModuleHandle <> 0) then DeInit;
  DeallocateHWND(HWindow);
  inherited;
end;

procedure TElPlayer.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_QUERYENDSESSION then Message.Result := 1 else
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;

function TElPlayer.GetHasEQ: Boolean;
begin
  if ModuleHandle <> 0
     then FDLLHasEQ(ModuleHandle, result)
     else raise TElSException.CreateErr(peNotInitialized);
end;

procedure TElPlayer.Equalizer(var EQData : pointer; var EQDataLen, channels, bands : integer);
begin
  if (ModuleHandle <> 0) and HasEqualizer then
  begin
    if not FDLLEQ(ModuleHandle, EQData, channels, bands) then
    begin
      FLE := FDLLGetErr(ModuleHandle);
      raise TElSException.CreateErr(TElSError(FLE));
    end;
    EQDataLen := sizeof(double) * bands * channels;
  end else
    if ModuleHandle = 0
       then raise TElSException.CreateErr(peNotInitialized)
       else raise TElSException.CreateErr(peNotImplemented);
end;

procedure TElPlayer.SetUseEQ(newValue: Boolean);
begin
    if ModuleHandle <> 0 then
    begin
      if HasEqualizer then if not FDLLUseEQ(ModuleHandle, newValue) then
      begin
        FLE := FDLLGetErr(ModuleHandle);
        raise TElSException.CreateErr(TElSError(FLE));
      end;
    end else FUseEQ := newValue;
end;

constructor TElPlayers.Create(Manager : TElPlayerMan);
begin
  FManager := Manager;
  inherited Create(TElPlayer);
end;

{$ifndef ver90}
function TElPlayers.GetOwner: TPersistent;
begin
  result := FManager;
end;
{$endif}

function TElPlayers.Add: TElPlayer;
begin
  result := TElPlayer(inherited Add);
end;

function TElPlayers.GetItems(Index : integer): TElPlayer;
begin
  result := TElPlayer(inherited GetItem(index));
end;

procedure TElPlayers.SetItems(Index : integer; newValue: TElPlayer);
begin
  inherited SetItem(Index, newValue);
end;

procedure TElPlayerMan.SetPlayers(newValue: TElPlayers);
begin
  if (FPlayers <> newValue) then
  begin
    FPlayers.Assign(newValue);
  end;  {if}
end;

function TElPlayerMan.WhoseType(Extension : string) : TElPlayer;
var i : integer;
    S : String;
begin
  result := nil;
  if (Extension = '.') then exit;
  for i := 0 to FPlayers.Count - 1 do
  begin
    if FPlayers[i].Initialized then
    begin
      try
        S := FPlayers[i].Extensions;
        if Pos(UpperCase(Extension), Uppercase(S)) > 0 then
        begin
          result := FPlayers[i];
          exit;
        end;
      except
      end;
    end;
  end;
end;

destructor TElPlayerMan.Destroy;
begin
  Players.Free;
  inherited;
end;

constructor TElPlayerMan.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPlayers := TElPlayers.Create(Self);
end;

procedure Register;
begin
  RegisterComponents('EldoS', [TElPlayerMan]);
end;

end.

