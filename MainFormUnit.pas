unit MainFormUnit;

interface

uses
  windows, System.SysUtils, System.Variants, SynCommons, SynDB, SynCrtSock,
  System.Classes, Vcl.Graphics, SynZip, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.AppEvnts, Vcl.StdCtrls, IdHTTPWebBrokerBridge, Web.HTTPApp, System.TypInfo,
  Soap.WebServExp, Soap.WSDLBind, Xml.XMLSchema, Soap.WSDLPub, Vcl.ComCtrls, Vcl.Menus,
  LogUtils, superobject, Vcl.ExtCtrls, Winapi.ShellApi, Messages, TLHelp32,
  RTC_CLTPOOL, Vcl.Grids, RawTcpClient;

const
  WM_NID = WM_User + 1000; // 声明一个常量
  G_ITEMSPLITER = '●';
  G_ROWSPLITER = '↓';

type
  TMainForm = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    ButtonStart: TButton;
    ButtonStop: TButton;
    ButtonOpenBrowser: TButton;
    EditPort: TEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Button1: TButton;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    N4: TMenuItem;
    PopupMenu1: TPopupMenu;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    Label2: TLabel;
    ComboBox2: TComboBox;
    Button2: TButton;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memo1: TMemo;
    StringGrid1: TStringGrid;
    Panel3: TPanel;
    Button31: TButton;
    Button41: TButton;
    TabSheet3: TTabSheet;
    Panel4: TPanel;
    StringGrid2: TStringGrid;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Button5: TButton;
    Button4: TButton;
    Button32: TButton;
    Button6: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    function Process(Ctxt: THttpServerRequest): cardinal;
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure EditPortChange(Sender: TObject);
    procedure memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure StringGrid2Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
  private
    FServer: THttpApiServer;
    function StartServer: Boolean;
    procedure WriteLines(pLog: string);

    { Private declarations } // 定义两个函数
    procedure SysCommand(var SysMsg: TMessage); message WM_SYSCOMMAND;
    procedure WMNID(var msg: TMessage); message WM_NID;
    { Private declarations }
  public
    { Public declarations }
    function ServerStatus: Boolean;
    procedure _Main_Log(pMsg: string);
    procedure loadClients();
    procedure loadDictionary();
    procedure SaveDictConfig(AbNew: Boolean);
    procedure CreateDictionary();

  end;

var
  MainForm: TMainForm;
  NotifyIcon: TNotifyIconData; // 全局变量
  FServerStatus: Boolean;
  G_CacheDict: TStringList;

implementation

{$R *.dfm}

uses
  LicenseUtils, Errors, TDbPack, XmlUtils, RTC_DBPOOL, CommonUtil, AboutUsUnit,
  SettingUnit, Contants, DateUtils, inifiles, IdURI, strutils, System.Types,
  SourceUnit, SQLCachesUnit, uAuthentication, ResUtils;

procedure TMainForm.WMNID(var msg: TMessage);
var
  mousepos: TPoint;
begin
  GetCursorPos(mousepos); // 获取鼠标位置
  case msg.LParam of
    WM_LBUTTONUP: // 在托盘区点击左键后
      begin
        MainForm.Visible := not MainForm.Visible; // 显示主窗体与否
        Shell_NotifyIcon(NIM_DELETE, @NotifyIcon); // 显示主窗体后删除托盘区的图标
        SetWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW); // 在任务栏显示程序
      end;
    WM_RBUTTONUP:
      PopupMenu1.Popup(mousepos.X, mousepos.Y); // 弹出菜单
  end;
end;

procedure TMainForm.SysCommand(var SysMsg: TMessage);
begin
  case SysMsg.WParam of
    SC_MINIMIZE: // 当最小化时
      begin
        SetWindowPos(Application.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_HIDEWINDOW);
        Hide; // 在任务栏隐藏程序
        // 在托盘区显示图标
        with NotifyIcon do
        begin
          // cbSize := SizeOf(TNotifyIconData);
          Wnd := Handle;

          uID := 1;
          uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
          uCallBackMessage := WM_NID;
          hIcon := Application.Icon.Handle;
          szTip := '莱微LIMS服务器';
        end;
        Shell_NotifyIcon(NIM_ADD, @NotifyIcon); // 在托盘区显示图标
      end;
  else
    inherited;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  AsHour: string;
begin
  DateTimeToString(AsHour, 'hh', Now);
  if AsHour = '23' then
  begin
    if SQLCaches <> nil then
    begin
      _log('开始清理缓冲报文，共' + SQLCaches.GetCount.ToString + '条');
      SQLCaches.ManagerCaches;
    end;
  end;
end;

procedure TMainForm.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  ButtonStart.Enabled := not FServerStatus;
  ButtonStop.Enabled := FServerStatus;
  EditPort.Enabled := not FServerStatus;
end;

function TMainForm.ServerStatus(): Boolean;
begin
  result := FServer.Started;
end;

