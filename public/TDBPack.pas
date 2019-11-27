unit TDBPack;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs,
  Registry, StrUtils, XMLDoc, XMLIntf, generics.collections, superobject, Data.Win.ADODB,
  TypInfo, Data.DB, IdHTTP, EncdDecd, syncobjs, XmlUtils, ActiveX;

type
  TPackDB = class
  private
    // _gCS: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    function _CreateQuery(pAdoCon: TADOConnection): TADOQuery;
    function _CreateProc(pAdoCon: TADOConnection): TADOStoredProc;
    function Login(pobj: AnsiString): ISuperObject;
    function Menus(pobj: AnsiString): ISuperObject;
    function Querys(pobj: AnsiString): ISuperObject;
    function _Querys(pobj: AnsiString): ISuperObject;
    function Query(pobj: AnsiString): ISuperObject;
    function _Query(pobj: AnsiString): ISuperObject;
    function Eexports(pobj: AnsiString): ISuperObject;
    function ElnFile(pobj: AnsiString): ISuperObject;
    function _selectSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _selectCountSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _selectSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _selectCountSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _procSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Proced; pParams: TParameters): string;
    function _procSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pNdProc: _THXML_Proced; pParams: TParameters): string;
    function Proc(pobj: string): ISuperObject;
    function Insert(pobj: string): ISuperObject;
    function _insertSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): TStringBuilder;
    function _insertSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function Updates(pobj: string): ISuperObject;
    function Update(pobj: string): ISuperObject;
    function _Update(pobj: AnsiString): ISuperObject;
    function _updateSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _updateSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function Delete(pobj: AnsiString): ISuperObject;
    function _deleteSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _deleteSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
    function _where(jsonStr: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>; pEle: _THXML_Select): string;
    function _getWhere(pjsFilter: TSuperArray; fieldsList: TDictionary<string, _THXML_Field>; pIsWhere: string): string;
    function _getWhereFieldOPString(pJson: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>): string;
    function _getWhereFieldTypeString(pobj: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>; op: string): string;
    function _prepareParams(pNode: _THXML_Param; pValue: Variant; psFieldName: string; pParams: TParameters): string;
    function _prepareParams_old(pNode: _THXML_Param; pValue: Variant; psFieldName: string; pParams: TParameters): string;
    function _getOrderby(pJson: ISuperObject; node: _THXML_Select; pFields: TDictionary<string, _THXML_Field>): string;
    function pageSql(select: string; pagenum: integer; pagesize: integer): string;
    function MysqlPageSql(AiIdx, pagenum, pagesize: integer; select: string): string;
    function OraclePageSql(AiIdx, pagenum, pagesize: integer; select: string): string;
    function seltables(pobj: AnsiString): ISuperObject;
    function selIndexs(pobj: AnsiString): ISuperObject;
    function selFields(pobj: AnsiString): ISuperObject;
    function tabFields(pobj: AnsiString): ISuperObject;
    function dataSetToJson(pQuery: TADOQuery; pFlag, ptbName: string): ISuperObject;
    function dataRowToJson(pQuery: TADOQuery; pFlag, ptbName: string): ISuperObject;
    function dataSetToJsonWithColNames(pQuery: TADOQuery; pFlag: string): ISuperObject;
    function ProcDataSetToJsonWithColNames(pQuery: TADOStoredProc; pFlag: string): ISuperObject;
    procedure _readFieldData(ptbName: string; pJsRes: ISuperObject; pField: TField);
    procedure _dbLog(pJson: ISuperObject; pJuser: ISuperObject; pType: string; pCon: TADOConnection);
  end;

var
  Dbpack: TPackDB;

implementation

uses
  DBACCess, Contants, CommonUtil, DBML, ResUtils, Errors, LoginUtils, RTC_DBPOOL,
  supertypes, DateUtils, SQLCachesUnit, uAuthentication;

constructor TPackDB.Create;
var
  ModuleName, fpth: string;
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: integer;
  AsTmp: string;
begin
  inherited Create;
  // _gCS := TCriticalSection.Create;

end;
/// <summary>
///
/// </summary>

destructor TPackDB.Destroy;
begin
  // _gCS.Free;
  inherited;
end;

function StrHash(const SoureStr: string): Cardinal;
const
  cLongBits = 32;
  cOneEight = 4;
  cThreeFourths = 24;
  cHighBits = $F0000000;
var
  I: integer;
  P: PChar;
  Temp: Cardinal;
begin
  Result := 0;
  P := PChar(SoureStr);
  I := Length(SoureStr);
  while I > 0 do
  begin
    Result := (Result shl cOneEight) + Ord(P^);
    Temp := Result and cHighBits;
    if Temp <> 0 then
      Result := (Result xor (Temp shr cThreeFourths)) and (not cHighBits);
    Dec(I);
    Inc(P);
  end;
end;
/// ////
///
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._CreateQuery(pAdoCon: TADOConnection): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := pAdoCon;
end;

function TPackDB._CreateProc(pAdoCon: TADOConnection): TADOStoredProc;
begin
  Result := TADOStoredProc.Create(nil);
  Result.Connection := pAdoCon;
end;
/// ////
/// 判断在dbxml字段区域里是否存在传入的字段
/// @author zephyr
/// @return void
/// @date 2016-3-2

// function TPackDB._getField(str: string; nodeList: IXMLNodeList): IXMLNode;
// var
// AnodeTmp: IXMLNode;
// AiIdx, AiCnt: Integer;
// begin
// Result := nil;
// AiCnt := nodeList.Count - 1;
// for AiIdx := 0 to AiCnt do
// begin
// AnodeTmp := nodeList[AiIdx];
// if UpperCase(VarToStr(AnodeTmp.Attributes[Contants.ALIAS])) = UpperCase(str) then
// begin
// Result := AnodeTmp;
// Break;
// end;
// end;
//
// end;
/// ////
/// 登录
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB.Login(pobj: AnsiString): ISuperObject;
var
  AsUserName, AsUserPwd, AsTmp, AsCount: string;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt, AiToken: integer;
begin

  try
    try
      AiToken := -1;
      AsUserPwd := '';
      AjsnPost := SO(pobj)[Contants.O];
      AjsTmp1 := AjsnPost[Contants.USERNAME];
      if (AjsTmp1 = nil) then
      begin
        // 口令登陆
        AjsTmp1 := AjsnPost[Contants.USERCMD];
        if (AjsTmp1 <> nil) then
        begin
          AsTmp := AjsTmp1.AsString;
          AsUserName := LowerCase(_GUList.Values[AsTmp]);
          AiToken := 1;
        end
        else
        begin
          // 令牌登陆
          AjsTmp1 := AjsnPost[Contants.USERTOKEN];
          if (AjsTmp1 <> nil) then
          begin
            AsUserName := LowerCase(AjsTmp1.AsString);
            AiToken := 0;
          end;
        end;
      end
      else
      begin
        // 普通登陆
        AsUserName := LowerCase(AjsTmp1.AsString);
        AiCnt := _GUList.Count - 1;
        for AiIdx := 0 to AiCnt do
        begin
          if _GUList.ValueFromIndex[AiIdx] = AsUserName then
          begin
            _GUList.Delete(AiIdx);
            Break;
          end;
        end;
      end;

      if (AjsTmp1 <> nil) then
      begin
        AjsTmp1 := AjsnPost[Contants.USERPWD];
        if (AjsTmp1 <> nil) then
        begin
          AsUserPwd := AjsTmp1.AsString;
        end;
        if isNotEmpty(AsUserName) then
        begin
          AjsRes := LoginUtils.getUserInfor(AsUserName, AiToken = 0);
          if (AjsRes <> nil) then
          begin
            if ((AiToken > -1) or (AjsRes['user_pwd'].AsString = CommonUtil.encodeStrNj(AsUserPwd))) then
            begin
              // 返回数据
              AjsTmp := TSuperObject.Create(stObject);
              if AsTmp = '' then
              begin
                AsTmp := DateTimeToUnix(Now).ToString;
                _GUList.Add(AsTmp + '=' + AsUserName);
              end;
              AjsRes.S['user_cmd'] := AsTmp;

              AjsTmp[Contants.Data] := AjsRes;
              Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsTmp, Errors.SUCC);
            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.LOGINFPWD);
            end;

          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.LOGINUSER);
          end;

        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.USERNAMEANDPWDNOTNULL);
        end;

      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.USERNAMEANDPWDNOTNULL);
      end;

    except
      on e: Exception do
      begin
        _log(e.Message);
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + e.Message);
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
  end;

end;

/// ////
/// 获取用户的菜单目录
/// @author zephyr
/// @return void
/// @date 2016-3-2
function TPackDB.Menus(pobj: AnsiString): ISuperObject;
var
  AsRes, AsMsg, AsUserId, AsMenuDepth1, AsMenuDepth2, AsParentId: string;
  AvrUserId, AvrMenuDepth1, AvrMenuDepth2, AvrParentId: ISuperObject;
  AjsRes, AjsnPost: ISuperObject;
begin
  try
    try
      // jsonStr 已验证非空
      if CommonUtil.isNotEmpty(pobj) then
      begin
        AjsnPost := SO(pobj)[Contants.O];
        AvrUserId := AjsnPost['user_id'];
        AvrMenuDepth1 := AjsnPost['menu_depth1'];
        AvrMenuDepth2 := AjsnPost['menu_depth2'];
        AvrParentId := AjsnPost['parentid'];
        if (AvrUserId <> nil) and (AvrMenuDepth1 <> nil) and (AvrMenuDepth2 <> nil) and (AvrParentId <> nil) then
        begin
          AsUserId := AvrUserId.AsString;
          AsMenuDepth1 := AvrMenuDepth1.AsString;
          AsMenuDepth2 := AvrMenuDepth2.AsString;
          AsParentId := AvrParentId.AsString;
          AjsRes := LoginUtils.getUserMenus(AsUserId, AsMenuDepth1, AsMenuDepth2, AsParentId);
          if (AjsRes <> nil) then
          begin
            // 返回数据
            Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, '0', AjsRes, Errors.SUCC);
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.SUCCFLAG, Errors.USERNOPREMISSION);
          end
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.MENUPARAMSERRROE);

        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
    AsRes := '';
    AsMsg := '';
    AsUserId := '';
    AsMenuDepth1 := '';
    AsMenuDepth2 := '';
    AsParentId := '';
  end;

end;
/// ////
/// 查询多笔数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB.Querys(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsSql, AsSqlCount, AsCount, AsOstr: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1: ISuperObject;
  AiIdx, AiCnt, AiDbIdx: integer;
  AndSelect: _THXML_Select;
  AsIsPage: string;
  AqryTmp: TADOQuery;
  ApoTmp: TPSQL_REC;

  procedure __Querys();
  begin
    try
      AqryTmp := _RTC_DBPOLL.GetDBQuery;
      with AqryTmp do
      begin
        try
          // 查询数据
          close;
          Parameters.Clear;
          SQL.Clear;
          _log('Querys_cache:' + AsSql, COMINFOR.FDEVMODE);
          SQL.Append(AsSql);
          Open;
          AjsRes := dataSetToJson(AqryTmp, Contants.ROWS, AsTabAliasName);
          if (AsSqlCount <> '') then
          begin
            // 查询数量
            close;
            SQL.Clear;
            _log('Querys_cache_count:' + AsSqlCount, COMINFOR.FDEVMODE);
            SQL.Append(AsSqlCount);
            Open;
            if (RecordCount > 0) then
            begin
              First;
              AsCount := VarToStr(Fields[0].Value);
            end;
          end;
        except
          on e: Exception do
          begin
            _log(e.Message);
            Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
          end;
        end;
      end;
    finally
      _RTC_DBPOLL.PutDBConn(AqryTmp);

    end;
  end;

begin
  // _gCS.Enter;
  AsTmp := 'no sql';
  try
    CoInitialize(nil);
    try
      _log('Querys:' + pobj, COMINFOR.FDEVMODE);
      AjsnPost := SO(pobj)[Contants.O];
      AsOstr := AjsnPost.AsJSon();
      ApoTmp := SQLCaches.get(AsOstr);
      if ApoTmp <> nil then
      begin
        AsTabAliasName := ApoTmp.FAIASNAME;
        AsSql := ApoTmp.FSQLTEXT;
        AsSqlCount := ApoTmp.FSQLCNTTEXT;
        __Querys();
        // 返回数据
        Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, AsCount, AjsRes, Errors.SUCC);
      end
      else
      begin
        // AjsnPost := SO(pobj)[Contants.O];
        AjsTmp1 := AjsnPost[Contants.ALIAS];
        if (AjsTmp1 <> nil) then
        begin
          AsTabAliasName := AjsTmp1.AsString;
          AjsTmp1 := AjsnPost[Contants.SELINDEX];
          if (AjsTmp1 <> nil) then
          begin
            AsSelName := AjsTmp1.AsString;
            if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
            begin
              AnodList := _XML_Poll._loadFields(AsTabAliasName);
              if (AnodList <> nil) then
              begin
                AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
                try
                  // AiDbIdx := dbPoolClass.GetQueryFromPool;
                  AqryTmp := _RTC_DBPOLL.GetDBQuery;
                  with AqryTmp do
                  begin
                    try
                      // 查询数据
                      close;
                      Parameters.Clear;
                      SQL.Clear;
                      AsSql := _selectSqlText(AsTabAliasName, AsSelName, AjsnPost, AndSelect, AnodList, Parameters);
                      _log('Querys:' + AsSql, COMINFOR.FDEVMODE);
                      SQL.Append(AsSql);
                      Open;
                      AjsRes := dataSetToJson(AqryTmp, Contants.ROWS, AsTabAliasName);

                      AsIsPage := AndSelect._ispage;
                      if (AsIsPage = '1') then
                      begin
                        AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName + '_count');
                        if AndSelect <> nil then
                        begin
                          // 查询数量
                          close;
                          SQL.Clear;
                          AsSqlCount := _selectCountSqlText(AsTabAliasName, AsSelName + Contants.INDEXCOUNT, AjsnPost, AndSelect, AnodList, Parameters);
                          _log('Querys:' + AsSqlCount, COMINFOR.FDEVMODE);
                          SQL.Append(AsSqlCount);
                          Open;
                          if (RecordCount > 0) then
                          begin
                            First;
                            AsCount := VarToStr(Fields[0].Value);
                          end;
                          SQLCaches.Add(AsOstr, AsTabAliasName, AsSql, AsSqlCount);
                        end
                        else
                        begin
                          _log('pack:没有找到分页数量语句，请检查配置文件中是否包含分页数量语句');
                          raise Exception.Create('pack:没有找到分页数量语句，请检查配置文件中是否包含分页数量语句');
                        end;
                      end;
                      SQLCaches.Add(AsOstr, AsTabAliasName, AsSql, AsSqlCount);
                      // _dbLog( AjsnPost, SO(pSession), Contants._NEW);
                    except
                      on e: Exception do
                      begin
                        _log(e.Message);
                        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
                      end;
                    end;
                  end;
                finally
                  // dbPoolClass.FreeQuery(AiDbIdx);
                  _RTC_DBPOLL.PutDBConn(AqryTmp);
                  if AjsnPost <> nil then
                  begin
                    AjsnPost := nil;
                  end;
                end;
                // 返回数据
                Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, AsCount, AjsRes, Errors.SUCC);
              end
              else
              begin
                Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
              end;
            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
          end;
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
        end;
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
      end;
    end;
  finally
    // _gCS.Leave;
    couninitialize;
  end;

