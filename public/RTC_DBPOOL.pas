unit RTC_DBPOOL;

// RTC SDK Test proyect
// freeware
// Font used in Delphi IDE = Fixedsys

interface

uses
  Classes, SysUtils, Uni, THighlander_rtcDatabasePool, CommonUtil, Data.Win.ADODB;

type
  TDbObjPool = record
    ConnObj: TADOConnection; // ���ݿ����Ӷ���
    QryObj: TADOQuery; // ���ݿ���ʶ���
  end;

  PDBObjPool = ^TDbObjPool;

  THL_RTC_DBPoll = class(THL_RTC_DBPool)
  protected
    function SetUpDBConnection: TADOConnection; override;
  public
    function GetDBConnection: TADOConnection;
    function GetDBQuery: TADOQuery;
    function GetDBStoredProc: TADOStoredProc;
    procedure PutDBConn(conn: TComponent);
    function CanConnected: boolean;
  end;

var
  _RTC_DBPOLL: THL_RTC_DBPoll;
  _G_CREATE_COUNT: integer = 0;

implementation

function THL_RTC_DBPoll.SetUpDBConnection: TADOConnection;
var
  AsbTmp: TStringBuilder;
begin
  Result := TADOConnection.Create(nil);
  AsbTmp := TStringBuilder.Create;
  try
    try
      with Result do
      begin
        Close;
        LoginPrompt := False;
        if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 0 then
        begin
          AsbTmp.Append('Provider=MSDASQL.1;Password=' + COMINFOR.FCONFIGINFOR.DB_PWD + ';Persist Security Info=True;User ID=' + COMINFOR.FCONFIGINFOR.DB_USER + ';Data Source=' + COMINFOR.FCONFIGINFOR.DBSVR_IP + ';');
        end
        else if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 1 then
        begin
          AsbTmp.Append('Provider=MSDASQL.1;Persist Security Info=False;Extended Properties="DSN=' + COMINFOR.FCONFIGINFOR.DBSVR_IP + ';UID=' + COMINFOR.FCONFIGINFOR.DB_USER.ToUpper() + ';PWD=' + COMINFOR.FCONFIGINFOR.DB_PWD + ';');
          AsbTmp.Append('QTO=F;"');
          // Provider=MSDAORA.1;Password=limsadmin;User ID=limsv4;Data Source=orcl;Persist Security Info=True
          // AsbTmp.Append('Provider=MSDAORA.1;Password=limsadmin;User ID=limsv4;Data Source=orcl;Persist Security Info=False');
          // AsbTmp.Append('Provider=MSDASQL.1;Persist Security Info=False;Extended Properties="DSN=' + COMINFOR.FCONFIGINFOR.DBSVR_IP + ';UID=' + COMINFOR.FCONFIGINFOR.DB_USER.ToUpper() + ';PWD=' + COMINFOR.FCONFIGINFOR.DB_PWD + ';');
          // AsbTmp.Append('QTO=F;"');
          // AsbTmp.Append('DBA=W;APA=T;EXC=F;FEN=T;QTO=F;"');
          // AsbTmp.Append('FRC=10;FDL=10;LOB=T;RST=T;BTD=F;BNF=F;BAM=IfAllSuccessful;NUM=NLS;DPM=F;MTS=T;MDI=F;CSR=F;FWC=F;FBS=64000;TLO=O;MLD=0;ODA=F;"');
        end;
        Result.ConnectionString := AsbTmp.ToString();
        Open;
      end;
      _G_CREATE_COUNT := _G_CREATE_COUNT + 1;
      // _log('�������������������������������������������������������ӳأ�' + _G_CREATE_COUNT.ToString());
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(AsbTmp);
  end;
end;

function THL_RTC_DBPoll.GetDBConnection: TADOConnection;
begin
  // _log('������������������������������������������������TADOConnection��ʼ��ȡ���ӳأ�' + _G_CREATE_COUNT.ToString() + ',���ӳ�ʣ��������' + _RTC_DBPOLL.count.ToString);
  Result := TADOConnection(InternalGetDBConn);
  if Result = nil then
  begin
    // _log('������������������������������������������������TADOConnection��ȡ���ӳ�Ϊ�գ�' + _G_CREATE_COUNT.ToString());
    Result := SetUpDBConnection;
  end
  else if not(Result.Connected) then
  begin
    // _log('������������������������������������������������TADOConnection����ʧȥ���ӣ�' + _G_CREATE_COUNT.ToString());
    Result.Close;
    Result.Destroy;
    Result := SetUpDBConnection;
  end;
  Result.Tag := DateTimeToTimeStamp(now).Time;
  // MainForm.StatusBar1.Panels[5].Text := '���ӳ�������' + GetCount.ToString();
end;

function THL_RTC_DBPoll.GetDBQuery: TADOQuery;
var
  ArCon: TADOConnection;
