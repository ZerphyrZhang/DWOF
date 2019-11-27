unit Contants;

interface

const
  PREINDEX = 'o'; // json字符串中首标示

const
  DBXML = 'db.xml'; // 数据库配置文件名称

const
  FIELDS = 'fields'; // json串或者dbxml字段区域标示

const
  FILTER = 'filter'; // json字符串中条件标示

const
  FILTERS = 'filters'; // json字符串中条件标示

const
  SELINDEX = 'selindex'; // json字符串index标示

const
  XMLTABLE = 'table'; // dbxml中表标示

const
  NAME = 'name'; // dbxml中name标示

const
  ISPAGE = 'ispage'; // dbxml中ispage标示

const
  ISWHERE = 'iswhere'; // dbxml中iswhere标示

const
  SELECTS = 'selects'; // dbxml中selects区域

const
  PROCEDUES = 'procedues'; // dbxml中procedues区域

const
  PROCEDUE = 'procedue'; // dbxml中procedues区域

const
  PROC = 'proc'; // dbxml中procedues区域

const
  COLS = 'cols'; // dbxml中procedues区域

const
  PARAMS = 'params'; // dbxml中procedues区域

const
  PARAM = 'param'; // dbxml中procedues区域

const
  _PARAMS = '?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,';

const
  XMLFIELD = 'field'; // dbxml中字段标示、json串单个字段标示

const
  LOGIC = 'lgicp'; // 条件之间的连接符

const
  operator = 'op'; // 运算符

const
  VALUE = 'value'; // json串中值

const
  KEY = 'key'; // json串中值

const
  ALIAS = 'alias'; // dbxml中表及字段别名,json字符串中表别名

const
  FIELDTYPE = 'type'; // dbxml中字段类型

const
  INSERTPRE = 'insert into '; // 数据库添加方法前缀

const
  INSERTVALUE = ' values '; // 数据库添加方法数据值标示

const
  LEFTKH = '('; // 左括号

const
  RIGHTKH = ')'; // 右括号

const
  DIAN = ''''; // 字段单引号

const
  DOU = ','; // 逗号

const
  MAO = ':'; // 冒号

const
  WEN = '?'; // 问号

const
  FEN = ';'; // 分号

const
  _AND = ' and '; // and

const
  OPTS: array [0 .. 1] of string = ('and', 'or'); { ' and ', ' or ' }// and

const
  EQ = '='; // 等于

const
  UPDATE = 'update ';

const
  _SET = ' set ';

const
  WHERE = ' where ';

const
  LIKE = ' like ';

const
  PERCENT = '%';

const
  DELETEFRM = 'delete from ';

const
  EMPTY = ''; // 空字符串

const
  PAGENUM = 'pagenum'; // 页码

const
  PAGESIZE = 'pagesize'; // 每页显示数量

const
  SORTTYPE = 'sorttype'; // 排序标示

const
  SORTFIELD = 'sortdatafield'; // 排序标示

const
  SORTORDER = 'sortorder'; // 排序标示

const
  ORDERBY = 'orderby'; // 排序标示

const
  ORDERASC = ' asc '; // 排序标示

const
  GROUPBY = 'groupby'; // 分组标示

const
  SELECT = 'select'; // select

const
  XING = '*';

const
  FROM = 'from';

const
  T = 't'; // 表别名

const
  O = 'o';

const
  TDIAN = '.';

const
  KONGGE = ' ';

const
  DATA = 'data';

const
  PRE_D = 'd_';

const
  ROWS = 'rows';

const
  STRUCTURE = 'structure';

const
  LIMIT = 'limit';

const
  INDEXCOUNT = '_count';

const
  ODDERBY = ' order by ';

const
  ORDERBYSQL = 'order by';

const
  GROUPBYSQL = 'group by';

const
  CURRENT_USER = 'currentUser'; // 当前登录用户

const
  SUPERADMIN_NAME = 'superadmin'; // 超级管理员

const
  ITEMS = 'items';

const
  SQL_ISNULL = 'isnull';

const
  SQL_ISNOTNULL = 'nisnull';

const
  SQL_EQ = '=';

const
  SQL_CEQ = 'eq';

const
  SQL_NEQ = '<>';

const
  SQL_CNEQ = 'neq';

const
  SQL_GTE = '>=';

const
  SQL_CGTE = 'gte';

const
  SQL_GT = '>';

const
  SQL_CGT = 'gt';

const
  SQL_LTE = '<=';

const
  SQL_CLTE = 'lte';

const
  SQL_LT = '<';

const
  SQL_CLT = 'lt';

const
  SQL_IN = 'in';

const
  SQL_NOTIN = 'nin';

const
  SQL_CONTANTS = 'contain';

const
  SUCCFLAG = '1';

const
  FAILFLAG = '"0"';

const
  LICENSEFLAG = '-1';

const
  IS_KEY = 'iskey';

const
  IS_NULL = ' is null ';

const
  IS_NOT_NULL = ' is not null ';

const
  IMAGEPATH = '/upload'; // 存放电子签名的路径

const
  SERVERFOLDER = '/LIMS4.0';

const
  SERVERIP = 'http://localhost:8093';

const
  REPORT_PDF_PATH = 'D:\\COA-DOCUMENT\\COA\\'; // pdf报告存放位置

const
  USERTOKEN = 'd_token';

const
  USERCMD = 'd_usercmd';

const
  USERNAME = 'd_username';

const
  USERPWD = 'd_userpwd';

const
  REQUSTPARAMINDEX = 2;

const
  PROCCALL = ' call ';

const
  INIFILENAME = 'config.ini';

const
  SVRCONFIG = 'svrsetting';

const
  SVRIP = 'svrip';

const
  DBSVRCONFIG = 'dbsvrsetting';

const
  DBTYPE = 'db_type';

const
  DBSVRIP = 'db_svrip';

const
  DBSVRPORT = 'db_svrport';

const
  DBNAME = 'db_name';

const
  DBUSER = 'db_user';

const
  DBPWD = 'db_pwd';

const
  CONPOOLCONFIG = 'cnpoolsetting';

const
  TOMCATSETING = 'tcatseting';

const
  TOMCATPATH = 'tcatpath';

const
  PLMAX = 'plmax';

const
  PLMIN = 'plmin';

const
  SVRPORT = 'svrport';

const
  ISTYPE = 'is_type';

const
  _LOGIN = 'login';

const
  _NEW = 'new';

const
  _UPDATE = 'update';

const
  _DELETE = 'delete';

const
  _EXECPROC = 'proc';

const
  _SLOGIN = '登录系统';

const
  _SNEW = '插入数据';

const
  _SUPDATE = '修改数据';

const
  _SDELETE = '删除数据';

const
  _SEXECPROC = '存储过程';

implementation

end.
