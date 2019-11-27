unit CommonUtil;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs,
  Registry, StrUtils, system.json, generics.collections, Data.DB, cxVGrid, Vcl.Forms, Vcl.StdCtrls;

type
  TSVR_SETTING = record
    SVR_IP: string;
    SVR_PORT: string;
    CUR_SVR: string;
    DBSVR_TYPE: Integer;
    DBSVR_IP: string;
    DBSVR_PORT: Integer;
    DB_NAME: string;
    DB_USER: string;
    DB_PWD: string;
    DB_FILE: string;
    POOL_MAX: Integer;
    POOL_MIN: Integer;
    TCAT_PATH: string;
  end;

  TPSVR_SETTING = ^TSVR_SETTING;

  TCommonInfor = class
  public
    FCONFIGINFOR: TPSVR_SETTING;
    FAPPPATH: string;
    FINIPATH: string;
    FDEVMODE: Integer;
    constructor Create();
    destructor Destroy;
    function loadDBConfig(AsCurCfg: string): boolean;
  end;

function VayisNull(obj: Variant): boolean;

function VarNotNull(obj: Variant): boolean;

function isNull(obj: TObject): boolean;

function isNotNull(obj: TObject): boolean;

function isEmpty(str: string): boolean;

function isNotEmpty(str: string): boolean;

function strToDate(str: string): TDateTime;

function StrToInteger(str: string): Integer;

function StrToflt(str: string): double;

function encodeStrNj(str: string): string;

function listToStr(pSbSql: string; str: string): string;

procedure _log(cTxt: string; const ALevel: Integer = 0);

function GetBuildInfo: string;

procedure readFileToByte(pFile: string; pParms: Tparam);

function ExtractFileNameNoExt(FileString: string): string;

function FindProcess(AFileName: string): boolean; //

procedure LW_MSG_ERROR(AsContent: string);

procedure LW_MSG_INFOR(AsContent: string);

function VGCellCheck(AcxRowEditor: TcxEditorRow): boolean;

function VGCellValue(AcxRowEditor: TcxEditorRow): string;

procedure VGSetCellValue(AcxRowEditor: TcxEditorRow; AsValue: string);

function DownLoadFile(AsFilePath: string): string;

function GetXlsFile(AsFilePath: string): string;

function chkedit(AetTmp: TEdit): boolean;
function chkedits(AetTmps: array of TEdit): boolean;

var
  COMINFOR: TCommonInfor;
  _gTypeNames: TDictionary<string, string>;

implementation

uses
  Contants, Inifiles, MD5, TLHelp32, IdHTTP, LogUtils;
/// <summary>
///
/// </summary>
/// <returns></returns>

function GetAppFilePath(): string;
var
  ModuleName: string;
begin
  // SetLength(ModuleName, 255);
  // GetModuleFileName(HInstance, PChar(ModuleName), Length(ModuleName));
  // result := ExtractFileDir(ModuleName);
  result := ExtractFilePath(Application.Exename);
end;

/// <summary>
///
/// </summary>

constructor TCommonInfor.Create();
var
  AiniFile: TIniFile;
  AsCurSvr: string;
