unit SourceUnit;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, Vcl.Dialogs, XMLDoc, XMLIntf, superobject, ElnManager;

type

  TSourceThread = class(TThread)
  private
    // procedure Comm1ReceiveData(Sender: TObject; Buffer: Pointer; BufferLength: Word);

    FElnMgr: TElnManager;
  protected
    procedure Execute; override;
    procedure ReadTplFile();
    function ReadXlsFile(ApFileData: TP_FILEDATA; AjsData: IsuperObject): boolean;
    function ReadXmlFile(ApFileData: TP_FILEDATA; AjsData: IsuperObject): boolean;
    function _ColName(const AiColCnt: Integer): string;
    function _ColRowName(AiCol, AiRow: Integer): string;
  public
    constructor Create(AElnMgr: TElnManager);
    destructor destroy; override;
  end;

var
  G_COMSTART: boolean;
  G_XLS_FILE: Variant;
  G_XML_FILE: IXMLDocument;

implementation

uses
  System.TypInfo, DateUtils, Comobj, ElnUtils, Commonutil, Contants, Variants, activex, ExcelUnit;

constructor TSourceThread.Create(AElnMgr: TElnManager);
begin
  { Place thread code here }
  inherited Create(True);
  FElnMgr := AElnMgr;
  Priority := tpNormal;
end;

destructor TSourceThread.destroy;
begin
  inherited destroy;
  if not VarIsEmpty(G_XLS_FILE) then
  begin
    G_XLS_FILE.Quit;
  end;
  if G_XML_FILE <> nil then
  begin
    FreeAndNil(G_XML_FILE);
  end;
end;

procedure TSourceThread.Execute;
begin
  try
    coinitialize(nil);

    try
      G_XLS_FILE := CreateOleObject('excel.application');
    except
      _log('打开Excel异常，请检查是否安装Excel组件！！');
      Exit;
    end;
    try
      G_XML_FILE := TXMLDocument.Create(nil);
    except
      _log('加载XML异常，请联系系统管理员！！');
      Exit;
    end;

    while True do
    begin
      try
        ReadTplFile();
      except
        on e: exception do
        begin
          _log(e.Message);
          continue;
        end;
      end;
    end;
  finally
    couninitialize;
  end;
end;

procedure TSourceThread.ReadTplFile();
var
  ApFileData: TP_FILEDATA;
  AjsData: IsuperObject;
begin
  ApFileData := FElnMgr.GetTplFileData();
  if ApFileData <> nil then
  begin
    try
      AjsData := TSuperObject.Create(stObject); // SO('{t:1,structure:[],rows:[]}');
      AjsData[Contants.STRUCTURE] := SA([]);
      AjsData[Contants.Rows] := SA([]);

      if ReadXlsFile(ApFileData, AjsData) then
      begin
        if ReadXmlFile(ApFileData, AjsData) then
        begin
          ApFileData._FILE_DATAS := AjsData;
          FElnMgr.AddFiled(ApFileData);
        end
        else
        begin
          raise exception.Create('解析模板文件2：' + ApFileData._FILE_PATH + '发生异常。');
        end;
      end
      else
      begin
        raise exception.Create('解析模板文件1：' + ApFileData._FILE_PATH + '发生异常。');
      end;

    except
      on e: exception do
      begin
        FreeAndNil(AjsData);
        raise exception.Create('解析模板文件：' + ApFileData._FILE_PATH + '发生异常。' + e.Message);
      end;
    end;

  end;
end;

function TSourceThread.ReadXlsFile(ApFileData: TP_FILEDATA; AjsData: IsuperObject): boolean;
var
  AsFileName: string;
  FWorkbook1, FWorksheet1, FRange: Variant;
  AjsRowSru, AjaryRow: IsuperObject;
  AiRIdx, AiCIdx, AiRCnt, AiCCnt, MaxRow, MaxCol, AiMegerColCnt, AiTmp: Integer;
  AayMegerRowCnt: array of Integer;
  AcMegerArea: TExcelUtils;
  AbNotIn: boolean;