end;
/// ////
/// 查询多笔数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._Querys(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1: ISuperObject;
  AiIdx, AiCnt, AiDbIdx: integer;
  AndSelect: _THXML_Select;
  AsIsPage: string;
  AqryTmp: TADOQuery;
  AiTmp: integer;
begin
  // _gCS.Enter;
  AsTmp := 'no sql';
  try
    try
      _log('Querys:' + pobj, COMINFOR.FDEVMODE);
      AjsnPost := SO(pobj)[Contants.O];
      AjsTmp1 := AjsnPost[Contants.ALIAS];
      if (AjsTmp1 <> nil) then
      begin
        AsTabAliasName := AjsTmp1.AsString;
        AjsTmp1 := AjsnPost[Contants.SELINDEX];
        if (AjsTmp1 <> nil) then
        begin
          AsSelName := AjsTmp1.AsString;
          if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
          begin
            AnodList := _XML_Poll._loadFields(AsTabAliasName);
            if (AnodList <> nil) then
            begin
              AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
              try
                // AiDbIdx := dbPoolClass.GetQueryFromPool;
                AqryTmp := _RTC_DBPOLL.GetDBQuery;
                with AqryTmp do
                begin
                  try
                    // 查询数据
                    close;
                    Parameters.Clear;
                    SQL.Clear;
                    AsTmp := _selectSqlText(AsTabAliasName, AsSelName, AjsnPost, AndSelect, AnodList, Parameters);

                    _log('Querys:' + AsTmp, COMINFOR.FDEVMODE);
                    SQL.Append(AsTmp);
                    Open;

                    AjsRes := dataSetToJson(AqryTmp, Contants.ROWS, AsTabAliasName);

                    AsIsPage := AndSelect._ispage;
                    if (AsIsPage = '1') then
                    begin
                      AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName + '_count');
                      if AndSelect <> nil then
                      begin
                        // 查询数量
                        close;
                        SQL.Clear;
                        AsTmp := _selectCountSqlText(AsTabAliasName, AsSelName + Contants.INDEXCOUNT, AjsnPost, AndSelect, AnodList, Parameters);
                        _log('Querys:' + AsTmp, COMINFOR.FDEVMODE);
                        SQL.Append(AsTmp);
                        Open;
                        if (RecordCount > 0) then
                        begin
                          First;
                          AsCount := VarToStr(Fields[0].Value);
                        end;
                      end
                      else
                      begin
                        _log('pack:没有找到分页数量语句，请检查配置文件中是否包含分页数量语句');
                        raise Exception.Create('pack:没有找到分页数量语句，请检查配置文件中是否包含分页数量语句');
                      end;

                    end;
                    // _dbLog( AjsnPost, SO(pSession), Contants._NEW);
                  except
                    on e: Exception do
                    begin
                      _log(e.Message);
                      Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
                    end;
                  end;
                end;
              finally
                // dbPoolClass.FreeQuery(AiDbIdx);
                _RTC_DBPOLL.PutDBConn(AqryTmp);
                if AjsnPost <> nil then
                begin
                  AjsnPost := nil;
                end;
              end;
              // 返回数据
              Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, AsCount, AjsRes, Errors.SUCC);
            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
          end;
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
      end;

    end;
  finally
    // _gCS.Leave;

  end;

end;
/// ////
/// 查询单笔数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._Query(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt, AiDbIdx: integer;
  AndSelect: _THXML_Select;
  AqryTmp: TADOQuery;
begin
  // _gcs.Enter;
  try
    try
      _log('Query:' + pobj, COMINFOR.FDEVMODE);
      AjsnPost := SO(pobj)[Contants.O];
      AjsTmp1 := AjsnPost[Contants.ALIAS];
      if (AjsTmp1 <> nil) then
      begin
        AsTabAliasName := AjsTmp1.AsString;
        AjsTmp1 := AjsnPost[Contants.SELINDEX];
        if (AjsTmp1 <> nil) then
        begin
          AsSelName := AjsTmp1.AsString;
          if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
          begin
            AnodList := _XML_Poll._loadFields(AsTabAliasName);
            if (AnodList <> nil) then
            begin
              AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
              try

                AqryTmp := _RTC_DBPOLL.GetDBQuery;
                with AqryTmp do
                begin
                  // 查询数据
                  close;
                  Parameters.Clear;
                  SQL.Clear;
                  AsTmp := _selectSqlText(AsTabAliasName, AsSelName, AjsnPost, AndSelect, AnodList, Parameters);
                  _log('Query:' + AsTmp, COMINFOR.FDEVMODE);
                  SQL.Append(AsTmp);
                  Open;

                  AjsRes := dataRowToJson(AqryTmp, Contants.Data, AsTabAliasName);

                end;
              finally
                // dbPoolClass.FreeQuery(AiDbIdx);
                _RTC_DBPOLL.PutDBConn(AqryTmp);
                if AjsnPost <> nil then
                begin
                  AjsnPost := nil;
                end;
              end;
              // 返回数据
              Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsRes, Errors.SUCC);
            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
            end;

          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
          end;
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
        end;

      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
      end;

    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
  end;

end;
/// ////
/// 查询单笔数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB.Query(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsSql, AsCount, AsOstr: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1: ISuperObject;
  AlsFieldNames: TStringList;
  AiIdx, AiCnt, AiDbIdx: integer;
  AndSelect: _THXML_Select;
  AqryTmp: TADOQuery;
  ApoTmp: TPSQL_REC;

  procedure __Query();
  begin
    try
      AqryTmp := _RTC_DBPOLL.GetDBQuery;
      with AqryTmp do
      begin
        // 查询数据
        close;
        Parameters.Clear;
        SQL.Clear;
        _log('Query_cache:' + AsSql, COMINFOR.FDEVMODE);
        SQL.Append(AsSql);
        Open;
        AjsRes := dataRowToJson(AqryTmp, Contants.Data, AsTabAliasName);
      end;
    finally
      _RTC_DBPOLL.PutDBConn(AqryTmp);
      if AjsnPost <> nil then
      begin
        AjsnPost := nil;
      end;
    end;
  end;

begin
  // _gcs.Enter;
  try
    CoInitialize(nil);
    try
      _log('Query:' + pobj, COMINFOR.FDEVMODE);
      AjsnPost := SO(pobj)[Contants.O];
      AsOstr := AjsnPost.AsJSon();
      ApoTmp := SQLCaches.get(AsOstr);
      if ApoTmp <> nil then
      begin
        AsTabAliasName := ApoTmp.FAIASNAME;
        AsSql := ApoTmp.FSQLTEXT;
        __Query();
        // 返回数据
        Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsRes, Errors.SUCC);
      end
      else
      begin
        // AjsnPost := SO(pobj)[Contants.O];
        AjsTmp1 := AjsnPost[Contants.ALIAS];
        if (AjsTmp1 <> nil) then
        begin
          AsTabAliasName := AjsTmp1.AsString;
          AjsTmp1 := AjsnPost[Contants.SELINDEX];
          if (AjsTmp1 <> nil) then
          begin
            AsSelName := AjsTmp1.AsString;
            if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
            begin
              AnodList := _XML_Poll._loadFields(AsTabAliasName);
              if (AnodList <> nil) then
              begin
                AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
                try
                  AqryTmp := _RTC_DBPOLL.GetDBQuery;
                  with AqryTmp do
                  begin
                    // 查询数据
                    close;
                    Parameters.Clear;
                    SQL.Clear;
                    AsSql := _selectSqlText(AsTabAliasName, AsSelName, AjsnPost, AndSelect, AnodList, Parameters);
                    _log('Query:' + AsSql, COMINFOR.FDEVMODE);
                    SQL.Append(AsSql);
                    Open;
                    AjsRes := dataRowToJson(AqryTmp, Contants.Data, AsTabAliasName);
                    SQLCaches.Add(AsOstr, AsTabAliasName, AsSql, '');
                  end;
                finally
                  _RTC_DBPOLL.PutDBConn(AqryTmp);
                  if AjsnPost <> nil then
                  begin
                    AjsnPost := nil;
                  end;
                end;
                // 返回数据
                Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsRes, Errors.SUCC);
              end
              else
              begin
                Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
              end;

            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
          end;

        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
        end;
      end;

    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
    couninitialize;
  end;

end;
/// ////
/// 导出数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB.Eexports(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount, AsType: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsnPost, AjsRes, AjsTmp, AjsTmp1, AjsType: ISuperObject;
  AiIdx, AiCnt, AiDbIdx: integer;
  AndSelect: _THXML_Select;
  AndProce: _THXML_Proced;
  AsIsPage: Variant;
  AqryTmp: TADOQuery;
  AprcTmp: TADOStoredProc;
begin
  CoInitialize(nil);
  try
    try
      AjsnPost := SO(pobj)[Contants.O];
      AjsTmp1 := AjsnPost[Contants.ALIAS];
      if (AjsTmp1 <> nil) then
      begin
        AsTabAliasName := AjsTmp1.AsString;
        AjsTmp1 := AjsnPost[Contants.SELINDEX];
        if (AjsTmp1 <> nil) then
        begin
          AsSelName := AjsTmp1.AsString;
          if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
          begin
            AnodList := _XML_Poll._loadFields(AsTabAliasName);
            if (AnodList <> nil) then
            begin
              AjsType := AjsnPost[Contants.ISTYPE];
              try
                if AjsType = nil then
                begin
                  AqryTmp := _RTC_DBPOLL.GetDBQuery;

                  with AqryTmp do
                  begin
                    try
                      try
                        // 查询数据
                        close;
                        AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
                        Parameters.Clear;

                        SQL.Clear;
                        AsTmp := _selectSqlText(AsTabAliasName, AsSelName, AjsnPost, AndSelect, AnodList, Parameters);
                        _log(AsTmp, COMINFOR.FDEVMODE);
                        SQL.Append(AsTmp);
                        Open;

                        AjsRes := dataSetToJsonWithColNames(AqryTmp, Contants.ROWS);
                        AsIsPage := AndSelect._ispage;
                        if (CommonUtil.isNotEmpty(AsIsPage)) then
                        begin
                          AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName + '_count');
                          // 查询数量
                          close;
                          SQL.Clear;
                          SQL.Append(_selectSqlText(AsTabAliasName, AsSelName + Contants.INDEXCOUNT, AjsnPost, AndSelect, AnodList, Parameters));
                          Open;
                          if (RecordCount > 0) then
                          begin
                            First;
                            AsCount := VarToStr(Fields[0].Value);
                          end;
                        end;
                      except
                        on e: Exception do
                        begin
                          _log(e.Message);
                          Exception.ThrowOuterException(Exception.Create('pack:' + e.Message));
                        end;

                      end;
                    finally
                      _RTC_DBPOLL.PutDBConn(AqryTmp);
                      if AjsnPost <> nil then
                      begin
                        AjsnPost := nil;
                      end;
                      // if AnodList <> nil then
                      // begin
                      // FreeAndNil(AnodList);
                      // end;
                      // if AndSelect <> nil then
                      // begin
                      // FreeAndNil(AndSelect);
                      // end;
                    end;
                  end;
                end
                else if AjsType.AsString = '5' then
                begin
                  AprcTmp := _RTC_DBPOLL.GetDBStoredProc;
                  with AprcTmp do
                  begin
                    try
                      try
                        // 过程
                        AndProce := _XML_Poll._loadProcedure(AsTabAliasName, AsSelName);
                        close;
                        // SpecificOptions.Values['FetchAll'] := 'False';
                        Parameters.Clear;
                        // SQL.Clear;

                        AprcTmp.ProcedureName := AndProce._proc_name;
                        AsTmp := _procSqlText(AsTabAliasName, AsSelName, AjsnPost, AndProce, Parameters);
                        _log(AsTmp, COMINFOR.FDEVMODE);
                        // SQL.Append(AsTmp);
                        Open;
                        // AsIsPage := AndProce._ispage;
                        // if (CommonUtil.isNotEmpty(AsIsPage)) then
                        // begin
                        // AsCount := Fields[0].AsString;
                        // Next;
                        // AjsRes := ProcDataSetToJsonWithColNames(AprcTmp, Contants.ROWS);
                        // end
                        // else
                        // begin
                        // AjsRes := ProcDataSetToJsonWithColNames(AprcTmp, Contants.ROWS);
                        // end;

                        AsIsPage := AndProce._ispage;
                        if (CommonUtil.isNotEmpty(AsIsPage)) then
                        begin
                          AqryTmp := TADOQuery.Create(nil);
                          AqryTmp.Recordset := AprcTmp.Recordset;
                          AsCount := AqryTmp.Fields[0].AsString;
                          AqryTmp.close;
                          AqryTmp.Recordset := AprcTmp.NextRecordset(AiDbIdx);
                          AjsRes := dataSetToJsonWithColNames(AqryTmp, Contants.ROWS);
                          AqryTmp.close;
                        end
                        else
                        begin
                          AqryTmp := TADOQuery.Create(nil);
                          AqryTmp.Recordset := AprcTmp.Recordset;
                          AjsRes := dataSetToJsonWithColNames(AqryTmp, Contants.ROWS);
                          AqryTmp.close;
                        end;

                      except
                        on e: Exception do
                        begin
                          _log(e.Message);
                          Exception.ThrowOuterException(Exception.Create('pack:' + e.Message));
                        end;
                      end;
                    finally
                      _RTC_DBPOLL.PutDBConn(AprcTmp);
                      if AjsnPost <> nil then
                      begin
                        AjsnPost := nil;
                      end;
                      // if AndProce <> nil then
                      // begin
                      // FreeAndNil(AndProce);
                      // end;
                    end;

                  end;
                end;
                // _dbLog( AjsnPost, SO(pSession), Contants._NEW);

              except
                on e: Exception do
                begin
                  _log(e.Message);
                  Exception.ThrowOuterException(Exception.Create('pack:' + e.Message));
                end;
              end;

              // 返回数据
              Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, AsCount, AjsRes, Errors.SUCC);
            end
            else
            begin
              Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
          end;
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
        end;

      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
      end;

    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
      end;

    end;
  finally
    couninitialize;
  end;