procedure TMainForm._Main_Log(pMsg: string);
begin
  memo1.Lines.Add(pMsg);
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  AiDbIdx, AiIdx, AiCnt: Integer;
  AsTmp: string;
begin
  AsTmp := Trim(Edit1.Text);
  AsTmp := TIdURI.URLDecode(AsTmp);
  try
    if AsTmp <> '' then
    begin
      AiIdx := ComboBox1.ItemIndex;
      case AiIdx of
        0:
          begin
            _log(DbPack.Querys(AsTmp).AsString);
          end;
        1:
          begin
            _log(DbPack.Query(AsTmp).AsString);
          end;
        2:
          begin
            _log(DbPack.insert(AsTmp).AsString);
          end;
        3:
          begin

            _log(DbPack.update(AsTmp).AsString);
          end;
        4:
          begin
            _log(DbPack.delete(AsTmp).AsString);
          end;
        5:
          begin
            _log(DbPack.Proc(AsTmp).AsString);
          end;
        6:
          begin
            _log(DbPack.login(AsTmp).AsString);
          end;
        7:
          begin
            _log(DbPack.Menus(AsTmp).AsString);
          end;
        8:
          begin
            _log(DbPack.selIndexs(AsTmp).AsString);
          end;
        9:
          begin
            _log(DbPack.selFields(AsTmp).AsString);
          end;
        10:
          begin
            _log(DbPack.Eexports(AsTmp).AsString);
          end;
        11:
          begin
            _log(DbPack.ElnFile(AsTmp).AsString);
          end;
      end;
    end;
  except
    on e: Exception do
    begin
      _log('测试--->' + e.Message);
    end;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  AsTmp: ISuperObject;

  procedure ProcessList(); //
  var
    hSnapshot: THandle; // 用于获得进程列表
    lppe: TProcessEntry32; // 用于查找进程
    Found: Boolean; // 用于判断进程遍历是否完成
  begin
    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); // 获得系统进程列表
    lppe.dwSize := SizeOf(TProcessEntry32); // 在调用Process32First API之前，需要初始化lppe记录的大小
    Found := Process32First(hSnapshot, lppe); // 将进程列表的第一个进程信息读入ppe记录中
    while Found do
    begin
      memo1.Lines.Add(ExtractFileName(lppe.szExeFile));

      // if ((UpperCase(ExtractFileName(lppe.szExeFile)) = UpperCase(AFileName)) or (UpperCase(lppe.szExeFile) = UpperCase(AFileName))) then
      // begin
      //
      // end;
      Found := Process32Next(hSnapshot, lppe); // 将进程列表的下一个进程信息读入lppe记录中
    end;
  end;

begin
  try
    try
      // AsTmp := SO('{name:"dddd"}');
      ProcessList;
    finally
      AsTmp := nil;
    end;
    // pJson := httpdecode(pJson);
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;

end;

procedure TMainForm.Button31Click(Sender: TObject);
begin
  if FServerStatus = true then
  begin
    _CLT_MGR.FTcpServer.Active := true;
    StatusBar1.Panels[5].Text := '等待接入状态';
  end
  else
  begin
    LW_MSG_ERROR('请先开启服务器应用');
  end;
end;

procedure TMainForm.Button32Click(Sender: TObject);
begin
  CreateDictionary;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  _CLT_MGR.FTcpServer.DisConnectAll();
  _CLT_MGR.FTcpServer.Active := true;
end;

procedure TMainForm.Button41Click(Sender: TObject);
begin
  if FServerStatus = true then
  begin
    _CLT_MGR.FTcpServer.Active := false;
    StatusBar1.Panels[5].Text := '关闭客户端接入';
  end
  else
  begin
    LW_MSG_ERROR('请先开启服务器应用');
  end;
end;

procedure TMainForm.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  StartServer;
  LURL := Format('http://localhost:%s', [EditPort.Text]);
  ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMainForm.ButtonStartClick(Sender: TObject);
var
  AtLimit, AtNow: TDateTime;
begin
  if ComboBox2.ItemIndex > -1 then
  begin
    if COMINFOR.loadDBConfig(ComboBox2.Text) then
    begin
      AtLimit := StrToDate('2029-04-02');
      if CompareDate(Now, AtLimit) = -1 then
      begin
        if StartServer then
        begin
          // if not FindProcess('java.exe') then
          // begin
          if FileExists(COMINFOR.FCONFIGINFOR.TCAT_PATH + '\startup.bat') then
          begin
            ShellExecute(Handle, 'open', PWideChar(COMINFOR.FCONFIGINFOR.TCAT_PATH + '\startup.bat'), 'title', nil, SW_SHOWNORMAL);
            // Winexec(AsTmp, SW_NORMAL);
          end;
          // end;

        end;
      end
      else
      begin
        ShowMessage('应用服务器无法开启！！');
      end;
    end
    else
    begin
      LW_MSG_ERROR('加载配置文件失败！！');
    end;
  end
  else
  begin
    LW_MSG_INFOR('请选择您要连接的服务器！！');
  end;