begin
  Result := false;
  try
    try
      // coinitialize(nil);
      AsFileName := ApFileData._FILE_XLSPATH;
      AcMegerArea := TExcelUtils.Create;
      if FileExists(AsFileName) then
      begin
        FWorkbook1 := G_XLS_FILE.WorkBooks.Open(AsFileName);
        // FWorkSheet := FWorkBook.WorkSheets.Add;

        FWorksheet1 := FWorkbook1.WorkSheets[1];
        FWorksheet1.Activate;

        MaxRow := FWorksheet1.UsedRange.Rows.count;
        MaxCol := FWorksheet1.UsedRange.Columns.count;
        setLength(AayMegerRowCnt, MaxCol);
        for AiRIdx := 1 to MaxRow do
        begin
          AjaryRow := SA([]);
          AiMegerColCnt := 0;
          for AiCIdx := 1 to MaxCol do
          begin
            // FCell := FWorksheet1.Cells[AiRIdx, AiCIdx];
//            vSheet.Columns[i].ColumnWidth := 8
            AjsRowSru := nil;
            FRange := FWorksheet1.Range[_ColRowName(AiCIdx, AiRIdx)];
            if FRange.HasFormula = True then
            begin
              AjaryRow.s[inttostr(AiCIdx - 1)] := Vartostr(FRange.Formula);
            end
            else
            begin
              AjaryRow.s[inttostr(AiCIdx - 1)] := Vartostr(FRange);
            end;
            AbNotIn := not AcMegerArea.InArea(AiRIdx, AiCIdx);

            AiCCnt := FRange.MergeArea.Columns.count;
            if AiCIdx > AiMegerColCnt then
            begin
              if AiCCnt > 1 then
              begin
                if AbNotIn then
                begin
                  AjsRowSru := SO('{row:' + inttostr(AiRIdx - 1) + ', col:' + inttostr(AiCIdx - 1) + ', colspan:' + inttostr(AiCCnt) + ', rowspan:1}');
                  AjsData.A[Contants.STRUCTURE].Add(AjsRowSru);
                end;
                AiMegerColCnt := AiMegerColCnt + AiCCnt;
              end
              else
              begin
                AiMegerColCnt := AiMegerColCnt + 1;
              end;
            end;

            AiRCnt := FRange.MergeArea.Rows.count;
            if AiRIdx > AayMegerRowCnt[AiCIdx] then
            begin
              if AiRCnt > 1 then
              begin
                if AbNotIn then
                begin
                  if AjsRowSru <> nil then
                  begin
                    AjsRowSru.i['rowspan'] := (AiRCnt);
                  end
                  else
                  begin
                    AjsRowSru := SO('{row:' + inttostr(AiRIdx - 1) + ', col:' + inttostr(AiCIdx - 1) + ', rowspan:' + inttostr(AiRCnt) + ', colspan:1}');
                    AjsData.A[Contants.STRUCTURE].Add(AjsRowSru);
                  end;
                  for AiTmp := 0 to AiCCnt - 1 do
                  begin
                    AayMegerRowCnt[AiCCnt + AiTmp] := AayMegerRowCnt[AiCCnt + AiTmp] + AiRCnt;
                  end;
                  if (AiRCnt > 1) and (AiCCnt > 1) then
                  begin
                    AcMegerArea.Add(AiRIdx, AiCIdx, AiRCnt, AiCCnt);
                  end;
                end;
              end
              else
              begin
                AayMegerRowCnt[AiCIdx] := AayMegerRowCnt[AiCIdx] + 1;
              end;
            end;
          end;
          AjsData.A[Contants.Rows].Add((AjaryRow));
        end;
        Result := True;
      end
      else
      begin
        raise exception.Create('解析ELN数据文件：文件不存在' + AsFileName);
      end;
    except
      on e: exception do
      begin
        raise exception.Create(e.Message);
      end;
    end;
  finally
    if not VarIsEmpty(FWorkbook1) then
    begin
      FWorkbook1.Close;
      AcMegerArea.Free;
    end;
    // couninitialize;
  end;
end;

function TSourceThread.ReadXmlFile(ApFileData: TP_FILEDATA; AjsData: IsuperObject): boolean;
var
  AsFileName: string;
  AjsRowSru, AjsField, AjayFields, AjsTable, AjsItem: IsuperObject;
  AiIdx, AiCnt, AiIdx1, AiCnt1, AiIdx2, AiCnt2: Integer;
  _RootNode, AndRootFields, AndTable, AndSelIdx, AndField: IXMLNode;
  AndsTables, AndsSelIdxs, AndsField: IXMLNodeList;