end;
/// ////
/// 导出数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

// function TPackDB.ElnFile(pobj: AnsiString; pSession: string): ISuperObject;
// var
// AsTmp, AsFName, AsFilePath: string;
// AjsnPost, AjsRes, AjsFPath, AjsFName: ISuperObject;
// AiTmp: integer;
// begin
// try
// AjsnPost := SO(pobj)[Contants.O];
// AjsFPath := AjsnPost['fpath'];
// AjsFName := AjsnPost['fname'];
// if (AjsFPath <> nil) and (AjsFName <> nil) then
// begin
// AsTmp := AjsFPath.AsString;
// AsFName := AjsFName.AsString;
// if (AsTmp <> '') and (AsFName <> '') then
// begin
// AsFilePath := DownLoadFile(AsTmp);
// if AsFilePath <> '' then
// begin
// AiTmp := _AddFile(AsFilePath, AsFName);
// while AjsRes = nil do
// begin
// AjsRes := _getFile(AiTmp);
// end;
// Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, '0', AjsRes, Errors.SUCC);
// end
// else
// begin
// raise Exception.Create('ELNFILE:下载模板文件失败');
// end;
// end
// else
// begin
// raise Exception.Create('ELNFILE:请求模板参数不完整！');
// end;
// end
// else
// begin
// raise Exception.Create('ELNFILE:未发现文件路径');
// end;
//
// except
// on e: Exception do
// begin
// Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
// end;
//
// end;
//
// end;
/// ////
/// 导出数据
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB.ElnFile(pobj: AnsiString): ISuperObject;
var
  AsTmp, AsFilePath, AsSaveFolder: string;
  AjsnPost, AjsRes, AjsFPath: ISuperObject;
  AiTmp: integer;
begin
  try
    AjsnPost := SO(pobj)[Contants.O];
    AjsFPath := AjsnPost['fpath'];
    if (AjsFPath <> nil) then
    begin
      AsTmp := AjsFPath.AsString;
      if (AsTmp <> '') then
      begin
        AsFilePath := DownLoadFile(AsTmp);
        if AsFilePath <> '' then
        begin
          AsSaveFolder := inttostr(DateTimeToUnix(Now));
          if DBML.DBModule.unZipFile(AsFilePath, AsSaveFolder, _GZipPwd) then
          begin
            // AsFilePath := COMINFOR.FAPPPATH + '\template\' + AsSaveFolder + '\' + AsFName;
            AsFilePath := COMINFOR.FAPPPATH + '\template\' + AsSaveFolder + '\';
            AsFilePath := GetXlsFile(AsFilePath);
            AsFilePath := AsFilePath.Replace('\', '\\');
            AjsRes := SO('{fpath:"' + AsFilePath + '"}');
            Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, '0', AjsRes, Errors.SUCC);
          end;
        end
        else
        begin
          raise Exception.Create('ELNFILE:下载模板文件失败');
        end;
      end
      else
      begin
        raise Exception.Create('ELNFILE:请求模板参数不完整！');
      end;
    end
    else
    begin
      raise Exception.Create('ELNFILE:未发现文件路径');
    end;

  except
    on e: Exception do
    begin
      Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + AsTmp));
    end;

  end;

end;
/// ////
/// 执行存储过程
/// @author zephyr
/// @return void
/// @date 2016-3-2

/// /特殊字符对大小写string和AnsiString处理有区别，所以统一改成string

function TPackDB.Proc(pobj: string): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount: string;
  AnodProc: _THXML_Proced;
  AjsPost, AjsnPost, AjsRes, AjsTmp1, AjsUser: ISuperObject;
  AiDbIdx: integer;
  AprcTmp: TADOStoredProc;
  AsIsPage: Variant;
  AcnTmp: TADOConnection;
  AryTmp: TADOQuery;
begin
  // _gCS.Enter;
  AsTmp := '';
  try
    AjsPost := SO(pobj);
    AjsUser := AjsPost['sid'];
    AjsnPost := AjsPost[Contants.O];
    AjsTmp1 := AjsnPost[Contants.ALIAS];
    if (AjsTmp1 <> nil) then
    begin
      AsTabAliasName := AjsTmp1.AsString;
      AjsTmp1 := AjsnPost[Contants.SELINDEX];
      if (AjsTmp1 <> nil) then
      begin
        AsSelName := AjsTmp1.AsString;

        if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
        begin
          AnodProc := _XML_Poll._loadProcedure(AsTabAliasName, AsSelName);
          if (AnodProc <> nil) then
          begin
            // AnodProc := AnodList.ChildNodes[0];
            try
              CoInitialize(nil);
              AcnTmp := _RTC_DBPOLL.GetDBConnection;
              AprcTmp := _CreateProc(AcnTmp);
              // AcnTmp.BeginTrans;

              with AprcTmp do
              begin
                try
                  close;
                  // SpecificOptions.Values['FetchAll'] := 'False';
                  Parameters.Clear;
                  // SQL.Clear;
                  AprcTmp.ProcedureName := AnodProc._proc_name;
                  AsTmp := _procSqlText(AsTabAliasName, AsSelName, AjsnPost, AnodProc, Parameters);
                  _log(AsTmp + pobj, COMINFOR.FDEVMODE);
                  // SQL.Append(AsTmp);
                  Open;

                  AsIsPage := AnodProc._ispage;
                  if (CommonUtil.isNotEmpty(AsIsPage)) then
                  begin
                    AryTmp := TADOQuery.Create(nil);
                    AryTmp.Recordset := AprcTmp.Recordset;
                    AsCount := AryTmp.Fields[0].AsString;
                    AryTmp.close;
                    AryTmp.Recordset := AprcTmp.NextRecordset(AiDbIdx);
                    AjsRes := dataSetToJson(AryTmp, Contants.ROWS, AsTabAliasName);
                    AryTmp.close;
                    // 返回数据
                    Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, AsCount, AjsRes, Errors.SUCC);
                  end
                  else
                  begin
                    AryTmp := TADOQuery.Create(nil);
                    AryTmp.Recordset := AprcTmp.Recordset;
                    AjsRes := dataSetToJson(AryTmp, Contants.Data, AsTabAliasName);
                    AryTmp.close;
                    // 返回数据
                    Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsRes, Errors.SUCC);
                  end;
                  _dbLog(AjsnPost, AjsUser, Contants._EXECPROC, AcnTmp);
                  // AcnTmp.CommitTrans;
                except
                  on e: Exception do
                  begin
                    // if AcnTmp.InTransaction then
                    // AcnTmp.RollbackTrans;
                    _log(e.Message);
                    Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + pobj));
                  end;
                end;
              end;
            finally
              // dbPoolClass.FreeQuery(AiDbIdx);
              _RTC_DBPOLL.PutDBConn(AprcTmp);
              // _gCS.Leave;
              if AjsnPost <> nil then
              begin
                AjsnPost := nil;
              end;
              if AryTmp <> nil then
              begin
                AryTmp.Free;
              end;
              AsTabName := '';
              AsTabAliasName := '';
              AsSelName := '';
              AsTmp := '';
              AsCount := '';
              couninitialize;
            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
          end;

        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
        end
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
      end;
    end
    else
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
    end;
  except
    on e: Exception do
    begin
      _log('pack:' + e.Message + ':' + pobj + ':' + AsTmp);
      Exception.ThrowOuterException(Exception.Create('pack:' + e.Message + ':' + pobj + ':' + AsTmp));
    end;
  end;
end;
/// ////
/// 组装查询
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._selectSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsbSql: TStringBuilder;
  AsWhere, AsGroupBy, AsOrderBy, AsTmp, AsIsWhere, AsIsGroupby: string;
  AiIdx: integer;
begin
  AsbSql := TStringBuilder.Create;
  try
    try
      if (pndSelect <> nil) then
      begin
        AsTmp := Contants.KONGGE + pndSelect._sqltext;
        AsWhere := Contants.KONGGE + _where(pJson, nodeList, pndSelect);

        // 加载where 条件
        if (CommonUtil.isNotEmpty(AsWhere)) then
        begin
          AiIdx := AsTmp.IndexOf('%s');
          AsIsWhere := pndSelect._iswhere;
          if (CommonUtil.isNotEmpty(AsIsWhere)) then
          begin
            if AiIdx > 0 then
            begin
              AsbSql.Append(Format(AsTmp, [Contants.KONGGE + AsWhere]));
            end
            else
            begin
              AsbSql.Append(AsTmp + Contants.KONGGE + AsWhere);
            end;
          end
          else
          begin
            if AiIdx > 0 then
            begin
              AsbSql.Append(Format(AsTmp, [Contants.KONGGE + Contants.WHERE + AsWhere]));
            end
            else
            begin
              AsbSql.Append(AsTmp + Contants.KONGGE + Contants.WHERE + AsWhere);
            end;
          end;
        end
        else
        begin
          AsbSql.Append(AsTmp);
        end;

        // 拼接groupby分组
        AsIsGroupby := pndSelect._groupby;
        if (CommonUtil.isNotEmpty(AsIsGroupby)) then
        begin
          AsbSql.Append(Contants.KONGGE + Contants.GROUPBYSQL + Contants.KONGGE + AsIsGroupby);
        end;

        // 拼接oderby分组
        if (nodeList <> nil) then
        begin
          AsOrderBy := _getOrderby(pJson, pndSelect, nodeList);
          if (CommonUtil.isNotEmpty(AsOrderBy)) then
          begin
            AsbSql.Append(Contants.KONGGE + Contants.ORDERBYSQL + Contants.KONGGE + AsOrderBy);
          end;
        end;
        Result := AsbSql.ToString();
      end
      else
      begin
        raise Exception.Create(Errors.NOTFINDQUERYPARAMS); // 未找到查询语句
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    AsWhere := '';
    AsGroupBy := '';
    AsOrderBy := '';
    AsTmp := '';
    AsIsWhere := '';
    AsIsGroupby := '';
    freeAndNil(AsbSql);
  end;
end;

function TPackDB._selectCountSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsbSql: TStringBuilder;
  AsWhere, AsGroupBy, AsOrderBy, AsTmp, AsIsWhere, AsIsGroupby: string;
  AiIdx: integer;
begin
  AsbSql := TStringBuilder.Create;
  try
    try
      if (pndSelect <> nil) then
      begin
        AsTmp := Contants.KONGGE + pndSelect._sqltext;
        AsWhere := Contants.KONGGE + _where(pJson, nodeList, pndSelect);

        // 加载where 条件
        if (CommonUtil.isNotEmpty(AsWhere)) then
        begin
          AiIdx := AsTmp.IndexOf('%s');
          AsIsWhere := pndSelect._iswhere;
          if (CommonUtil.isNotEmpty(AsIsWhere)) then
          begin
            if AiIdx > 0 then
            begin
              AsbSql.Append(Format(AsTmp, [Contants.KONGGE + AsWhere]));
            end
            else
            begin
              AsbSql.Append(AsTmp + Contants.KONGGE + AsWhere);
            end;
          end
          else
          begin
            if AiIdx > 0 then
            begin
              AsbSql.Append(Format(AsTmp, [Contants.KONGGE + Contants.WHERE + AsWhere]));
            end
            else
            begin
              AsbSql.Append(AsTmp + Contants.KONGGE + Contants.WHERE + AsWhere);
            end;
          end;
        end
        else
        begin
          AsbSql.Append(AsTmp);
        end;

        // // 拼接groupby分组
        // AsIsGroupby := pndSelect._groupby;
        // if (CommonUtil.isNotEmpty(AsIsGroupby)) then
        // begin
        // AsbSql.Append(Contants.KONGGE + Contants.GROUPBYSQL + Contants.KONGGE + AsIsGroupby);
        // end;

        // 拼接oderby分组
        // if (nodeList <> nil) then
        // begin
        // AsOrderBy := _getOrderby(pJson, pndSelect, nodeList);
        // if (CommonUtil.isNotEmpty(AsOrderBy)) then
        // begin
        // AsbSql.Append(Contants.KONGGE + Contants.ORDERBYSQL + Contants.KONGGE + AsOrderBy);
        // end;
        // end;
        Result := AsbSql.ToString();
      end
      else
      begin
        raise Exception.Create(Errors.NOTFINDQUERYPARAMS); // 未找到查询语句
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    freeAndNil(AsbSql);
  end;
end;
/// ////
/// 组装查询SQL
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._selectSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsTabName, AsSqlText: string;
  AsIsPage: string;
  AiPageNum, AiPageSize: integer;
  AjsPageNum, AjsPageSize: ISuperObject;
begin
  // _gCS.Enter;
  try
    try
      AsSqlText := _selectSql(tbName, selName, pjsonFields, pndSelect, nodeList, pParams);
      // AsSqlText := AsSql;
      // 是否分页
      AsIsPage := pndSelect._ispage;
      if (AsIsPage <> '') then
      begin
        // 组装分页信息
        AjsPageNum := pjsonFields[Contants.pagenum];
        AjsPageSize := pjsonFields[Contants.pagesize];
        if (AjsPageNum <> nil) and (AjsPageSize <> nil) then
        begin
          AiPageNum := AjsPageNum.AsInteger;
          AiPageSize := AjsPageSize.AsInteger;
          Result := pageSql(AsSqlText, AiPageNum, AiPageSize);
        end
        else
        begin
          Result := Contants.select + Contants.KONGGE + AsSqlText;
        end;
      end
      else
      begin
        Result := Contants.select + Contants.KONGGE + AsSqlText;
      end;

    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
    AsSqlText := '';
    AjsPageNum := nil;
    AjsPageNum := nil;
  end;