end;

procedure TMainForm.ButtonStopClick(Sender: TObject);
begin
  FServer.Free;
  FServer := nil;
  FServerStatus := false;
  Timer1.Enabled := false;
  WriteLines('服务器关闭成功');
  StatusBar1.Panels[3].Text := '关闭';
end;

procedure TMainForm.EditPortChange(Sender: TObject);
var
  AiniFile: Tinifile;
begin
  AiniFile := Tinifile.Create(COMINFOR.FINIPATH);
  try
    COMINFOR.FCONFIGINFOR.SVR_PORT := EditPort.Text;
    AiniFile.WriteString(Contants.SVRCONFIG, Contants.SVRPORT, EditPort.Text);
  finally

  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ButtonStop.Enabled then
  begin
    LW_MSG_ERROR('请先点击关闭按钮，关闭服务应用，再尝试关闭应用程序！！');
    CanClose := false;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

  try

    StatusBar1.Panels[0].Text := '版本' + GetBuildInfo;
    StatusBar1.Panels[4].Text := '运行模式';
    COMINFOR := TCommonInfor.Create;

    EditPort.Text := COMINFOR.FCONFIGINFOR.SVR_PORT;
    ComboBox1.ItemIndex := 0;
    FServerStatus := false;
  except
    on e: Exception do
    begin
      LW_MSG_ERROR('同时只允许一台服务器应用程序在运行');
      Application.Terminate;
    end;
  end;

end;

function TMainForm.Process(Ctxt: THttpServerRequest): cardinal;
var
  FN, cmd: RawUTF8;
  AsSendMsg: string;
  list: TStringList;
  AsMethodName, AsUid: SockString;
  AsTmp: string;
  AiTmp, AiLen, Ailenmsg: int64;
  AojTmp, AojPost: ISuperObject;
  AcTmp: TRawTcpClient;
  AnsRecv, AnsTmp: AnsiString;

  procedure _getClient();
  begin
    AsUid := AojPost['uid'].AsString;
    AcTmp := _CLT_MGR.GetClient(AsUid);
  end;

  procedure _login();
  begin
    AojTmp := DbPack.login(AsTmp);
    if (AojTmp <> nil) then
    begin
      if (AojTmp['t'].AsString = '1') then
      begin
        AiTmp := DateTimeToUnix(Now);
        fAuthentication.CreateSession(AiTmp, AojTmp);
        AojTmp.I['sid'] := AiTmp;
        Ctxt.OutContent := AojTmp.AsJSon();
      end
      else
      begin
        Ctxt.OutContent := AojTmp.AsJSon();
      end;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '登陆失败，未查询到用户相关信息。').AsJSon;
    end;
  end;

  procedure _ClientExecute(pType: string);
  begin
    AnsTmp := AnsiString(pType + ':' + AsTmp);
    AcTmp.sendBuffer(@AnsTmp[1], Length(AnsTmp));
    SetLength(AnsRecv, 102400000);
    AiLen := AcTmp.RecvBuffer(@AnsRecv[1], 102400000);
    SetLength(AnsRecv, AiLen);
    Ctxt.OutContent := AnsRecv;
  end;

  procedure _do_pro();
  begin
    if AojPost['sid'] <> nil then
    begin
      AiTmp := AojPost['sid'].AsInteger;
      if fAuthentication.SessionExists(AiTmp) then
      begin
        Ctxt.OutContent := DbPack.Proc(AsTmp).AsJSon();
      end
      else
      begin
        Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
      end;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
    end;
  end;

  procedure _do_update();
  begin
    if AojPost['sid'] <> nil then
    begin
      AiTmp := AojPost['sid'].AsInteger;
      if fAuthentication.SessionExists(AiTmp) then
      begin
        Ctxt.OutContent := DbPack.update(AsTmp).AsJSon();
      end
      else
      begin
        Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
      end;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
    end;
  end;

  procedure _do_new();
  begin
    if AojPost['sid'] <> nil then
    begin
      AiTmp := AojPost['sid'].AsInteger;
      if fAuthentication.SessionExists(AiTmp) then
      begin
        Ctxt.OutContent := DbPack.insert(AsTmp).AsJSon();
      end
      else
      begin
        Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
      end;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
    end;
  end;

  procedure _do_del();
  begin
    if AojPost['sid'] <> nil then
    begin
      AiTmp := AojPost['sid'].AsInteger;
      if fAuthentication.SessionExists(AiTmp) then
      begin
        Ctxt.OutContent := DbPack.delete(AsTmp).AsJSon();
      end
      else
      begin
        Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
      end;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '用户未登陆或登陆超时，请重新登陆之后再试。').AsJSon;
    end;
  end;
  procedure _do_dict();
  begin
    if G_CacheDict <> nil then
    begin
      AojTmp := SO(G_CacheDict.Text);
      Ctxt.OutContent := ResUtils.JsonForSelects(Contants.SUCCFLAG, '1', AojTmp, Errors.SUCC).AsJSon;
    end
    else
    begin
      Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '未发现字典文件。').AsJSon;
    end;
  end;
  function _getRemoteIP(): string;
  var
    AiRmtIdx: Integer;
    AsHeaders: SockString;
  begin
    AsHeaders := Ctxt.InHeaders;
    AiRmtIdx := Pos('Remote', AsHeaders);
    result := Trim(Copy(AsHeaders, AiRmtIdx + 9, 18));
  end;