begin
  FAPPPATH := GetAppFilePath;
  FINIPATH := FAPPPATH + Contants.INIFILENAME;
  FDEVMODE := 1;
  AiniFile := TIniFile.Create(FINIPATH);

  try
    new(FCONFIGINFOR);
    FCONFIGINFOR.SVR_IP := AiniFile.ReadString(Contants.SVRCONFIG, Contants.SVRIP, 'localhost');
    FCONFIGINFOR.SVR_PORT := AiniFile.ReadString(Contants.SVRCONFIG, Contants.SVRPORT, '8080');

    AsCurSvr := AiniFile.ReadString('CFGSVR', 'CURSVR', 'localhost');
    if AsCurSvr <> '' then
    begin
      FCONFIGINFOR.CUR_SVR := AsCurSvr;
      FCONFIGINFOR.DBSVR_TYPE := AiniFile.ReadInteger(AsCurSvr, Contants.DBTYPE, 0);
      FCONFIGINFOR.DBSVR_IP := AiniFile.ReadString(AsCurSvr, Contants.DBSVRIP, 'localhost');
      FCONFIGINFOR.DBSVR_PORT := AiniFile.ReadInteger(AsCurSvr, Contants.DBSVRPORT, 3306);
      FCONFIGINFOR.DB_NAME := AiniFile.ReadString(AsCurSvr, Contants.DBNAME, 'limsv3');
      FCONFIGINFOR.DB_USER := AiniFile.ReadString(AsCurSvr, Contants.DBUSER, 'lims');
      FCONFIGINFOR.DB_PWD := AiniFile.ReadString(AsCurSvr, Contants.DBPWD, 'limsadmin');
      FCONFIGINFOR.DB_FILE := AiniFile.ReadString(AsCurSvr, 'DBFILE', 'db.xml');

    end;

    FCONFIGINFOR.POOL_MAX := AiniFile.ReadInteger(Contants.CONPOOLCONFIG, Contants.PLMAX, 50);
    FCONFIGINFOR.POOL_MIN := AiniFile.ReadInteger(Contants.CONPOOLCONFIG, Contants.PLMIN, 30);
    FCONFIGINFOR.TCAT_PATH := AiniFile.ReadString(Contants.TOMCATSETING, Contants.TOMCATPATH, '');

    _gTypeNames := TDictionary<string, string>.Create();
    _gTypeNames.Add(Contants._LOGIN, Contants._SLOGIN);
    _gTypeNames.Add(Contants._NEW, Contants._SNEW);
    _gTypeNames.Add(Contants._UPDATE, Contants._SUPDATE);
    _gTypeNames.Add(Contants._DELETE, Contants._SDELETE);
    _gTypeNames.Add(Contants._EXECPROC, Contants._SEXECPROC);
  finally
    AiniFile.Free;

  end;
end;
/// <summary>
///
/// </summary>

destructor TCommonInfor.Destroy;
// var
// AsTmp:string;
begin
  FCONFIGINFOR.SVR_IP := '';
  FCONFIGINFOR.SVR_PORT := '';
  FCONFIGINFOR.CUR_SVR := '';
  FCONFIGINFOR.DBSVR_IP := '';
  FCONFIGINFOR.DB_NAME := '';
  FCONFIGINFOR.DB_USER := '';
  FCONFIGINFOR.DB_PWD := '';
  FCONFIGINFOR.DB_FILE := '';
  FCONFIGINFOR.TCAT_PATH := '';
  Dispose(FCONFIGINFOR);
  _gTypeNames.Clear;
  _gTypeNames.Free;
  // for AsTmp in _gTypeNames.Keys do
  // begin
  //
  // end;

end;

function TCommonInfor.loadDBConfig(AsCurCfg: string): boolean;
var
  AiniFile: TIniFile;
begin
  result := false;
  try
    try
      AiniFile := TIniFile.Create(FINIPATH);
      AiniFile.WriteString('CFGSVR', 'CURSVR', AsCurCfg);

      if AsCurCfg <> '' then
      begin
        FCONFIGINFOR.CUR_SVR := AsCurCfg;
        FCONFIGINFOR.DBSVR_TYPE := AiniFile.ReadInteger(AsCurCfg, Contants.DBTYPE, 0);
        FCONFIGINFOR.DBSVR_IP := AiniFile.ReadString(AsCurCfg, Contants.DBSVRIP, 'localhost');
        FCONFIGINFOR.DBSVR_PORT := AiniFile.ReadInteger(AsCurCfg, Contants.DBSVRPORT, 3306);
        FCONFIGINFOR.DB_NAME := AiniFile.ReadString(AsCurCfg, Contants.DBNAME, 'limsv3');
        FCONFIGINFOR.DB_USER := AiniFile.ReadString(AsCurCfg, Contants.DBUSER, 'lims');
        FCONFIGINFOR.DB_PWD := AiniFile.ReadString(AsCurCfg, Contants.DBPWD, 'limsadmin');
        FCONFIGINFOR.DB_FILE := AiniFile.ReadString(AsCurCfg, 'DBFILE', 'db.xml');
        result := true;
      end;
    except
      on e: exception do
      begin
        LW_MSG_ERROR('�������������ļ�ʧ�ܣ���' + e.Message);
      end;
    end;
  finally
    AiniFile.Free;
  end;
