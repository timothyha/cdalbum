(*************************************************************************)
(*                                                                       *)
(*                        TLanguage v1.0 demo                            *)
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
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, Lang;

type
  TMainForm = class(TForm)
    FruitsLabel: TLabel;
    FruitList: TListBox;
    MainMenu: TMainMenu;
    FileMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    LanguageCombo: TComboBox;
    Language1: TLanguage;
    AboutMenuItem: TMenuItem;
    HelpMenuItem: TMenuItem;
    N1: TMenuItem;
    LanguageLabel: TLabel;
    MessageBtn: TButton;
    AboutBtn: TButton;
    procedure ExitMenuItemClick(Sender: TObject);
    procedure MessageBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LanguageComboChange(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
  private
    { Private declarations }
    function  GetLangFileName(sLangName : String) : String;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses About;

{$R *.DFM}
{=================================}
procedure TMainForm.ExitMenuItemClick(Sender: TObject);
begin
  Application.Terminate;
end;
{=================================}
function  TMainForm.GetLangFileName(sLangName : String) : String;
var sDir : String;
begin
  sDir := ExtractFilePath(Application.ExeName);
  if (sDir[Length(sDir)] <> '\')
  then sDir := sDir + '\';
  Result := sDir + LowerCase(sLangName) + '.lng';
end;
{=================================}
procedure TMainForm.MessageBtnClick(Sender: TObject);
var sMessage : String;
begin
  if (FruitList.ItemIndex > -1) then
    sMessage := Language1.TranslateUserMessage('Selected fruit is') + ' ' +
                FruitList.Items[FruitList.ItemIndex]
  else
    sMessage := Language1.TranslateUserMessage('No one fruit is selected');
  MessageDlg(sMessage, mtInformation, [mbOK, mbHelp], 0);
end;
{=================================}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  LanguageCombo.ItemIndex := 0;
  LanguageComboChange(Sender);
end;
{=================================}
procedure TMainForm.LanguageComboChange(Sender: TObject);
begin
  Language1.LanguageFile := GetLangFileName(LanguageCombo.Text);
  Language1.Translate;
end;
{=================================}
procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
  with TAboutForm.Create(Application) do
    ShowModal;
end;
{=================================}
end.
