unit XmlUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs,
  Registry, StrUtils, XMLDoc, XMLIntf, generics.collections, system.TypInfo,
  syncobjs, Vcl.Forms;

type
  TDbTypes = (varchar, varchar2, date, int, number, md5, imgblob, sblob, none, lwdecimal, cursor);

  _THXML_Param = class
  private
  public
    _iskey: string;
    _type: string;
    _length: string;
    _fieldname: string;
    _isvirtual: string;
    constructor Create(ptype, plen, pfeildname: string);
    destructor Destroy; override;
  end;

  _THXML_Field = class(_THXML_Param)
  private
  public
    _isnull: string;
    _isvirtual: string;
    constructor Create(ptype, pfieldname, plen, pkey, pnul, pvirtual: string);
    destructor Destroy; override;
  end;

  _THXML_Select = class
  private
  public
    _name: string;
    _ispage: string;
    _orderby: string;
    _iswhere: string;
    _groupby: string;
    _sqltext: string;
    constructor Create(pname, pispage, porderby, piswhere, pgroupby, psqltxt: string);
    destructor Destroy; override;
  end;

  _THXML_Proced = class
  private
  public
    _ispage: string;
    _proc_name: string;
    _proc_params: TList;
    constructor Create(pname, pispage: string; params: TList);
    destructor Destroy; override;
  end;

  _THXML_Table = class
  private
    _TabName: string;
    _Fields: TDictionary<string, _THXML_Field>;
    _Selects: TDictionary<string, _THXML_Select>;
    _Procedus: TDictionary<string, _THXML_Proced>;
  public
    constructor Create(pname: string);
    destructor Destroy; override;
    property FTableName: string read _TabName;
  end;

  THXML_Poll = class
  private
    // _gCS: TCriticalSection;
    _gFile: IXMLDocument;
    _gTable: TDictionary<string, _THXML_Table>;
  public
    constructor Create;
    destructor Destroy; override;
    function _loadTable(pTbName: string): _THXML_Table;
    function _loadFields(pTbName: string): TDictionary<string, _THXML_Field>;
    function _loadSelects(pTbName: string): TDictionary<string, _THXML_Select>;
    function _loadSelect(pTbName: string; pSelName: string): _THXML_Select;
    function _loadField(pTbName: string; pfieldname: string): _THXML_Field;
    function _loadFieldByList(pFields: TDictionary<string, _THXML_Field>; pfieldname: string): _THXML_Field;
    function _loadProcedure(pTbName: string; pSelName: string): _THXML_Proced;
    function _getTableName(pTbName: string): string;
    function _fieldType(pTbName, pfieldname: string): TDbTypes;
    property _FTables: TDictionary<string, _THXML_Table> read _gTable;
  end;

var
  _XML_Poll: THXML_Poll;

implementation

uses
  Contants, Commonutil;

constructor THXML_Poll.Create;

  function _NodeValue(pNode: IXMLNode; pname: string): string;
  begin
    result := '';
    if pNode.HasAttribute(pname) then
    begin
      result := VarToStr(pNode.Attributes[pname]);
    end;
  end;

var
  ModuleName, fpth: string;
  AnodeRoot, AnodeTmp, AnodeTmp1, AnodeTmp2, AnodeTmp0: IXMLNode;
  AnodeList, AnodeList1, AnodeList2: IXMLNodeList;
  AiIdx, AiCnt, AiTmp, AiIdx1, AiCnt1, AiIdx2, AiCnt2, AiIdx0, AiCnt0: Integer;
  AsTmp, AsTmp1, AsTmp2: string;
  AcsFeild: _THXML_Field;
  AcsSelect: _THXML_Select;
  AcsParam: _THXML_Param;
  AcsProced: _THXML_Proced;
  AcsTable: _THXML_Table;
  AdcParams: TList;
