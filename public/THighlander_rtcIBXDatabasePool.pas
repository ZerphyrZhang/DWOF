unit THighlander_rtcIBXDatabasePool;

// RTC SDK Test proyect
// freeware
// Font used in Delphi IDE = Fixedsys

interface

uses
  // From CodeGear
  Classes, SysUtils,

  // Classes and Components for accessing Interbase from Codegear
  Uni,

  // From RealThinClient
  rtcSyncObjs,

  // Dennis Ortiz rtc DBPool version;
  THighlander_rtcDatabasePool, CommonUtil;

type
  TDbObjPool = record
    ConnObj: TUniConnection;      //数据库连接对象
    QryObj: TUniQuery;            //数据库访问对象
  end;

  PDBObjPool = ^TDbObjPool;

  THL_RTC_IBXDBPoll = class(THL_RTC_DBPool)
  protected
    function SetUpDB: TUniQuery; override;
  public
    function GetDBConn: TUniQuery;
    procedure PutDBConn(conn: TUniQuery);
  end;

implementation

function THL_RTC_IBXDBPoll.SetUpDB: TUniQuery;
var
  pIBXTrans: TUniConnection;
begin
  pIBXTrans := TUniConnection.Create(nil);
  try
    with pIBXTrans do
    begin
      Close;
      LoginPrompt := False;
      ProviderName := 'MySQL';
      SpecificOptions.Values['UseUnicode'] := 'True';
      Username := COMINFOR.FCONFIGINFOR.DB_USER;
      Password := COMINFOR.FCONFIGINFOR.DB_PWD;
      Server := COMINFOR.FCONFIGINFOR.DBSVR_IP;
      Database := COMINFOR.FCONFIGINFOR.DB_NAME;
      Port := COMINFOR.FCONFIGINFOR.DBSVR_PORT;
      Open;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function THL_RTC_IBXDBPoll.GetDBConn: TUniQuery;
begin
  result := TUniQuery(InternalGetDBConn);

  if Result = nil then
  begin
    Result := SetupDB;
  end
  else if not (Result.Connection.Connected) then
  begin
    Result.Connection.Free;
    Result.Free;
    Result := SetupDB;
  end;

end;

procedure THL_RTC_IBXDBPoll.PutDBConn(conn: TUniQuery);
begin
  if conn is TUniQuery then
    InternalPutDBConn(conn);
end;

end.