end;
/// ////
/// 组装查询SQL
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._selectCountSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pndSelect: _THXML_Select; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsTabName, AsSqlText: string;
  AsIsPage: string;
  AiPageNum, AiPageSize: integer;
  AjsPageNum, AjsPageSize: ISuperObject;
begin
  // _gCS.Enter;
  try
    try
      AsSqlText := _selectCountSql(tbName, selName, pjsonFields, pndSelect, nodeList, pParams);
      Result := Contants.select + Contants.KONGGE + AsSqlText;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
    AsSqlText := ''
  end;
end;
/// ////
/// 组装查询
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._procSql(tbName: string; selName: string; pJson: ISuperObject; pndSelect: _THXML_Proced; pParams: TParameters): string;
var
  AsbSql: TStringBuilder;
  AsValue, AsFieldName, AsOrderBy, AsTmp: string;
  AndProc, AndParams, AnodeTmp: _THXML_Proced;
  AndlistParams: TList;
  AiIdx, AiCnt: integer;
  AvTmp: ISuperObject;
  AcsParam: _THXML_Param;
begin
  // _gCS.Enter;
  try
    try
      AsbSql := TStringBuilder.Create;
      if (pndSelect <> nil) then
      begin
        AndProc := pndSelect;
        if AndProc <> nil then
        begin
          AndlistParams := pndSelect._proc_params;
          if AndlistParams <> nil then
          begin
            AsbSql.Append(Contants.PROCCALL + AndProc._proc_name + Contants.LEFTKH);
            AiCnt := AndlistParams.Count - 1;
            for AiIdx := 0 to AiCnt do
            begin
              AcsParam := AndlistParams[AiIdx];
              AsTmp := AcsParam._fieldname;
              AvTmp := pJson[AsTmp];
              if AvTmp <> nil then
              begin
                AsValue := AvTmp.AsString;
              end
              else
              begin
                AsValue := '';
              end;

              // if (POS('"', AsValue) > 0) then
              // begin
              // AsValue := AsValue.Replace('"', '&quot;');
              // end;
              /// 关闭原因，存储过程查询时有可能使用单引号
              // if (POS('''', AsValue) > 0) then
              // begin
              // AsValue := AsValue.Replace('''', '&apos;');
              // end;
              // _log('22--------------------->' + AsValue);

              AsFieldName := AsTmp;
              AsbSql.Append(Contants.MAO + AsFieldName + Contants.DOU);
              _prepareParams(AcsParam, AsValue, AsFieldName, pParams);
            end;
            AsTmp := AsbSql.ToString;
            AsTmp := AsTmp.Substring(0, AsTmp.Length - 1);
            Result := AsTmp + Contants.RIGHTKH;
          end
          else
          begin
            raise Exception.Create(Errors.NOTFINDQUERYPARAMS);
          end;
        end
        else
        begin
          raise Exception.Create(Errors.NOTFINDQUERYPARAMS);
        end;
      end
      else
      begin
        raise Exception.Create(Errors.NOTFINDQUERYPARAMS); // 未找到查询语句
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
    if (AsbSql <> nil) then
    begin
      freeAndNil(AsbSql);
    end;
  end;

end;
/// ////
/// 组装存储过程SQL
/// @author zephyr
/// @return void
/// @date 2016-3-2

function TPackDB._procSqlText(tbName: string; selName: string; pjsonFields: ISuperObject; pNdProc: _THXML_Proced; pParams: TParameters): string;
begin
  try
    Result := _procSql(tbName, selName, pjsonFields, pNdProc, pParams);
  except
    on e: Exception do
    begin
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;
  end;
end;
/// ////
/// 新增
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26
/// /特殊字符对大小写string和AnsiString处理有区别，所以统一改成string

function TPackDB.Insert(pobj: string): ISuperObject;
var
  AsbSql, AsbSqlText: TStringBuilder;
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsPost, AjsnPost, AjsTmp1, AjsUser: ISuperObject;
  AiRes, AiDbIdx: integer;
  AcnTmp: TADOConnection;
  AqryTmp: TADOQuery;
begin
  try
    AjsPost := SO(pobj);
    AjsUser := AjsPost['sid'];
    AjsnPost := AjsPost[Contants.O];
    AjsTmp1 := AjsnPost[Contants.ALIAS];
    if (AjsTmp1 <> nil) then
    begin
      AsTabAliasName := AjsTmp1.AsString;
      AjsTmp1 := AjsnPost[Contants.SELINDEX];
      if (AjsTmp1 <> nil) then
      begin
        AsSelName := AjsTmp1.AsString;
        if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
        begin
          AnodList := _XML_Poll._loadFields(AsTabAliasName);
          if (AnodList <> nil) then
          begin
            try
              CoInitialize(nil);
              AcnTmp := _RTC_DBPOLL.GetDBConnection;
              AqryTmp := _CreateQuery(AcnTmp);
              // AcnTmp.BeginTrans;
              with AqryTmp do
              begin
                try
                  Parameters.Clear;
                  SQL.Clear;
                  AsTmp := _insertSqlText(AsTabAliasName, AjsnPost, AnodList, Parameters);
                  _log(AsTmp, COMINFOR.FDEVMODE);
                  SQL.Append(AsTmp);
                  ExecSQL;
                  _dbLog(AjsnPost, AjsUser, Contants._NEW, AcnTmp);
                  // AcnTmp.CommitTrans;
                except
                  on e: Exception do
                  begin
                    // AcnTmp.RollbackTrans;
                    _log(e.Message);
                    Exception.ThrowOuterException(Exception.Create(e.Message));
                  end;
                end;
              end;
            finally
              // dbPoolClass.FreeQuery(AiDbIdx);
              _RTC_DBPOLL.PutDBConn(AcnTmp);
              if AjsnPost <> nil then
              begin
                AjsnPost := nil;
              end;
              if AqryTmp <> nil then
              begin
                AqryTmp.Free;
              end;
              couninitialize;
            end;
            Result := ResUtils.JsonForResMsg(Contants.SUCCFLAG, Errors.SUCC);
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
          end;

        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDSELINDEX);
      end;
    end
    else
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
    end;
  except
    on e: Exception do
    begin
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;
  end;

end;

/// ////
/// 组装添加sql
/// @author yzw
/// @return void
/// @throws Exception
/// @date 2016-3-2
function TPackDB._insertSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): TStringBuilder;
var
  AnodeTmp: _THXML_Field;
  AiIdx, AiCnt: integer;
  AsTmp, AsFieldName, AsValue: string;
  AijsnTmp: ISuperObject;
  AaryField: TStringBuilder;
  AvTmp: ISuperObject;
begin
  // _gCS.Enter;
  try
    try
      AijsnTmp := pjsonFields[Contants.Fields];
      Result := TStringBuilder.Create;
      AiCnt := nodeList.Count - 1;
      for AnodeTmp in nodeList.Values do
      begin
        // AnodeTmp := nodeList[AiIdx];
        AsTmp := 'd_' + AnodeTmp._fieldname;
        AvTmp := AijsnTmp[AsTmp];
        if (AvTmp <> nil) then
        begin
          AsValue := AvTmp.AsString();
          // if (POS('"', AsValue) > 0) then
          // begin
          // AsValue := AsValue.Replace('"', '&quot;');
          // end;
          // if (POS('''', AsValue) > 0) then
          // begin
          // AsValue := AsValue.Replace('''', '&apos;');
          // end;
          AsFieldName := AnodeTmp._fieldname;
          Result.Append(AsFieldName + Contants.DOU);
          _prepareParams(AnodeTmp, AsValue, AsFieldName, pParams);

        end;
        AaryField := Result;
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;

  finally
    // _gCS.Leave;
  end;
end;
/// ////
/// 组装添加sql
/// @author yzw
/// @return void
/// @throws Exception
/// @date 2016-3-2

function TPackDB._insertSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsbSql, AsbSqlText: TStringBuilder;
  AsTabName: string;
begin
  // _gCS.Enter;
  try
    try
      AsbSqlText := _insertSql(tbName, pjsonFields, nodeList, pParams);

      AsbSql := TStringBuilder.Create;
      AsbSql.Append(Contants.INSERTPRE);
      AsTabName := _XML_Poll._getTableName(tbName);
      AsbSql.Append(AsTabName);
      AsbSql.Append(Contants.LEFTKH);
      AsbSql.Append(CommonUtil.listToStr(AsbSqlText.ToString(), Contants.DOU));
      AsbSql.Append(Contants.RIGHTKH);
      AsbSql.Append(Contants.INSERTVALUE);
      AsbSql.Append(Contants.LEFTKH);
      AsbSql.Append(Contants.MAO + CommonUtil.listToStr(AsbSqlText.ToString(), Contants.DOU + Contants.MAO));
      AsbSql.Append(Contants.RIGHTKH);

      Result := AsbSql.ToString();
    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;

  finally
    // _gCS.Leave;
    if AsbSql <> nil then
    begin
      freeAndNil(AsbSql);
    end;
    if AsbSqlText <> nil then
    begin
      freeAndNil(AsbSqlText);
    end;
  end;
end;
/// <summary>
/// 修改
/// </summary>
/// <param name="pobj"></param>
/// <returns></returns>
/// /特殊字符对大小写string和AnsiString处理有区别，所以统一改成string

function TPackDB.Update(pobj: string): ISuperObject;
var
  AjsnPost: ISuperObject;
begin
  try
    try
      AjsnPost := SO(pobj)[Contants.O];
      if (AjsnPost[Contants.ITEMS]) = nil then
      begin
        Result := _Update(pobj);
      end
      else
      begin
        Result := Updates(pobj);
      end;
    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
  end;
end;

/// ////
/// 单笔修改
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function TPackDB._Update(pobj: AnsiString): ISuperObject;
var
  AsbSql, AsbSqlText: TStringBuilder;
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsPost, AjsnPost, AjsTmp1, AjsUser: ISuperObject;
  AcnTmp: TADOConnection;
  AqryTmp: TADOQuery;
  AiDbIdx: integer;
begin
  // _gCS.Enter;
  try
    AjsPost := SO(pobj);
    AjsUser := AjsPost['sid'];
    AjsnPost := AjsPost[Contants.O];
    AjsTmp1 := AjsnPost[Contants.ALIAS];
    if (AjsTmp1 <> nil) then
    begin
      AsTabAliasName := AjsTmp1.AsString;
      // AsSelName := AjsnPost[Contants.SELINDEX].AsString;
      if isNotEmpty(AsTabAliasName) then
      begin
        AnodList := _XML_Poll._loadFields(AsTabAliasName);
        if (AnodList <> nil) then
        begin
          try
            CoInitialize(nil);
            AcnTmp := _RTC_DBPOLL.GetDBConnection;
            AqryTmp := _CreateQuery(AcnTmp);
            // AcnTmp.BeginTrans;
            with AqryTmp do
            begin
              try
                close;
                Parameters.Clear;
                SQL.Clear;
                AsTmp := _updateSqlText(AsTabAliasName, AjsnPost, AnodList, Parameters);
                _log(AsTmp, COMINFOR.FDEVMODE);
                SQL.Append(AsTmp);
                ExecSQL;
                _dbLog(AjsnPost, AjsUser, Contants._Update, AcnTmp);
                // AcnTmp.CommitTrans;
              except
                on e: Exception do
                begin
                  // AcnTmp.RollbackTrans;
                  _log(e.Message);
                  Exception.ThrowOuterException(Exception.Create(e.Message));
                end;
              end;
            end;
          finally
            // dbPoolClass.FreeQuery(AiDbIdx);
            _RTC_DBPOLL.PutDBConn(AcnTmp);
            if AjsnPost <> nil then
            begin
              AjsnPost := nil;
            end;
            if AqryTmp <> nil then
            begin
              AqryTmp.Free;
            end;
            couninitialize;
          end;
          Result := ResUtils.JsonForResMsg(Contants.SUCCFLAG, Errors.SUCC);
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
        end;

      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
      end;
    end
    else
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
    end;
  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + e.Message);
    end;

  end;
end;
/// ////
/// 多笔数据操作
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function TPackDB.Updates(pobj: string): ISuperObject;
var
  AsbSql, AsbSqlText: TStringBuilder;
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsPost, AjsnPost, AjsTmp, AjsTmp1, AjsRes, AjsTmpObj, AjsAryRes, AjsUser: ISuperObject;
  AconTmp: TADOConnection;
  AqryTmp, AqryTmp1: TADOQuery;
  AprcTmp: TADOStoredProc;
  AiDbIdx, AiIdx, AiCnt: integer;
  AjsAryItems: TSuperArray;
  AsIsPage: Variant;
  AnodProc, AndProce: _THXML_Proced;
