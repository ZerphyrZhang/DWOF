unit XmlUtils1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Types, Math, Vcl.Dialogs, Registry, StrUtils, XMLDoc, XMLIntf, generics.collections;

procedure _loadXmlFile();

function _loadTable(pTbName: string): IXMLNode;

function _loadFields(pTbName: string): IXMLNodeList;

function _loadSelects(pTbName: string): IXMLNodeList;

function _loadSelect(pTbName: string; pSelName: string): IXMLNode;

function _loadField(pTbName: string; pFieldName: string): IXMLNode;

function _loadFieldByList(pFields: IXMLNodeList; pFieldName: string): IXMLNode;

function _loadProcedure(pTbName: string; pSelName: string): IXMLNode;

function _getTableName(pTbName: string): string;

implementation

uses
  Contants;

var
  _gFile: IXMLDocument;
  _gTable: TDictionary<string, IXMLNode>;

  ///
/// ����XML�ĵ�
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

procedure _initDatas();
var
  XmlRoot: IXMLNode;
  NodePos: IXMLNode;
  b: string;
  x, y: double;
  ModuleName, fpth: string;
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
  AsTmp: string;
begin
  SetLength(ModuleName, 255);
  GetModuleFileName(HInstance, PChar(ModuleName), Length(ModuleName));
  fpth := ExtractFileDir(ModuleName);

  _gFile := TXMLDocument.Create(nil);
  _gFile.LoadFromFile(fpth + '\db.xml');
  if (_gTable = nil) then
  begin
    _gTable := TDictionary<string, IXMLNode>.Create;
  end;
  // �жϼ������Ƿ������
  AnodeRoot := _gFile.DocumentElement;
  AnodeList := AnodeRoot.ChildNodes;
  AiCnt := AnodeList.Count;
  for AiIdx := 0 to AiCnt do
  begin
    AnodeTmp := AnodeList[AiIdx];
    AsTmp := UpperCase(VarToStr(AnodeTmp.Attributes[Contants.ALIAS]));
    _gTable.Add(AsTmp, AnodeTmp);
  end;
end;
///
/// ����XML�ĵ�
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

procedure _loadXmlFile();
var
  XmlRoot: IXMLNode;
  NodePos: IXMLNode;
  b: string;
  x, y: double;
  ModuleName, fpth: string;
begin
  SetLength(ModuleName, 255);
  GetModuleFileName(HInstance, PChar(ModuleName), Length(ModuleName));
  fpth := ExtractFileDir(ModuleName);

  _gFile := TXMLDocument.Create(nil);
  _gFile.LoadFromFile(fpth + '\db.xml');

end;
///
// ����XML�ĵ���Table
//
// @author zephyr
// @return void
// @throws DocumentException
// @throws Exception
// @date 2016-5-23
///

function _loadTable(pTbName: string): IXMLNode;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
  AsTmp: string;
begin
  result := nil;
  if (_gFile = nil) then
  begin
    _loadXmlFile();
  end;

  if (_gTable = nil) then
  begin
    _gTable := TDictionary<string, IXMLNode>.Create;
  end;
  pTbName := UpperCase(pTbName);
  // �жϼ������Ƿ������
  if (_gTable.containsKey(pTbName)) then
  begin
    if _gTable.TryGetValue(pTbName, AnodeTMp) then
    begin
      Result := AnodeTMp;
    end;
  end
  else
  begin
    AnodeRoot := _gFile.DocumentElement;
    AnodeList := AnodeRoot.ChildNodes;
    AiCnt := AnodeList.Count;
    for AiIdx := 0 to AiCnt do
    begin
      AnodeTmp := AnodeList[AiIdx];
      AsTmp := UpperCase(VarToStr(AnodeTmp.Attributes[Contants.ALIAS]));
      if AsTmp = pTbName then
      begin
        _gTable.Add(pTbName, AnodeTmp);
        Result := AnodeTmp;
        Break;
      end;
    end;
  end;

end;
///////
/// ���ر���fields�ֶ�
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

