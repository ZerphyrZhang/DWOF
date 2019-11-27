unit THighlander_rtcDatabasePool;

// RTC SDK Test proyect
// freeware
// Font used in Delphi IDE = Fixedsys

{
  Database parameters:
  Set before first call to AddDBConn or GetDBConn.

  Put a database connection back into the pool.
  Need to call this after you’re done using the connection.

  GetDBConn = Get database connection from the pool.
  Need to call this after you’re done using the connection.

  CloseAllDBConns = Close all connections inside the Pool.
}

interface

uses

  // From CodeGear
  Classes, SysUtils, Data.Win.ADODB,

  // From RealThinClient
syncobjs;

type
  THL_RTC_DBPool = class
  private
    CS: TCriticalSection;
    fDBPool: TList;
  protected
    function SetUpDBConnection: TADOConnection; virtual; abstract;
    function InternalGetDBConn: TComponent;
    procedure InternalPutDBConn(conn: TComponent);
    function GetCount: integer;
  public
    db_server: ansistring;
    db_username: ansistring;
    db_password: ansistring;
    property Count: integer read GetCount;
    constructor Create;
    destructor Destroy; override;
    procedure AddDBConn;
    procedure CloseAllDBConns;
  end;

implementation

constructor THL_RTC_DBPool.Create;
begin
  inherited Create;
  CS := TCriticalSection.Create;
  fDBPool := TList.Create;
end;

function THL_RTC_DBPool.GetCount: integer;
begin
  result := fDBPool.Count;
end;

destructor THL_RTC_DBPool.Destroy;
begin
  CloseAllDBConns;
  fDBPool.Free;
  CS.Free;
  inherited;
end;

procedure THL_RTC_DBPool.AddDBConn;
begin
  CS.Enter;
  try
    fDBPool.Add(SetUpDBConnection);
  finally
    CS.Leave;
  end;
end;

function THL_RTC_DBPool.InternalGetDBConn: TComponent;
begin
  result := nil;
  CS.Enter;
  try
    if fDBPool.Count > 0 then
    begin
      result := fDBPool.items[fDBPool.Count - 1];
      fDBPool.Delete(fDBPool.Count - 1);
    end;
  finally
    CS.Leave;
  end;
end;

procedure THL_RTC_DBPool.InternalPutDBConn(conn: TComponent);
begin
  CS.Enter;
  try
    fDBPool.Add(conn);

  finally
    CS.Leave;
  end;
end;

procedure THL_RTC_DBPool.CloseAllDBConns;
var
  i: integer;
  dbx: TComponent;
begin
  CS.Enter;
  try
    for i := 0 to fDBPool.Count - 1 do
    begin
      dbx := fDBPool.items[i];
      FreeAndNil(dbx);
    end;
    fDBPool.clear;
  finally
    CS.Leave;
  end;
end;

end.

