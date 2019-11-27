unit thdlogmghandlepas;

interface

uses
  Classes, windows, logmanagerpas, stdctrls, Messages;

type
  Tthdloghandle = class(TThread)
  private
    { Private declarations }
    FLogMgr: TLogManager;
    FNewLogAddEvent: TlogEvent;
    fmemolog: Tmemo;
  protected
    procedure Execute; override;
  public
    constructor create(ALogMgr: TLogManager; memolog: Tmemo);
    destructor destroy; override;
  end;

implementation

constructor Tthdloghandle.create(ALogMgr: TLogManager; memolog: Tmemo);
begin
  inherited create(true);
  FLogMgr := ALogMgr;
  fmemolog := memolog;
  FNewLogAddEvent := TlogEvent.create('HAS_NEW_LOG_ADDED', false);
  Priority := tpLower;
end;

destructor Tthdloghandle.destroy;
begin
  FNewLogAddEvent.Free; // yj
  inherited destroy;
end;

procedure Tthdloghandle.Execute;
var
  sTmp: string;
begin
  { Place thread code here }
  while true and (not terminated) do
  begin
    if FLogMgr.HasWaitingLog then
    begin
      sTmp := FLogMgr.GetFirstWaitingLog;
      if sTmp <> '' then
      begin
        if FLogMgr.MsgLevel = 0 then
        begin
          fmemolog.Lines.Add(sTmp);
          FLogMgr.WriteLogToFile(sTmp);
        end;
        SendMessage(fmemolog.Handle, WM_VSCROLL, SB_BOTTOM, 0);
      end;
      if fmemolog.Lines.Count > 180 then
      begin
        fmemolog.Lines.Delete(0);
      end;
    end
    else
    begin
      FNewLogAddEvent.Wait(INFINITE);
    end;
  end;
end;

end.