begin
  // _gCS.Enter;

  try
    AjsPost := SO(pobj);
    AjsUser := AjsPost['sid'];
    AjsnPost := AjsPost[Contants.O];
    AjsAryRes := TSuperObject.Create(stObject);
    AjsAryRes[Contants.ROWS] := SA([]);

    AjsAryItems := AjsnPost[Contants.ITEMS].AsArray;
    // AjsUser := fAuthentication.GetSession(AjsnPost['sid'].AsInteger);
    AiCnt := AjsAryItems.Length - 1;
    try
      CoInitialize(nil);
      AconTmp := _RTC_DBPOLL.GetDBConnection;
      // AconTmp.BeginTrans;
      try
        for AiIdx := 0 to AiCnt do
        begin
          AjsTmp := AjsAryItems[AiIdx];
          AjsTmp1 := AjsTmp[Contants.ALIAS];
          if (AjsTmp1 <> nil) then
          begin
            AsTabAliasName := AjsTmp1.AsString;
            AjsTmp1 := AjsTmp[Contants.SELINDEX];
            if (AjsTmp1 <> nil) then
            begin
              AsSelName := AjsTmp1.AsString;
              if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
              begin
                AnodList := _XML_Poll._loadFields(AsTabAliasName);
                if (AnodList <> nil) then
                begin
                  AjsTmp1 := AjsTmp[Contants.ISTYPE];
                  if (AjsTmp1 <> nil) then
                  begin
                    AsTmp := AjsTmp1.AsString;
                    if (AsTmp = '1') then
                    begin
                      if AqryTmp = nil then
                      begin
                        AqryTmp := TADOQuery.Create(nil);
                        AqryTmp.Connection := AconTmp;
                      end;
                      with AqryTmp do
                      begin
                        // 新增
                        close;
                        Parameters.Clear;
                        SQL.Clear;
                        AsTmp := _insertSqlText(AsTabAliasName, AjsTmp, AnodList, Parameters);
                        SQL.Append(AsTmp);
                        ExecSQL;
                        _dbLog(AjsTmp, AjsUser, Contants._NEW, AconTmp);
                        _log('insert:' + AsTmp, COMINFOR.FDEVMODE);
                      end;
                    end
                    else if (AsTmp = '2') then
                    begin
                      if AqryTmp = nil then
                      begin
                        AqryTmp := TADOQuery.Create(nil);
                        AqryTmp.Connection := AconTmp;
                      end;
                      with AqryTmp do
                      begin
                        // 修改
                        close;
                        Parameters.Clear;
                        SQL.Clear;
                        AsTmp := _updateSqlText(AsTabAliasName, AjsTmp, AnodList, Parameters);
                        SQL.Append(AsTmp);
                        ExecSQL;
                        _dbLog(AjsTmp, AjsUser, Contants._Update, AconTmp);
                        _log('update:' + AsTmp, COMINFOR.FDEVMODE);
                      end;
                    end
                    else if (AsTmp = '3') then
                    begin
                      if AqryTmp = nil then
                      begin
                        AqryTmp := TADOQuery.Create(nil);
                        AqryTmp.Connection := AconTmp;
                      end;
                      with AqryTmp do
                      begin
                        // 删除
                        close;
                        Parameters.Clear;
                        SQL.Clear;
                        AsTmp := _deleteSqlText(AsTabAliasName, AjsTmp, AnodList, Parameters);
                        SQL.Append(AsTmp);
                        ExecSQL;
                        _dbLog(AjsTmp, AjsUser, Contants._DELETE, AconTmp);
                        _log('delete:' + AsTmp, COMINFOR.FDEVMODE);
                      end;
                    end
                    else if (AsTmp = '5') then
                    begin
                      if AprcTmp = nil then
                      begin
                        AprcTmp := TADOStoredProc.Create(nil);
                        AprcTmp.Connection := AconTmp;
                      end;
                      if AqryTmp1 = nil then
                      begin
                        AqryTmp1 := TADOQuery.Create(nil);
                      end;
                      AndProce := _XML_Poll._loadProcedure(AsTabAliasName, AsSelName);
                      with AprcTmp do
                      begin
                        // 过程
                        close;
                        Parameters.Clear;
                        AprcTmp.ProcedureName := AndProce._proc_name;
                        AsTmp := _procSqlText(AsTabAliasName, AsSelName, AjsTmp, AndProce, Parameters);
                        _log('proc:' + AsTmp, COMINFOR.FDEVMODE);
                        // SQL.Append(AsTmp);
                        Open;
                        AsIsPage := AndProce._ispage;
                        if (CommonUtil.isNotEmpty(AsIsPage)) then
                        begin
                          AqryTmp1.Recordset := AprcTmp.Recordset;
                          AsCount := AqryTmp1.Fields[0].AsString;
                          AqryTmp1.close;
                          AqryTmp1.Recordset := AprcTmp.NextRecordset(AiDbIdx);
                          AjsRes := dataSetToJson(AqryTmp1, Contants.ROWS, AsTabAliasName);
                          AqryTmp1.close;
                          AjsTmpObj := TSuperObject.Create(stObject);
                          AjsTmpObj.S['totalrecords'] := AsCount;
                          AjsTmpObj.Merge(AjsRes);
                          AjsAryRes.A[AsSelName].Add(AjsTmpObj);
                        end
                        else
                        begin
                          AqryTmp1.Recordset := AprcTmp.Recordset;
                          AjsRes := dataSetToJson(AqryTmp1, AsSelName, AsTabAliasName);
                          AjsAryRes.A[Contants.ROWS].Add(AjsRes);
                        end;
                        _dbLog(AjsTmp, AjsUser, Contants._EXECPROC, AconTmp);
                      end;
                    end;
                  end
                  else
                  begin
                    // if AconTmp.InTransaction then
                    // AconTmp.RollbackTrans;
                    _log(Errors.UNFINDISTYPE);
                    raise Exception.Create(Errors.UNFINDISTYPE);
                  end;

                end
                else
                begin
                  // if AconTmp.InTransaction then
                  // AconTmp.RollbackTrans;
                  _log(Errors.FIELDSISNULL);
                  raise Exception.Create(Errors.FIELDSISNULL);
                end;
              end
              else
              begin
                // if AconTmp.InTransaction then
                // AconTmp.RollbackTrans;
                _log(Errors.POSTINFORERROR);
                raise Exception.Create(Errors.POSTINFORERROR);
              end;
            end
            else
            begin
              // if AconTmp.InTransaction then
              // AconTmp.RollbackTrans;
              _log(Errors.UNFINDALIEAS);
              raise Exception.Create(Errors.UNFINDALIEAS);
            end;
          end
          else
          begin
            // if AconTmp.InTransaction then
            // AconTmp.RollbackTrans;
            _log(Errors.UNFINDSELINDEX);
            raise Exception.Create(Errors.UNFINDSELINDEX);
          end;
        end;
        // AconTmp.CommitTrans;
        Result := ResUtils.JsonForSelects(Contants.SUCCFLAG, '0', AjsAryRes, Errors.SUCC);
      except
        on e: Exception do
        begin
          // if AconTmp.InTransaction then
          // AconTmp.RollbackTrans;
          _log(e.Message);
          raise Exception.Create(e.Message);
        end;
      end;
    finally
      _RTC_DBPOLL.PutDBConn(AconTmp);
      if AjsnPost <> nil then
      begin
        AjsnPost := nil;
      end;
      if AqryTmp <> nil then
      begin
        AqryTmp.Free;
      end;
      if AqryTmp1 <> nil then
      begin
        AqryTmp1.Free;
      end;
      if AprcTmp <> nil then
      begin
        AprcTmp.Free;
      end;
      couninitialize;
    end;
  except
    on e: Exception do
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + e.Message);
    end;
  end;
end;

/// ////
/// 组装更新sql
/// @author yzw
/// @return void
/// @throws Exception
/// @date 2016-3-2

function TPackDB._updateSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AnodeTmp: _THXML_Field;
  AiIdx, AiCnt: integer;
  AsTmp, AsFieldName, AsValue: string;
  AijsnTmp: ISuperObject;
  AsbRes: TStringBuilder;
  AvTmp: ISuperObject;
begin
  // _gCS.Enter;
  Result := '';
  try
    try
      AijsnTmp := pjsonFields[Contants.Fields];
      AsbRes := TStringBuilder.Create;
      // AiCnt := nodeList.Count - 1;
      for AnodeTmp in nodeList.Values do
      begin
        // AnodeTmp := nodeList[AiIdx];
        if AnodeTmp._isvirtual = '' then
        begin
          AsTmp := 'd_' + AnodeTmp._fieldname;
          AvTmp := AijsnTmp[AsTmp];
          if (AvTmp <> nil) then
          begin
            AsValue := AvTmp.AsString;
            // if (POS('"', AsValue) > 0) then
            // begin
            // AsValue := AsValue.Replace('"', '&quot;');
            // end;
            // if (POS('''', AsValue) > 0) then
            // begin
            // AsValue := AsValue.Replace('''', '&apos;');
            // end;
            // AsValue := QuotedStr(AsValue);
            // _log(AsValue);
            AsFieldName := AnodeTmp._fieldname;
            AsbRes.Append(AsFieldName + Contants.KONGGE + Contants.EQ + Contants.MAO + AsFieldName + Contants.KONGGE + Contants.DOU);
            _prepareParams(AnodeTmp, AsValue, AsFieldName, pParams);
          end;
        end;
      end;
      AsTmp := AsbRes.ToString;
      AsTmp := AsTmp.Substring(0, AsTmp.Length - 1);
      Result := AsTmp + Contants.WHERE + Contants.KONGGE + _where(pjsonFields, nodeList, nil);

    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;
    end;
  finally
    // _gCS.Leave;
    if AsbRes <> nil then
    begin
      freeAndNil(AsbRes);
    end;
  end;
end;
/// ////
/// 组装更新sql
/// @author yzw
/// @return void
/// @throws Exception
/// @date 2016-3-2

function TPackDB._updateSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsbSql: TStringBuilder;
  AsTabName, AsSqlText: string;
begin
  AsSqlText := '';
  AsbSql := TStringBuilder.Create;
  try
    try
      AsSqlText := _updateSql(tbName, pjsonFields, nodeList, pParams);
      AsbSql.Append(Contants.Update + Contants.KONGGE);
      AsTabName := _XML_Poll._getTableName(tbName);
      AsbSql.Append(AsTabName);
      AsbSql.Append(Contants.KONGGE + Contants._SET);
      AsbSql.Append(AsSqlText);

      Result := AsbSql.ToString();
    except
      on e: Exception do
      begin
        _log(e.Message);
        raise Exception.Create(e.Message);
      end;

    end;
  finally
    AsSqlText := '';
    if AsbSql <> nil then
    begin
      freeAndNil(AsbSql);
    end;
  end;
end;

/// ////
/// 删除
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-12-26

function TPackDB.Delete(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: TDictionary<string, _THXML_Field>;
  AjsPost, AjsnPost, AjsTmp1, AjsUser: ISuperObject;
  AcnTmp: TADOConnection;
  AqryTmp: TADOQuery;
  AiDbIdx: integer;
begin
  try
    CoInitialize(nil);
    try
      AjsPost := SO(pobj);
      AjsUser := AjsPost['sid'];
      AjsnPost := AjsPost[Contants.O];
      AjsTmp1 := AjsnPost[Contants.ALIAS];
      if (AjsTmp1 <> nil) then
      begin
        AsTabAliasName := AjsTmp1.AsString;
        if isNotEmpty(AsTabAliasName) then
        begin
          AnodList := _XML_Poll._loadFields(AsTabAliasName);
          if (AnodList <> nil) then
          begin
            try
              AcnTmp := _RTC_DBPOLL.GetDBConnection;
              AqryTmp := _CreateQuery(AcnTmp);
              // AcnTmp.BeginTrans;
              with AqryTmp do
              begin
                try
                  close;
                  Parameters.Clear;
                  SQL.Clear;
                  AsTmp := _deleteSqlText(AsTabAliasName, AjsnPost, AnodList, Parameters);
                  _log(AsTmp, COMINFOR.FDEVMODE);
                  SQL.Append(AsTmp);
                  ExecSQL;
                  _dbLog(AjsnPost, AjsUser, Contants._DELETE, AcnTmp);
                  // AcnTmp.CommitTrans;
                except
                  on e: Exception do
                  begin
                    // AcnTmp.RollbackTrans;
                    _log(e.Message);
                    Exception.ThrowOuterException(Exception.Create(e.Message));
                  end;
                end;
              end;
            finally
              // dbPoolClass.FreeQuery(AiDbIdx);
              _RTC_DBPOLL.PutDBConn(AcnTmp);
            end;

            Result := ResUtils.JsonForResMsg(Contants.SUCCFLAG, Errors.SUCC);
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
          end;

        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.UNFINDALIEAS);
      end;

    except
      on e: Exception do
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.SERVERERROR + Contants.MAO + e.Message);
      end;

    end;
  finally
    if (AjsnPost <> nil) then
    begin
      AjsnPost := nil;
    end;
    if (AqryTmp <> nil) then
    begin
      AqryTmp.Free;
    end;
    couninitialize;
  end;

end;

/// <summary>
///
/// </summary>
/// <param name="tbName"></param>
/// <param name="pjsonFields"></param>
/// <param name="nodeList"></param>
/// <param name="pParams"></param>
/// <returns></returns>

