unit DBML;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, Uni, MemDS, Data.Win.ADODB,
  SPComm, CnClasses, CnObjectPool, CnADOConPool;

type
  TDBModule = class(TDataModule)
    ADOStoredProc1: TADOStoredProc;
    cm1: TComm;
    ADOQuery1: TADOQuery;
    ADOConnection1: TADOConnection;
    ADOConnection2: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function unZipFile(zipFilePath, pSaveFolder, zipFilePassword: string): Boolean;
  end;

const
  _GZipPwd = '.aer1258963!@#$';

var
  DBModule: TDBModule;
  _GUList: TStringList;

implementation

uses
  CommonUtil, VCLZip, VCLUnZip;
{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDBModule.DataModuleCreate(Sender: TObject);
begin
  try
    // with UniConnection1 do
    // begin
    // Close;
    // ProviderName := 'MySQL';
    // Username := COMINFOR.FCONFIGINFOR.DB_USER;
    // Password := COMINFOR.FCONFIGINFOR.DB_PWD;
    // Server := COMINFOR.FCONFIGINFOR.DBSVR_IP;
    // Database := COMINFOR.FCONFIGINFOR.DB_NAME;
    // Port := COMINFOR.FCONFIGINFOR.DBSVR_PORT;
    // Open;
    // end;
    _GUList := TStringList.Create;
  finally

  end;
end;

procedure TDBModule.DataModuleDestroy(Sender: TObject);
begin
  _GUList.Free;
end;

function TDBModule.unZipFile(zipFilePath, pSaveFolder, zipFilePassword: string): Boolean;
var
  UnZippedCount: integer;
  VCLUnZip1: TVCLUnZip;
  AsFilePath: string;
begin
  Result := True;
  VCLUnZip1 := TVCLUnZip.Create(nil);
  AsFilePath := COMINFOR.FAPPPATH + '\template\' + pSaveFolder + '\';
  try
    with VCLUnZip1 do
    begin
      ZipName := zipFilePath; // ZIP文件
      Password := zipFilePassword;

      ReadZip;

      DestDir := AsFilePath; // 解压后文件路径
      DoAll := True;
      RecreateDirs := True;
      RetainAttributes := True;
      OverwriteMode := Always;

      try
        UnZippedCount := UnZip;
      except
        on E: Exception do
        begin
          _log('解析模板文件异常：' + E.Message);
          Result := False;
          Exit;
        end;
      end;
    end;
  finally
    VCLUnZip1.Free;
  end;
end;

end.