begin
  inherited Create;
  // _gCS := TCriticalSection.Create;

  // SetLength(ModuleName, 255);
  // GetModuleFileName(HInstance, PChar(ModuleName), Length(ModuleName));
  // fpth := ExtractFileDir(ModuleName);

  fpth := ExtractFileDir(ParamStr(0)) + '/' + COMINFOR.FCONFIGINFOR.DB_FILE;
  ;

  // try
  _gFile := TXMLDocument.Create(nil);
  if not FileExists(fpth) then
  begin
    raise Exception.Create('未发现配置文件【' + COMINFOR.FCONFIGINFOR.DB_FILE + '】，请检查文件名称输入是否正确！！');
  end;
  _gFile.LoadFromFile(fpth);
  if (_gTable = nil) then
  begin
    _gTable := TDictionary<string, _THXML_Table>.Create;
  end
  else
  begin
    _gTable.Clear;
  end;

  // 加载db.xml中数据
  AnodeRoot := _gFile.DocumentElement;
  AnodeList := AnodeRoot.ChildNodes;
  AiCnt := AnodeList.Count - 1;
  for AiIdx := 0 to AiCnt do
  begin
    AnodeTmp := AnodeList[AiIdx];
    AcsTable := _THXML_Table.Create(_NodeValue(AnodeTmp, 'name'));

    AiCnt0 := AnodeTmp.ChildNodes.Count - 1;
    for AiIdx0 := 0 to AiCnt0 do
    begin
      AnodeTmp0 := AnodeTmp.ChildNodes[AiIdx0];
      AsTmp2 := LowerCase(AnodeTmp0.NodeName);
      // fields
      if AsTmp2 = 'fields' then
      begin
        AnodeList1 := AnodeTmp0.ChildNodes;
        AiCnt1 := AnodeList1.Count - 1;
        for AiIdx1 := 0 to AiCnt1 do
        begin
          AnodeTmp1 := AnodeList1[AiIdx1];
          if LowerCase(VarToStr(AnodeTmp1.NodeName)) = 'field' then
          begin
            AcsFeild := _THXML_Field.Create(_NodeValue(AnodeTmp1, Contants.FIELDTYPE), VarToStr(AnodeTmp1.NodeValue), _NodeValue(AnodeTmp1, 'length'), _NodeValue(AnodeTmp1, Contants.IS_KEY), _NodeValue(AnodeTmp1, 'isnull'), _NodeValue(AnodeTmp1, 'isvirtual'));
            if not AcsTable._Fields.ContainsKey(UpperCase(_NodeValue(AnodeTmp1, Contants.ALIAS))) then
            begin
              AcsTable._Fields.Add(UpperCase(_NodeValue(AnodeTmp1, Contants.ALIAS)), AcsFeild);
            end;
          end;
        end;
      end
      else if AsTmp2 = 'selects' then
      begin
        // selects
        AnodeList1 := AnodeTmp0.ChildNodes;
        AiCnt1 := AnodeList1.Count - 1;
        for AiIdx1 := 0 to AiCnt1 do
        begin
          AnodeTmp1 := AnodeList1[AiIdx1];
          if LowerCase(VarToStr(AnodeTmp1.NodeName)) = 'select' then
          begin
            AcsSelect := _THXML_Select.Create(_NodeValue(AnodeTmp1, 'name'), _NodeValue(AnodeTmp1, 'ispage'), _NodeValue(AnodeTmp1, 'orderby'), _NodeValue(AnodeTmp1, 'iswhere'), _NodeValue(AnodeTmp1, 'groupby'), VarToStr(AnodeTmp1.NodeValue));

            if not AcsTable._Selects.ContainsKey(_NodeValue(AnodeTmp1, 'name')) then
            begin
              AcsTable._Selects.Add(_NodeValue(AnodeTmp1, 'name'), AcsSelect);
            end;
          end;
        end;
      end
      else if AsTmp2 = 'procedues' then
      begin
        // procedues
        AnodeList1 := AnodeTmp0.ChildNodes;
        AiCnt1 := AnodeList1.Count - 1;
        for AiIdx1 := 0 to AiCnt1 do
        begin
          AnodeTmp1 := AnodeList1[AiIdx1];
          if LowerCase(VarToStr(AnodeTmp1.NodeName)) = 'procedue' then
          begin
            AsTmp1 := VarToStr(AnodeTmp1.ChildNodes[0].NodeValue);
            AnodeList2 := AnodeTmp1.ChildNodes[1].ChildNodes;
            AiCnt2 := AnodeList2.Count - 1;
            AdcParams := TList.Create;
            for AiIdx2 := 0 to AiCnt2 do
            begin
              AnodeTmp2 := AnodeList2[AiIdx2];
              if LowerCase(VarToStr(AnodeTmp2.NodeName)) = 'param' then
              begin
                AcsParam := _THXML_Param.Create(_NodeValue(AnodeTmp2, Contants.FIELDTYPE), _NodeValue(AnodeTmp2, 'length'), VarToStr(AnodeTmp2.NodeValue));
                AdcParams.Add(AcsParam);
              end;
            end;
            AcsProced := _THXML_Proced.Create(AsTmp1, _NodeValue(AnodeTmp1.ChildNodes[0], 'ispage'), AdcParams);
            AcsTable._Procedus.Add(_NodeValue(AnodeTmp1, 'name'), AcsProced);
          end;
        end;
      end;
    end;
    AsTmp := UpperCase(_NodeValue(AnodeTmp, Contants.ALIAS));
    _gTable.Add(AsTmp, AcsTable);
  end;
  // except
  // on E: Exception do
  // begin
  /// /      Application.MessageBox(PWideChar(E.Message + '>>>' + AsTmp + ':' + AsTmp2 + ':' + AsTmp1), PWideChar('运行提示'));
  // LW_MSG_ERROR(E.Message);
  // end;
  //
  // end;