function _loadFields(pTbName: string): IXMLNodeList;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
begin
  _loadTable(pTbName);
  // �жϼ������Ƿ������
  AnodeTmp := _gTable[UpperCase(pTbName)];
  AnodeTmp := AnodeTmp.ChildNodes[0];
  result := AnodeTmp.ChildNodes;

end;
///////
/// ���ر�������select
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

function _loadSelects(pTbName: string): IXMLNodeList;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
begin
  _loadTable(pTbName);
		// �жϼ������Ƿ������
  AnodeTmp := _gTable[UpperCase(pTbName)];
  AnodeTmp := AnodeTmp.ChildNodes[1];
  result := AnodeTmp.ChildNodes;
end;
///////
/// ���ر���select
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

function _loadSelect(pTbName: string; pSelName: string): IXMLNode;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
begin
  _loadTable(pTbName);
  // �жϼ������Ƿ������
  AnodeTmp := _gTable[UpperCase(pTbName)];
  AnodeTmp := AnodeTmp.ChildNodes[1];
  AnodeList := AnodeTmp.ChildNodes;
  AiCnt := AnodeList.Count - 1;
  pSelName := UpperCase(pSelName);
  for AiIdx := 0 to AiCnt do
  begin
    AnodeTmp := AnodeList[AiIdx];
    if UpperCase(VarToStr(AnodeTmp.Attributes[Contants.NAME])) = pSelName then
    begin
      Result := AnodeTmp;
      Break;
    end;
  end;

end;
///////
/// ��ȡ���ݿ�
/// @param pTbName
/// @param pSelName
/// @return
/// @throws DocumentException
////

function _loadField(pTbName: string; pFieldName: string): IXMLNode;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
begin
  begin
    AnodeList := _loadFields(pTbName);
    AiCnt := AnodeList.Count - 1;
    pFieldName := UpperCase(pFieldName);
    for AiIdx := 0 to AiCnt do
    begin
      AnodeTmp := AnodeList[AiIdx];
      if UpperCase(VarToStr(AnodeTmp.Attributes[Contants.ALIAS])) = pFieldName then
      begin
        Result := AnodeTmp;
        Break;
      end;
    end;
  end;
end;
///////
/// �����ֶ������ȡ��
/// @param pFields
/// @return
/// @throws DocumentException
////

function _loadFieldByList(pFields: IXMLNodeList; pFieldName: string): IXMLNode;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AiIdx, AiCnt: Integer;
begin
  Result := nil;
  AiCnt := pFields.Count - 1;
  pFieldName := UpperCase(pFieldName);
  for AiIdx := 0 to AiCnt do
  begin
    AnodeTmp := pFields[AiIdx];
    if UpperCase(VarToStr(AnodeTmp.Attributes[Contants.ALIAS])) = pFieldName then
    begin
      Result := AnodeTmp;
      Break;
    end;
  end;
end;
///////
/// ���ر���Procedure
///
/// @author zephyr
/// @return void
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-23
////

function _loadProcedure(pTbName: string; pSelName: string): IXMLNode;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
begin
  _loadTable(pTbName);
		// �жϼ������Ƿ������
  AnodeTmp := _gTable[UpperCase(pTbName)];
  AnodeTmp := AnodeTmp.ChildNodes[2];
  AnodeList := AnodeTmp.ChildNodes;

  AiCnt := AnodeList.Count - 1;
  pSelName := UpperCase(pSelName);
  for AiIdx := 0 to AiCnt do
  begin
    AnodeTmp := AnodeList[AiIdx];
    if UpperCase(VarToStr(AnodeTmp.Attributes[Contants.NAME])) = pSelName then
    begin
      Result := AnodeTmp;
      Break;
    end;
  end;
end;
///////
/// ��ȡ������
///
/// @author zephyr
/// @return String
/// @throws DocumentException
/// @throws Exception
/// @date 2016-5-24
////

function _getTableName(pTbName: string): string;
var
  AnodeRoot, AnodeTmp: IXMLNode;
  AnodeList: IXMLNodeList;
  AiIdx, AiCnt: Integer;
begin
  _loadTable(pTbName);
		// �жϼ������Ƿ������
  AnodeTmp := _gTable[UpperCase(pTbName)];
  Result := VarToStr(AnodeTmp.Attributes[Contants.NAME]);
end;

end.


