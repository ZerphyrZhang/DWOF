unit SettingUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask, AdvEdit, AdvIPEdit, AdvEdBtn, AdvDirectoryEdit, Vcl.ToolWin,
  Vcl.ActnMan, Vcl.ActnCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, cxStyles, cxEdit, cxDropDownEdit, cxTextEdit,
  cxDataControllerConditionalFormattingRulesManagerDialog, cxVGrid,
  cxInplaceContainer, dxSkinTheBezier;

type
  TFrmSetting = class(TForm)
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label6: TLabel;
    edt_plmax: TEdit;
    Label7: TLabel;
    edt_plmin: TEdit;
    Label8: TLabel;
    edt_port: TEdit;
    TabSheet4: TTabSheet;
    Label10: TLabel;
    edt_svrip: TAdvIPEdit;
    edt_tcatpath: TAdvDirectoryEdit;
    Panel3: TPanel;
    ListBox1: TListBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Label12: TLabel;
    Button5: TButton;
    Button6: TButton;
    cxVerticalGrid1: TcxVerticalGrid;
    cve_dbtype: TcxEditorRow;
    cve_dbip: TcxEditorRow;
    cve_dbport: TcxEditorRow;
    cxVerticalGrid1CategoryRow3: TcxCategoryRow;
    cve_dbname: TcxEditorRow;
    cve_dbusername: TcxEditorRow;
    cve_dbpwd: TcxEditorRow;
    Button4: TButton;
    cve_svrname: TcxEditorRow;
    cxVerticalGrid1CategoryRow2: TcxCategoryRow;
    cxVerticalGrid1CategoryRow5: TcxCategoryRow;
    cve_dbfile: TcxEditorRow;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    procedure WriteConfig();
    procedure ReadConfig();
    function ValueCheck(): boolean;
  public
    { Public declarations }
  end;

var
  FrmSetting: TFrmSetting;

implementation

uses
  System.IniFiles, CommonUtil, Contants, MainFormUnit, StrUtils, System.Types;
{$R *.dfm}

procedure TFrmSetting.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TFrmSetting.WriteConfig();
var
  AsSvrName, AsSecSvrName, AsTmp: string;
  AiniFile: TIniFile;
  AiIdx, AiCnt: integer;
begin

  try
    try
      if ValueCheck() then
      begin
        AiniFile := TIniFile.create(COMINFOR.FINIPATH);
        /// 服务器配置保存
        AiniFile.WriteString(Contants.SVRCONFIG, Contants.SVRIP, edt_svrip.IPAddress);
        AiniFile.WriteString(Contants.SVRCONFIG, Contants.SVRPORT, edt_port.Text);
        /// ////////////////////////////////////////////////////////////////////////

        /// 数据库连接保存
        AsSecSvrName := AiniFile.ReadString('CFGSVR', 'SVRLST', '');
        if ListBox1.ItemIndex > -1 then
        begin
          // 修改
          AsSvrName := ListBox1.Items[ListBox1.ItemIndex];
          AsTmp := VGCellValue(cve_svrname);
          if AsTmp <> AsSvrName then
          begin
            AsSecSvrName := StringReplace(AsSecSvrName, AsSvrName + ',', AsTmp + ',', [rfReplaceAll]);
            AiniFile.WriteString('CFGSVR', 'SVRLST', AsSecSvrName);

            AiCnt := MainForm.ComboBox2.Items.Count - 1;
            for AiIdx := 0 to AiCnt do
            begin
              if MainForm.ComboBox2.Items[AiIdx] = AsSvrName then
              begin
                MainForm.ComboBox2.Items[AiIdx] := AsTmp;
              end;
            end;
            ListBox1.Items[ListBox1.ItemIndex] := AsTmp;
          end;

        end
        else
        begin
          // 添加
          AsSvrName := VGCellValue(cve_svrname);
          if POS(AsSvrName + ',', AsSecSvrName) > 0 then
          begin
            if MessageBox(Application.Handle, PWideChar(AsSvrName + '已经存在,是否覆盖？'), '系统提示', MB_OKCANCEL + MB_ICONINFORMATION) <> IDYES then
            begin
              exit;
            end;
          end
          else
          begin
            AsSecSvrName := AsSecSvrName + AsSvrName + ',';
            AiniFile.WriteString('CFGSVR', 'SVRLST', AsSecSvrName);
            ListBox1.Items.Add(AsSvrName);
            MainForm.ComboBox2.Items.Add(AsSvrName);
          end;
        end;
        AsTmp := VGCellValue(cve_dbtype);
        if AsTmp = 'MYSQL' then
        begin
          AiniFile.WriteInteger(AsSvrName, Contants.DBTYPE, 0);
        end
        else if AsTmp = 'ORACLE' then
        begin
          AiniFile.WriteInteger(AsSvrName, Contants.DBTYPE, 1);
        end;

        AiniFile.WriteString(AsSvrName, Contants.DBSVRIP, VGCellValue(cve_dbip));
        AiniFile.WriteInteger(AsSvrName, Contants.DBSVRPORT, StrToIntDef(VGCellValue(cve_dbport), 3306));
        AiniFile.WriteString(AsSvrName, Contants.DBNAME, VGCellValue(cve_dbname));
        AiniFile.WriteString(AsSvrName, Contants.DBUSER, VGCellValue(cve_dbusername));
        AiniFile.WriteString(AsSvrName, Contants.DBPWD, VGCellValue(cve_dbpwd));
        AiniFile.WriteString(AsSvrName, 'DBFILE', VGCellValue(cve_dbfile));
        /// /////////////////////////////////////////////////////////////////////////// ////////////////////

        /// 最大/小连接池，toamcat配置保存
        AiniFile.WriteInteger(Contants.CONPOOLCONFIG, Contants.PLMAX, StrToIntDef(edt_plmax.Text, 100));
        AiniFile.WriteInteger(Contants.CONPOOLCONFIG, Contants.PLMIN, StrToIntDef(edt_plmin.Text, 30));
        AiniFile.WriteString(Contants.TOMCATSETING, Contants.TOMCATPATH, edt_tcatpath.Text);
        /// /////////////////////////////////////////////////////////////////////////// ////////////////////

        LW_MSG_INFOR('保存成功。');

      end;
    except
      on e: exception do
      begin
        LW_MSG_INFOR('保存失败！！' + e.Message);
      end;
    end;
  finally
    AiniFile.Free;
  end;