begin
  result := 404;
  if Ctxt = nil then
  begin
    exit;
  end;
  Ctxt.OutContentType := JSON_CONTENT_TYPE;
  Ctxt.OutCustomHeaders := 'Access-Control-Allow-Headers: content-type,x-requested-with' + #13#10'Access-Control-Allow-Credentials: false' + #13#10'Access-Control-Allow-Origin: *' + #13#10'Content-Type: application/json; charset=UTF-8';
  if (Ctxt.Method = 'OPTIONS') then
  begin
    result := 200;
  end
  else if (Ctxt.Method = 'POST') then
  begin
    try
      try
        AsTmp := TIdURI.URLDecode(Ctxt.InContent);
        AsMethodName := Ctxt.URL;
        _log(_getRemoteIP + '  >>  ' + AsMethodName + ':' + AsTmp, COMINFOR.FDEVMODE);
        try
          AojPost := SO(AsTmp);
        except
          on e: Exception do
          begin
            Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '提交非法报文格式，请验证后再尝试。').AsJSon;
            result := 200;
            exit;
          end;
        end;
        if SameText(AsMethodName, '/do_login') then
        begin
          AojTmp := DbPack.login(AsTmp);
          if (AojTmp <> nil) then
          begin
            if (AojTmp['t'].AsString = '1') then
            begin
              AiTmp := DateTimeToUnix(Now);
              fAuthentication.CreateSession(AiTmp, AojTmp);
              AojTmp.I['sid'] := AiTmp;
              AsUid := AojTmp['data']['group_id'].AsString;
              AcTmp := _CLT_MGR.GetClient(AsUid);
              if (AcTmp <> nil) then
              begin
                AsSendMsg := AojTmp.AsJSon();
                Ailenmsg := Length(AsSendMsg);
                AnsTmp := AnsiString('05' + Ailenmsg.ToString + ':' + AsSendMsg);
                Ailenmsg := Length(AnsTmp);
                AcTmp.sendBuffer(@AnsTmp[1], Ailenmsg);
                SetLength(AnsRecv, 102400000);
                AiLen := AcTmp.RecvBuffer(@AnsRecv[1], 102400000);
                SetLength(AnsRecv, AiLen);
                Ctxt.OutContent := AnsRecv;
              end
              else
              begin
                Ctxt.OutContent := AojTmp.AsJSon();
              end;
            end
            else
            begin
              Ctxt.OutContent := AojTmp.AsJSon();
            end;
          end
          else
          begin
            Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.FAILFLAG, '登陆失败，未查询到用户相关信息。').AsJSon;
          end;
          result := 200;
        end
        else
        begin
          if SameText(AsMethodName, '/do_querys') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('03');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_queryOne') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.Query(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('04');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.Query(AsTmp).AsJSon();
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_pro') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                _do_pro;
              end
              else
              begin
                _ClientExecute('06');
              end;
            end
            else
            begin
              _do_pro;
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_update') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                _do_update;
              end
              else
              begin
                _ClientExecute('01');
              end;
            end
            else
            begin
              _do_update;
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_new') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                _do_new;
              end
              else
              begin
                _ClientExecute('00');
              end;
            end
            else
            begin
              _do_new;
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_del') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                _do_del;
              end
              else
              begin
                _ClientExecute('02');
              end;
            end
            else
            begin
              _do_del;
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_export') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.Eexports(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('12');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.Eexports(AsTmp).AsJSon();
            end;
            // Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
            result := 200;
          end
          else if SameText(AsMethodName, '/do_down') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('03');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
            end;
            // Ctxt.OutContent := DbPack.Querys(AsTmp).AsJSon();
            result := 200;
          end
          else if SameText(AsMethodName, '/do_seltables') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.seltables(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('08');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.seltables(AsTmp).AsJSon();
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_selindexs') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.selIndexs(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('09');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.selIndexs(AsTmp).AsJSon();
            end;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_selfields') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.selFields(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('10');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.selFields(AsTmp).AsJSon();
            end;
            // Ctxt.OutContent := DbPack.selFields(AsTmp).AsJSon();
            result := 200;
          end
          else if SameText(AsMethodName, '/do_dict') then
          begin
            _do_dict;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_dictchange') then
          begin
            CreateDictionary;
            Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.SUCCFLAG, Errors.SUCC).AsJSon;
            result := 200;
          end
          else if SameText(AsMethodName, '/do_menu') then
          begin
            if AojPost['uid'] <> nil then
            begin
              _getClient();
              if AcTmp = nil then
              begin
                Ctxt.OutContent := DbPack.Menus(AsTmp).AsJSon();
              end
              else
              begin
                _ClientExecute('07');
              end;
            end
            else
            begin
              Ctxt.OutContent := DbPack.Menus(AsTmp).AsJSon();
            end;
            // Ctxt.OutContent := DbPack.Menus(AsTmp).AsJSon();
            result := 200;
          end
          else if SameText(AsMethodName, '/do_authentication') then
          begin
            Ctxt.OutContent := ResUtils.JsonForResMsg(Contants.SUCCFLAG, '用户已经登陆。').AsJSon;
            result := 200;
          end;
        end;
      except
        on e: Exception do
        begin
          _log(e.Message);
          result := 407;
        end;
      end;
    finally
      AnsRecv := '';
    end;
  end;