end;
/// <summary>
///
/// </summary>

destructor THXML_Poll.Destroy;
var
  tbkey, fkey, skey, pkey: string;
  AtbTmp: _THXML_Table;
  AfdTmp: _THXML_Field;
  AstTmp: _THXML_Select;
  AprTmp: _THXML_Proced;

  // _Fields: TDictionary<string, _THXML_Field>;
  // _Selects: TDictionary<string, _THXML_Select>;
  // _Procedus: TDictionary<string, _THXML_Proced>;
begin
  // _gCS.Free;
  _gFile := nil;
  // _gTable.Destroy;
  for tbkey in _gTable.Keys do
  begin
    AtbTmp := _gTable.Items[tbkey];
    for fkey in AtbTmp._Fields.Keys do
    begin
      AfdTmp := AtbTmp._Fields.Items[fkey];
      AfdTmp.Destroy;
    end;
    AtbTmp._Fields.Free;
    for skey in AtbTmp._Selects.Keys do
    begin
      AstTmp := AtbTmp._Selects.Items[skey];
      AstTmp.Destroy;
    end;
    AtbTmp._Selects.Free;
    for pkey in AtbTmp._Procedus.Keys do
    begin
      AprTmp := AtbTmp._Procedus.Items[pkey];
      AprTmp.Destroy;
    end;
    AtbTmp._Procedus.Free;
  end;
  _gTable.Free;
  // _gFields.Free;
  // _gFieldCache.Free;
  inherited;
end;

///
// 加载XML文档中Table
//
// @author zephyr
// @return void
// @throws DocumentException
// @throws Exception
// @date 2016-5-23
///

function THXML_Poll._loadTable(pTbName: string): _THXML_Table;
var
  AnodeTmp: _THXML_Table;
begin
  result := nil;
  // if (_gTable = nil) then
  // begin
  // _gTable := TDictionary<string, _THXML_Table>.Create;
  // end;
  pTbName := UpperCase(pTbName);

  // _gCS.Enter;
  try
    // 判断集合里是否包含表
    if (_gTable.ContainsKey(pTbName)) then
    begin
      if _gTable.TryGetValue(pTbName, AnodeTmp) then
      begin
        result := AnodeTmp;
      end;
    end;
  finally
    // _gCS.Leave;
  end;
end;
/// ////
/// 加载表中fields字段
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
/// /

function THXML_Poll._loadFields(pTbName: string): TDictionary<string, _THXML_Field>;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Field>;
begin
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      result := AnodeTmp._Fields;
    end
    else
    begin
      result := nil;
    end;
  end
  else
  begin
    result := nil;
  end;
end;

function THXML_Poll._fieldType(pTbName, pfieldname: string): TDbTypes;
var
  AnodeTmp: _THXML_Table;
  AsTmp: string;
  AndTmp: IXMLNode;
  MyEnum: TDbTypes;
begin
  result := none;
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      if AnodeTmp._Fields <> nil then
      begin
        if AnodeTmp._Fields.ContainsKey(pfieldname) then
        begin
          AsTmp := AnodeTmp._Fields[pfieldname]._type;
          if AsTmp <> '' then
          begin
            MyEnum := TDbTypes(GetEnumvalue(TypeInfo(TDbTypes), AsTmp));
            result := MyEnum;
          end;
        end;
      end;
    end;
  end;
end;
/// ////
/// 加载表中所有select
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
/// /

function THXML_Poll._loadSelects(pTbName: string): TDictionary<string, _THXML_Select>;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Field>;
begin
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      result := AnodeTmp._Selects;
    end
    else
    begin
      result := nil;
    end;
  end
  else
  begin
    result := nil;
  end;
end;
/// ////
/// 加载表中select
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
/// /

function THXML_Poll._loadSelect(pTbName: string; pSelName: string): _THXML_Select;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Select>;
begin
  result := nil;
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      AdcRes := AnodeTmp._Selects;
      if AdcRes <> nil then
      begin
        if AdcRes.ContainsKey(pSelName) then
        begin
          result := AdcRes[pSelName]
        end;
      end;
    end;
  end;
