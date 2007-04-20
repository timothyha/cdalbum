unit rating;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB97Ctls, StdCtrls, ExtCtrls;

type
  TRatingForm = class(TForm)
    Panel1: TPanel;
    RatingsRadioGroup: TRadioGroup;
    RatingsGroupBox: TGroupBox;
    RatingsCheckBox: TCheckBox;
    RatingsComboBox: TComboBox;
    OKButton: TToolbarButton97;
    CancelButton: TToolbarButton97;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure OKButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure RatingsCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Rating: integer;
    MinimumRating: integer;
    UseRatings: boolean;
  end;

var
  RatingForm: TRatingForm;

implementation

{$R *.DFM}

procedure TRatingForm.FormCreate(Sender: TObject);
begin
  Left := (Screen.Width-Width) div 2;
  Top := (Screen.Height-Height) div 2;
end;

procedure TRatingForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Rating := 5-RatingsRadioGroup.ItemIndex;
    ModalResult := mrOK;
  end;

  if Key = #27 then
  begin
    Key := #0;
    ModalResult := mrCancel;
  end;
end;

procedure TRatingForm.OKButtonClick(Sender: TObject);
begin
  Rating := 5-RatingsRadioGroup.ItemIndex;
end;

procedure TRatingForm.FormActivate(Sender: TObject);
begin
  RatingsRadioGroup.ItemIndex := 5-Rating;

  RatingsRadioGroup.Enabled := UseRatings;
  RatingsCheckBox.Checked := UseRatings;

  RatingsComboBox.ItemIndex := MinimumRating - 1;

  ActiveControl := Panel1;
end;

procedure TRatingForm.RatingsCheckBoxClick(Sender: TObject);
begin
  RatingsRadioGroup.Enabled := RatingsCheckBox.Checked;
end;

end.