end;

// function Tdwof._C12DBE4F(pJson: string; pSession: string): string;
// var
// AojTmp, AojSession: ISuperObject;
// AcTmp: TRawTcpClient;
// AnsRecv, AnsTmp: AnsiString;
// AiLen: Integer;
// begin
// try
// try
// AojSession := SO(pSession);
// AojSession['data'].Delete('user_pic');
// pSession := AojSession.AsJSon();
// AcTmp := _CLT_MGR.GetClient(AojSession['data']['group_id'].asstring);
// if AcTmp = nil then
// begin
// pJson := TIdURI.URLDecode(pJson);
// AojTmp := Dbpack.Querys(pJson, pSession);
// result := AojTmp.AsJSon();
// end
// else
// begin
// AnsTmp := AnsiString('03' + IntToStr(length(pJson)) + ':' + pJson + pSession);
// AcTmp.sendBuffer(@AnsTmp[1], Length(AnsTmp));
// SetLength(AnsRecv, 102400000);
// AiLen := AcTmp.RecvBuffer(@AnsRecv[1], 102400000);
// SetLength(AnsRecv, AiLen);
//
// result := AnsRecv;
// end;
// except
// on e: exception do
// begin
// result := ResUtils.JsonForResMsg('0', e.Message).AsString;
// _Log('_C12DBE4FDUBC--->' + e.Message);
// end;
// end;
// finally
// if AojTmp <> nil then
// begin
// AojTmp := nil;
// end;
// if AcTmp <> nil then
// begin
// _CLT_MGR.PutClient(AcTmp);
// end;
// pJson := '';
// end;
//
// end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // if (LogUtils.LogMgr <> nil) then
  // begin
  LogUtils._Destroy();
  // end;
  // if ElnUtils.ElnMgr <> nil then
  // begin
  // ElnUtils._Destroy;
  // end;
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon); // 删除托盘图标
  if (_XML_Poll <> nil) then
  begin
    _XML_Poll.Destroy;
  end;
  if (_RTC_DBPOLL <> nil) then
  begin
    _RTC_DBPOLL.Free;
  end;
  if (_CLT_MGR <> nil) then
  begin
    _CLT_MGR.Free;
  end;
  if (SQLCaches <> nil) then
  begin
    SQLCaches.Free;
  end;
  if (fAuthentication <> nil) then
  begin
    fAuthentication.Free;
  end;
  if (DbPack <> nil) then
  begin
    DbPack.Free;
  end;
  COMINFOR.Free;
  if (FServerStatus = true) then
  begin
    FServer.Free;
    FServer := nil;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  AiniFile: Tinifile;
  AsSecSvrs, AsTmp: string;
  AaryItems: TStringDynArray;
  AiIdx, AiCnt: Integer;
begin
  try
    PageControl1.ActivePageIndex := 0;
    AiniFile := Tinifile.Create(COMINFOR.FINIPATH);
    ComboBox2.Items.Clear;
    AsSecSvrs := AiniFile.ReadString('CFGSVR', 'SVRLST', '');
    AaryItems := SplitString(AsSecSvrs, ',');
    AiCnt := Length(AaryItems) - 2;
    for AiIdx := 0 to AiCnt do
    begin
      AsTmp := AaryItems[AiIdx];
      ComboBox2.Items.Add(AsTmp);
      if AsTmp = COMINFOR.FCONFIGINFOR.CUR_SVR then
      begin
        ComboBox2.ItemIndex := AiIdx;
      end;
    end;
  finally
    AiniFile.Free;
  end;
end;

procedure TMainForm.memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) then
  begin
    if (Key = 76) then
    begin
      // Panel1.Visible := not Panel1.Visible;
      // Button1.Visible := not Button1.Visible;
      // ButtonOpenBrowser.Visible := not ButtonOpenBrowser.Visible;
      N2.Visible := not N2.Visible;
      GroupBox1.Visible := not GroupBox1.Visible;
    end;
    if (Key = 77) then
    begin
      if COMINFOR.FDEVMODE = 1 then
      begin
        COMINFOR.FDEVMODE := 0;
        StatusBar1.Panels[4].Text := '开发模式';
      end
      else
      begin
        COMINFOR.FDEVMODE := 1;
        StatusBar1.Panels[4].Text := '运行模式';
      end;

    end;

  end;
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
  FrmSetting := TFrmSetting.Create(Self);
  FrmSetting.ShowModal;
