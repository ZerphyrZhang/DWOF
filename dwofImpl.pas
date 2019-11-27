{ Invokable implementation File for Tdwof which implements Idwof }

unit dwofImpl;

interface

uses
  Soap.InvokeRegistry, System.Types, Soap.XSBuiltIns, dwofIntf, System.SysUtils,
  System.Classes, System.Generics.Collections, RawTcpClient;

type

  { Tdwof }
  Tdwof = class(TInvokableClass, Idwof)
    function _A4B64FBF(pJson: string; pSession: string): string; // 00新增
    function _B8C6FFBE(pJson: string; pSession: string): string; // 01修改
    function _A5D2BE4F(pJson: string; pSession: string): string; // 02删除
    function _C12DBE4F(pJson: string; pSession: string): string; // 03多笔查询
    function _B1C6FFBE(pJson: string; pSession: string): string; // 04单笔查询
    function _E4A5D2BA(pJson: string): string; // 05登录
    function _D112DBCD(pJson: string; pSession: string): string; // 06存储过程
    function _EC12DB3D(pJson: string): string; // 07获取目录

    function _EC12DB3E(pJson: string; pSession: string): string; // 08do_seltables
    function _EC12DB3F(pJson: string; pSession: string): string; // 09do_selindexs
    function _EC12DB3S(pJson: string; pSession: string): string; // 10do_selfields

    function _EC12DB3T(pJson: string; pSession: string): string; // 11do_tabfields

    function _EC12DB3R(pJson: string; pSession: string): string; // 12do_exprot
    function _EC12DB4R(pJson: string; pSession: string): string; // 13do_elnfile

//    function _C12DBE4FF(pJson: string; pSession: string): string;
  public
  end;

implementation

uses
  TDbpack, LicenseUtils, CommonUtil, IdURI, DateUtils, ResUtils, Contants,
  Errors, SuperObject, RTC_CLTPOOL;

procedure FreeSuperobject(AoTmp: ISuperObject);
var
  AoRows: ISuperObject;
  AoyRows: TSuperArray;
  AiIdx, AiCnt: integer;
begin
  AoRows := AoTmp[Contants.ROWS];
  if (AoRows <> nil) then
  begin
    AoyRows := AoRows.AsArray;
    AiCnt := AoyRows.Length;
    for AiIdx := 0 to AiCnt do
    begin
      AoyRows[AiIdx] := nil;
    end;
  end;
  AoRows := nil;
end;



//function Tdwof._C12DBE4F(pJson: string; pSession: string): string;
//var
//  AojTmp, AojSession: ISuperObject;
//  AcTmp: TRawTcpClient;
//  AnsRecv, AnsTmp: AnsiString;
//  AiLen: Integer;
//begin
//  try
//    try
//      AojSession := SO(pSession);
//      AojSession['data'].Delete('user_pic');
//      pSession := AojSession.AsJSon();
//      AcTmp := _CLT_MGR.GetClient(AojSession['data']['group_id'].asstring);
//      if AcTmp = nil then
//      begin
//        pJson := TIdURI.URLDecode(pJson);
//        AojTmp := Dbpack.Querys(pJson, pSession);
//        result := AojTmp.AsJSon();
//      end
//      else
//      begin
//        AnsTmp := AnsiString('03' + IntToStr(length(pJson)) + ':' + pJson + pSession);
//        AcTmp.sendBuffer(@AnsTmp[1], Length(AnsTmp));
//        SetLength(AnsRecv, 102400000);
//        AiLen := AcTmp.RecvBuffer(@AnsRecv[1], 102400000);
//        SetLength(AnsRecv, AiLen);
//
//        result := AnsRecv;
//      end;
//    except
//      on e: exception do
//      begin
//        result := ResUtils.JsonForResMsg('0', e.Message).AsString;
//        _Log('_C12DBE4FDUBC--->' + e.Message);
//      end;
//    end;
//  finally
//    if AojTmp <> nil then
//    begin
//      AojTmp := nil;
//    end;
//    if AcTmp <> nil then
//    begin
//      _CLT_MGR.PutClient(AcTmp);
//    end;
//    pJson := '';
//  end;
//
//end;

function Tdwof._E4A5D2BA(pJson: string): string;
var
  AtLimit, AtNow: TDateTime;
  AsTmp: ISuperObject;
begin
  try
    AtLimit := StrToDate('2019-12-31');
    if CompareDate(now, AtLimit) = -1 then
    begin
      // pJson := httpdecode(pJson);
      try
        pJson := TIdURI.URLDecode(pJson);
        AsTmp := Dbpack.Login(pJson);
        result := AsTmp.AsJSon();
      finally
        AsTmp := nil;
        pJson := '';
      end;
    end
    else
    begin
      result := ResUtils.JsonForResMsg(Contants.FAILFLAG, '抱歉，系统暂停服务，请联系贵单位财务部门付费。').AsJSon();
    end;
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_E4A5D2BADL--->' + e.Message);
    end;
  end;
end;

function Tdwof._A4B64FBF(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try
    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Insert(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Insert(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_A4B64FBFXZ--->' + e.Message);
    end;

  end;
end;

function Tdwof._B8C6FFBE(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Update(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Update(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_B8C6FFBEGX--->' + e.Message);
    end;

  end;

end;

function Tdwof._A5D2BE4F(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Delete(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Delete(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_A5D2BE4FSC--->' + e.Message);
    end;

  end;

end;

function Tdwof._C12DBE4F(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
  AiTmp:Cardinal;
begin
  try
    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Querys(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Querys(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_C12DBE4FDUBC--->' + e.Message);
    end;
  end;

end;

function Tdwof._B1C6FFBE(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try
    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Query(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Query(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_B1C6FFBEDBC--->' + e.Message);
    end;

  end;

end;

function Tdwof._D112DBCD(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);

      AsTmp := Dbpack.Proc(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Proc(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_D112DBCDCG--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3D(pJson: string): string;
var
  AsTmp: ISuperObject;
begin
  try
    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Menus(pJson);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.Menus(pJson).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3DML--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3E(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.seltables(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.seltables(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3FIDX3EE--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3F(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.selIndexs(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;

    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.selIndexs(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3FIDX--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3S(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.selFields(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;

    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.selFields(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3DFS--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3T(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.tabFields(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);
    // pJson := TIdURI.URLDecode(pJson);
    // result := Dbpack.tabFields(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3T--->' + e.Message);
    end;

  end;

end;

function Tdwof._EC12DB3R(pJson: string; pSession: string): string;
var
  AsTmp, AoRows, AoTmp: ISuperObject;
  AoyRows: TSuperArray;
  AiIdx, AiCnt: integer;
begin
  try
    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.Eexports(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3DFS--->' + e.Message);
    end;
  end;

end;

function Tdwof._EC12DB4R(pJson: string; pSession: string): string;
var
  AsTmp: ISuperObject;
begin
  try

    try
      pJson := TIdURI.URLDecode(pJson);
      AsTmp := Dbpack.ElnFile(pJson, pSession);
      result := AsTmp.AsJSon();
    finally
      AsTmp := nil;
      pJson := '';
    end;
    // pJson := httpdecode(pJson);

    // result := Dbpack.ElnFile(pJson, pSession).AsJSon();
  except
    on e: exception do
    begin
      result := ResUtils.JsonForResMsg('0', e.Message).AsString;
      _Log('_EC12DB3DFS4R--->' + e.Message);
    end;

  end;

end;

initialization

{ Invokable classes must be registered }
  InvRegistry.RegisterInvokableClass(Tdwof);

end.

