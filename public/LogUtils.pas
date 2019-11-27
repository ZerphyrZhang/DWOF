unit LogUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Vcl.StdCtrls,
  safeLogger;

procedure _Create(mLog: Tmemo);

procedure _Destroy();

procedure _WriteLog(sTxt: string; const ALevel: Integer = 0);

var
  FSafeLogger: TSafeLogger;

implementation

procedure _Create(mLog: Tmemo);
begin
  sfLogger.setAppender(TStringsAppender.Create(mLog.Lines));
  sfLogger.AppendInMainThread := true;
  sfLogger.start;

  FSafeLogger := TSafeLogger.Create;
  FSafeLogger.setAppender(TLogFileAppender.Create(true));
  FSafeLogger.start;
end;

procedure _Destroy();
begin
  if FSafeLogger <> nil then
  begin
    FSafeLogger.Enable := false;
    FreeAndNil(FSafeLogger);
  end;
end;

procedure _WriteLog(sTxt: string; const ALevel: Integer = 0);
begin
  FSafeLogger.logMessage(sTxt, 'DEBUG');
  if ALevel = 0 then
  begin
    sfLogger.logMessage(sTxt);
  end;
end;

end.

