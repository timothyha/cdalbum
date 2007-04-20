program album;

uses
  Forms,
  main in 'main.pas' {MainForm},
  rating in 'rating.pas' {RatingForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'CD Album';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TRatingForm, RatingForm);
  Application.Run;
end.