end;

procedure TMainForm.N2Click(Sender: TObject);
var
  AsTmp: string;
begin
  AsTmp := ExtractFilePath(Application.Exename) + 'LogFiles\';
  ShellExecute(Handle, nil, 'Explorer.exe', PChar(Format('/e,/select,%s', [AsTmp])), nil, SW_NORMAL);
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
  FrmAbout := TFrmAbout.Create(Self);
  FrmAbout.ShowModal;
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(ExtractFilePath(Application.Exename) + 'Update.exe'), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  MainForm.Visible := true; // 显示窗体
  SetWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW);
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon); // 删除托盘图标
end;

procedure TMainForm.N7Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 1 then
  begin
    if FServerStatus = true then
    begin
      loadClients;
    end
    else
    begin
      LW_MSG_ERROR('请先开启服务器应用');
    end
  end
  else if PageControl1.ActivePageIndex = 2 then
  begin
    if FServerStatus = true then
    begin
      loadDictionary();
    end
    else
    begin
      LW_MSG_ERROR('请先开启服务器应用');
    end
  end;

end;

function TMainForm.StartServer: Boolean;
var
  AsRes: string;
begin
  result := false;
  try
    LogUtils._Create(memo1);
    AsRes := ValidateLicense;
    if (AsRes = '200') then
    begin
      if FServerStatus = false then
      begin
        G_CacheDict := TStringList.Create;
        G_CacheDict.LoadFromFile('dictionary.json');

        _XML_Poll := THXML_Poll.Create;
        WriteLines('文件读取完成');
        if _RTC_DBPOLL = nil then
        begin
          _RTC_DBPOLL := THL_RTC_DBPoll.Create;
        end
        else
        begin
          _RTC_DBPOLL.CloseAllDBConns;
        end;

        if _RTC_DBPOLL.CanConnected then
        begin
          WriteLines('连接池准备完成');
          StatusBar1.Panels[1].Text := '连接池：正常';

          DbPack := TPackDB.Create();
          WriteLines('数据初始化完成');

          // ElnUtils._Create();
          WriteLines('文件下载服务启动完成');

          if _CLT_MGR = nil then
          begin
            _CLT_MGR := TClientsManager.Create();
          end
          else
          begin
            _CLT_MGR.DeleteAllClient;
          end;
          WriteLines('负载均衡服务器初始化完成');

          if SQLCaches = nil then
          begin
            SQLCaches := TSQLCacheManager.Create();
            WriteLines('查询缓存机制创建完成');
          end;
          if fAuthentication = nil then
          begin
            fAuthentication := TAuthentication.Create();
            WriteLines('验证机制创建完成');
          end;

          FServer := THttpApiServer.Create(true); // https.sys rest server
          FServer.RegisterCompress(CompressGZip); // 压缩

          // FServer.LogStart('D:\Projects\dwof8\exefile\losg');
          FServer.OnRequest := Process; // 处理通信事件

          FServer.AddUrl('', EditPort.Text, false, '+', true); // 注册http URL
          FServer.AddUrl('', EditPort.Text, true, '+', true); // 注册https url
          FServer.Clone(120); // 创建N个工作线程
          FServer.Start;
          FServerStatus := true;
          // FServer.Bindings.Clear;
          // FServer.DefaultPort := StrToInt(EditPort.Text);
          // FServer.Active := true;

          Timer1.Enabled := true;

          WriteLines('服务器开启成功。（服务端口：' + EditPort.Text + '）');
          StatusBar1.Panels[3].Text := '正常';
          result := true;
        end;

      end
      else
      begin
        WriteLines('服务器已经开启');
        StatusBar1.Panels[3].Text := '正常';
        result := true;
      end;
    end
    else
    begin
      if (AsRes = '-102') then
      begin
        WriteLines(Errors.INPUTKEYISNULL);
        StatusBar1.Panels[3].Text := '未认证';
      end
      else if (AsRes = '-101') then
      begin
        WriteLines(Errors.LICENSECHEKERROR);
        StatusBar1.Panels[3].Text := '未认证';
      end
      else
      begin
        WriteLines(Errors.UNKNOWERROR);
        WriteLines(AsRes);
        StatusBar1.Panels[3].Text := '未认证';
      end;
    end;
  except
    on e: Exception do
    begin
      WriteLines(e.Message);
      StatusBar1.Panels[3].Text := '未认证';
    end;
  end;

end;

procedure TMainForm.StringGrid2Click(Sender: TObject);
begin
  with StringGrid2 do
  begin
    if row > 0 then
    begin
      Edit5.Text := Cells[0, row];
      Edit4.Text := Cells[1, row];
      Edit3.Text := Cells[2, row];
      Edit2.Text := Cells[3, row];
    end;
  end;

end;

///
procedure TMainForm.WriteLines(pLog: string);
begin
  _log(pLog);
