unit ElnManager;

interface

uses
  windows, sysutils, syncobjs, classes, dialogs, FileCtrl, generics.collections, SuperObject;

type
  T_FILEDATA = record
    _FILE_ID: integer;
    _FILE_PATH: string;
    _FILE_XLSPATH: string;
    _FILE_XMLPATH: string;
    _FILE_DATAS: IsuperObject;
  end;

  TP_FILEDATA = ^T_FILEDATA;

  T_MEGERAREA = record
    _ROW: integer;
    _COL: integer;
    _ROWCNT: integer;
    _COLCNT: integer;
  end;

  TP_MEGERAREA = ^T_MEGERAREA;

  TElnManager = class
  private
    FFileLock: TCriticalSection;
    FList: Tlist;
    FFileDatas: TDictionary<integer, TP_FILEDATA>;
    function unZipFile(zipFilePath, psFileName, zipFilePassword: string): Boolean;
  public
    constructor create();
    destructor destroy; override;
    function AddTplFile(AsFilePath, AsFileName: string): integer;
    function GetTplFileData(): TP_FILEDATA;
    procedure AddFiled(ApFile: TP_FILEDATA);
    function GetFiled(AiFileIndex: integer): TP_FILEDATA;

  end;

const
  _GZipPwd = '.aer1258963!@#$';

implementation

uses DateUtils, VCLZip, VCLUnZip, CommonUtil;

constructor TElnManager.create();
begin
  inherited create;
  FList := Tlist.create;
  FFileDatas := TDictionary<integer, TP_FILEDATA>.create;
  FFileLock := TCriticalSection.create;
end;

destructor TElnManager.destroy;

begin
  FFileLock.Free;
  FList.Free;
  FFileDatas.Free;
  inherited destroy;
end;

function TElnManager.unZipFile(zipFilePath, psFileName, zipFilePassword: string): Boolean;
var
  UnZippedCount: integer;
  VCLUnZip1: TVCLUnZip;
  AsFilePath: string;
begin
  Result := True;
  VCLUnZip1 := TVCLUnZip.create(nil);
  AsFilePath := COMINFOR.FAPPPATH + '\template\' + psFileName + '\';
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

function TElnManager.AddTplFile(AsFilePath, AsFileName: string): integer;
var
  ApFileData: TP_FILEDATA;
  AiFileIdx: integer;
begin
  Result := -1;
  FFileLock.enter;
  try
    AiFileIdx := DateTimeToUnix(Now);
    if unZipFile(AsFilePath, AiFileIdx.ToString, _GZipPwd) then
    begin
      New(ApFileData);
      ApFileData._FILE_ID := AiFileIdx;
      ApFileData._FILE_PATH := AsFilePath;
      ApFileData._FILE_XLSPATH := COMINFOR.FAPPPATH + '\template\' + AiFileIdx.ToString + '\' + AsFileName;
      ApFileData._FILE_XMLPATH := COMINFOR.FAPPPATH + '\template\' + AiFileIdx.ToString + '\' + ChangeFileExt(AsFileName, '.xml');;
      ApFileData._FILE_DATAS := nil;
      FList.Add(ApFileData);
      Result := ApFileData._FILE_ID;
    end;

  finally
    FFileLock.Leave;
  end;
end;

procedure TElnManager.AddFiled(ApFile: TP_FILEDATA);
begin
  FFileDatas.Add(ApFile._FILE_ID, ApFile);
end;

function TElnManager.GetTplFileData(): TP_FILEDATA;
var
  ApFileData: TP_FILEDATA;
begin
  Result := nil;
  FFileLock.enter;
  try
    if FList.Count > 0 then
    begin
      Result := FList.items[0];
      FList.Delete(0);
    end;
  finally
    FFileLock.Leave;
  end;
end;

function TElnManager.GetFiled(AiFileIndex: integer): TP_FILEDATA;
begin
  if FFileDatas.ContainsKey(AiFileIndex) then
  begin
    Result := FFileDatas[AiFileIndex];
  end
  else
  begin
    Result := nil;
  end;

end;

end.
