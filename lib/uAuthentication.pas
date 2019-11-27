/// <author>cxg 2017-12-20</author>
/// SESSION��֤

unit uAuthentication;

interface

uses
  SysUtils, SyncObjs, SynCommons, SynCrtSock, superobject, generics.collections;

type
  TAuthentication = class
    /// ��֤SESSION
  private
    FSessionList: TDictionary<int64, Isuperobject>;
    sessions: TIntegerDynArray;
    sessionsCount: Integer;
    CS: TCriticalSection;
    procedure lock;
    procedure unlock;
  public
    constructor Create();
    destructor Destroy; override;
    /// <summary>
    /// ɾ��ָ��SESSION
    /// </summary>
    /// <param name="sessionid"></param>
    procedure RemoveSession(sessionid: Integer);
    /// <summary>
    /// ����һ���µ�SESSION
    /// </summary>
    /// <param name="sessionid"></param>
    /// <param name="pinfor"></param>
    procedure CreateSession(sessionid: Integer; pinfor: Isuperobject);
    /// <summary>
    /// SESSION�Ѿ���֤���ˣ�
    /// </summary>
    /// <param name="sessionid"></param>
    /// <returns>TRUE-SESSION��֤����</returns>
    function SessionExists(sessionid: Integer): boolean;
    /// <summary>
    /// �˶��û���������
    /// </summary>
    /// <param name="user"></param>
    /// <param name="password"></param>
    /// <returns></returns>
    function checkUser(const user, password: string): boolean;
    function GetSession(sessionid: Integer): Isuperobject;
  end;

var
  fAuthentication: TAuthentication;

implementation

uses DateUtils;
{ TAuthentication }

function TAuthentication.checkUser(const user, password: string): boolean;
begin
  // Result := (user = FUser) and (password = FPassword);
  Result := true;
end;

constructor TAuthentication.Create();
begin
  CS := TCriticalSection.Create;
  sessionsCount := 0;
  FSessionList := TDictionary<int64, Isuperobject>.Create();
end;

procedure TAuthentication.CreateSession(sessionid: Integer; pinfor: Isuperobject);
begin
  lock;
  try
    AddSortedInteger(sessions, sessionsCount, sessionid);
    if not FSessionList.ContainsKey(sessionid) then
    begin
      FSessionList.Add(sessionid, pinfor);
    end;
  finally
    unlock;
  end;
end;

destructor TAuthentication.Destroy;
var
  AsTmp: int64;
  ArcTmp: Isuperobject;
begin
  CS.Free;
  for AsTmp in FSessionList.Keys do
  begin
    ArcTmp := FSessionList[AsTmp];
    ArcTmp := nil;
  end;
  FSessionList.Free;
  inherited;
end;

procedure TAuthentication.lock;
begin
  CS.Enter;
end;

procedure TAuthentication.RemoveSession(sessionid: Integer);
var
  i: Integer;
begin
  lock;
  try
    i := FastFindIntegerSorted(pointer(sessions), sessionsCount - 1, sessionid); // �ҵ����
    if i >= 0 then
      DeleteInteger(sessions, sessionsCount, i); // �������ɾ��
  finally
    unlock;
  end;
end;

function TAuthentication.SessionExists(sessionid: Integer): boolean;
var
  AdtLoginDateTime: TDateTime;
  AiHours, AiIdx: Integer;
begin
  lock;
  try
    AiIdx := FastFindIntegerSorted(pointer(sessions), sessionsCount - 1, sessionid);
    Result := AiIdx >= 0;
    if Result = true then
    begin
      try
        AdtLoginDateTime := UnixToDateTime(sessionid);
      except
        on e: exception do
        begin
          Result := False;
          raise exception.Create('�Ƿ�SessionID:' + e.Message);
        end;
      end;
      AiHours := HoursBetween(now(), AdtLoginDateTime);
      if AiHours > 8 then
      begin
        Result := False;
        DeleteInteger(sessions, sessionsCount, AiIdx);
      end;
    end;
  finally
    unlock;
  end;
end;

function TAuthentication.GetSession(sessionid: Integer): Isuperobject;
begin
  lock;
  Result := nil;
  try
    if (FSessionList.ContainsKey(sessionid)) then
    begin
      Result := FSessionList[sessionid];
    end;
  finally
    unlock;
  end;
end;

procedure TAuthentication.unlock;
begin
  CS.Leave;
end;

end.