function TPackDB._deleteSqlText(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
var
  AsbSql: TStringBuilder;
  AsTabName: string;
begin
  AsbSql := TStringBuilder.Create;
  try
    try
      AsbSql.Append(Contants.DeleteFrm + Contants.KONGGE);
      AsTabName := _XML_Poll._getTableName(tbName);
      AsbSql.Append(AsTabName);
      AsbSql.Append(_deleteSql(tbName, pjsonFields, nodeList, pParams));

      Result := AsbSql.ToString();
    except
      on e: Exception do
      begin
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if (AsbSql <> nil) then
    begin
      freeAndNil(AsbSql);
    end;
  end;

end;
/// <summary>
///
/// </summary>
/// <param name="tbName"></param>
/// <param name="pjsonFields"></param>
/// <param name="nodeList"></param>
/// <param name="pParams"></param>
/// <returns></returns>

function TPackDB._deleteSql(tbName: string; pjsonFields: ISuperObject; nodeList: TDictionary<string, _THXML_Field>; pParams: TParameters): string;
begin
  Result := Contants.WHERE + Contants.KONGGE + _where(pjsonFields, nodeList, nil);
end;
/// ////
/// 准备字段参数
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23

function TPackDB._prepareParams(pNode: _THXML_Param; pValue: Variant; psFieldName: string; pParams: TParameters): string;
var
  AsTmp, AsTmp1: string;
  AeParamType: TDbTypes;
  AvTmp: string;
  Aparam: TParameter;
  idhttp1: TIdHTTP;
  ms: TMemoryStream;
  AiLen: integer;
begin
  try
    try
      if (pNode <> nil) then
      begin
        AvTmp := pNode._iskey;
        AiLen := StrToIntDef(pNode._length, 50);
        if (not CommonUtil.isNotEmpty(AvTmp)) then
        begin
          // if (CommonUtil.VarNotNull(pValue)) then
          // begin
          AsTmp := pNode._type;
          AeParamType := TDbTypes(GetEnumvalue(TypeInfo(TDbTypes), AsTmp));
          case AeParamType of
            varchar:
              begin
                Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftString, pdInput, AiLen, VarToStr(pValue));
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            varchar2:
              begin
                Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftString, pdInput, AiLen, VarToStr(pValue));
                // Aparam.Value := VarToStr(pValue);
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            date:
              begin

                Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftDate, pdInput, AiLen, CommonUtil.strToDate(VarToStr(pValue)));
                // Aparam := pParams.CreateParameter(TFieldType.ftDate, psFieldName, ptInput);
                // Aparam.Value := CommonUtil.strToDate(VarToStr(pValue));
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            int:
              begin
                // Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftInteger, pdInput, pNode._length, CommonUtil.strToDate(VarToStr(pValue)));
                // Aparam := pParams.CreateParameter(TFieldType.ftInteger, psFieldName, ptInput);
                if (isNotEmpty(pValue)) then
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftInteger, pdInput, AiLen, CommonUtil.StrToInteger(VarToStr(pValue)));
                  // Aparam.Value := CommonUtil.StrToInteger(VarToStr(pValue));
                  _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
                end
                else
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftInteger, pdInput, AiLen, null);
                  // Aparam.Value := null;
                end;

              end;
            lwdecimal:
              begin

                // Aparam := pParams.CreateParameter(TFieldType.ftFloat, psFieldName, ptInput);
                if (isNotEmpty(pValue)) then
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftFloat, pdInput, AiLen, CommonUtil.StrToflt(VarToStr(pValue)));
                  // Aparam.Value := CommonUtil.StrToflt(VarToStr(pValue));
                  _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
                end
                else
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftFloat, pdInput, AiLen, null);
                  // Aparam.Value := null;
                end;
              end;
            number:
              begin

                // Aparam := pParams.CreateParameter(TFieldType.ftFloat, psFieldName, ptInput);
                if (isNotEmpty(pValue)) then
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftFloat, pdInput, AiLen, CommonUtil.StrToflt(VarToStr(pValue)));
                  // Aparam.Value := CommonUtil.StrToflt(VarToStr(pValue));
                  _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
                end
                else
                begin
                  Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftFloat, pdInput, AiLen, null);
                  // Aparam.Value := null;
                end;
              end;
            md5:
              begin
                Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftString, pdInput, AiLen, CommonUtil.encodeStrNj(VarToStr(pValue)));
                // Aparam := pParams.CreateParameter(TFieldType.ftString, psFieldName, ptInput);
                // Aparam.Value := CommonUtil.encodeStrNj(VarToStr(pValue));
              end;
            imgblob:
              begin
                Aparam := pParams.AddParameter;
                Aparam.Name := psFieldName;
                Aparam.DataType := TFieldType.ftBlob;
                Aparam.Direction := pdInput;
                if (isNotEmpty(pValue)) then
                begin
                  AsTmp1 := VarToStr(pValue);
                  ms := TMemoryStream.Create;
                  idhttp1 := TIdHTTP.Create(nil);
                  idhttp1.ProtocolVersion := pv1_1;
                  idhttp1.ReadTimeout := 30000;
                  idhttp1.HandleRedirects := True;
                  idhttp1.get(AsTmp1, ms);
                  ms.Position := 0;
                  Aparam.Size := ms.Size;
                  Aparam.LoadFromStream(ms, ftBlob);
                end
                else
                begin
                  Aparam := pParams.AddParameter;
                  Aparam.Name := psFieldName;
                  Aparam.DataType := TFieldType.ftBlob;
                  Aparam.Value := 'empty_blob()';
                end;

              end;
            sblob:
              begin
                Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftBlob, pdInput, AiLen, VarToStr(pValue));
                // Aparam := pParams.CreateParameter(TFieldType.ftBlob, psFieldName, ptInput);
                // AsTmp1 := VarToStr(pValue);
                // Aparam.Value := AsTmp1;
              end;
            cursor:
              begin

                // Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftCursor, pdOutput, AiLen, '');
                // Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftCursor, ptOutput, pNode._length, VarToStr(pValue));
                // pParams.CreateParameter(TFieldType.ftCursor, psFieldName, ptOutput);
              end
          else
            begin
              Aparam := pParams.CreateParameter(psFieldName, TFieldType.ftString, pdInput, AiLen, VarToStr(pValue));
              // Aparam := pParams.CreateParameter(TFieldType.ftString, psFieldName, ptInput);
              // Aparam.Value := VarToStr(pValue);
            end;
          end
          // end;

        end
      end
    except
      on e: Exception do
      begin
        _log(psFieldName + ':' + e.Message);
        Exception.ThrowOuterException(Exception.Create(psFieldName + ':' + e.Message));
      end;

    end;
  finally
    if (idhttp1 <> nil) then
    begin
      idhttp1.Free;
    end;
    if (ms <> nil) then
    begin
      ms.Free;
    end;
  end;

end;
/// ////
/// 准备字段参数
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23

function TPackDB._prepareParams_old(pNode: _THXML_Param; pValue: Variant; psFieldName: string; pParams: TParameters): string;
var
  AsTmp, AsTmp1: string;
  MyEnum: TDbTypes;
  AvTmp: string;
  Aparam: TParameter;
  idhttp1: TIdHTTP;
  ms: TMemoryStream;
begin
  try
    try
      if (pNode <> nil) then
      begin
        AvTmp := pNode._iskey;
        if (not CommonUtil.isNotEmpty(AvTmp)) then
        begin
          // if (CommonUtil.VarNotNull(pValue)) then
          // begin
          AsTmp := pNode._type;
          MyEnum := TDbTypes(GetEnumvalue(TypeInfo(TDbTypes), AsTmp));
          Aparam := pParams.AddParameter();

          Aparam.Name := psFieldName;

          case MyEnum of
            varchar:
              begin
                // pParams.CreateParam(TFieldType.ftString,)
                Aparam.DataType := TFieldType.ftString;
                Aparam.Direction := pdInput;
                Aparam.Value := VarToStr(pValue);
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            varchar2:
              begin
                Aparam.DataType := TFieldType.ftString;
                Aparam.Direction := pdInput;
                Aparam.Value := VarToStr(pValue);
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            date:
              begin
                Aparam.DataType := TFieldType.ftDate;
                Aparam.Direction := pdInput;
                Aparam.Value := CommonUtil.strToDate(VarToStr(pValue));
                _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
              end;
            int:
              begin
                Aparam.DataType := TFieldType.ftInteger;
                Aparam.Direction := pdInput;
                if (isNotEmpty(pValue)) then
                begin
                  Aparam.Value := CommonUtil.StrToInteger(VarToStr(pValue));
                  _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
                end
                else
                begin
                  Aparam.Value := null;
                end;

              end;
            lwdecimal, number:
              begin
                Aparam.DataType := TFieldType.ftFloat;
                Aparam.Direction := pdInput;
                if (isNotEmpty(pValue)) then
                begin
                  Aparam.Value := CommonUtil.StrToflt(VarToStr(pValue));
                  _log(psFieldName + ':' + VarToStr(pValue), COMINFOR.FDEVMODE);
                end
                else
                begin
                  Aparam.Value := null;
                end;
              end;
            md5:
              begin
                Aparam.DataType := TFieldType.ftString;
                Aparam.Direction := pdInput;
                Aparam.Value := CommonUtil.encodeStrNj(VarToStr(pValue));

              end;
            imgblob:
              begin
                Aparam.DataType := TFieldType.ftBlob;
                Aparam.Direction := pdInput;
                if (isNotEmpty(pValue)) then
                begin
                  AsTmp1 := VarToStr(pValue);
                  ms := TMemoryStream.Create;
                  idhttp1 := TIdHTTP.Create(nil);
                  idhttp1.ProtocolVersion := pv1_0;
                  idhttp1.ReadTimeout := 30000;
                  idhttp1.HandleRedirects := True;
                  idhttp1.get(AsTmp1, ms);
                  Aparam.LoadFromStream(ms, ftBlob);
                end
                else
                begin
                  Aparam.Value := null;
                end;

              end;
            sblob:
              begin
                Aparam.DataType := TFieldType.ftBlob;
                Aparam.Direction := pdInput;
                AsTmp1 := VarToStr(pValue);
                Aparam.Value := AsTmp1;
              end;
            cursor:
              begin
                Aparam.DataType := TFieldType.ftCursor;
                Aparam.Direction := pdOutput;
                // Aparam.Value := AsTmp1;
              end
          else
            begin
              Aparam.Value := pValue;
            end;

          end
          // end;

        end
      end
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if (idhttp1 <> nil) then
    begin
      idhttp1.Free;
    end;
    if (ms <> nil) then
    begin
      ms.Free;
    end;
  end;

end;

/// ////
/// 组装where条件
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23
function TPackDB._where(jsonStr: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>; pEle: _THXML_Select): string;
var
  AjsFilter: TSuperArray;
  AsHasWhere: string;
  AjsonFilter: ISuperObject;
begin

  try
    try
      Result := '';
      // 获取条件的数组
      AjsonFilter := jsonStr[Contants.FILTER];

      if (AjsonFilter <> nil) then
      begin
        if (pEle <> nil) then
        begin
          AsHasWhere := pEle._iswhere;
        end;

        if (AjsonFilter <> nil) then
        begin
          AjsFilter := AjsonFilter.AsArray;
          Result := _getWhere(AjsFilter, fieldsList, AsHasWhere);
        end;
      end
      else
      begin
        Result := '';
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if (AjsonFilter <> nil) then
    begin
      AjsonFilter := nil;
      // FreeAndNil(AjsonFilter);
    end;
    if (AjsFilter <> nil) then
    begin
      AjsFilter := nil;
      // FreeAndNil(AjsFilter);
    end;
  end;

end;
/// ////
/// 拼接where条件：
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23

function TPackDB._getWhere(pjsFilter: TSuperArray; fieldsList: TDictionary<string, _THXML_Field>; pIsWhere: string): string;
var
  AsbWhere: TStringBuilder;
  AjsObj, AjsTmp, AjsTmp1: ISuperObject;
  AjsAryFlter: TSuperArray;
  AiIdx, AiCnt: integer;
  AsLogic, AsWhere: string;
begin
  try
    try
      AsbWhere := TStringBuilder.Create;
      AiCnt := pjsFilter.Length - 1;
      for AiIdx := 0 to AiCnt do
      begin
        AjsObj := pjsFilter[AiIdx];
        if AjsObj <> nil then
        begin
          AjsTmp := AjsObj[Contants.FILTERS];
          if AjsTmp = nil then
          begin
            AsWhere := _getWhereFieldOPString(AjsObj, fieldsList);
            if (CommonUtil.isNotEmpty(AsWhere)) then
            begin
              if ((CommonUtil.isNotEmpty(AsbWhere.ToString())) or (CommonUtil.isNotEmpty(pIsWhere))) then
              begin
                AjsTmp1 := AjsObj[Contants.LOGIC];
                if AjsTmp1 <> nil then
                begin
                  AsLogic := Contants.OPTS[AjsTmp1.AsInteger];
                end
                else
                begin
                  AsLogic := Contants._AND;
                end;

                AsbWhere.Append(Contants.KONGGE + AsLogic + Contants.KONGGE);
              end;
              AsbWhere.Append(AsWhere);
            end;
            Result := AsbWhere.ToString();
          end
          else
          begin
            AjsAryFlter := AjsTmp.AsArray;
            AsWhere := _getWhere(AjsAryFlter, fieldsList, pIsWhere);
            if (leftstr(AsWhere, 6) = '  and ') then
            begin
              AsWhere := RightStr(AsWhere, AsWhere.Length - 5);
            end
            else if (leftstr(AsWhere, 4) = ' or ') then
            begin
              AsWhere := RightStr(AsWhere, AsWhere.Length - 3);
            end;
            if (CommonUtil.isNotEmpty(AsWhere)) then
            begin
              if (CommonUtil.isNotEmpty(AsbWhere.ToString())) then
              begin
                AjsTmp1 := AjsObj[Contants.LOGIC];
                if AjsTmp1 <> nil then
                begin
                  AsLogic := Contants.OPTS[AjsObj[Contants.LOGIC].AsInteger];
                end
                else
                begin
                  AsLogic := Contants._AND;
                end;
                AsbWhere.Append(AsLogic + Contants.KONGGE + Contants.LEFTKH + AsWhere + Contants.RIGHTKH);
              end
              else
              begin
                AsbWhere.Append(Contants.KONGGE + Contants.LEFTKH + AsWhere + Contants.RIGHTKH);
              end;
            end;
            Result := AsbWhere.ToString();
          end;
        end;
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AsbWhere <> nil then
    begin
      freeAndNil(AsbWhere);
    end;
    if AjsAryFlter <> nil then
    begin
      AjsAryFlter := nil;
    end;

  end;

  // return AsbWhere.toString();
end;

/// ////
/// 根据运算符类型拼接条件
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23
function TPackDB._getWhereFieldOPString(pJson: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>): string;
var
  AsbWhere: TStringBuilder;
  AjsTmp: ISuperObject;
  AsTmp: string;
  AiIdx, AiCnt: integer;
  AndTmp: _THXML_Field;
  AvarTmp: string;
