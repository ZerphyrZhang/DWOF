unit LoginUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs,
  Registry, StrUtils, system.json, XMLDoc, XMLIntf, superobject, IdHTTPServer,
  IdCustomHTTPServer, IdContext, Data.Win.ADODB;

function _IsLogin(pServer: TIdHTTPServer; ARequestInfo: TIdHTTPRequestInfo): Boolean;

function getUserInfor(pUserName: string; pToken: Boolean): ISuperObject;

function getUserMenus(user_id: string; menu_depth1: string; menu_depth2: string; parentid: string): ISuperObject;

function getMenuCommonSql(userid, menu_depth1, menu_depth2, preid: string): string;

function getUserById(user_id: string): ISuperObject;

implementation

uses
  DBML, TDbPack, Contants, RTC_DBPOOL, CommonUtil, ActiveX;
/// //
// 根据用户名获取用户信息
// @author yzw
// @return String
// @date 2016-3-17

function getUserInfor(pUserName: string; pToken: Boolean): ISuperObject;
var
  AsRes: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt: Integer;
  AsTmp: string;
  AcnTmp: TADOConnection;
  AqryTmp: TADOQuery;
begin
  CoInitialize(nil);
  try
    try
      AcnTmp := _RTC_DBPOLL.GetDBConnection;
      AqryTmp := TADOQuery.Create(nil);
      AqryTmp.Connection := AcnTmp;
      AcnTmp.BeginTrans;
      with AqryTmp do
      begin
        try
          Close;
          sql.Clear;
          sql.Append('select * from pub_user ');
          if (pToken = False) then
          begin
            sql.Append('where user_name=''' + pUserName + '''');
          end
          else
          begin
            sql.Append('where token=''' + pUserName + '''');
          end;
          Open;

          if (not Eof) then
          begin
            AlsFieldNames := TStringList.Create;
            GetFieldNames(AlsFieldNames);
            AiCnt := AlsFieldNames.Count - 1;
            AsRes := TSuperObject.Create(stObject);
            for AiIdx := 0 to AiCnt do
            begin
              AsTmp := AlsFieldNames[AiIdx].ToLower;
              AsRes.S[AsTmp] := FieldByName(AsTmp).AsString;
            end;
            AsTmp := '{d_user_id:' + AsRes['user_id'].AsString + ',d_user_name:' + AsRes['full_name'].AsString + '}';
            DbPack._dbLog(SO(AsTmp), nil, Contants._LOGIN, AcnTmp);
          end
          else
          begin
            DbPack._dbLog(SO('{d_user_id:"-999",d_user_name:' + pUserName + ',msg:"登录失败!用户名不存在!"}'), nil, Contants._LOGIN, AcnTmp);
          end;
          AcnTmp.CommitTrans;
          Result := AsRes;
        except
          on e: Exception do
          begin
            if AcnTmp.InTransaction then
              AcnTmp.RollbackTrans;
            Exception.ThrowOuterException(Exception.Create(e.Message));
          end;
        end;
      end;
    finally
      FreeAndNil(AlsFieldNames);
      _RTC_DBPOLL.PutDBConn(AcnTmp);
      if AqryTmp <> nil then
      begin
        AqryTmp.free;
      end;
      CoUninitialize;
    end;
  except
    on e: Exception do
    begin
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;
  end;
end;

/// <summary>
/// 查看用户是否登录
/// </summary>
/// <param name="pServer"></param>
/// <param name="ARequestInfo"></param>
/// <returns></returns>
function _IsLogin(pServer: TIdHTTPServer; ARequestInfo: TIdHTTPRequestInfo): Boolean;
var
  AseTmp, AseTmp1: TIdHTTPSession;
begin

  AseTmp := ARequestInfo.Session;
  if (AseTmp <> nil) then
  begin
    AseTmp1 := pServer.SessionList.GetSession(AseTmp.SessionID, AseTmp.RemoteHost);
    if (AseTmp1 <> nil) then
    begin
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

/// <summary>
/// 获取目录
/// </summary>
/// <param name="user_id"></param>
/// <param name="menu_depth1"></param>
/// <param name="menu_depth2"></param>
/// <param name="parentid"></param>
/// <returns></returns>
function getUserMenus(user_id: string; menu_depth1: string; menu_depth2: string; parentid: string): ISuperObject;
var
  AsRes, AjsUser, AjsRes, AjsTmp: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt, AiDbIdx: Integer;
  AsTmp, AsUserName, AsParentId: string;
  AsbSql: TStringBuilder;
  AqryTmp: TADOQuery;
  ArtcTmp: THL_RTC_DBPoll;
begin
  CoInitialize(nil);
  try
    try
      AjsUser := getUserById(user_id);
      if (AjsUser <> nil) then
      begin
        AsUserName := AjsUser['user_name'].AsString;
        AsbSql := TStringBuilder.Create;
        AsParentId := '';
        if (parentid <> '') then
        begin
          AsParentId := ' and m.parentid like ''%' + parentid + '%'' ';
        end;
        if (Contants.SUPERADMIN_NAME = AsUserName) then
        begin
          AsbSql.Append('select m.* from pub_menu m where m.parentid is not null and m.menu_depth >=' + menu_depth1 + '  and  m.menu_depth <= ' + menu_depth2 + ' and  m.parentid is not null ' + AsParentId + ' order by m.menu_id ');
        end
        else
        begin
          AsbSql.Append(getMenuCommonSql(user_id, menu_depth1, menu_depth2, AsParentId));
        end;
        _log(AsbSql.ToString, 1);
        AqryTmp := _RTC_DBPOLL.GetDBQuery;
        try
          with AqryTmp do
          begin
          // Connection := DBML.DBModule.UniConnection1;
            Close;
            sql.Clear;
            sql.Append(AsbSql.ToString);
            Open;
            if (RecordCount > 0) then
            begin
              AlsFieldNames := TStringList.Create;
              GetFieldNames(AlsFieldNames);
              AiCnt := AlsFieldNames.Count - 1;
              AjsRes := TSuperObject.Create(stObject);
              AjsRes[Contants.ROWS] := SA([]);
              while (not Eof) do
              begin
                AjsTmp := TSuperObject.Create(stObject);
                for AiIdx := 0 to AiCnt do
                begin
                  AsTmp := AlsFieldNames[AiIdx].ToLower;
                  AjsTmp.S[AsTmp] := FieldByName(AsTmp).AsString;
                end;
                AjsRes.A[Contants.ROWS].Add(AjsTmp);
                Next;
              end;
            end;
            FreeAndNil(AlsFieldNames);
          end;
        finally
          _RTC_DBPOLL.PutDBConn(AqryTmp);
        end;

        Result := AjsRes;
      end;
    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    CoUninitialize;
  end;

end;
/// <summary>
/// 获取某一个人登录后的菜单公用sql
/// </summary>
/// <param name="userid"></param>
/// <param name="menu_depth1"></param>
/// <param name="menu_depth2"></param>
/// <param name="preid"></param>
/// <returns></returns>

function getMenuCommonSql(userid, menu_depth1, menu_depth2, preid: string): string;
var
  AsBaseSql: string;
begin
  AsBaseSql := 'm.*';
  Result := Contants.SELECT + ' distinct ' + Contants.KONGGE + AsBaseSql + Contants.KONGGE + Contants.FROM + Contants.LEFTKH + Contants.SELECT + Contants.KONGGE + AsBaseSql + Contants.KONGGE + Contants.FROM + ' pub_user_role b ,pub_role_menu c ,pub_menu m ' + Contants.WHERE + ' b.user_id=' + userid + ' and b.role_id=c.role_id and c.menu_id=m.menu_id ' + preid + ' and m.menu_depth >=' + menu_depth1 + ' and m.menu_depth <= ' + menu_depth2 + ' union select ' + AsBaseSql + ' from pub_user_menu b,pub_menu m where m.menu_depth >=' + menu_depth1 + ' and m.menu_depth <= ' + menu_depth2 + '  and  b.user_id=' + userid + '  and b.menu_id=m.menu_id ' + preid + Contants.RIGHTKH + 'm ' + Contants.KONGGE + Contants.ORDERBYSQL + ' m.menu_id';
end;
/// <summary>
/// 根据UserId获取用户
/// </summary>
/// <param name="user_id"></param>
/// <returns></returns>

function getUserById(user_id: string): ISuperObject;
var
  AsRes: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt: Integer;
  AsTmp: string;
  AqryTmp: TADOQuery;
begin

  CoInitialize(nil);
  try
    try
      AqryTmp := _RTC_DBPOLL.GetDBQuery;
      with AqryTmp do
      begin
        // Connection := DBML.DBModule.UniConnection1;
        Close;
        sql.Clear;
        sql.Append('select * from pub_user where user_id=''' + user_id + '''');
        Open;

        AlsFieldNames := TStringList.Create;
        GetFieldNames(AlsFieldNames);
        AiCnt := AlsFieldNames.Count - 1;
        if (not Eof) then
        begin
          AsRes := TSuperObject.Create(stObject);
          for AiIdx := 0 to AiCnt do
          begin
            AsTmp := AlsFieldNames[AiIdx].ToLower;
            AsRes.S[AsTmp] := FieldByName(AsTmp).AsString;
          end;
        end;
        Result := AsRes;
        FreeAndNil(AlsFieldNames);
      end;
    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    _RTC_DBPOLL.PutDBConn(AqryTmp);
    CoUninitialize;
  end;
end;

end.

