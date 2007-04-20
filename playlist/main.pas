unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    OKButton: TButton;
    Panel1: TPanel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function StripNumbers(s: string): string;
var
  i, code, ps: integer;
begin
  Result := s;

  ps := Pos(' ', s);
  if ps = 0 then Exit;

  Val(Copy(s,1,ps-1), i, code);
  if code = 0 then Result := Copy(s, ps+1, Length(s));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  F: TSearchRec;
begin
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;

  Form1.Caption := GetCurrentDir;

  if ParamStr(1) <> '' then ChDir(ParamStr(1));

  Listbox1.Items.BeginUpdate;

  if FindFirst('*.mp3', faAnyFile, F) = 0 then
  begin
    repeat
      ListBox1.Items.Add(F.Name);
    until FindNext(F) <> 0;
  end;

  if FindFirst('*.wav', faAnyFile, F) = 0 then
  begin
    repeat
      ListBox1.Items.Add(F.Name);
    until FindNext(F) <> 0;
  end;

  if FindFirst('*.wma', faAnyFile, F) = 0 then
  begin
    repeat
      ListBox1.Items.Add(F.Name);
    until FindNext(F) <> 0;
  end;

  Listbox1.Items.EndUpdate;

  if FileExists(Form1.Caption + '\album.ini') then
    Memo1.Lines.LoadFromFile(Form1.Caption + '\album.ini');
end;

procedure TForm1.OKButtonClick(Sender: TObject);
var
  s: TStrings;
  i: integer;
begin
  Listbox1.Items.SaveToFile('PlayList.m3u');

  s := TStringList.Create;

  s.Add('[general]');
  s.Add('name=' + ExtractFileName(Form1.Caption)); // name of the path;
  s.Add('tracks=' + IntToStr(Listbox1.Items.Count));
  s.Add('volume=100');

  for i:=0 to Listbox1.Items.Count-1 do
  begin
    s.Add('');
    s.Add('[track_' + IntToStr(i+1) + ']');
    s.Add('name=' + StripNumbers(Copy(Listbox1.Items[i], 1, Length(Listbox1.Items[i])-4)));
    s.Add('path=' + Listbox1.Items[i]);
  end;

  if FileExists(Form1.Caption + '\album.ini') then
  begin
    if Application.MessageBox('Overwrite existing ALBUM.INI ?',
      'Please confirm', MB_YESNO + MB_DEFBUTTON2) = IDYES then
    s.SaveToFile('album.ini');
  end
  else
    s.SaveToFile('album.ini');

  s.Free;
  Close;
end;

end.