begin
  try
    try
      AsbWhere := TStringBuilder.Create;
      // 条件的字段类型有待丰富 ：判断条件字段的数据类型
      AjsTmp := pJson[Contants.operator];
      if AjsTmp <> nil then
      begin
        AsTmp := AjsTmp.AsString;
        if (AsTmp = Contants.SQL_EQ) or (AsTmp = Contants.SQL_CEQ) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_EQ));
        end
        else if (AsTmp = SQL_NEQ) or (AsTmp = Contants.SQL_CNEQ) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_NEQ));
        end
        else if (AsTmp = SQL_GT) or (AsTmp = SQL_CGT) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_GT));
        end
        else if (AsTmp = SQL_GTE) or (AsTmp = SQL_CGTE) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_GTE));
        end
        else if (AsTmp = SQL_LT) or (AsTmp = SQL_CLT) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_LT));
        end
        else if (AsTmp = SQL_LTE) or (AsTmp = SQL_CLTE) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_LTE));
        end
        else if (AsTmp = SQL_IN) then
        begin
          AsTmp := pJson[Contants.Value].AsString;
          if (CommonUtil.isNotEmpty(AsTmp)) then
          begin

            // AiCnt := fieldsList.Count - 1;
            AvarTmp := UpperCase(pJson[Contants.XMLFIELD].AsString);
            if fieldsList.ContainsKey(AvarTmp) then
            begin
              AndTmp := fieldsList[AvarTmp];
              AsbWhere.Append(AndTmp._fieldname);
              AsbWhere.Append(Contants.KONGGE + 'in' + Contants.KONGGE);
              AsbWhere.Append(Contants.LEFTKH + '''' + AsTmp + '''' + Contants.RIGHTKH);
            end;
          end;
        end
        else if (AsTmp = SQL_NOTIN) then
        begin
          AsTmp := pJson[Contants.Value].AsString;
          if (CommonUtil.isNotEmpty(AsTmp)) then
          begin

            // AiCnt := fieldsList.Count - 1;
            AvarTmp := UpperCase(pJson[Contants.XMLFIELD].AsString);
            if fieldsList.ContainsKey(AvarTmp) then
            begin
              AndTmp := fieldsList[AvarTmp];
              AsbWhere.Append(AndTmp._fieldname);
              AsbWhere.Append(Contants.KONGGE + ' not in' + Contants.KONGGE);
              AsbWhere.Append(Contants.LEFTKH + '''' + AsTmp + '''' + Contants.RIGHTKH);
            end;
          end;
        end
        else if (AsTmp = SQL_CONTANTS) then
        begin
          AsTmp := pJson[Contants.Value].AsString;
          if (CommonUtil.isNotEmpty(AsTmp)) then
          begin
            AvarTmp := UpperCase(pJson[Contants.XMLFIELD].AsString);
            if fieldsList.ContainsKey(AvarTmp) then
            begin
              AndTmp := fieldsList[AvarTmp];
              AsbWhere.Append(AndTmp._fieldname);
              AsbWhere.Append(Contants.KONGGE + Contants.LIKE + Contants.KONGGE);
              AsbWhere.Append(Contants.DIAN + Contants.PERCENT + AsTmp + Contants.PERCENT + Contants.DIAN);
            end;
          end;
        end
        else if (AsTmp = SQL_ISNULL) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_ISNULL));
        end
        else if (AsTmp = SQL_ISNOTNULL) then
        begin
          AsbWhere.Append(_getWhereFieldTypeString(pJson, fieldsList, Contants.SQL_ISNOTNULL));
        end
      end;
      Result := AsbWhere.ToString();
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AsbWhere <> nil then
    begin
      freeAndNil(AsbWhere);
    end;
  end;
end;

function TPackDB._getWhereFieldTypeString(pobj: ISuperObject; fieldsList: TDictionary<string, _THXML_Field>; op: string): string;
var
  AsbWhere: TStringBuilder;
  AjsValue, AjsField: ISuperObject;
  AsValue, AsTmp, AsTmp1, AsFieldType: string;
  AiIdx, AiCnt: integer;
  AndField: _THXML_Field;
  MyEnum: TDbTypes;
begin

  try
    try
      AsbWhere := TStringBuilder.Create;
      AjsValue := pobj[Contants.Value];
      if AjsValue <> nil then
      begin
        AsValue := AjsValue.AsString;
        // AiCnt := fieldsList.Count - 1;
        for AndField in fieldsList.Values do
        begin

          AsTmp := UpperCase('d_' + AndField._fieldname);
          AsTmp1 := UpperCase(pobj[Contants.XMLFIELD].AsString);
          if (AsTmp = AsTmp1) then
          begin
            // 数据库字段
            AsbWhere.Append((AndField._fieldname));

            // 数值
            if (op = Contants.SQL_ISNULL) then
            begin
              AsbWhere.Append(Contants.KONGGE + Contants.IS_NULL + Contants.KONGGE);
            end
            else if (op = Contants.SQL_ISNOTNULL) then
            begin
              AsbWhere.Append(Contants.KONGGE + Contants.IS_NOT_NULL + Contants.KONGGE);
            end
            else
            begin
              AsbWhere.Append(Contants.KONGGE + op + Contants.KONGGE);

              AsFieldType := AndField._type;
              MyEnum := TDbTypes(GetEnumvalue(TypeInfo(TDbTypes), AsFieldType));

              case MyEnum of
                varchar, varchar2:
                  begin
                    AsbWhere.Append(Contants.DIAN + AsValue + Contants.DIAN);
                  end;
                date:
                  begin
                    AsbWhere.Append(CommonUtil.strToDate(AsValue));
                  end;
                int:
                  begin
                    AsbWhere.Append(CommonUtil.StrToInteger(AsValue));
                  end;
                number:
                  begin
                    AsbWhere.Append(CommonUtil.StrToInteger(AsValue));
                  end;
                // md5:
                // begin
                // Aparam.Value := CommonUtil.encodeStr(VarToStr(pValue));
                //
                // end;
                // blob:
                // if(''.equals(pValue))begin
                // objects.add('');
                // endelsebegin
                // objects.add(readFileToByte((String) pValue));
                // end;
                // break;
              else
                begin
                  AsbWhere.Append(Contants.DIAN + AsValue + Contants.DIAN);

                end;
              end;
              //
            end;
          end;
        end;
      end;
      Result := AsbWhere.ToString();
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if (AsbWhere <> nil) then
    begin
      freeAndNil(AsbWhere);
    end;
  end;

end;

/// ////
/// 获取排序语句
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23
function TPackDB._getOrderby(pJson: ISuperObject; node: _THXML_Select; pFields: TDictionary<string, _THXML_Field>): string;
var
  AsOrderBy, AsAsc: string;
  AndOrderBy: _THXML_Field;
  AjsOrderBy, AjsSortType: ISuperObject;
begin
  try
    try
      AsOrderBy := '';
      AjsOrderBy := pJson[Contants.SORTFIELD];
      if (AjsOrderBy <> nil) then
      begin
        AjsSortType := pJson[Contants.SORTTYPE];
        if AjsSortType <> nil then
        begin
          AsOrderBy := AjsOrderBy.AsString;
        end
        else
        begin
          AsOrderBy := AjsOrderBy.AsString;
          AndOrderBy := _XML_Poll._loadFieldByList(pFields, AsOrderBy.ToUpper);
          if (AndOrderBy <> nil) then
          begin
            AsOrderBy := AndOrderBy._fieldname;
          end
          else
          begin
            AsOrderBy := copy(AsOrderBy, 3, Length(AsOrderBy) - 2);
          end;

          if (CommonUtil.isNotEmpty(AsOrderBy)) then
          begin
            AsAsc := pJson[Contants.SORTORDER].AsString;
            if (CommonUtil.isNotEmpty(AsAsc)) then
            begin
              AsOrderBy := AsOrderBy + Contants.KONGGE + AsAsc;
            end
            else
            begin
              AsOrderBy := AsOrderBy + Contants.KONGGE + Contants.ORDERASC;
            end
          end
          else
          begin
            raise Exception.Create('排序字段为空！！');
          end;
        end;
      end
      else
      begin
        AsOrderBy := node._orderby;
      end;

      Result := AsOrderBy;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    // if (AndOrderBy <> nil) then
    // begin
    // FreeAndNil(AndOrderBy);
    // end;
  end;
end;

/// ////
/// 组装分页信息
/// @author zephyr
/// @return void
/// @throws Exception
/// @date 2016-5-23
function TPackDB.pageSql(select: string; pagenum: integer; pagesize: integer): string;
var
  AiIdx: integer;
begin
  try
    AiIdx := 0;
    if (pagenum > 0) then
    begin
      AiIdx := pagenum * pagesize;
    end;
    if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 0 then
    begin
      Result := MysqlPageSql(AiIdx, pagenum, pagesize, select);
    end
    else if COMINFOR.FCONFIGINFOR.DBSVR_TYPE = 1 then
    begin
      Result := OraclePageSql(AiIdx, pagenum, pagesize, select);
    end;

  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;
  end;
end;

function TPackDB.MysqlPageSql(AiIdx, pagenum, pagesize: integer; select: string): string;
begin
  if (pagenum = 0) and (pagesize = 0) then
  begin
    Result := Contants.select + Contants.KONGGE + Contants.T + Contants.TDIAN + Contants.XING + Contants.KONGGE + Contants.FROM + Contants.LEFTKH + Contants.select + Contants.KONGGE + select + Contants.RIGHTKH + Contants.T;
  end
  else
  begin
    // select t.* from(select ---- )t
    Result := Contants.select + Contants.KONGGE + Contants.T + Contants.TDIAN + Contants.XING + Contants.KONGGE + Contants.FROM + Contants.LEFTKH + Contants.select + Contants.KONGGE + select + Contants.KONGGE + Contants.RIGHTKH + Contants.T + Contants.KONGGE + Contants.LIMIT + Contants.KONGGE + inttostr(AiIdx) + Contants.DOU + inttostr(pagesize);
  end;
end;

function TPackDB.OraclePageSql(AiIdx, pagenum, pagesize: integer; select: string): string;
begin
  if (pagenum = 0) and (pagesize = 0) then
  begin
    Result := Contants.select + Contants.KONGGE + Contants.T + Contants.TDIAN + Contants.XING + Contants.KONGGE + Contants.FROM + Contants.LEFTKH + Contants.select + Contants.KONGGE + select + Contants.RIGHTKH + Contants.T;
  end
  else
  begin
    // select t.* from(select ---- )t
    Result := Contants.select + Contants.KONGGE + Contants.XING + Contants.KONGGE + Contants.FROM + Contants.LEFTKH + Contants.select + Contants.KONGGE + ' A1.*,rownum rn from (select ' + select + ')A1 where rownum <=' + inttostr((pagenum + 1) * pagesize) + ' ) where rn>' + inttostr(AiIdx);
  end;
end;

/// <summary>
/// do_seltables
/// </summary>
/// <param name="pobj"></param>
/// <param name="pSession"></param>
/// <returns></returns>

function TPackDB.seltables(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: TDictionary<string, _THXML_Table>;
  AjsnPost, AjsTmp, AjsAryRes: ISuperObject;
  AvTmp: Variant;
  AndTmp: string;
begin
  try
    if isNotEmpty(pobj) then
    begin
      AnodList := _XML_Poll._FTables;

      AjsAryRes := TSuperObject.Create(stObject);
      AjsAryRes[Contants.ROWS] := SA([]);
      if (AnodList <> nil) then
      begin
        for AndTmp in AnodList.Keys do
        begin
          AjsTmp := TSuperObject.Create(stObject);
          // AndTmp := AnodList.Get(AiIdx);
          // AvTmp := AndTmp
          if (CommonUtil.isNotEmpty(AndTmp)) then
          begin
            AjsTmp.S[Contants.Value] := AnodList[AndTmp].FTableName;
            AjsTmp.S[Contants.KEY] := AndTmp;
          end
          else
          begin
            Continue;
          end;
          AjsAryRes.A[Contants.ROWS].Add(AjsTmp);
        end;
        Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsAryRes, Errors.SUCC);
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
      end;
    end
    else
    begin
      Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
    end;
  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;

  end;
end;
/// <summary>
/// do_selindexs
/// </summary>
/// <param name="pobj"></param>
/// <param name="pSession"></param>
/// <returns></returns>

function TPackDB.selIndexs(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: TDictionary<string, _THXML_Select>;
  AjsnPost, AjsTmp, AjsAryRes: ISuperObject;
  AvTmp: Variant;
  AndTmp: string;
begin
  try
    try
      AjsnPost := SO(pobj)[Contants.O];
      AsTabAliasName := AjsnPost[Contants.ALIAS].AsString;
      // AsSelName := AjsnPost[Contants.SELINDEX].AsString;

      if isNotEmpty(AsTabAliasName) then
      begin
        AnodList := _XML_Poll._loadSelects(AsTabAliasName);

        AjsAryRes := TSuperObject.Create(stObject);
        AjsAryRes[Contants.ROWS] := SA([]);
        if (AnodList <> nil) then
        begin
          for AndTmp in AnodList.Keys do
          begin
            AjsTmp := TSuperObject.Create(stObject);
            // AndTmp := AnodList.Get(AiIdx);
            // AvTmp := AndTmp
            if (CommonUtil.isNotEmpty(AndTmp)) then
            begin
              AjsTmp.S[Contants.Value] := AndTmp;
            end
            else
            begin
              Continue;
            end;
            AjsAryRes.A[Contants.ROWS].Add(AjsTmp);
          end;
          Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsAryRes, Errors.SUCC);
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
    // if AnodList <> nil then
    // begin
    // FreeAndNil(AnodList);
    // end;
  end;
end;
/// <summary>
/// do_selfields
/// </summary>
/// <param name="pobj"></param>
/// <param name="pSession"></param>
/// <returns></returns>

function TPackDB.selFields(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsSelName, AsTmp: string;
  AnodList: IXMLNodeList;
  AjsnPost, AjsTmp, AjsAryRes: ISuperObject;
  AiIdx, AiCnt, AiDbIdx: integer;
  AvTmp: string;
  AndTmp, AndSelect: _THXML_Select;
  AqryTmp: TADOQuery;
begin
  try
    try
      AjsnPost := SO(pobj)[Contants.O];
      AsTabAliasName := AjsnPost[Contants.ALIAS].AsString;
      AsSelName := AjsnPost[Contants.SELINDEX].AsString;

      if isNotEmpty(AsTabAliasName) and isNotEmpty(AsSelName) then
      begin
        AndSelect := _XML_Poll._loadSelect(AsTabAliasName, AsSelName);
        if (AndSelect <> nil) then
        begin
          AvTmp := AndSelect._sqltext;
          if (CommonUtil.isNotEmpty(AvTmp)) then
          begin
            try
              AsTmp := (AvTmp);

              CoInitialize(nil);
              AqryTmp := _RTC_DBPOLL.GetDBQuery;
              with AqryTmp do
              begin
                close;
                Parameters.Clear;
                SQL.Clear;
                SQL.Append(Contants.select + Contants.KONGGE + AsTmp + Contants.WHERE + Contants.KONGGE + ' 1<>1;');
                Open;
                AiCnt := Fields.Count - 1;
                AjsAryRes := TSuperObject.Create(stObject);
                AjsAryRes[Contants.ROWS] := SA([]);
                for AiIdx := 0 to AiCnt do
                begin
                  AjsTmp := TSuperObject.Create(stObject);
                  AjsTmp.S[Contants.Value] := Contants.PRE_D + LowerCase(Fields[AiIdx].FieldName);
                  AjsAryRes.A[Contants.ROWS].Add(AjsTmp);
                end;

              end;
              Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsAryRes, Errors.SUCC);
            finally
              // dbPoolClass.FreeQuery(AiDbIdx);
              _RTC_DBPOLL.PutDBConn(AqryTmp);
              couninitialize;

            end;
          end
          else
          begin
            Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
          end;
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
    // if AndSelect <> nil then
    // begin
    // FreeAndNil(AndSelect);
    // end;
  end;