end;

procedure TFrmSetting.ReadConfig();
var
  AiniFile: TIniFile;
  AsSecSvrs: string;
  AaryItems: TStringDynArray;
  AiIdx, AiCnt: integer;
begin
  AiniFile := TIniFile.create(COMINFOR.FINIPATH);
  try
    edt_svrip.IPAddress := AiniFile.ReadString(Contants.SVRCONFIG, Contants.SVRIP, 'localhost');
    edt_port.Text := AiniFile.ReadString(Contants.SVRCONFIG, Contants.SVRPORT, '8080');

    ListBox1.Clear;
    AsSecSvrs := AiniFile.ReadString('CFGSVR', 'SVRLST', '');
    AaryItems := SplitString(AsSecSvrs, ',');
    AiCnt := Length(AaryItems) - 2;
    for AiIdx := 0 to AiCnt do
    begin
      ListBox1.Items.Add(AaryItems[AiIdx]);
    end;

    edt_plmax.Text := IntToStr(AiniFile.ReadInteger(Contants.CONPOOLCONFIG, Contants.PLMAX, 100));
    edt_plmin.Text := IntToStr(AiniFile.ReadInteger(Contants.CONPOOLCONFIG, Contants.PLMIN, 30));
    edt_tcatpath.Text := AiniFile.ReadString(Contants.TOMCATSETING, Contants.TOMCATPATH, '');
  finally
    AiniFile.Free;
  end;

end;

procedure TFrmSetting.Button2Click(Sender: TObject);
begin
  WriteConfig;
end;

procedure TFrmSetting.Button3Click(Sender: TObject);
var
  AiniFile: TIniFile;
begin
  if ListBox1.ItemIndex > -1 then
  begin
    WriteConfig;
    AiniFile := TIniFile.create(COMINFOR.FINIPATH);
    AiniFile.WriteString('CFGSVR', 'CURSVR', ListBox1.Items[ListBox1.ItemIndex]);
    COMINFOR := TCommonInfor.create;
    if MainForm.ServerStatus then
    begin
      MainForm.ButtonStopClick(nil);
      MainForm.EditPort.Text := edt_port.Text;
      MainForm.ButtonStartClick(nil);
    end
    else
    begin
      MainForm.EditPort.Text := edt_port.Text;
    end;
    close;
  end
  else
  begin
    LW_MSG_ERROR('请选择需要应用的服务器！！');
  end;
end;

procedure TFrmSetting.Button5Click(Sender: TObject);
begin
  ListBox1.ClearSelection;
end;

