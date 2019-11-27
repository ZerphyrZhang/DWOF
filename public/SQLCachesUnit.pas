unit SQLCachesUnit;

interface

uses
  Classes, SysUtils, StrUtils, CommonUtil, generics.collections, syncobjs;

type
  TSQL_REC = record
    FHASHID: Cardinal;
    FAIASNAME: string;
    FSQLTEXT: string;
    FSQLCNTTEXT: string;
    FUSENUM: integer;
  end;

  TPSQL_REC = ^TSQL_REC;

  TSQLCacheManager = class
  private
    _gSqls: TDictionary<string, TPSQL_REC>;
    _gCS: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(pHID: string; pFAIASNAME, pFSQLTEXT, pFSQLCNTTEXT: string);
    function Get(pHID: string): TPSQL_REC;
    function GetCount(): integer;
    procedure ManagerCaches();
  end;

var
  SQLCaches: TSQLCacheManager;

implementation

constructor TSQLCacheManager.Create;
begin
  inherited Create;
  _gCS := TCriticalSection.Create;
  _gSqls := TDictionary<string, TPSQL_REC>.Create();
end;
/// <summary>
///
/// </summary>

destructor TSQLCacheManager.Destroy;
var
  AsTmp: string;
  ArcTmp: TPSQL_REC;
begin
  for AsTmp in _gSqls.Keys do
  begin
    ArcTmp := _gSqls[AsTmp];
    Dispose(ArcTmp);
  end;
  _gSqls.Free;
  _gCS.Free;
end;

procedure TSQLCacheManager.Add(pHID: string; pFAIASNAME, pFSQLTEXT, pFSQLCNTTEXT: string);
var
  ArcTmp: TPSQL_REC;
begin
  _gCS.Enter;
  try
    if _gSqls.ContainsKey(pHID) then
    begin
      ArcTmp := _gSqls[pHID];
      ArcTmp.FAIASNAME := pFAIASNAME;
      ArcTmp.FSQLTEXT := pFSQLTEXT;
      ArcTmp.FSQLCNTTEXT := pFSQLCNTTEXT;
    end
    else
    begin
      new(ArcTmp);
      ArcTmp.FAIASNAME := pFAIASNAME;
      ArcTmp.FSQLTEXT := pFSQLTEXT;
      ArcTmp.FSQLCNTTEXT := pFSQLCNTTEXT;
      ArcTmp.FUSENUM := 1;
      _gSqls.Add(pHID, ArcTmp);
    end;
  finally
    _gCS.Leave;
  end;

end;

function TSQLCacheManager.Get(pHID: string): TPSQL_REC;
begin
  Result := nil;
  if _gSqls.ContainsKey(pHID) then
  begin
    Result := _gSqls[pHID];
    Result.FUSENUM := Result.FUSENUM + 1;
  end;
end;

function TSQLCacheManager.GetCount(): integer;
begin
  Result := _gSqls.Count;
end;

procedure TSQLCacheManager.ManagerCaches();
var
  AsTmp: string;
  ArcTmp: TPSQL_REC;
  AlstKeys: TStringList;
  AiIdx, AiCnt: integer;
begin
  _gCS.Enter;
  AlstKeys := TStringList.Create;
  try
    try
      for AsTmp in _gSqls.Keys do
      begin
        ArcTmp := _gSqls[AsTmp];
        if ArcTmp.FUSENUM = 1 then
        begin
          AlstKeys.Add(AsTmp);
        end;
      end;
      AiCnt := AlstKeys.Count;
      if AiCnt > 0 then
      begin
        for AiIdx := 0 to AiCnt - 1 do
        begin
          AsTmp := AlstKeys[AiIdx];
          ArcTmp := _gSqls[AsTmp];
          if ArcTmp <> nil then
          begin
            Dispose(ArcTmp);
          end;
          _gSqls.Remove(AsTmp);
        end;
        _log('������ϣ��������屨��' + AiCnt.ToString + '��');
      end
      else
      begin
        _log('δ������Ҫ����ı���');
      end;
    except
      on E: Exception do
      begin
        _log('�����Ļ���س��ֹ��ϣ�' + E.Message);
      end;
    end;

  finally
    AlstKeys.Free;
    _gCS.Leave;
  end;

end;

end.
