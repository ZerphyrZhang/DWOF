unit ExcelUnit;

interface

uses classes, sysutils, ElnManager;

type
  TExcelUtils = class
  private
    FLIST: TLIST;
  protected
  public
    constructor Create();
    destructor destroy;

    procedure Add(AiRow, AiCol, AiRowCnt, AiColCnt: integer);
    function InArea(AiRow, AiCol: integer): boolean;
  end;

implementation

constructor TExcelUtils.Create();
begin
  FLIST := TLIST.Create;
end;

destructor TExcelUtils.destroy;
begin
  inherited destroy;
  FLIST.Free;
end;

procedure TExcelUtils.Add(AiRow, AiCol, AiRowCnt, AiColCnt: integer);
var
  ApTmp: TP_MEGERAREA;
begin
  new(ApTmp);
  ApTmp._ROW := AiRow;
  ApTmp._COL := AiCol;
  ApTmp._ROWCNT := AiRowCnt;
  ApTmp._COLCNT := AiColCnt;
  FLIST.Add(ApTmp);
end;

function TExcelUtils.InArea(AiRow, AiCol: integer): boolean;
var
  ApTmp: TP_MEGERAREA;
  AiIdx, AiCnt: integer;
  AlstIdxs: TStringList;
begin
  result := false;
  AlstIdxs := TStringList.Create;
  try
    AiCnt := FLIST.Count - 1;
    for AiIdx := 0 to AiCnt do
    begin
      ApTmp := FLIST.Items[AiIdx];
      if ((ApTmp._ROW + ApTmp._ROWCNT) > AiRow) and ((ApTmp._COL + ApTmp._COLCNT) > AiCol) then
      begin
        result := true;
        break;
      end
      else if ((ApTmp._ROW + ApTmp._ROWCNT) < AiRow) then
      begin
        AlstIdxs.Add(inttostr(AiIdx));
      end;
    end;
    AiCnt := AlstIdxs.Count - 1;
    for AiIdx := 0 to AiCnt do
    begin
      FLIST.Delete(strtoint(AlstIdxs[AiIdx]));
    end;
  finally
    AlstIdxs.Free;
  end;
end;

end.
