unit dbpool;

interface

uses
  DB, Uni, classes, Dialogs, SysUtils, DBAccess, CommonUtil;

type
  TDbObjPool = record
    Flag: boolean;                //当前对象是否被使用
    ConnObj: TUniConnection;      //数据库连接对象
    QryObj: TUniQuery;            //数据库访问对象
  end;

  PDBObjPool = ^TDbObjPool;

  {处理数据库连接池类}
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
//**:功能：设置数据库连接字符串.并测试数据库连接,如果连接失败，终止应用程序
//**:输入：paPwd:数据库访问密码
//**:      paUser:数据库访问用户
//**:      paDS:ODBC数据源
//**:      paDB:要访问的数据库名称
//**:***************************************************************************
constructor TDbPoolClass.Create();
begin
  DB_POOL_NUMBER := COMINFOR.FCONFIGINFOR.POOL_MAX;
  //记录连接池允许最大连接个数
  SetLength(DbObjPool, DB_POOL_NUMBER);

  //根据ODBC配置信息，构造连接字符串。
//  localConnStr := 'Provider=MSDASQL.1;Persist Security Info=False;' + 'Password=' + paPwd + ';User ID=' + paUser + ';Data Source=' + paDS + ';Initial Catalog=' + paDB;

  //建立数据库连接。如果连接失败，停止应用程序执行。
  try
    InitDbPool;
  except
    raise Exception.Create('连接数据库失败!');
  end;
end;
//**:***************************************************************************
//**:功能：释放线程池中的所有连接对象
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
//**:功能：数据库连接池的对象，并使对象保持连接
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
//**:功能： 取得当前数据库连接使用个数
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
//**:功能：取得指定序号的数据库连接池中的数据库访问对象.
//**:***************************************************************************
function TDbPoolClass.GetNewQuery(const paIndex: integer): TUniQuery;
begin
  if ((paIndex < 1) or (DB_POOL_NUMBER < paIndex)) then
    raise Exception.Create('尚未申请数据库访问对象.');
  if not DbObjPool[paIndex].Flag then
    raise Exception.Create('数据库连接池访问发生混乱.');

  DbObjPool[paIndex].QryObj.Close;
  DbObjPool[paIndex].QryObj.SQL.Clear;
  DbObjPool[paIndex].ConnObj.Open;
  DbObjPool[paIndex].ConnObj.Connected := true;

  result := DbObjPool[paIndex].QryObj;
  _log(_getDBPoolInfor);
end;



//**:***************************************************************************
//**:功能：释放指定的数据库连接对象
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
//**:功能：从数据库连接池中申请数据库访问对象.
//**:返回：该对象的序号.
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
//      raise Exception.Create('等待申请数据库连接对象失败');
//
//    for i := 1 to DB_POOL_NUMBER do
//      if not DbObjPool[i].Flag then
//      begin
//        DbObjPool[i].Flag := true;
//        result := i;
//        exit;    //申请到对象，返回
//      end;
//    sleep(5);    //等待5毫秒继续申请，直至超时.
//  end;
//end;

function TDbPoolClass._getDBPoolInfor(): string;
var
  AiCnt: Integer;
begin
  AiCnt := getPoolUseNum;
  result := '连接池数量：' + inttostr(DB_POOL_NUMBER) + ',当前已使用：' + inttostr(AiCnt) + '，还剩：' + inttostr(DB_POOL_NUMBER - AiCnt);
end;

end.