end;

procedure TMainForm.loadClients();
var
  AiTmp, AiIdx, AiCnt: Integer;
  AsTmp: string;
  AdTmp: TPCLT_REC;
begin
  with StringGrid1 do
  begin
    Cells[0, 0] := '序号';
    Cells[1, 0] := '客户端地址';
    Cells[2, 0] := '端口号';
    Cells[3, 0] := '任务组编号';
  end;
  AiCnt := StringGrid1.RowCount - 1;
  with StringGrid1 do
  begin
    for AiIdx := 1 to AiCnt do
    begin
      Cells[0, AiIdx] := '';
      Cells[1, AiIdx] := '';
      Cells[2, AiIdx] := '';
      Cells[3, AiIdx] := '';
    end;
  end;
  StringGrid1.RowCount := 2;

  AiTmp := 1;
  for AsTmp in _CLT_MGR._gClts.Keys do
  begin
    AdTmp := _CLT_MGR._gClts[AsTmp];
    with StringGrid1 do
    begin
      Cells[0, AiTmp] := (AiTmp).ToString;
      Cells[1, AiTmp] := AdTmp.CLT_IP;
      Cells[2, AiTmp] := AdTmp.CLT_PORT.ToString;
      Cells[3, AiTmp] := AsTmp;
    end;
    AiTmp := AiTmp + 1;
    if StringGrid1.RowCount = AiTmp then
    begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
    end;
  end;

end;

procedure TMainForm.loadDictionary();
var
  AiTmp, AiIdx, AiCnt, AiIdx1, AiCnt1: Integer;
  AsTmp: string;
  AdTmp: TPCLT_REC;
  AiniFile: Tinifile;
  AaryVls, AaryVl: TStringDynArray;
begin
  with StringGrid2 do
  begin
    Cells[0, 0] := '字典索引';
    Cells[1, 0] := '值字段';
    Cells[2, 0] := '文本字段';
    Cells[3, 0] := '查询报文';
  end;
  AiCnt := StringGrid2.RowCount - 1;
  with StringGrid2 do
  begin
    for AiIdx := 1 to AiCnt do
    begin
      Cells[0, AiIdx] := '';
      Cells[1, AiIdx] := '';
      Cells[2, AiIdx] := '';
      Cells[3, AiIdx] := '';
    end;
  end;
  StringGrid2.RowCount := 2;

  AiTmp := 1;

  AiniFile := Tinifile.Create(COMINFOR.FINIPATH);
  AsTmp := AiniFile.ReadString('dcts', 'dctsidxs', '');
  if (AsTmp <> '') then
  begin
    AaryVls := SplitString(AsTmp, G_ROWSPLITER);
    AiCnt := Length(AaryVls);
    for AiIdx := 1 to AiCnt do
    begin
      AaryVl := SplitString(AaryVls[AiIdx - 1], G_ITEMSPLITER);
      with StringGrid2 do
      begin
        Cells[0, AiIdx] := AaryVl[0];
        Cells[1, AiIdx] := AaryVl[1];
        Cells[2, AiIdx] := AaryVl[2];
        Cells[3, AiIdx] := AaryVl[3];
        RowCount := RowCount + 1;
      end;
    end;
    StringGrid2.RowCount := StringGrid2.RowCount - 1;
  end;

end;

procedure TMainForm.SaveDictConfig(AbNew: Boolean);
var
  AiIdx, AiCnt: Integer;
  AsTmp: string;
  AiniFile: Tinifile;
begin
  if (chkedits([Edit5, Edit4, Edit3, Edit2])) then
  begin
    with StringGrid2 do
    begin
      if AbNew then
      begin
        if (RowCount = 2) and (Cells[0, row] = '') then
        begin
          row := 1;
        end
        else
        begin
          RowCount := RowCount + 1;
          row := RowCount - 1;
        end;
      end;
      Cells[0, row] := Edit5.Text;
      Cells[1, row] := Edit4.Text;
      Cells[2, row] := Edit3.Text;
      Cells[3, row] := Edit2.Text;
      AsTmp := '';
      AiCnt := StringGrid2.RowCount;
      for AiIdx := 1 to AiCnt - 1 do
      begin
        AsTmp := AsTmp + Cells[0, AiIdx] + G_ITEMSPLITER + Cells[1, AiIdx] + G_ITEMSPLITER + Cells[2, AiIdx] + G_ITEMSPLITER + Cells[3, AiIdx] + G_ROWSPLITER;
      end;
      AsTmp := Copy(AsTmp, 1, Length(AsTmp) - 1);
      AiniFile := Tinifile.Create(COMINFOR.FINIPATH);
      try
        AiniFile.WriteString('dcts', 'dctsidxs', AsTmp);
      finally
        AiniFile.Free;
      end;
    end;
  end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  SaveDictConfig(false);
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  SaveDictConfig(true);
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  AiIdx, AiCnt: Integer;
  AsTmp: string;
  AiniFile: Tinifile;
