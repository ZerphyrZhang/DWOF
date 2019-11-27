program Adwof8;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Windows,
  system.SysUtils,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  MessageDigest_5 in 'lib\MessageDigest_5.pas',
  superdate in 'lib\superdate.pas',
  supertimezone in 'lib\supertimezone.pas',
  supertypes in 'lib\supertypes.pas',
  superxmlparser in 'lib\superxmlparser.pas',
  CommonUtil in 'public\CommonUtil.pas',
  Contants in 'public\Contants.pas',
  DBML in 'public\DBML.pas' {DBModule: TDataModule},
  TDBPack in 'public\TDBPack.pas',
  Errors in 'public\Errors.pas',
  LoginUtils in 'public\LoginUtils.pas',
  ResUtils in 'public\ResUtils.pas',
  XmlUtils in 'public\XmlUtils.pas',
  XmlUtils1 in 'public\XmlUtils1.pas',
  Vcl.Themes,
  Vcl.Styles,
  LicenseUtils in 'public\LicenseUtils.pas',
  LogUtils in 'public\LogUtils.pas',
  logmanagerpas in 'lib\logmanagerpas.pas',
  uThreadPool in 'public\uThreadPool.pas',
  AboutUsUnit in 'AboutUsUnit.pas' {FrmAbout},
  SettingUnit in 'SettingUnit.pas' {FrmSetting},
  superobject in 'lib\superobject.pas',
  MD5 in 'public\MD5.pas',
  THighlander_rtcClientPool in 'public\THighlander_rtcClientPool.pas',
  SourceUnit in 'public\SourceUnit.pas',
  ElnUtils in 'public\ElnUtils.pas',
  ElnManager in 'public\ElnManager.pas',
  ExcelUnit in 'public\ExcelUnit.pas',
  THighlander_rtcDatabasePool in 'public\THighlander_rtcDatabasePool.pas',
  RTC_DBPOOL in 'public\RTC_DBPOOL.pas',
  RTC_CLTPOOL in 'public\RTC_CLTPOOL.pas',
  SQLCachesUnit in 'public\SQLCachesUnit.pas',
  uAuthentication in 'lib\uAuthentication.pas',
  SynCommons in 'lib\SynCommons.pas';

{$R *.res}
{$R UAC.res}

var
  hAppMutex: THandle; // 声明互斥变量

procedure setSysDateFormat();
var
  fs: TFormatSettings;
begin
  // 设置WINDOWS系统的短日期的格式
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SSHORTDATE, 'yyyy-MM-dd');
  Application.UpdateFormatSettings := False;
  // 设定程序本身所使用的日期时间格式
  fs.LongDateFormat := 'yyyy-MM-dd';
  fs.ShortDateFormat := 'yyyy-MM-dd';
  fs.LongTimeFormat := 'hh:nn:ss';
  fs.ShortTimeFormat := 'hh:nn:ss';
  fs.DateSeparator := '-';
  fs.timeSeparator := ':';
end;

begin
  hAppMutex := CreateMutex(nil, False, 'dwof');
  if ((hAppMutex <> 0) and (GetLastError() = ERROR_ALREADY_EXISTS)) then
  begin
    Application.MessageBox(PWideChar('服务器已经运行, 按确定关闭此窗口!'), PWideChar('运行提示'));
  end
  else
  begin
//    ReportMemoryLeaksOnShutdown := DebugHook <> 0;
    setSysDateFormat;
//    if WebRequestHandler <> nil then
//      WebRequestHandler.WebModuleClass := WebModuleClass;

    Application.Initialize;

    TStyleManager.TrySetStyle('Sapphire Kamri');
    Application.CreateForm(TMainForm, MainForm);
    Application.CreateForm(TDBModule, DBModule);
    Application.Run;
  end;

  ReleaseMutex(hAppMutex); // 关闭互斥体 CloseHandle(hAppMutex)作用一样

end.

