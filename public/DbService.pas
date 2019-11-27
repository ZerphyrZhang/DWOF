unit DbService;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs, Registry, StrUtils, system.json, XMLDoc, XMLIntf, superobject, IdHTTPServer, IdCustomHTTPServer, IdContext;

function Login(pJson: string): ISuperObject;

function Menus(pjson: string): ISuperObject;

function Insert(pjson: string; pSession: string): ISuperObject;

function Update(pjson: string; pSession: string): ISuperObject;

function Delete(pjson: string; pSession: string): ISuperObject;

function Proc(pServer: TIdHTTPServer; ARequestInfo: TIdHTTPRequestInfo): ISuperObject;

function Querys(pjson: string; pSession: string): ISuperObject;

function Query(pjson: string; pSession: string): ISuperObject;

implementation

uses
  Contants, XmlUtils, CommonUtil, TDbPack, ResUtils, Errors, LoginUtils;
  ///////
/// 新增
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Login(pJson: string): ISuperObject;
var
  AsJson: string;
  AjsRes: ISuperObject;
begin
  try
    AsJson := pJson;
    AjsRes := DbPack.Login(AsJson);

    if (AjsRes[Contants.T].AsString = Contants.SUCCFLAG) then
    begin
//      if (pServer.SessionState = true) then
//      begin
//        pServer.CreateSession(pContext, AResponseInfo, ARequestInfo);
//        ARequestInfo.Session.Lock;
//        ARequestInfo.Session.Content.Values['username'] := '';
//        ARequestInfo.Session.Unlock;
//        pServer.SessionList.Add(ARequestInfo.Session);
//      end;

    end;
    result := AjsRes;
  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;

///////
/// 获取目录
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Menus(pjson: string): ISuperObject;
begin
  try
    Result := DbPack.Menus(pjson);
  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 新增
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Insert(pjson: string; pSession: string): ISuperObject;
begin
  try

    Result := DbPack.Insert(pjson, pSession);

  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 修改
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Update(pjson: string; pSession: string): ISuperObject;
begin
  try

    Result := DbPack.Update(pjson,pSession);

  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 删除
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Delete(pjson: string; pSession: string): ISuperObject;
begin
  try

    Result := DbPack.Delete(pjson,pSession);

  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 查询
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Querys(pjson: string; pSession: string): ISuperObject;
begin
  try

    Result := DbPack.Querys(pjson,pSession);

  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 执行存储过程
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Proc(pServer: TIdHTTPServer; ARequestInfo: TIdHTTPRequestInfo): ISuperObject;
begin
  try
    if (LoginUtils._IsLogin(pServer, ARequestInfo) = True) then
    begin
//      Result := DbPack.Proc(ARequestInfo.Params.Strings[Contants.REQUSTPARAMINDEX]);
    end
    else
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.NOTLOGIN);
    end;
  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;
///////
/// 查询
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function Query(pjson: string; pSession: string): ISuperObject;
begin
  try

    Result := DbPack.Query(pjson,pSession);

  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + E.Message);
    end;
  end;

end;

end.


