unit RTC_CLTPOOL;

// RTC SDK Test proyect
// freeware
// Font used in Delphi IDE = Fixedsys

interface

uses
  Classes, SysUtils, StrUtils, THighlander_rtcClientPool, CommonUtil,
  RawTcpClient, generics.collections, iocpTcpServer;

type
  TCLT_REC = record
    CLT_IP: string;
    CLT_PORT: integer;
  end;

  TPCLT_REC = ^TCLT_REC;

  TClientsManager = class
  private
    // _gCS: TCriticalSection;

  public
    _gClts: TDictionary<string, TPCLT_REC>;
    FTcpServer: TIocpTcpServer;
    constructor Create;
    destructor Destroy; override;
    procedure AddGroup(pGrpID, pCltIP: string; pCltPort: integer);
    procedure DeleteGroup(pGrpID: string);
    procedure DeleteClient(pCltIp: string);
    procedure DeleteAllClient();
    function GetClient(pGrpID: string): TRawTcpClient;
    procedure PutClient(conn: TComponent);
    procedure OnRecvBuffer(pvClientContext: TIocpClientContext; buf: Pointer; len: cardinal; errCode: Integer);
  end;

  THL_RTC_CLTPoll = class(THL_RTC_CLTPool)
  protected
    function SetUpClient(pHost: string; pPort: integer): TRawTcpClient; override;
  public
    function GetClient(pHost: string; pPort: integer): TRawTcpClient;
    procedure PutClient(conn: TComponent);
  end;

var
  _RTC_CLTPOLL: THL_RTC_CLTPoll;
  _CLT_MGR: TClientsManager;

implementation

uses
  iocpEngine, MainFormUnit;

function THL_RTC_CLTPoll.SetUpClient(pHost: string; pPort: integer): TRawTcpClient;
begin
  Result := TRawTcpClient.Create(nil);
  try
    try
      with Result do
      begin
        Result.Host := pHost;
        Result.Port := pPort;
        Result.Connect;
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally

  end;
end;

function THL_RTC_CLTPoll.GetClient(pHost: string; pPort: integer): TRawTcpClient;
begin
  Result := TRawTcpClient(InternalGetClient);
  if Result = nil then
  begin
    Result := SetUpClient(pHost, pPort);
  end
  else
  begin
    if not ((Result.Host = pHost) and (Result.Port = pPort)) then
    begin
      if Result.Active then
      begin
        Result.Disconnect;
      end;
      Result.Host := pHost;
      Result.Port := pPort;
      Result.Connect;
    end
    else
    begin
      Result.Disconnect;
      Result.Connect;
    end;
  end;
  _log('负载均衡连接已创建数量：' + GetCount.ToString());
end;

procedure THL_RTC_CLTPoll.PutClient(conn: TComponent);
begin
  if conn is TRawTcpClient then
  begin
    InternalPutClient(conn);
  end;
  _log('负载均衡连接已创建数量：' + GetCount.ToString());
end;

constructor TClientsManager.Create;
begin
  inherited Create;
  _gClts := TDictionary<string, TPCLT_REC>.Create();
  _RTC_CLTPOLL := THL_RTC_CLTPoll.Create;
  FTcpServer := TIocpTcpServer.Create(nil);
  FTcpServer.OnDataReceived := self.OnRecvBuffer;

  FTcpServer.Port := 3021;
//  FTcpServer.createDataMonitor;
end;
/// <summary>
///
/// </summary>

destructor TClientsManager.Destroy;
var
  AsTmp: string;
  ArcTmp: TPCLT_REC;
begin
  // _gCS.Free;
  for AsTmp in _gClts.Keys do
  begin
    ArcTmp := _gClts[AsTmp];
    Dispose(ArcTmp);
  end;
  _gClts.Free;
  _RTC_CLTPOLL.Destroy;
  FTcpServer.Free;
end;

procedure TClientsManager.AddGroup(pGrpID: string; pCltIP: string; pCltPort: integer);
var
  ArcTmp: TPCLT_REC;
begin
  if _gClts.ContainsKey(pGrpID) then
  begin
    ArcTmp := _gClts[pGrpID];
    ArcTmp.CLT_IP := pCltIP;
    ArcTmp.CLT_PORT := pCltPort;
  end
  else
  begin
    new(ArcTmp);
    ArcTmp.CLT_IP := pCltIP;
    ArcTmp.CLT_PORT := pCltPort;
    _gClts.Add(pGrpID, ArcTmp);
  end;
end;