end;
/// <summary>
///
/// </summary>
/// <param v="cTxt"></param>

procedure _log(cTxt: string; const ALevel: Integer = 0);
var
  AsMsg: string;
begin
  _WriteLog(cTxt, ALevel);
  // if ALevel = 0 then
  // begin
  // AsMsg := '[' + FormatDateTime('yyyy/mm/dd hh:nn:ss:zzz', now) + ']' + '------> ' + cTxt;
  /// /    MainForm._Main_Log(AsMsg);
  // end;
end;
///
/// �ж϶����Ƿ�Ϊnull
///
/// @author yzw
/// @result := boolean
/// @date 2016-3-2
/// /

function VayisNull(obj: Variant): boolean;
begin
  if VarIsNull(obj) or (obj = Unassigned) then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

///
/// �ж϶����Ƿ�Ϊnull
///
/// @author yzw
/// @result := boolean
/// @date 2016-3-2
/// /

function VarNotNull(obj: Variant): boolean;
begin
  if VayisNull(obj) then
  begin
    result := false;
  end
  else
  begin
    result := true;
  end;
end;
/// �ж϶����Ƿ�Ϊnull
/// @author yzw
/// @result := boolean
/// @date 2016-3-2

function isNull(obj: TObject): boolean;
begin
  if obj = nil then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;
/// �ж϶����Ƿ�Ϊnull
/// @author yzw
/// @result := boolean
/// @date 2016-3-2

function isNotNull(obj: TObject): boolean;
begin
  result := not isNull(obj);
end;

/// ////
/// �ж��ַ���Ϊ��
///
/// @author yzw
/// @result := boolean
/// @date 2016-3-2
/// /
function isEmpty(str: string): boolean;
begin
  if (trim(str) = '') then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;
/// ////
/// �ж��ַ����Ƿ�Ϊ��
///
/// @author yzw
/// @result := boolean
/// @date 2016-3-2
/// /

function isNotEmpty(str: string): boolean;
begin
  result := not isEmpty(str);
end;

/// ////
/// json�ַ���תΪjson��ʽ����
///
/// @author yzw
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /
function strToJson(str: string): TJSONObject;
begin
  if (isNotEmpty(str)) then
  begin
    result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(str), 0) as TJSONObject; // תΪjson
  end
  else
  begin
    result := nil;
  end;
end;
/// ////
/// �ַ���תΪ���ڸ�ʽ
///
/// @author yzw
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /

function strToDate(str: string): TDateTime;
var
  FSetting: TFormatSettings;
begin

  FSetting := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  FSetting.ShortDateFormat := 'yyyy-MM-dd';
  FSetting.DateSeparator := '-';
  // FSetting.TimeSeparator:=':';
  FSetting.LongTimeFormat := 'hh:mm:ss.zzz';
  result := StrToDateTime(str, FSetting);
end;
/// ////
/// �ַ���ת����
///
/// @author zepher
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /

function StrToInteger(str: string): Integer;
begin
  result := strToInt(str);
end;
/// ////
/// �ַ���ת����
///
/// @author zepher
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /

function StrToflt(str: string): double;
begin
  result := strtofloat(str);
end;

/// ////
/// �û�����md5����
///
/// @author zepher
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /
// function encodeStr(str: string): string;
// var
// MD5: IMD5;
// AsTmp: string;
// begin
// result := '';
//
// if (isNotEmpty(str)) then
// begin
// MD5 := GetMD5;
// MD5.Init;
// MD5.Update(TByteDynArray(RawByteString(str)), Length(str));
// AsTmp := LowerCase(MD5.AsString);
// result := AsTmp;
// end;
// end;
/// ////
/// �û�����md5����
///
/// @author zepher
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /
function encodeStrNj(str: string): string;
var
  AsTmp: string;