begin
  if (MessageBox(Application.Handle, '确定删除选中的字典配置。', '提示', MB_OKCANCEL + MB_ICONINFORMATION) = IDOK) then
  begin
    with StringGrid2 do
    begin
      Cells[0, row] := '';
      Cells[1, row] := '';
      Cells[2, row] := '';
      Cells[3, row] := '';

      AiCnt := RowCount;
      for AiIdx := row to AiCnt - 1 do
      begin
        Cells[0, AiIdx] := Cells[0, AiIdx + 1];
        Cells[1, AiIdx] := Cells[0, AiIdx + 1];
        Cells[2, AiIdx] := Cells[0, AiIdx + 1];
        Cells[3, AiIdx] := Cells[0, AiIdx + 1];
      end;
      RowCount := RowCount - 1;
      AiCnt := RowCount;
      for AiIdx := 1 to AiCnt - 1 do
      begin
        AsTmp := AsTmp + Cells[0, AiIdx] + G_ITEMSPLITER + Cells[1, AiIdx] + G_ITEMSPLITER + Cells[2, AiIdx] + G_ITEMSPLITER + Cells[3, AiIdx] + G_ROWSPLITER;
      end;
      AsTmp := Copy(AsTmp, 1, Length(AsTmp) - 1);
      AiniFile := Tinifile.Create(COMINFOR.FINIPATH);
      try
        AiniFile.WriteString('dcts', 'dctsidxs', AsTmp);
      finally
        AiniFile.Free;
      end;
    end;
  end;
end;

procedure TMainForm.CreateDictionary();
var
  AiIdx, AiCnt, AiiIdx, AiiCnt: Integer;
  AsDtIndx, AsDtValue, AsDtText, AsDtCfg, AsTmp: string;
  AojDict, AojData, AojTmp, AojItem: ISuperObject;
  AoyRows: TSuperArray;
begin
  try
    with StringGrid2 do
    begin
      if (RowCount > 1) and (Cells[0, 1] <> '') and (Cells[3, 1] <> '') then
      begin
        AojDict := TSuperObject.Create(stObject);
        AiCnt := RowCount;
        AsDtIndx := Cells[0, 1];
        AsDtValue := Cells[1, 1];
        AsDtText := Cells[2, 1];
        AsDtCfg := Cells[3, 1];
        AojData := DbPack.Querys(AsDtCfg);
        if AojData['t'].AsInteger = 1 then
        begin
          AoyRows := AojData[Contants.ROWS].AsArray;
          AiCnt := AoyRows.Length;
          for AiIdx := 0 to AiCnt - 1 do
          begin
            AojTmp := AoyRows[AiIdx];
            AsTmp := AojTmp['d_dict_typecode'].AsString;
            if AojDict[AsTmp] = nil then
            begin
              AojDict[AsTmp] := SA([]);
            end;
            AojItem := SO('{"label":' + AojTmp['d_badt_name'].AsJSon + ',"value":' + AojTmp['d_badt_code'].AsJSon + ',"level":' + AojTmp['d_badt_level1'].AsJSon + ',"level2":' + AojTmp['d_badt_level2'].AsJSon + ',"level3":' + AojTmp['d_badt_level3'].AsJSon + ',"level4":' + AojTmp['d_badt_level4'].AsJSon + '}');
            AojDict.A[AsTmp].Add(AojItem);
          end;
          AiCnt := RowCount;
          for AiIdx := 2 to AiCnt - 1 do
          begin
            AsDtIndx := Cells[0, AiIdx];
            AsDtValue := Cells[1, AiIdx];
            AsDtText := Cells[2, AiIdx];
            AsDtCfg := Cells[3, AiIdx];

            AojData := DbPack.Querys(AsDtCfg);
            if AojData['t'].AsInteger = 1 then
            begin
              AoyRows := AojData[Contants.ROWS].AsArray;
              if AojDict[AsDtIndx] = nil then
              begin
                AojDict[AsDtIndx] := SA([]);
              end;
              AiiCnt := AoyRows.Length;
              for AiiIdx := 0 to AiiCnt - 1 do
              begin
                AojTmp := AoyRows[AiiIdx];
                AojItem := SO('{"label":' + AojTmp[AsDtText].AsJSon + ',"value":' + AojTmp[AsDtValue].AsJSon + '}');
                AojDict.A[AsDtIndx].Add(AojItem);
              end;
            end
            else
            begin
              _log('[' + AsDtIndx + ']' + '生成字典失败');
            end;
          end;
          AojDict.SaveTo('dictionary.json');
          G_CacheDict := TStringList.Create;
          G_CacheDict.LoadFromFile('dictionary.json');
          _log('数据字典生成成功。');
        end
        else
        begin
          _log('生成字典失败');
        end;
      end
      else
      begin
        LW_MSG_INFOR('请添加字典文件配置');
      end;
    end;
  except
    on e: Exception do
    begin
      _log('生成字典出现故障：' + e.Message);
    end;
  end;

end;

end.
