unit AboutUsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TFrmAbout = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

uses
  CommonUtil;
{$R *.dfm}

procedure TFrmAbout.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
  Label8.Caption := GetBuildInfo;
end;

end.