procedure TFrmSetting.Button6Click(Sender: TObject);
var
  AiniFile: TIniFile;
  AsSecSvr, AsCurSvr, AsItem: string;
  AiIdx, AiCnt: integer;
begin
  if ListBox1.ItemIndex > -1 then
  begin
    AsItem := ListBox1.Items[ListBox1.ItemIndex];
    if MessageBox(Application.Handle, PWideChar('确定删除【' + AsItem + '】？'), '系统提示', MB_OKCANCEL + MB_ICONINFORMATION) = IDOK then
    begin
      AiniFile := TIniFile.create(COMINFOR.FINIPATH);

      AsSecSvr := AiniFile.ReadString('CFGSVR', 'SVRLST', '');
      AsSecSvr := StringReplace(AsSecSvr, AsItem + ',', '', [rfReplaceAll]);
      AiniFile.WriteString('CFGSVR', 'SVRLST', AsSecSvr);

      AiniFile.DeleteKey(AsItem, Contants.DBTYPE);
      AiniFile.DeleteKey(AsItem, Contants.DBSVRIP);
      AiniFile.DeleteKey(AsItem, Contants.DBSVRPORT);
      AiniFile.DeleteKey(AsItem, Contants.DBNAME);
      AiniFile.DeleteKey(AsItem, Contants.DBUSER);
      AiniFile.DeleteKey(AsItem, Contants.DBPWD);
      AiniFile.DeleteKey(AsItem, 'DBFILE');
      ListBox1.DeleteSelected;
      AiCnt := MainForm.ComboBox2.Items.Count - 1;
      for AiIdx := 0 to AiCnt do
      begin
        if MainForm.ComboBox2.Items[AiIdx] = AsItem then
        begin
          MainForm.ComboBox2.Items.Delete(AiIdx);
        end;
      end;

    end;
  end
  else
  begin
    LW_MSG_ERROR('请选择您要删除的服务器配置！！');
  end;
end;

procedure TFrmSetting.FormCreate(Sender: TObject);
begin
  ReadConfig();
  PageControl1.ActivePageIndex := 1;
end;

procedure TFrmSetting.ListBox1DblClick(Sender: TObject);
var
  AiTmp: integer;
  AsItem: string;
  AiniFile: TIniFile;
begin
  AsItem := ListBox1.Items[ListBox1.ItemIndex];

  AiniFile := TIniFile.create(COMINFOR.FINIPATH);
  VGSetCellValue(cve_svrname, AsItem);

  AiTmp := (AiniFile.ReadInteger(AsItem, Contants.DBTYPE, 0));
  if AiTmp = 0 then
  begin
    VGSetCellValue(cve_dbtype, 'MYSQL');
  end
  else if AiTmp = 1 then
  begin
    VGSetCellValue(cve_dbtype, 'ORACLE');
  end;
  VGSetCellValue(cve_dbip, AiniFile.ReadString(AsItem, Contants.DBSVRIP, 'localhost'));
  VGSetCellValue(cve_dbport, IntToStr(AiniFile.ReadInteger(AsItem, Contants.DBSVRPORT, 3306)));
  VGSetCellValue(cve_dbname, AiniFile.ReadString(AsItem, Contants.DBNAME, 'limsv3'));
  VGSetCellValue(cve_dbusername, AiniFile.ReadString(AsItem, Contants.DBUSER, 'lims'));
  VGSetCellValue(cve_dbpwd, AiniFile.ReadString(AsItem, Contants.DBPWD, 'limsadmin'));
  VGSetCellValue(cve_dbfile, AiniFile.ReadString(AsItem, 'DBFILE', 'db.xml'));

end;

function TFrmSetting.ValueCheck(): boolean;
begin
  result := True;
  if not VGCellCheck(cve_svrname) then
  begin
    result := false;
    exit;
  end;
  if not VGCellCheck(cve_dbtype) then
  begin
    result := false;
    exit;
  end;
  if not VGCellCheck(cve_dbip) then
  begin
    result := false;
    exit;
  end;
//  if not VGCellCheck(cve_dbport) then
//  begin
//    result := false;
//    exit;
//  end;
//  if not VGCellCheck(cve_dbname) then
//  begin
//    result := false;
//    exit;
//  end;
  if not VGCellCheck(cve_dbusername) then
  begin
    result := false;
    exit;
  end;
  if not VGCellCheck(cve_dbpwd) then
  begin
    result := false;
    exit;
  end;
  if not VGCellCheck(cve_dbfile) then
  begin
    result := false;
    exit;
  end;
end;

end.