end;
/// ////
/// 获取数据库
/// @param pTbName
/// @param pSelName
/// @return
/// @throws DocumentException
/// /

function THXML_Poll._loadField(pTbName: string; pfieldname: string): _THXML_Field;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Field>;
begin
  result := nil;
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      AdcRes := AnodeTmp._Fields;
      if AdcRes <> nil then
      begin
        result := AdcRes[pfieldname]
      end;
    end;
  end;
end;
/// ////
/// 根据字段数组获取列
/// @param pFields
/// @return
/// @throws DocumentException
/// /

function THXML_Poll._loadFieldByList(pFields: TDictionary<string, _THXML_Field>; pfieldname: string): _THXML_Field;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Field>;
begin
  result := nil;
  if (pFields <> nil) then
  begin
    if pFields.ContainsKey(pfieldname) then
    begin
      result := pFields[pfieldname];
    end;
  end;
end;
/// ////
/// 加载表中Procedure
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
/// /

function THXML_Poll._loadProcedure(pTbName: string; pSelName: string): _THXML_Proced;
var
  AnodeTmp: _THXML_Table;
  AdcRes: TDictionary<string, _THXML_Proced>;
begin
  result := nil;
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      AdcRes := AnodeTmp._Procedus;
      if AdcRes <> nil then
      begin
        result := AdcRes[pSelName]
      end;
    end;
  end;
end;
/// ////
/// 获取表名称
///
/// @author zephyr
/// @return String
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-24
/// /

function THXML_Poll._getTableName(pTbName: string): string;
var
  AnodeTmp: _THXML_Table;
begin
  result := '';
  if (_gTable <> nil) then
  begin
    AnodeTmp := _loadTable(pTbName);
    if (AnodeTmp <> nil) then
    begin
      result := AnodeTmp._TabName;
    end;
  end;
end;

constructor _THXML_Field.Create(ptype, pfieldname, plen, pkey, pnul, pvirtual: string);
begin
  _type := ptype;
  _fieldname := pfieldname;
  _length := plen;
  _iskey := pkey;
  _isnull := pnul;
  _isvirtual := pvirtual;
end;
/// <summary>
///
/// </summary>

destructor _THXML_Field.Destroy;
begin
  _type := '';
  _fieldname := '';
  _length := '';
  _iskey := '';
  _isnull := '';
  _isvirtual := '';

end;

constructor _THXML_Select.Create(pname, pispage, porderby, piswhere, pgroupby, psqltxt: string);
begin
  _name := pname;
  _ispage := pispage;
  _orderby := porderby;
  _iswhere := piswhere;
  _groupby := pgroupby;
  _sqltext := psqltxt;
end;
/// <summary>
///
/// </summary>

destructor _THXML_Select.Destroy;
begin
  _name := '';
  _ispage := '';
  _orderby := '';
  _iswhere := '';
  _groupby := '';
  _sqltext := '';
  inherited Destroy;
end;

constructor _THXML_Param.Create(ptype, plen, pfeildname: string);
begin
  _type := ptype;
  _length := plen;
  _fieldname := pfeildname;
end;
/// <summary>
///
/// </summary>

destructor _THXML_Param.Destroy;
begin
  _type := '';
  _length := '';
  _fieldname := '';
end;

constructor _THXML_Proced.Create(pname, pispage: string; params: TList);
begin
  _ispage := pispage;
  _proc_name := pname;
  _proc_params := params;
end;
/// <summary>
///
/// </summary>

destructor _THXML_Proced.Destroy;
var
  AiIdx, AiCnt: integer;
  AoTmp: _THXML_Param;
begin
  _ispage := '';
  _proc_name := '';
  AiCnt := _proc_params.Count - 1;
  for AiIdx := 0 to AiCnt do
  begin
    AoTmp := _THXML_Param(_proc_params[AiIdx]);
    AoTmp.Destroy;
  end;
  _proc_params.Free;
end;

constructor _THXML_Table.Create(pname: string);
begin
  _TabName := pname;
  _Fields := TDictionary<string, _THXML_Field>.Create;
  _Selects := TDictionary<string, _THXML_Select>.Create;
  _Procedus := TDictionary<string, _THXML_Proced>.Create;
end;
/// <summary>
///
/// </summary>

destructor _THXML_Table.Destroy;
begin
  _Fields.Free;
  _Selects.Free;
  _Procedus.Free;
end;

end.