begin
  result := '';
  if (isNotEmpty(str)) then
  begin
    result := LowerCase(MD5.MD5Print(MD5AnsiString(str)));
  end;
end;
/// �����ַ���ת�ַ��� ���ݷָ���
///
/// @author zepher
/// @result := String
/// @throws Exception
/// @date 2016-2-29
/// /

function listToStr(pSbSql: string; str: string): string;
var
  AsTmp: string;
  AaryTmp: TArray<string>;
begin
  AaryTmp := pSbSql.Split([Contants.DOU], ExcludeEmpty);
  result := AsTmp.Join(str, AaryTmp);
end;
/// <summary>
/// //��ȡ�汾��
/// </summary>
/// <returns></returns>

function GetBuildInfo: string;
var
  verinfosize: DWORD;
  verinfo: pointer;
  vervaluesize: DWORD;
  vervalue: pvsfixedfileinfo;
  dummy: DWORD;
  v1, v2, v3, v4: word;
begin

  verinfosize := getfileversioninfosize(PChar(paramstr(0)), dummy);
  if verinfosize = 0 then
  begin
    dummy := getlasterror;
    result := '0.0.0.0';
  end;
  getmem(verinfo, verinfosize);
  getfileversioninfo(PChar(paramstr(0)), 0, verinfosize, verinfo);

  verqueryvalue(verinfo, '\', pointer(vervalue), vervaluesize);

  with vervalue^ do
  begin
    v1 := dwfileversionms shr 16;
    v2 := dwfileversionms and $FFFF;
    v3 := dwfileversionls shr 16;
    v4 := dwfileversionls and $FFFF;
  end;
  result := inttostr(v1) + '.' + inttostr(v2) + '.' + inttostr(v3) + '.' + inttostr(v4);
  freemem(verinfo, verinfosize);

end;

procedure readFileToByte(pFile: string; pParms: Tparam);
var
  Mem: TMemoryStream;
  buf: array of byte; // �½�Ϊ0���Լ�1
begin
  try
    try
      Mem := TMemoryStream.Create;
      Mem.LoadFromFile(pFile);
      pParms.LoadFromFile(pFile, ftBlob);

    except
      on e: exception do
      begin
        exception.ThrowOuterException(exception.Create(e.Message));
      end;

    end;
  finally
    Mem.Free;
  end;

end;

function ExtractFileNameNoExt(FileString: string): string;
var
  FileWithExtString: string;
  FileExtString: string;
  LenExt: Integer;
  LenNameWithExt: Integer;
begin
  FileWithExtString := ExtractFileName(FileString);
  LenNameWithExt := Length(FileWithExtString);
  FileExtString := ExtractFileExt(FileString);
  LenExt := Length(FileExtString);
  if LenExt = 0 then
  begin
    result := FileWithExtString;
  end
  else
  begin
    result := Copy(FileWithExtString, 1, (LenNameWithExt - LenExt));
  end;
end;

function FindProcess(AFileName: string): boolean; //
var
  hSnapshot: THandle; // ���ڻ�ý����б�
  lppe: TProcessEntry32; // ���ڲ��ҽ���
  Found: boolean; // �����жϽ��̱����Ƿ����
begin
  result := false;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); // ���ϵͳ�����б�
  lppe.dwSize := SizeOf(TProcessEntry32); // �ڵ���Process32First API֮ǰ����Ҫ��ʼ��lppe��¼�Ĵ�С
  Found := Process32First(hSnapshot, lppe); // �������б�ĵ�һ��������Ϣ����ppe��¼��
  while Found do
  begin
    if ((UpperCase(ExtractFileName(lppe.szExeFile)) = UpperCase(AFileName)) or (UpperCase(lppe.szExeFile) = UpperCase(AFileName))) then
    begin
      result := true;
    end;
    Found := Process32Next(hSnapshot, lppe); // �������б����һ��������Ϣ����lppe��¼��
  end;
end;