end;
/// <summary>
/// do_tabFields
/// </summary>
/// <param name="pobj"></param>
/// <param name="pSession"></param>
/// <returns></returns>

function TPackDB.tabFields(pobj: AnsiString): ISuperObject;
var
  AsTabName, AsTabAliasName, AsTmp: string;
  AnodList: IXMLNodeList;
  AjsnPost, AjsTmp, AjsAryRes: ISuperObject;
  AiIdx, AiCnt, AiDbIdx: integer;
  AvTmp: string;
  AndSelect: TDictionary<string, _THXML_Field>;
begin
  try
    try
      AjsnPost := SO(pobj)[Contants.O];
      AsTabAliasName := AjsnPost[Contants.ALIAS].AsString;

      if isNotEmpty(AsTabAliasName) then
      begin
        AndSelect := _XML_Poll._loadFields(AsTabAliasName);
        if (AndSelect <> nil) then
        begin
          AjsAryRes := TSuperObject.Create(stObject);
          AjsAryRes[Contants.ROWS] := SA([]);
          for AvTmp in AndSelect.Keys do
          begin
            AjsTmp := TSuperObject.Create(stObject);
            AjsTmp.S[Contants.Value] := LowerCase(AvTmp);
            AjsAryRes.A[Contants.ROWS].Add(AjsTmp);
          end;
          Result := ResUtils.JsonForSelect(Contants.SUCCFLAG, AjsAryRes, Errors.SUCC);
        end
        else
        begin
          Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
        end;
      end
      else
      begin
        Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.POSTINFORERROR);
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;
  finally
    if AjsnPost <> nil then
    begin
      AjsnPost := nil;
    end;
    // if AndSelect <> nil then
    // begin
    // AndSelect := nil;
    // end;
  end;
end;

/// <summary>
/// Dataset转JSON
/// </summary>
/// <param name="pQuery"></param>
/// <returns></returns>
function TPackDB.dataSetToJson(pQuery: TADOQuery; pFlag, ptbName: string): ISuperObject;
var
  // AlsFieldNames: TStringList;
  AiIdx, AiCnt: integer;
  AjsRes, AjsTmp: ISuperObject;
  AsTmp: string;
begin
  try
    try
      // pQuery.cursor := pQuery.ParamByName('').AsCursor;

      with pQuery do
      begin
        AiCnt := Fields.Count - 1;

        AjsRes := TSuperObject.Create(stObject);
        AjsRes[pFlag] := SA([]);
        while (not Eof) do
        begin
          AjsTmp := TSuperObject.Create(stObject);
          for AiIdx := 0 to AiCnt do
          begin
            _readFieldData(ptbName, AjsTmp, Fields[AiIdx]);
          end;
          AjsRes.A[pFlag].Add(AjsTmp);
          Next;
        end;
      end;
      Result := AjsRes;
    finally
      // FreeAndNil(AlsFieldNames);
    end;
  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;

  end;

end;

/// <summary>
/// DataRow转JSON
/// </summary>
/// <param name="pQuery"></param>
/// <returns></returns>

function TPackDB.dataRowToJson(pQuery: TADOQuery; pFlag, ptbName: string): ISuperObject;
var
  AlsFieldNames: TStringList;
  AiIdx, AiCnt, AiSize: integer;
  AjsRes, AjsTmp: ISuperObject;
  AsTmp, AsTmp1: string;
begin
  try
    try
      with pQuery do
      begin
        AjsRes := TSuperObject.Create(stObject);
        AjsRes[pFlag] := TSuperObject.Create(stObject);
        AlsFieldNames := TStringList.Create;
        GetFieldNames(AlsFieldNames);
        AiCnt := AlsFieldNames.Count - 1;
        if (not Eof) then
        begin
          AjsTmp := TSuperObject.Create(stObject);
          for AiIdx := 0 to AiCnt do
          begin
            _readFieldData(ptbName, AjsTmp, Fields[AiIdx]);
          end;
          AjsRes[pFlag] := AjsTmp;
        end;
      end;
      Result := AjsRes;
    finally
      if AlsFieldNames <> nil then
      begin
        freeAndNil(AlsFieldNames);
      end;

    end;
  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;

  end;

end;
/// <summary>
/// Dataset转JSON
/// </summary>
/// <param name="pQuery"></param>
/// <returns></returns>

function TPackDB.dataSetToJsonWithColNames(pQuery: TADOQuery; pFlag: string): ISuperObject;
var
  // AlsFieldNames: TStringList;
  AiIdx, AiCnt: integer;
  AjsRes, AjsTmp: ISuperObject;
  AsTmp: string;
  AsbTmp: TStringBuilder;
begin
  AsbTmp := TStringBuilder.Create;
  try
    try
      with pQuery do
      begin
        AjsRes := TSuperObject.Create(stObject);

        AiCnt := Fields.Count - 1;
        for AiIdx := 0 to AiCnt do
        begin
          AsbTmp.Append(Fields[AiIdx].FieldName + Contants.DOU);
        end;
        AsTmp := AsbTmp.ToString;
        AsTmp := AsTmp.Substring(0, AsTmp.Length - 1);
        AjsRes.S[Contants.COLS] := AsTmp;

        AjsRes[pFlag] := SA([]);
        while (not Eof) do
        begin
          AjsTmp := TSuperObject.Create(stObject);
          for AiIdx := 0 to AiCnt do
          begin
            AsTmp := Fields[AiIdx].FieldName;
            AjsTmp.S[LowerCase(AsTmp)] := FieldByName(AsTmp).AsString;
          end;
          AjsRes.A[pFlag].Add(AjsTmp);
          Next;
        end;
      end;
      Result := AjsRes;
    finally
      // FreeAndNil(AlsFieldNames);
      if AsbTmp <> nil then
      begin
        freeAndNil(AsbTmp);
      end;
    end;
  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;

  end;

end;
/// <summary>
/// Dataset转JSON
/// </summary>
/// <param name="pQuery"></param>
/// <returns></returns>

function TPackDB.ProcDataSetToJsonWithColNames(pQuery: TADOStoredProc; pFlag: string): ISuperObject;
var
  // AlsFieldNames: TStringList;
  AiIdx, AiCnt: integer;
  AjsRes, AjsTmp: ISuperObject;
  AsTmp: string;
  AsbTmp: TStringBuilder;
begin
  try
    try
      with pQuery do
      begin
        AjsRes := TSuperObject.Create(stObject);
        AsbTmp := TStringBuilder.Create;
        AiCnt := Fields.Count - 1;
        for AiIdx := 0 to AiCnt do
        begin
          AsbTmp.Append(Fields[AiIdx].FieldName + Contants.DOU);
        end;
        AsTmp := AsbTmp.ToString;
        AsTmp := AsTmp.Substring(0, AsTmp.Length - 1);
        AjsRes.S[Contants.COLS] := AsTmp;

        AjsRes[pFlag] := SA([]);
        while (not Eof) do
        begin
          AjsTmp := TSuperObject.Create(stObject);
          for AiIdx := 0 to AiCnt do
          begin
            AsTmp := Fields[AiIdx].FieldName;
            AjsTmp.S[LowerCase(AsTmp)] := FieldByName(AsTmp).AsString;
          end;
          AjsRes.A[pFlag].Add(AjsTmp);
          Next;
        end;
      end;
      Result := AjsRes;
    finally
      // FreeAndNil(AlsFieldNames);
      if AsbTmp <> nil then
      begin
        freeAndNil(AsbTmp);
      end;

    end;
  except
    on e: Exception do
    begin
      _log(e.Message);
      Exception.ThrowOuterException(Exception.Create(e.Message));
    end;
  end;
end;

/// <summary>
/// 读取字段信息
/// </summary>
/// <param name="pJsRes"></param>
/// <param name="pField"></param>
procedure TPackDB._readFieldData(ptbName: string; pJsRes: ISuperObject; pField: TField);
var
  AaryInput: TArray<Byte>;
  AiSize: integer;
  AsTmp, AsTmp1: string;
  AmsInput: TMemoryStream;
  MyEnum: TDbTypes;
begin
  try
    try
      AsTmp := pField.FieldName;

      if (pField.IsBlob) then
      begin
        MyEnum := _XML_Poll._fieldType(ptbName, UpperCase(Contants.PRE_D + AsTmp));
        if MyEnum = imgblob then
        begin
          AaryInput := pField.AsBytes;
          AiSize := Length(AaryInput);
          // AmsInput := TMemoryStream.Create;
          // AmsInput.Clear;
          // AmsInput.Write(AaryInput, AiSize);
          // AsTmp1 := EncodeBase64(AmsInput.Memory, AmsInput.Size);
          AsTmp1 := string(EncodeBase64(@AaryInput[0], AiSize));

          pJsRes.S[Contants.PRE_D + LowerCase(AsTmp)] := AsTmp1;
        end
        else
        begin
          pJsRes.S[Contants.PRE_D + LowerCase(AsTmp)] := pField.AsString;
        end;
      end
      else
      begin
        pJsRes.S[Contants.PRE_D + LowerCase(AsTmp)] := pField.AsString;
      end;
    except
      on e: Exception do
      begin
        _log(e.Message);
        Exception.ThrowOuterException(Exception.Create(e.Message));
      end;

    end;

  finally
    if (AmsInput <> nil) then
    begin
      AmsInput.Free;
    end;
  end;

end;
/// ////
/// 数据库日志
/// @author zephyr
/// @param file
/// @return 2015-3-25

procedure TPackDB._dbLog(pJson: ISuperObject; pJuser: ISuperObject; pType: string; pCon: TADOConnection);
var
  AsbSql, AsbSqlText: TStringBuilder;
  AsTabName, AsTabAliasName, AsSelName, AsTmp, AsCount: string;
  AnodList, AnodProc: _THXML_Proced;
  AjsnPost, AjsRes, AjsUser: ISuperObject;
  AiDbIdx: integer;
  AcnTmp: TADOConnection;
  AprcTmp: TADOStoredProc;
  AvIsPage: Variant;
begin
  try
    AjsnPost := TSuperObject.Create(stObject);
    AsTabAliasName := 'log';
    AsSelName := 'log_proc1';
    AjsnPost.S[Contants.ALIAS] := AsTabAliasName;
    AjsnPost.S[Contants.SELINDEX] := AsSelName;
    if pJuser = nil then
    begin
      if pJson['sid'] <> nil then
      begin
        AjsUser := fAuthentication.GetSession(pJson['sid'].AsInteger);
      end;
    end
    else
    begin
      AjsUser := fAuthentication.GetSession(pJuser.AsInteger);
    end;

    AnodProc := _XML_Poll._loadProcedure(AsTabAliasName, AsSelName);
    if (AnodProc <> nil) then
    begin

      try
        CoInitialize(nil);
        AprcTmp := _CreateProc(pCon);

        with AprcTmp do
        begin
          try
            close;
            Parameters.Clear;
            // SQL.Clear;
            AjsnPost.S['key_id'] := '';
            if (AjsUser = nil) then
            begin
              if (pJson <> nil) then
              begin
                AjsnPost.S['user_id'] := pJson['d_user_id'].AsString;
                AjsnPost.S['user_name'] := pJson['d_user_name'].AsString;
              end
              else
              begin
                AjsnPost.S['user_id'] := '-1';
                AjsnPost.S['user_name'] := pJson.AsString;
              end;
            end
            else
            begin
              AjsRes := AjsUser[Contants.Data];
              if (AjsRes <> nil) then
              begin
                AjsnPost.S['user_id'] := AjsRes['user_id'].AsString;
                AjsnPost.S['user_name'] := AjsRes['full_name'].AsString;
              end
              else
              begin
                AjsnPost.S['user_id'] := '-2';
                AjsnPost.S['user_name'] := '未登录';
              end;

            end;

            AjsnPost.S['l_type'] := pType;
            AjsnPost.S['reason'] := _gTypeNames[pType];
            if (pJson <> nil) then
            begin
              AjsRes := pJson[Contants.ALIAS];
              if (AjsRes <> nil) then
              begin
                AjsnPost.S['tablename'] := AjsRes.AsString;
              end
              else
              begin
                AjsnPost.S['tablename'] := 'null';
              end;

              AjsRes := pJson[Contants.FILTER];
              if (AjsRes <> nil) then
              begin
                AjsnPost.S['tablekey'] := AjsRes.AsString;
              end
              else
              begin
                AjsnPost.S['tablekey'] := 'null';
              end;

              AjsRes := pJson[Contants.Fields];
              if (AjsRes <> nil) then
              begin
                AjsnPost.S['l_content'] := AjsRes.AsString;
              end
              else
              begin
                AjsnPost.S['l_content'] := 'null';
              end;
            end
            else
            begin
              AjsnPost.S['tablename'] := '';
              AjsnPost.S['tablekey'] := '';
              AjsnPost.S['l_content'] := '';
            end;
            AprcTmp.ProcedureName := AnodProc._proc_name;
            AsTmp := _procSqlText(AsTabAliasName, AsSelName, AjsnPost, AnodProc, Parameters);
            // SQL.Append(AsTmp);
            ExecProc;
          except
            on e: Exception do
            begin
              _log(e.Message);
              Exception.ThrowOuterException(Exception.Create(e.Message));
            end;
          end;
        end;
      finally
        // dbPoolClass.FreeQuery(AiDbIdx);
        // _RTC_DBPOLL.PutDBConn(AprcTmp);
        if AjsnPost <> nil then
        begin
          AjsnPost := nil;
          // FreeAndNil(AsbTmp);
        end;
        if AprcTmp <> nil then
        begin
          AprcTmp.Free;
        end;
        couninitialize;
      end;
    end
    else
    begin
      // Result := ResUtils.JsonForResMsg(Contants.FAILFLAG, Errors.FIELDSISNULL);
    end;
  except
    on e: Exception do
    begin
      Exception.ThrowOuterException(Exception.Create(e.Message + ':' + AsTmp));
    end;
  end;
end;

initialization

CoInitialize(nil);

finalization

couninitialize;

end.