begin
  Result := false;

  try
    AsFileName := ApFileData._FILE_XMLPATH;
    if FileExists(AsFileName) then
    begin
      G_XML_FILE.LoadFromFile(AsFileName);
      G_XML_FILE.Active := True;
      _RootNode := G_XML_FILE.DocumentElement;

      // 读取查询信息
      AndRootFields := _RootNode.ChildNodes.FindNode('fields');
      if AndRootFields <> nil then
      begin
        AndsTables := AndRootFields.ChildNodes;
        if AndsTables <> nil then
        begin
          AiCnt := AndsTables.count - 1;
          AjsData['tabs'] := SA([]);
          for AiIdx := 0 to AiCnt do
          begin
            AndTable := AndsTables[AiIdx];
            AndsSelIdxs := AndTable.ChildNodes;
            AiCnt1 := AndsSelIdxs.count - 1;
            for AiIdx1 := 0 to AiCnt1 do
            begin
              AndSelIdx := AndsSelIdxs[AiIdx1];

              AjsTable := TSuperObject.Create(stObject);
              AjsTable.s['alias'] := AndTable.NodeName;
              AjsTable.s['selindex'] := AndSelIdx.NodeName;
              AjsTable['fileds'] := SA([]);

              AndsField := AndSelIdx.ChildNodes;
              AiCnt2 := AndsField.count - 1;
              for AiIdx2 := 0 to AiCnt2 do
              begin
                AndField := AndsField[AiIdx2];
                AjsField := SO('{fieldname:' + Vartostr(AndField.GetAttribute('fieldname')) + ',StartColumn:' + Vartostr(AndField.GetAttribute('StartColumn')) + ',EndColumn:' + Vartostr(AndField.GetAttribute('EndColumn')) + ',StartRow:' + Vartostr(AndField.GetAttribute('StartRow')) + ',EndRow:' + Vartostr(AndField.GetAttribute('EndRow')) + ',Type:' + Vartostr(AndField.GetAttribute('Type')) + '}'); // 0:字符串 1：base64图片
                AjsTable.A['fileds'].Add(AjsField);
              end;
            end;
            AjsData.A['tabs'].Add(AjsTable);
          end;
        end
        else
        begin
          raise exception.Create('解析ELN配置文件错误：未发现查询字段表信息');
        end;
      end
      else
      begin
        raise exception.Create('解析ELN配置文件错误：未发现查询字段信息');
      end;
      // 读取项目信息
      AndRootFields := _RootNode.ChildNodes.FindNode('items');
      if AndRootFields <> nil then
      begin
        AndsTables := AndRootFields.ChildNodes;
        AiCnt := AndsTables.count - 1;
        AjsData['items'] := SA([]);
        for AiIdx := 0 to AiCnt do
        begin
          AndTable := AndsTables[AiIdx];
          AjsItem := SO('{item_id:' + Vartostr(AndField.GetAttribute('item_id')) + ',item_name:' + Vartostr(AndField.GetAttribute('item_name')) + ',StartColumn:' + Vartostr(AndField.GetAttribute('StartColumn')) + ',EndColumn:' + Vartostr(AndField.GetAttribute('EndColumn')) + ',StartRow:' + Vartostr(AndField.GetAttribute('StartRow')) + ',EndRow:' + Vartostr(AndField.GetAttribute('EndRow')) + ',Type:' + Vartostr(AndField.GetAttribute('Type')) + '}'); // 0:字符串 1：base64图片
          AjsData.A['items'].Add(AjsItem);
        end;
      end
      else
      begin
        raise exception.Create('解析ELN配置文件错误：未发现项目信息');
      end;
      // 读取分析方法信息
      Result := True;
    end
    else
    begin
      raise exception.Create('解析ELN配置文件：文件不存在' + AsFileName);
    end;
  except
    on e: exception do
    begin
      raise exception.Create(e.Message);
    end;
  end;
end;

function TSourceThread._ColName(const AiColCnt: Integer): string;
const
  AaryChars: array [0 .. 25] of Char = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
var
  nIndexOfList, nIndex: Integer;
begin
  Result := '';
  try
    if AiColCnt < 0 then
      Exit;
    if AiColCnt <= 26 then
      Result := AaryChars[AiColCnt - 1]
    else
    begin
      nIndexOfList := AiColCnt div 26;
      nIndex := AiColCnt mod 26;
      if nIndex = 0 then
        nIndex := 26;
      Result := AaryChars[nIndexOfList - 1] + AaryChars[nIndex - 1];
    end;
  except
  end;
end;

function TSourceThread._ColRowName(AiCol, AiRow: Integer): string;
begin
  Result := _ColName(AiCol) + inttostr(AiRow);
end;

end.
