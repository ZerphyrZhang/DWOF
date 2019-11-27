unit THighlander_rtcClientPool;

interface

uses
  // From CodeGear
  Classes, SysUtils, RawTcpClient,

  // From RealThinClient
  syncobjs;

type
  THL_RTC_CLTPool = class
  private
    CS: TCriticalSection;
    fCLTPool: TList;
  protected
    function SetUpClient(pHost: string; pPort: integer): TRawTcpClient; virtual; abstract;
    function InternalGetClient: TComponent;
    function GetCount: integer;
    procedure InternalPutClient(conn: TComponent);
  public
    db_server: ansistring;
    db_username: ansistring;
    db_password: ansistring;
    property Count: integer read GetCount;
    constructor Create;
    destructor Destroy; override;
    procedure AddClient(pHost: string; pPort: integer);
    procedure CloseAllClients;
  end;

implementation

constructor THL_RTC_CLTPool.Create;
begin
  inherited Create;
  CS := TCriticalSection.Create;
  fCLTPool := TList.Create;
end;

function THL_RTC_CLTPool.GetCount: integer;
begin
  result := fCLTPool.Count;
end;

destructor THL_RTC_CLTPool.Destroy;
begin
  CloseAllClients;
  fCLTPool.Free;
  CS.Free;
  inherited;
end;

procedure THL_RTC_CLTPool.AddClient(pHost: string; pPort: integer);
begin
  CS.Enter;
  try
    fCLTPool.Add(SetUpClient(pHost, pPort));
  finally
    CS.Leave;
  end;
end;

function THL_RTC_CLTPool.InternalGetClient: TComponent;
begin
  result := nil;
  CS.Enter;
  try
    if fCLTPool.Count > 0 then
    begin
      result := fCLTPool.items[fCLTPool.Count - 1];
      fCLTPool.Delete(fCLTPool.Count - 1);
    end;
  finally
    CS.Leave;
  end;
end;

procedure THL_RTC_CLTPool.InternalPutClient(conn: TComponent);
begin
  CS.Enter;
  try
    fCLTPool.Add(conn);
  finally
    CS.Leave;
  end;
end;

procedure THL_RTC_CLTPool.CloseAllClients;
var
  i: integer;
  dbx: TComponent;
begin
  CS.Enter;
  try
    for i := 0 to fCLTPool.Count - 1 do
    begin
      dbx := fCLTPool.items[i];
      FreeAndNil(dbx);
    end;
    fCLTPool.clear;
  finally
    CS.Leave;
  end;
end;

end.

