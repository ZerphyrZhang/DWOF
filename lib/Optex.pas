unit Optex;
{*------------------------------------------------------------------------------
  自实现优化互斥类(参见<Windows核心编程>)
  @author Jeffrey Richter(Hanxiao C2Delphi)
  @version  21/02/2009
-------------------------------------------------------------------------------}

interface

uses
  Windows;

type
  ///共享内存结构
  PSharedInfo = ^TSharedInfo;

  TSharedInfo = record
    m_dwSpinCount: DWORD;  /// (循环锁)循环次数
    m_lLockCount: Integer; /// 试图进入的次数
    m_dwThreadId: DWORD;   /// 拥有者(线程)ID
    m_lRecurseCount: Integer; /// 被拥有的次数
  end;
  ///自实现互斥类

  TOptex = class(TObject)
  private
    m_hevt: THandle;    /// 用于线程等待时的事件对象句柄
    m_hfm: THandle;     /// 共享内存句柄(内存映射方式实现的多进程共享)
    m_psi: PSharedInfo; /// 共享内存地址
    {*-------------------------------------------------------------------------

     @param
    ---------------------------------------------------------------------------}
    procedure CommonConstructor(dwSpinCount: DWORD; fUnicode: BOOL; pszName: Pointer); // 初始化
    function ConstructObjectName(pszResult: PAnsiChar; pszPrefix: PWideChar; fUnicode: BOOL; pszName: Pointer): PAnsiChar;
  public
    constructor Create(dwSpinCount: DWORD = 4000); overload;
    constructor Create(pszName: PAnsiChar; dwSpinCount: DWORD = 4000); overload;
    constructor Create(pszName: PWideChar; dwSpinCount: DWORD = 4000); overload;
    destructor Destroy(); override;
    {*-------------------------------------------------------------------------
    设置循环锁的次数
    @param dwSpinCount 循环锁次数
    ---------------------------------------------------------------------------}
    procedure SetSpinCount(dwSpinCount: DWORD);
    {*-------------------------------------------------------------------------
    进入临界区
    ---------------------------------------------------------------------------}
    procedure Enter;
    {*-------------------------------------------------------------------------
    尝试进入临界区
    ---------------------------------------------------------------------------}
    function TryEnter: Boolean;
    {*-------------------------------------------------------------------------
    离开临界区
    ---------------------------------------------------------------------------}
    procedure Leave;
    {*-------------------------------------------------------------------------
    判断是单进程锁或是多进程锁
    ---------------------------------------------------------------------------}
    function IsSingleProcessOptex: Boolean;
  end;

implementation
  /// 0=多处理器, 1=单处理器, -1=未定义

var
  sm_fUniprocessorHost: Integer = -1;

constructor TOptex.Create(dwSpinCount: DWORD = 4000);
begin
  CommonConstructor(dwSpinCount, FALSE, nil);
end;

constructor TOptex.Create(pszName: PAnsiChar; dwSpinCount: DWORD = 4000);
begin
  CommonConstructor(dwSpinCount, FALSE, pszName);
end;

constructor TOptex.Create(pszName: PWideChar; dwSpinCount: DWORD = 4000);
begin
  CommonConstructor(dwSpinCount, TRUE, pszName);
end;

function TOptex.IsSingleProcessOptex: Boolean;
begin
  Result := (m_hfm = 0);
end;

function TOptex.ConstructObjectName(pszResult: PAnsiChar; pszPrefix: PWideChar; fUnicode: BOOL; pszName: Pointer): PAnsiChar;
var
  ArgList: array[0..1] of PChar;
begin
  pszResult^ := #0;
  Result := nil;
  if (pszName <> nil) then
  begin
    ArgList[0] := pszPrefix;
    ArgList[1] := pszName;

    if fUnicode then
      wvsprintfA(pszResult, '%s%S', @ArgList[0])
    else
      wvsprintfA(pszResult, '%s%s', @ArgList[0]);
    Result := pszResult;
  end;
end;

procedure TOptex.CommonConstructor(dwSpinCount: DWORD; fUnicode: BOOL; pszName: Pointer);
var
  sinf: TSystemInfo;
  szResult: PAnsiChar;