procedure LW_MSG_ERROR(AsContent: string);
begin
  MessageBox(Application.Handle, PWideChar(AsContent), 'ϵͳ��ʾ', MB_OK + MB_ICONWARNING);
end;

procedure LW_MSG_INFOR(AsContent: string);
begin
  MessageBox(Application.Handle, PWideChar(AsContent), 'ϵͳ��ʾ', MB_OK + MB_ICONINFORMATION);
end;

function VGCellCheck(AcxRowEditor: TcxEditorRow): boolean;
var
  AcxRowEditProperty: TcxEditorRowProperties;
  AsValue: string;
begin
  result := true;
  AcxRowEditProperty := AcxRowEditor.Properties;
  AsValue := Vartostr(AcxRowEditProperty.Value);
  if AsValue = '' then
  begin
    result := false;
    LW_MSG_ERROR(AcxRowEditProperty.Caption + '������Ϊ�գ���');
    AcxRowEditor.Focused := true;
  end;
end;

function VGCellValue(AcxRowEditor: TcxEditorRow): string;
var
  AcxRowEditProperty: TcxEditorRowProperties;
  AsValue: string;
begin
  result := Vartostr(AcxRowEditor.Properties.Value);
end;

procedure VGSetCellValue(AcxRowEditor: TcxEditorRow; AsValue: string);
begin
  AcxRowEditor.Properties.Value := AsValue;
end;

function GetURLFileName(aURL: string): string;
var
  i: Integer;
  s: string;
begin
  s := aURL;
  i := Pos('/', s);
  while i <> 0 do
  begin
    Delete(s, 1, i);
    i := Pos('/', s);
  end;
  result := s;
end;

function DownLoadFile(AsFilePath: string): string;
var
  aURL, AsFileRootPath: string;
  MemStream: TMemoryStream;
  FileStream: TFileStream;
  FilePosition: Int64;
  FileSize: Integer;
  Filename: string;
  IdHTTP: TIdHttp;
begin
  result := '';
  IdHTTP := TIdHttp.Create(nil);
  try
    // http://192.168.1.119:8098/upgrade.zip
    aURL := AsFilePath;
    // �����ض���
    IdHTTP.HandleRedirects := true;
    IdHTTP.Request.Range := '';
    IdHTTP.Head(aURL);
    // ��ȡ�ض�����URL
    aURL := IdHTTP.URL.URI;
    // ��ȡ�ļ���
    AsFileRootPath := ExtractFilePath(Application.Exename) + 'template\\';
    if not DirectoryExists(AsFileRootPath) then
    begin
      ForceDirectories(AsFileRootPath);
    end;
    Filename := AsFileRootPath + GetURLFileName(aURL);
    if FileExists(Filename) then
    begin
      // DeleteFile(Filename);

      result := Filename;
      exit;
    end;
    if FileExists(Filename + '.tmp') then
    begin
      try
        FileStream := TFileStream.Create(Filename + '.tmp', fmOpenWrite);
        FileStream.Seek(0, soEnd); // ָ���Ƶ�ĩβ
      except
        _log(Format('ELNFILE:����ģ���ļ� "%s" ʧ��!', [Filename]));
        exit;
      end;
    end
    else
    begin
      FileStream := TFileStream.Create(Filename + '.tmp', fmCreate);
    end;
    // �����ڴ���
    MemStream := TMemoryStream.Create;
    // �õ��ļ���С
    FileSize := IdHTTP.Response.ContentLength;
    FilePosition := FileStream.Position;
    // ���ý�����
    // ProgressBar.Max := FileSize;
    try
      // ѭ�����أ�ÿ���ж��Ƿ���ͣ
      while (FilePosition < FileSize) do
      begin
        IdHTTP.Request.Range := inttostr(FilePosition) + '-';
        // ÿ������10240B���ļ��飬��Ȼ���Ըĳ�������С
        if FilePosition + 512000 < FileSize then
          IdHTTP.Request.Range := IdHTTP.Request.Range + inttostr(FilePosition + 511999);
        IdHTTP.get(aURL, MemStream); // ÿ�ηֱ�����ڴ���
        MemStream.SaveToStream(FileStream);
        inc(FilePosition, MemStream.Size);
        // ���½�����
        // ProgressBar.Position := FilePosition;
        // ����ڴ���
        MemStream.Clear;
        // ͨ���������������ֹ���濨��
        Application.ProcessMessages;
      end;
      // �������ڰ���ֹͣ��������ѭ��˵�����������,�޸��ļ���
      // if (not Stop) then
      // begin
      FreeAndNil(FileStream);
      RenameFile(Filename + '.tmp', Filename);
      result := Filename;
      // MessageBox(0, PWideChar(Format('����ģ���ļ� "%s" �ɹ�!', [Filename])), '��ʾ', MB_ICONERROR + MB_Ok);
      // end;
    finally
      MemStream.DisposeOf;
      if Assigned(FileStream) then
        FileStream.DisposeOf;
    end;
    // Result := True;
  finally
    // ���Ҫ�ǵ��ð�ť�ɰ�
    IdHTTP.DisposeOf;
  end;
