unit ResUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs, Registry, StrUtils, system.json, XMLDoc, XMLIntf, superobject;

type
  TReustTypes = (do_login, do_querys, do_new, do_update, do_del, do_queryOne, do_pro, do_down, do_menu, do_selindexs, do_selfields, do_upload, do_generatepdf, do_export);

function JsonForResMsg(res: string; msg: string): ISuperObject;

function JsonForSelects(res: string; totalrecords: string; rows: ISuperObject; msg: string): ISuperObject;

function JsonForSelect(res: string; data: ISuperObject; msg: string): ISuperObject;

function JsonForParamsError(): ISuperObject;

implementation

uses
  Contants, Errors;
/////
// 添加、更新、删除返回结果
// @author yzw
// @return String
// @throws Exception
// @date 2016-2-29

function JsonForResMsg(res: string; msg: string): ISuperObject;
begin
  Result := SO('{t:' + res + ', m:' + msg + '}');
end;

/////
// 查询多条记录返回
// @author yzw
// @return String
// @date 2016-3-17
function JsonForSelects(res: string; totalrecords: string; rows: ISuperObject; msg: string): ISuperObject;
var
  AsTmp: ISuperObject;
begin
  AsTmp := SO('{t:' + res + ', m:' + msg + ',totalrecords:' + totalrecords + '}');
  AsTmp.Merge(rows);
  Result := AsTmp;
end;

/////
// 查询单条记录返回
// @author yzw
// @return String
// @date 2016-3-17
function JsonForSelect(res: string; data: ISuperObject; msg: string): ISuperObject;
begin
  Result := SO('{t:' + res + ', m:' + msg + '}');
  Result.Merge(data);
end;
/////
// 提交数据格式错误
// @author yzw
// @return String
// @date 2016-3-17

function JsonForParamsError(): ISuperObject;
begin
  Result := SO('{t:' + Contants.FAILFLAG + ', m:' + Errors.POSTINFORERROR + '}');
end;

end.


