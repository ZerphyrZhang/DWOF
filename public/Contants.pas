unit Contants;

interface

const
  PREINDEX = 'o'; // json�ַ������ױ�ʾ

const
  DBXML = 'db.xml'; // ���ݿ������ļ�����

const
  FIELDS = 'fields'; // json������dbxml�ֶ������ʾ

const
  FILTER = 'filter'; // json�ַ�����������ʾ

const
  FILTERS = 'filters'; // json�ַ�����������ʾ

const
  SELINDEX = 'selindex'; // json�ַ���index��ʾ

const
  XMLTABLE = 'table'; // dbxml�б��ʾ

const
  NAME = 'name'; // dbxml��name��ʾ

const
  ISPAGE = 'ispage'; // dbxml��ispage��ʾ

const
  ISWHERE = 'iswhere'; // dbxml��iswhere��ʾ

const
  SELECTS = 'selects'; // dbxml��selects����

const
  PROCEDUES = 'procedues'; // dbxml��procedues����

const
  PROCEDUE = 'procedue'; // dbxml��procedues����

const
  PROC = 'proc'; // dbxml��procedues����

const
  COLS = 'cols'; // dbxml��procedues����

const
  PARAMS = 'params'; // dbxml��procedues����

const
  PARAM = 'param'; // dbxml��procedues����

const
  _PARAMS = '?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,';

const
  XMLFIELD = 'field'; // dbxml���ֶα�ʾ��json�������ֶα�ʾ

const
  LOGIC = 'lgicp'; // ����֮������ӷ�

const
  operator = 'op'; // �����

const
  VALUE = 'value'; // json����ֵ

const
  KEY = 'key'; // json����ֵ

const
  ALIAS = 'alias'; // dbxml�б��ֶα���,json�ַ����б����

const
  FIELDTYPE = 'type'; // dbxml���ֶ�����

const
  INSERTPRE = 'insert into '; // ���ݿ���ӷ���ǰ׺

const
  INSERTVALUE = ' values '; // ���ݿ���ӷ�������ֵ��ʾ

const
  LEFTKH = '('; // ������

const
  RIGHTKH = ')'; // ������

const
  DIAN = ''''; // �ֶε�����

const
  DOU = ','; // ����

const
  MAO = ':'; // ð��

const
  WEN = '?'; // �ʺ�

const
  FEN = ';'; // �ֺ�

const
  _AND = ' and '; // and

const
  OPTS: array [0 .. 1] of string = ('and', 'or'); { ' and ', ' or ' }// and

const
  EQ = '='; // ����

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
  EMPTY = ''; // ���ַ���

const
  PAGENUM = 'pagenum'; // ҳ��

const
  PAGESIZE = 'pagesize'; // ÿҳ��ʾ����

const
  SORTTYPE = 'sorttype'; // �����ʾ

const
  SORTFIELD = 'sortdatafield'; // �����ʾ

const
  SORTORDER = 'sortorder'; // �����ʾ

const
  ORDERBY = 'orderby'; // �����ʾ

const
  ORDERASC = ' asc '; // �����ʾ

const
  GROUPBY = 'groupby'; // �����ʾ

const
  SELECT = 'select'; // select

const
  XING = '*';

const
  FROM = 'from';

const
  T = 't'; // �����

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
  CURRENT_USER = 'currentUser'; // ��ǰ��¼�û�

const
  SUPERADMIN_NAME = 'superadmin'; // ��������Ա

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
  IMAGEPATH = '/upload'; // ��ŵ���ǩ����·��

const
  SERVERFOLDER = '/LIMS4.0';

const
  SERVERIP = 'http://localhost:8093';

const
  REPORT_PDF_PATH = 'D:\\COA-DOCUMENT\\COA\\'; // pdf������λ��

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
  _SLOGIN = '��¼ϵͳ';

const
  _SNEW = '��������';

const
  _SUPDATE = '�޸�����';

const
  _SDELETE = 'ɾ������';

const
  _SEXECPROC = '�洢����';

implementation

end.