end;

function GetXlsFile(AsFilePath: string): string;
var
  AsTmp, AsFileName, AsSavePath: string;
  FindResult: Integer;
  FSearchRec, DSearchRec: TSearchRec;
  AsFileExt: string;
begin
  result := '';
  FindResult := FindFirst(AsFilePath + '*.*', faAnyFile + faHidden + faSysFile + SysUtils.faReadOnly, FSearchRec);
  try
    while FindResult = 0 do
    begin
      AsFileExt := ExtractFileExt(FSearchRec.Name);
      if (AsFileExt = '.xlsx') or (AsFileExt = '.xls') then
      begin
        result := AsFilePath + FSearchRec.Name;
      end;
      FindResult := FindNext(FSearchRec);
    end;
  finally
    FindClose(FSearchRec);
  end;
end;

function chkedit(AetTmp: TEdit): boolean;
begin
  result := true;
  if AetTmp.Text = '' then
  begin
    result := false;
    LW_MSG_INFOR(AetTmp.Hint + '������Ϊ�ա�');
    AetTmp.SetFocus;
    exit;
  end;
end;

function chkedits(AetTmps: array of TEdit): boolean;
var
  AiiIdx, AiiCnt: Integer;
begin
  result := true;
  AiiIdx := 0;
  AiiCnt := Length(AetTmps);
  while (result) do
  begin
    result := chkedit(AetTmps[AiiIdx]);
    if (AiiIdx = AiiCnt - 1) then
    begin
      Break;
    end
    else
    begin
      AiiIdx := AiiIdx + 1;
    end;
  end;
end;

end.
/// ////
/// �ж϶����Ƿ�Ϊnull
///
/// @author yzw
/// @result := boolean
/// @date 2016-3-2
/// /
// function isLogoned(request:HttpServletRequest ) begin
// HttpSession ASession = request.getSession();
// Object obj = ASession.getAttribute(Contants.CURRENT_USER);
// result := CommonUtil.isNotNull(obj);
// end

/// ////
/// ����json�ֶ�����ȡjsonֵ �ַ���
///
/// @author yzw
/// @result := String
/// @date 2016-3-3
/// /
// function static String getJsonValue(JSONObject jsonStr, String attribute) begin
// if (isNotNull(jsonStr)) begin
// if (jsonStr.containsKey(attribute)) begin
// result := jsonStr.getString(attribute);
// end
// end
// result := null;
// end

/// ////
/// ��ȡxml�ļ���Ϣ
///
/// @author yzw
/// @result := void
/// @date 2016-2-29
/// /
// function static File getXmlData() begin
// String AsfilePath = ReadXml.class.getClassLoader().getResource(Contants.DBXML).getFile();
// System.out.println(AsfilePath);
// if (CommonUtil.isNotEmpty(AsfilePath)) begin
// // ��ȡ�ļ���λ�� �������ļ�
// result := new File(AsfilePath);
// end else begin
// result := null;
// end
