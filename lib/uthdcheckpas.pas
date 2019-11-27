unit uthdcheckpas;

interface

uses
  windows, Classes, logmanagerpas, Sysutils, inifiles;

const
  INTERVAL_TIME = 10;
  MINIMIUM_REMAINING_DISK_SPACE = 314572800;
  START_DELETE_REMAINING_DISK_SPACE = 314572800;

type
  TThdcheck = class(TThread)
  private
    FLogMgr: TLogManager;
    FTimerEvent: TlogEvent;
    FTimeCount: integer;
    FCurrentDate: TDateTime;
    FIsWarned: boolean;
    function IsAnotherDay(ADate: TDateTime): boolean;
    procedure TestFreeDisk;
  protected
    procedure Execute; override;
  public
    constructor Create(ALogMgr: TLogManager);
    destructor destroy; override;
  end;

implementation

uses
  LogUtils;

constructor TThdcheck.Create(ALogMgr: TLogManager);
begin
 { Place thread code here }
  inherited Create(true);
  FLogMgr := ALogMgr;
  FTimerEvent := TlogEvent.Create('TEN_SECONDS_INTERVAL_UP', false);
  FTimeCount := 0;
  FCurrentDate := now;
  FIsWarned := false;
  Priority := tpNormal;
end;

destructor TThdcheck.destroy;
begin
  FTimerEvent.Free;
  inherited destroy;

end;

procedure TThdcheck.Execute;
var
  NowDate: TDateTime;
  iMaxKeepDays: integer;
begin
  while (not terminated) do
  begin
    FTimeCount := (FTimeCount + INTERVAL_TIME) mod 3600;
    if FTimeCount = 0 then
    begin
      FLogMgr.FlushLogsToFile;
      TestFreeDisk;
    end;

    NowDate := now;

    if IsAnotherDay(NowDate) then
    begin
      FLogMgr.MoveToNextDay(NowDate);
      iMaxKeepDays := SysIniFile.ReadInteger('LogFile', 'MaxKeepDays', 7);
      FLogMgr.DelPreviousLogFiles(NowDate, iMaxKeepDays);
      FLogMgr.AddLog('The data has been transfered successfully!');
      FLogMgr.AddLog('Log files of ' + IntToStr(iMaxKeepDays) + ' days ago have been deleted');
    end;
    FTimerEvent.Wait(1000);
  end;
end;

function TThdcheck.IsAnotherDay(ADate: TDateTime): boolean;
var
  tmpOldDate, tmpNewDate: string;
begin
  tmpOldDate := FormatDateTime('yyyy/mm/dd', FCurrentDate);
  tmpNewDate := FormatDateTime('yyyy/mm/dd', ADate);
  if tmpOldDate <> tmpNewDate then
  begin
    result := true;
    FCurrentDate := ADate;
  end
  else
    result := false;
end;

procedure TThdcheck.TestFreeDisk;
var
  AmtFree: int64; //Cardinal;
  iMinKeepDays: integer;
begin
  AmtFree := DiskFree(0);

  if FIsWarned then
  begin
    FIsWarned := false;
    if (AmtFree < START_DELETE_REMAINING_DISK_SPACE) and (AmtFree >= 0) then
    begin
      iMinKeepDays := SysIniFile.ReadInteger('LogFile', 'MinKeepDays', 2);
      FLogMgr.DelPreviousLogFiles(FCurrentDate, iMinKeepDays);
      FLogMgr.AddLog('All log files of ' + intToStr(iMinKeepDays) + ' days ago have been deleted');
      AmtFree := DiskFree(0);
    end;
  end;

  if (AmtFree < MINIMIUM_REMAINING_DISK_SPACE) and (AmtFree >= 0) then
  begin
    FLogMgr.AddLog('The remaining space is only: ' + IntToStr(AmtFree) + ' bytes. Please remove previous Log Files. All log files of 2 days ago will be deleted in one hour !!!');
    FIsWarned := true;
  end;
end;

end.


