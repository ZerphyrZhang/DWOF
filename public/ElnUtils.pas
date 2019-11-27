unit ElnUtils;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Vcl.StdCtrls, SuperObject, ElnManager, SourceUnit;

procedure _Create();
procedure _Destroy();
function _AddFile(AsFilePath, AsFileName: string): integer;
function _getFile(AiFileIndex: integer): IsuperObject;

var
  ElnMgr: TElnManager;
  TSourcecheck: TSourceThread;

implementation

procedure _Create();
begin
  ElnMgr := TElnManager.Create();
  TSourcecheck := TSourceThread.Create(ElnMgr);
  TSourcecheck.Resume;
end;

procedure _Destroy();
var
  i: integer;
begin
  TSourcecheck.Terminate;
  ElnMgr.Free;
end;

function _AddFile(AsFilePath, AsFileName: string): integer;
begin
  result := ElnMgr.AddTplFile(AsFilePath, AsFileName);
end;

function _getFile(AiFileIndex: integer): IsuperObject;
var
  ApTmp: TP_FILEDATA;
begin
  result := nil;
  ApTmp := ElnMgr.GetFiled(AiFileIndex);
  if ApTmp <> nil then
  begin
    result := ApTmp._FILE_DATAS;
  end;
end;

end.
