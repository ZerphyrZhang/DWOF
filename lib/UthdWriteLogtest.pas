unit UthdWriteLogtest;

interface

uses
  Classes;

type
  TWriteLog = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  LogUtils;

procedure TWriteLog.Execute;
var
  i: integer;
begin
  for i := 0 to 2 do
  begin
    LogMgr.AddLog('This is a massage from thread!');
  end;
end;

end.