begin
  /// 进程中首个TOptex对象被建立,检查当前机器是否单处理器
  if (sm_fUniprocessorHost = -1) then
  begin
    GetSystemInfo(sinf);
    sm_fUniprocessorHost := Integer(sinf.dwNumberOfProcessors = 1);
  end;
  /// 初始化成员
  m_hevt := 0;
  m_hfm := 0;
  m_psi := nil;
  if (pszName = nil) then/// 单进程对象
  begin
    /// 建立局部事件对象
    m_hevt := CreateEventA(nil, FALSE, FALSE, nil);
    /// 申请局部结构内存
    New(m_psi);
    ZeroMemory(m_psi, SizeOf(TSharedInfo));
  end
  else
  begin/// 多进程
    /// 创建内全局Event
    ConstructObjectName(szResult, 'Optex_Event_', fUnicode, pszName);
    ///创建Event
    m_hevt := CreateEventA(nil, FALSE, FALSE, szResult);
    /// 申请全局结构内存,并将将创建的内存映射文件映射
    ConstructObjectName(szResult, 'Optex_MMF_', fUnicode, pszName);
    m_hfm := CreateFileMappingA(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TSharedInfo), szResult);
    m_psi := MapViewOfFile(m_hfm, FILE_MAP_WRITE, 0, 0, 0);
  end;
  /// 循环次数
  SetSpinCount(dwSpinCount);
end;

destructor TOptex.Destroy();
begin
  /// 单进程对象,当仍有线程拥有它时,不能释放,但强行退出
  if IsSingleProcessOptex() and (m_psi.m_dwThreadId <> 0) then
    Exit;
  /// 多进程对象. 当本线程拥有它时,不能释放
  if (IsSingleProcessOptex = FALSE) and (m_psi.m_dwThreadId = GetCurrentThreadId) then
    Exit;
  if IsSingleProcessOptex then
    Dispose(m_psi)
  else
  begin
    UnmapViewOfFile(m_psi);
    CloseHandle(m_hfm);
  end;
  CloseHandle(m_hevt);
end;

procedure TOptex.SetSpinCount(dwSpinCount: DWORD);
begin
  // 多处理器机器
  if (sm_fUniprocessorHost = 0) then
    InterlockedExchange(Integer(m_psi.m_dwSpinCount), Integer(dwSpinCount));
end;

procedure TOptex.Enter;
var
  dwThreadId: DWORD;
begin
  /// 循环中已成功进入
  if TryEnter then
    Exit;
  ///获取当前正调用该锁的线程ID
  dwThreadId := GetCurrentThreadId;
  /// 没有线程拥有该锁,此时m_lLockCount完成一次自增
  if (InterlockedIncrement(m_psi.m_lLockCount) = 1) then
  begin
    m_psi.m_dwThreadId := dwThreadId;
    m_psi.m_lRecurseCount := 1;
  end
  else
  begin
    /// 拥有锁的是之前的线程,无需等待
    if (m_psi.m_dwThreadId = dwThreadId) then
    begin
      /// 增加拥有计数
      Inc(m_psi.m_lRecurseCount);
    end
    else
    begin
      /// 等待其他线程离开
      WaitForSingleObject(m_hevt, INFINITE);
      /// 此时才可拥有对象
      m_psi.m_dwThreadId := dwThreadId;
      m_psi.m_lRecurseCount := 1;
    end;
  end;
end;

function TOptex.TryEnter: Boolean;
var
  dwThreadId, dwSpinCount: DWORD;
begin
  ///获取试图拥有该锁的线程ID
  dwThreadId := GetCurrentThreadId();
  /// 获取循环锁次数
  dwSpinCount := m_psi.m_dwSpinCount;
  repeat
    /// 若 m_lLockCount = 0, 则 m_lLockCount := 1, 且 Result = TRUE m_psi.m_lLockCount
    Result := (InterlockedCompareExchange(m_psi.m_lLockCount, 1, 0) = 0);
    /// 锁未被拥有
    if (Result) then
    begin
      m_psi.m_dwThreadId := dwThreadId;
      m_psi.m_lRecurseCount := 1;
    end
    else
    begin
      if (m_psi.m_dwThreadId = dwThreadId) then
      begin
        InterlockedIncrement(m_psi.m_lLockCount);   ///增加
        Inc(m_psi.m_lRecurseCount);
        Result := True;
      end;
    end;
    ///到达循环锁次数后就退出dwSpinCount=(0 -1)=$FFFFFFFF
    Dec(dwSpinCount);
  until (Result) or (dwSpinCount = $FFFFFFFF);
end;

procedure TOptex.Leave;
begin
  if (GetCurrentThreadId <> m_psi.m_dwThreadId) then
    Exit;
  /// 减少引用计数
  Dec(m_psi.m_lRecurseCount);
  if (m_psi.m_lRecurseCount > 0) then
  begin
    /// 依然拥有对象
    InterlockedDecrement(m_psi.m_lLockCount);
  end
  else
  begin
    /// 不再拥有对象,减少进入计数并放行其他线程
    m_psi.m_dwThreadId := 0;
    if (InterlockedDecrement(m_psi.m_lLockCount) > 0) then
      SetEvent(m_hevt);
  end;
end;

end.


