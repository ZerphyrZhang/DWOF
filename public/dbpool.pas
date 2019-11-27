unit dbpool;

interface

uses
  DB, Uni, classes, Dialogs, SysUtils, DBAccess, CommonUtil;

type
  TDbObjPool = record
    Flag: boolean;                //��ǰ�����Ƿ�ʹ��
    ConnObj: TUniConnection;      //���ݿ����Ӷ���
    QryObj: TUniQuery;            //���ݿ���ʶ���
  end;

  PDBObjPool = ^TDbObjPool;

  {�������ݿ����ӳ���}
  TDbPoolClass = class
  private
    { Private declarations }
    DB_POOL_NUMBER: integer;
    localConnStr: string;
    DbObjPool: array of TDbObjPool;
  public
    { Public declarations }
    constructor Create(); overload;
    destructor Destroy; override;
    procedure InitDbPool;
    function GetNewQuery(const paIndex: integer): TUniQuery;
    procedure FreeQuery(const paIndex: integer);
//    function GetQueryFromPool(): integer;
    function getPoolUseNum(): integer;
    function _getDBPoolInfor(): string;
  end;

var
  dbPoolClass: TDbPoolClass;

implementation

//**:***************************************************************************
//**:���ܣ��������ݿ������ַ���.���������ݿ�����,�������ʧ�ܣ���ֹӦ�ó���
//**:���룺paPwd:���ݿ��������
//**:      paUser:���ݿ�����û�
//**:      paDS:ODBC����Դ
//**:      paDB:Ҫ���ʵ����ݿ�����
//**:***************************************************************************
constructor TDbPoolClass.Create();
begin
  DB_POOL_NUMBER := COMINFOR.FCONFIGINFOR.POOL_MAX;
  //��¼���ӳ�����������Ӹ���
  SetLength(DbObjPool, DB_POOL_NUMBER);

  //����ODBC������Ϣ�����������ַ�����
//  localConnStr := 'Provider=MSDASQL.1;Persist Security Info=False;' + 'Password=' + paPwd + ';User ID=' + paUser + ';Data Source=' + paDS + ';Initial Catalog=' + paDB;

  //�������ݿ����ӡ��������ʧ�ܣ�ֹͣӦ�ó���ִ�С�
  try
    InitDbPool;
  except
    raise Exception.Create('�������ݿ�ʧ��!');
  end;
end;
//**:***************************************************************************
//**:���ܣ��ͷ��̳߳��е��������Ӷ���
//**:***************************************************************************

destructor TDbPoolClass.Destroy;
var
  i: integer;
begin
  for i := 1 to DB_POOL_NUMBER do
  begin
    DbObjPool[i].Flag := false;
    DbObjPool[i].ConnObj.free;
    DbObjPool[i].ConnObj := nil;
    DbObjPool[i].QryObj.free;
    DbObjPool[i].QryObj := nil;
  end;
end;

//**:***************************************************************************
//**:���ܣ����ݿ����ӳصĶ��󣬲�ʹ���󱣳�����
//**:***************ing************************************************************
procedure TDbPoolClass.InitDbPool;
var
  i: integer;
  AsTmp: TStrings;
begin
//  AsTmp:=TStrings.Create
  for i := 1 to DB_POOL_NUMBER do
  begin
    DbObjPool[i].Flag := false;
    DbObjPool[i].ConnObj := TUniConnection.Create(nil);
    DbObjPool[i].QryObj := TuniQuery.Create(nil);

    with DbObjPool[i].ConnObj do
    begin
      ProviderName := 'MySQL';
      SpecificOptions.Values['UseUnicode'] := 'True';
    end;
    DbObjPool[i].ConnObj.ConnectString := localConnStr;
    with DbObjPool[i].ConnObj do
    begin
      Close;
      ProviderName := 'MySQL';
      Username := COMINFOR.FCONFIGINFOR.DB_USER;
      Password := COMINFOR.FCONFIGINFOR.DB_PWD;
      Server := COMINFOR.FCONFIGINFOR.DBSVR_IP;
      Database := COMINFOR.FCONFIGINFOR.DB_NAME;
      Port := COMINFOR.FCONFIGINFOR.DBSVR_PORT;
//      Open;

    end;

    DbObjPool[i].QryObj.Connection := DbObjPool[i].ConnObj;
//    DbObjPool[i].QryObj.LockMode := DBAccess.TLockMode.lmPessimistic;
    DbObjPool[i].ConnObj.LoginPrompt := False;

    DbObjPool[i].ConnObj.Connected := False;
  end;
end;

//**:***************************************************************************
//**:���ܣ� ȡ�õ�ǰ���ݿ�����ʹ�ø���
//**:***************************************************************************
function TDbPoolClass.getPoolUseNum(): integer;
var
  i, j: integer;
begin
  j := 0;
  for i := 1 to DB_POOL_NUMBER do
    if DbObjPool[i].Flag then
      inc(j);
  result := j;
end;

//**:***************************************************************************
//**:���ܣ�ȡ��ָ����ŵ����ݿ����ӳ��е����ݿ���ʶ���.
//**:***************************************************************************
function TDbPoolClass.GetNewQuery(const paIndex: integer): TUniQuery;
begin
  if ((paIndex < 1) or (DB_POOL_NUMBER < paIndex)) then
    raise Exception.Create('��δ�������ݿ���ʶ���.');
  if not DbObjPool[paIndex].Flag then
    raise Exception.Create('���ݿ����ӳط��ʷ�������.');

  DbObjPool[paIndex].QryObj.Close;
  DbObjPool[paIndex].QryObj.SQL.Clear;
  DbObjPool[paIndex].ConnObj.Open;
  DbObjPool[paIndex].ConnObj.Connected := true;

  result := DbObjPool[paIndex].QryObj;
  _log(_getDBPoolInfor);
end;



//**:***************************************************************************
//**:���ܣ��ͷ�ָ�������ݿ����Ӷ���
//**:***************************************************************************

procedure TDbPoolClass.FreeQuery(const paIndex: integer);
begin
  if ((0 < paIndex) and (paIndex < (DB_POOL_NUMBER + 1))) then
  begin
    DbObjPool[paIndex].Flag := false;
    DbObjPool[paIndex].ConnObj.Close;
    DbObjPool[paIndex].ConnObj.Connected := False;
  end;
  _log(_getDBPoolInfor);
end;

//**:***************************************************************************
//**:���ܣ������ݿ����ӳ����������ݿ���ʶ���.
//**:���أ��ö�������.
//**:***************************************************************************
//function TDbPoolClass.GetQueryFromPool(): integer;
//var
//  i, j: integer;
//begin
//  j := 0;
//  while 1 = 1 do
//  begin
//    inc(j);
//    if j > 1000 then
//      raise Exception.Create('�ȴ��������ݿ����Ӷ���ʧ��');
//
//    for i := 1 to DB_POOL_NUMBER do
//      if not DbObjPool[i].Flag then
//      begin
//        DbObjPool[i].Flag := true;
//        result := i;
//        exit;    //���뵽���󣬷���
//      end;
//    sleep(5);    //�ȴ�5����������룬ֱ����ʱ.
//  end;
//end;

function TDbPoolClass._getDBPoolInfor(): string;
var
  AiCnt: Integer;
begin
  AiCnt := getPoolUseNum;
  result := '���ӳ�������' + inttostr(DB_POOL_NUMBER) + ',��ǰ��ʹ�ã�' + inttostr(AiCnt) + '����ʣ��' + inttostr(DB_POOL_NUMBER - AiCnt);
end;

end.


