(*************************************************************************)
(*                                                                       *)
(*                        TLanguage v1.0                                 *)
(*                                                                       *)
(*   This freeware component was designed for the Shareware Centrum      *)
(*   project - a professional tool for shareware programmers, helping    *)
(*   them track products/users/purchases, shareware archives uploads,    *)
(*   shareware registrators they work with and much, much more.          *)
(*                                                                       *)
(*   If you enjoyed this component, please support author and download   *)
(*   Shareware Centrum from my homepage. I hope you will enjoy this      *)
(*   tool.                                                               *)
(*                                                                       *)
(*                       (c) Serge Sushko                                *)
(*                        sushko@iname.com,                              *)
(*                http://members.tripod.com/~sushko/                     *)
(*                                1998                                   *)
(*                                                                       *)
(*************************************************************************)
unit Lang;
interface

uses Classes, Forms, Dialogs, IniFiles, TypInfo, SysUtils;

type TLanguageNotifyEvent = procedure (Sender     : TObject;
                                       AComponent : TComponent;
                                       PropertyName, OldValue : String;
                                   var NewValue : String) of object;

type
  TLanguage = class(TComponent)
  private
    FIniFile    : String;
    FProperties : TStrings;
    FSeparator  : String;
    FOnBeforeTranslation : TNotifyEvent;
    FOnAfterTranslation  : TNotifyEvent;
    FOnTranslate         : TLanguageNotifyEvent;
    function      GetFirstPart(var AString : String) : String;
    function      IsLastPart(AString : String) : Boolean;
    function      FindComponent(AOwner : TComponent; sName : String) : TComponent;
    function      GetProperty(AComponent : TComponent; sProperty : String) : String;
    procedure     SetProperty(AComponent : TComponent; sProperty, sValue : String);
    procedure     TranslateProperty(sProperty, sTranslation : String);
    function      GetStrings : TStrings;
    procedure     SetStrings(Value: TStrings);
    procedure     SetStringsProperty(AComponent : TComponent;
                                     PropInfo   : PPropInfo;
                                     sValues    : String);
  protected
    procedure     SetSeparator(sSeparator : String);
  public
    class function StringProperty(PropInfo : PPropInfo) : Boolean;
    class function IntegerProperty(PropInfo : PPropInfo) : Boolean;
    constructor   Create(AOwner : TComponent); override;
    destructor    Destroy; override;
    procedure     Translate;
    function      TranslateUserMessage(sMessage : String) : String;
  published
    property      LanguageFile        : String               read FIniFile             write FIniFile;
    property      Properties          : TStrings             read GetStrings           write SetStrings;
    property      OnBeforeTranslation : TNotifyEvent         read FOnBeforeTranslation write FOnBeforeTranslation;
    property      OnAfterTranslation  : TNotifyEvent         read FOnAfterTranslation  write FOnAfterTranslation;
    property      OnTranslate         : TLanguageNotifyEvent read FOnTranslate         write FOnTranslate;
    property      Separator           : String               read FSeparator           write SetSeparator;
  end;

procedure Register;

implementation
{ $R Lang.dcr }
{=====================}
procedure Register;
begin
  RegisterComponents('Samples', [TLanguage]);
end;
{=====================}
constructor TLanguage.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FProperties := TStringList.Create;
end;
{=====================}
destructor TLanguage.Destroy;
begin
  FProperties.Free;
  inherited Destroy;
end;
{=====================}
function TLanguage.GetFirstPart(var AString : String) : String;
begin
  If (Pos('.', AString) > 0) then
    begin
    Result  := Copy(AString, 1, Pos('.', AString)-1);
    Delete(AString, 1, Pos('.', AString));
    end
  else
    begin
    Result  := AString;
    AString := '';
    end;
  AString   := Trim(AString);
  Result    := Trim(Result);
end;
{=====================}
function TLanguage.IsLastPart(AString : String) : Boolean;
begin
  Result := (Pos('.', AString) = 0);
end;
{=====================}
function TLanguage.FindComponent(AOwner : TComponent; sName : String) : TComponent;
var i : Integer;
begin
  Result := Nil;
  If (AOwner <> Nil) then
    With AOwner do
      For i:=0 to ComponentCount-1 do
        If (UpperCase(Components[i].Name) = UpperCase(sName)) then
          begin
          Result := Components[i];
          Break;
          end;
end;
{=====================}
procedure TLanguage.SetProperty(AComponent : TComponent; sProperty, sValue : String);
var PropInfo: PPropInfo;
begin
  If (AComponent <> Nil) then
    begin
    PropInfo := GetPropInfo(AComponent.ClassInfo, sProperty);
    if (PropInfo <> Nil) then
      begin
      if (StringProperty(PropInfo)) then
        SetStrProp(AComponent, PropInfo, sValue)
      else if (IntegerProperty(PropInfo)) then
        SetOrdProp(AComponent, PropInfo, StrToInt(sValue))
      else
        SetStringsProperty(AComponent, PropInfo, sValue);
      end;
    end;
end;
{=====================}
function TLanguage.GetProperty(AComponent : TComponent; sProperty : String) : String;
var PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(AComponent.ClassInfo, sProperty);
  if (PropInfo <> Nil) then
    Result := GetStrProp(AComponent, PropInfo);
end;
{=====================}
procedure TLanguage.TranslateProperty(sProperty, sTranslation : String);
var AComponent : TComponent;
begin
  sProperty    := Trim(sProperty);
  AComponent   := Application;

  If (sProperty <> '') then
    While (not IsLastPart(sProperty)) do
      AComponent := FindComponent(AComponent, GetFirstPart(sProperty))
  else
    Exit;

  If ((AComponent <> Nil) and (sTranslation <> '')) then
    begin
    if (Assigned(FOnTranslate))
    then FOnTranslate(Self, AComponent, sProperty,
                      GetProperty(AComponent, sProperty), sTranslation);
    SetProperty(AComponent, GetFirstPart(sProperty), sTranslation);
    end;
end;
{=====================}
procedure TLanguage.Translate;
var i : Integer;
begin
  if (Assigned(FOnBeforeTranslation))
  then FOnBeforeTranslation(Self);
  With TIniFile.Create(FIniFile) do
    begin
    For i:=0 to FProperties.Count-1 do
      if (Trim(FProperties[i]) <> '') then
        TranslateProperty(FProperties[i],
                          ReadString('Translations', FProperties[i], ''));
    Free;
    end;
  if (Assigned(FOnAfterTranslation))
  then FOnAfterTranslation(Self);
end;
{=====================}
procedure TLanguage.SetStrings(Value: TStrings);
begin
  FProperties.Assign(Value);
end;
{=====================}
function TLanguage.GetStrings : TStrings;
begin
  Result := FProperties;
end;
{=====================}
function TLanguage.TranslateUserMessage(sMessage : String) : String;
begin
  With TIniFile.Create(FIniFile) do
    begin
    Result := ReadString('Messages', sMessage, sMessage);
    Free;
    end;
end;
{=====================}
class function TLanguage.StringProperty(PropInfo : PPropInfo) : Boolean;
var aPropInfo : TPropInfo;
    ppType    : PPTypeInfo;
    pType     : PTypeInfo;
    TypeInfo  : TTypeInfo;
begin
  aPropInfo   := PropInfo^;
  ppType      := aPropInfo.PropType;
  pType       := ppType^;
  TypeInfo    := pType^;
  if (TypeInfo.Kind = tkString) or
     (TypeInfo.Kind = tkLString) or
     (TypeInfo.Kind = tkWString)
  then
    Result := True
  else
    Result := False;
end;
{=====================}
class function TLanguage.IntegerProperty(PropInfo : PPropInfo) : Boolean;
var aPropInfo : TPropInfo;
    ppType    : PPTypeInfo;
    pType     : PTypeInfo;
    TypeInfo  : TTypeInfo;
begin
  aPropInfo   := PropInfo^;
  ppType      := aPropInfo.PropType;
  pType       := ppType^;
  TypeInfo    := pType^;
  Result      :=(TypeInfo.Kind = tkInteger);
end;
{=====================}
procedure TLanguage.SetStringsProperty(AComponent : TComponent;
                                       PropInfo   : PPropInfo;
                                       sValues    : String);
var AStrings : TStringList;
    sBuffer  : String;
begin
  AStrings := TStringList.Create;
  while (Pos(FSeparator, sValues) > 0) do
    begin
    sBuffer := System.Copy(sValues, 1, Pos(FSeparator, sValues)-1);
    System.Delete(sValues, 1, Pos(FSeparator, sValues) - 1 + Length(FSeparator));
    AStrings.Add(Trim(sBuffer));
    end;
  if (Length(Trim(sValues)) > 0)
  then AStrings.Add(Trim(sValues));

  SetOrdProp(AComponent, PropInfo, LongInt(Pointer(AStrings)));

  AStrings.Free;
end;
{=====================}
procedure TLanguage.SetSeparator(sSeparator : String);
begin
  if (Length(Trim(sSeparator)) = 0)
  then FSeparator := ','
  else FSeparator := sSeparator;
end;
{=====================}
end.