procedure TClientsManager.DeleteGroup(pGrpID: string);
begin
  if _gClts.ContainsKey(pGrpID) then
  begin
    _gClts.Remove(pGrpID);
  end;
end;

procedure TClientsManager.DeleteClient(pCltIp: string);
var
  AiIdx, AiCnt: integer;
  AsTmp, AsTmp1: string;
  ArcTmp: TPCLT_REC;
  AsbTmp: TStringBuilder;
begin
  AsbTmp := TStringBuilder.Create;
  try
    for AsTmp in _gClts.Keys do
    begin
      ArcTmp := _gClts[AsTmp];
      if ArcTmp <> nil then
      begin
        if ArcTmp.CLT_IP = pCltIp then
        begin
          AsbTmp.Append(AsTmp);
        end;
      end;
    end;
    AiCnt := AsbTmp.Length - 1;
    for AiIdx := 0 to AiCnt do
    begin
      AsTmp1 := AsbTmp[AiIdx];
      if _gClts.ContainsKey(AsTmp1) then
      begin
        ArcTmp := _gClts[AsTmp1];
        Dispose(ArcTmp);
        _gClts.Remove(AsTmp1);
      end;
    end;
  finally
    FreeAndNil(AsbTmp);
  end;
end;

procedure TClientsManager.DeleteAllClient();
var
  AsTmp: string;
  ArcTmp: TPCLT_REC;
begin
  try
    for AsTmp in _gClts.Keys do
    begin
      ArcTmp := _gClts[AsTmp];
      if ArcTmp <> nil then
      begin
        dispose(ArcTmp);
      end;
    end;
    _gClts.Clear;
    _RTC_CLTPOLL.CloseAllClients;
  finally

  end;
end;

function TClientsManager.GetClient(pGrpID: string): TRawTcpClient;
var
  ArcTmp: TPCLT_REC;
begin
  ArcTmp := nil;
  Result := nil;
  if _gClts.ContainsKey(pGrpID) then
  begin
    ArcTmp := _gClts[pGrpID];
    Result := _RTC_CLTPOLL.GetClient(ArcTmp.CLT_IP, ArcTmp.CLT_PORT);
  end;
end;

procedure TClientsManager.PutClient(conn: TComponent);
begin
  if conn is TRawTcpClient then
  begin
    _RTC_CLTPOLL.InternalPutClient(conn);
  end;
  _log('负载均衡连接已创建数量：' + _RTC_CLTPOLL.GetCount.ToString());
end;

procedure TClientsManager.OnRecvBuffer(pvClientContext: TIocpClientContext; buf: Pointer; len: cardinal; errCode: Integer);
var
  AsRecv, AsTmp, AsGrpId, AsCltPort, AsOp: AnsiString;
  AiIdx: integer;
begin
  if errCode = 0 then
  begin
    SetLength(AsRecv, len);
    Move(buf^, AsRecv[1], len);
    AsOp := LeftStr(AsRecv, 1);
    if AsOp = '0' then
    begin
      AiIdx := pos(':', AsRecv);
      if AiIdx <> 0 then
      begin
        AsRecv := RightStr(AsRecv, length(AsRecv) - 1);
        AsCltPort := LeftStr(AsRecv, AiIdx - 2);
        AsGrpId := RightStr(AsRecv, len - AiIdx);
        DeleteGroup(AsGrpId);
        AsTmp := AnsiString('300');
        pvClientContext.PostWSASendRequest(@AsTmp[1], length(AsTmp));
        MainForm.loadClients;
      end
      else
      begin
        AsTmp := AnsiString('301');
        pvClientContext.PostWSASendRequest(@AsTmp[1], length(AsTmp));
      end;
    end
    else if AsOp = '1' then
    begin
      AiIdx := pos(':', AsRecv);
      if AiIdx <> 0 then
      begin
        AsRecv := RightStr(AsRecv, length(AsRecv) - 1);
        AsCltPort := LeftStr(AsRecv, AiIdx - 2);
        AsGrpId := RightStr(AsRecv, len - AiIdx);
        AddGroup(AsGrpId, pvClientContext.RemoteAddr, strtoint(AsCltPort));
        AsTmp := AnsiString('200');
        pvClientContext.PostWSASendRequest(@AsTmp[1], length(AsTmp));
        MainForm.loadClients;
      end
      else
      begin
        AsTmp := AnsiString('201');
        pvClientContext.PostWSASendRequest(@AsTmp[1], length(AsTmp));
      end;
    end;
  end
  else
  begin
    pvClientContext.DoDisconnect;
  end;
end;

end.