begin
  // _log('������������������������������������������������TADOQuery��ʼ��ȡ���ӳأ�' + _G_CREATE_COUNT.ToString() + ',���ӳ�ʣ��������' + _RTC_DBPOLL.count.ToString);
  Result := TADOQuery.Create(nil);
  ArCon := TADOConnection(InternalGetDBConn);
  if ArCon = nil then
  begin
    // _log('������������������������������������������������TADOQuery��ȡ���ӳ�Ϊ�գ�' + _G_CREATE_COUNT.ToString());
    ArCon := SetUpDBConnection;
  end
  else if not(ArCon.Connected) then
  begin
    // _log('������������������������������������������������TADOQuery����ʧȥ���ӣ�' + _G_CREATE_COUNT.ToString());
    ArCon.Close;
    ArCon.Destroy;
    ArCon := SetUpDBConnection;
  end;
  ArCon.Tag := DateTimeToTimeStamp(now).Time;
  Result.connection := ArCon;
end;

function THL_RTC_DBPoll.GetDBStoredProc: TADOStoredProc;
var
  ArCon: TADOConnection;
begin
  // _log('������������������������������������������������TADOStoredProc��ʼ��ȡ���ӳأ�' + _G_CREATE_COUNT.ToString() + ',���ӳ�ʣ��������' + _RTC_DBPOLL.count.ToString);
  Result := TADOStoredProc.Create(nil);
  ArCon := TADOConnection(InternalGetDBConn);
  if ArCon = nil then
  begin
    // _log('������������������������������������������������TADOStoredProc��ȡ���ӳ�Ϊ�գ�' + _G_CREATE_COUNT.ToString());
    ArCon := SetUpDBConnection;
  end
  else if not(ArCon.Connected) then
  begin
    // _log('������������������������������������������������TADOStoredProc����ʧȥ���ӣ�' + _G_CREATE_COUNT.ToString());
    ArCon.Close;
    ArCon.Destroy;
    ArCon := SetUpDBConnection;
  end;
  ArCon.Tag := DateTimeToTimeStamp(now).Time;
  Result.connection := ArCon;
end;

procedure THL_RTC_DBPoll.PutDBConn(conn: TComponent);
var
  ArQry: TADOQuery;
  ArPro: TADOStoredProc;
  AiInTime, AdtNow, AiTimes: integer;
begin
  if conn is TADOQuery then
  begin
    // _log('������������������������������������������������TADOQuery�Ż����ӣ�' + _G_CREATE_COUNT.ToString());
    ArQry := TADOQuery(conn);
    InternalPutDBConn(ArQry.connection);
    AiInTime := ArQry.connection.Tag;
    AdtNow := DateTimeToTimeStamp(now).Time;
    conn.Free;
    AiTimes := AdtNow - AiInTime;
  end
  else if conn is TADOStoredProc then
  begin
    // _log('������������������������������������������������TADOStoredProc�Ż����ӣ�' + _G_CREATE_COUNT.ToString());
    ArPro := TADOStoredProc(conn);
    AiInTime := ArPro.connection.Tag;
    AdtNow := DateTimeToTimeStamp(now).Time;
    InternalPutDBConn(ArPro.connection);
    conn.Free;
    AiTimes := AdtNow - AiInTime;
  end
  else if conn is TADOConnection then
  begin
    // _log('������������������������������������������������TADOConnection�Ż����ӣ�' + _G_CREATE_COUNT.ToString());
    AiInTime := conn.Tag;
    AdtNow := DateTimeToTimeStamp(now).Time;
    InternalPutDBConn(conn);
    AiTimes := AdtNow - AiInTime;
  end;
  _log('ִ����ɣ�����ʱ' + AiTimes.ToString + '���룬���ӳ�ʵʱʣ��������' + GetCount.ToString());
end;

function THL_RTC_DBPoll.CanConnected: boolean;
var
  pIBXTrans: TADOConnection;
  AsbTmp: TStringBuilder;
begin
  Result := False;
  pIBXTrans := TADOConnection.Create(nil);
  AsbTmp := TStringBuilder.Create;
  try
    try
      with pIBXTrans do
      begin
        Close;
        LoginPrompt := False;
        if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 0 then
        begin
          AsbTmp.Append('Provider=MSDASQL.1;Password=' + COMINFOR.FCONFIGINFOR.DB_PWD + ';Persist Security Info=True;User ID=' + COMINFOR.FCONFIGINFOR.DB_USER + ';Data Source=' + COMINFOR.FCONFIGINFOR.DBSVR_IP + ';');
        end
        else if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 1 then
        begin
          //
          AsbTmp.Append('Provider=MSDASQL.1;Persist Security Info=False;Extended Properties="DSN=' + COMINFOR.FCONFIGINFOR.DBSVR_IP + ';UID=' + COMINFOR.FCONFIGINFOR.DB_USER.ToUpper() + ';PWD=' + COMINFOR.FCONFIGINFOR.DB_PWD + ';');
          AsbTmp.Append('QTO=F;"');
          // AsbTmp.Append('DBA=W;APA=T;EXC=F;FEN=T;QTO=T;FRC=10;FDL=10;LOB=T;RST=T;BTD=F;BNF=F;BAM=IfAllSuccessful;NUM=NLS;DPM=F;MTS=T;MDI=F;CSR=F;FWC=F;FBS=64000;TLO=O;MLD=0;ODA=F;"');

        end;
        pIBXTrans.ConnectionString := AsbTmp.ToString();
        Open;

        Close;
        Result := True;
      end;
    except

      raise;
    end;
  finally
    FreeAndNil(pIBXTrans);
    FreeAndNil(AsbTmp);
  end;
end;

end.
