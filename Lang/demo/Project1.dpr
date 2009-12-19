program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  About in 'About.pas' {AboutForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TLanguage demo';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
