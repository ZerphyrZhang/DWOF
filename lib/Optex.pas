unit Optex;
{*------------------------------------------------------------------------------
  ��ʵ���Ż�������(�μ�<Windows���ı��>)
  @author Jeffrey Richter(Hanxiao C2Delphi)
  @version  21/02/2009
-------------------------------------------------------------------------------}

interface

uses
  Windows;

type
  ///�����ڴ�ṹ
  PSharedInfo = ^TSharedInfo;

  TSharedInfo = record
    m_dwSpinCount: DWORD;  /// (ѭ����)ѭ������
    m_lLockCount: Integer; /// ��ͼ����Ĵ���
    m_dwThreadId: DWORD;   /// ӵ����(�߳�)ID
    m_lRecurseCount: Integer; /// ��ӵ�еĴ���
  end;
  ///��ʵ�ֻ�����

  TOptex = class(TObject)
  private
    m_hevt: THandle;    /// �����̵߳ȴ�ʱ���¼�������
    m_hfm: THandle;     /// �����ڴ���(�ڴ�ӳ�䷽ʽʵ�ֵĶ���̹���)
    m_psi: PSharedInfo; /// �����ڴ��ַ
    {*-------------------------------------------------------------------------

     @param
    ---------------------------------------------------------------------------}
    procedure CommonConstructor(dwSpinCount: DWORD; fUnicode: BOOL; pszName: Pointer); // ��ʼ��
    function ConstructObjectName(pszResult: PAnsiChar; pszPrefix: PWideChar; fUnicode: BOOL; pszName: Pointer): PAnsiChar;
  public
    constructor Create(dwSpinCount: DWORD = 4000); overload;
    constructor Create(pszName: PAnsiChar; dwSpinCount: DWORD = 4000); overload;
    constructor Create(pszName: PWideChar; dwSpinCount: DWORD = 4000); overload;
    destructor Destroy(); override;
    {*-------------------------------------------------------------------------
    ����ѭ�����Ĵ���
    @param dwSpinCount ѭ��������
    ---------------------------------------------------------------------------}
    procedure SetSpinCount(dwSpinCount: DWORD);
    {*-------------------------------------------------------------------------
    �����ٽ���
    ---------------------------------------------------------------------------}
    procedure Enter;
    {*-------------------------------------------------------------------------
    ���Խ����ٽ���
    ---------------------------------------------------------------------------}
    function TryEnter: Boolean;
    {*-------------------------------------------------------------------------
    �뿪�ٽ���
    ---------------------------------------------------------------------------}
    procedure Leave;
    {*-------------------------------------------------------------------------
    �ж��ǵ����������Ƕ������
    ---------------------------------------------------------------------------}
    function IsSingleProcessOptex: Boolean;
  end;

implementation
  /// 0=�ദ����, 1=��������, -1=δ����

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
  /// �������׸�TOptex���󱻽���,��鵱ǰ�����Ƿ񵥴�����
  if (sm_fUniprocessorHost = -1) then
  begin
    GetSystemInfo(sinf);
    sm_fUniprocessorHost := Integer(sinf.dwNumberOfProcessors = 1);
  end;
  /// ��ʼ����Ա
  m_hevt := 0;
  m_hfm := 0;
  m_psi := nil;
  if (pszName = nil) then/// �����̶���
  begin
    /// �����ֲ��¼�����
    m_hevt := CreateEventA(nil, FALSE, FALSE, nil);
    /// ����ֲ��ṹ�ڴ�
    New(m_psi);
    ZeroMemory(m_psi, SizeOf(TSharedInfo));
  end
  else
  begin/// �����
    /// ������ȫ��Event
    ConstructObjectName(szResult, 'Optex_Event_', fUnicode, pszName);
    ///����Event
    m_hevt := CreateEventA(nil, FALSE, FALSE, szResult);
    /// ����ȫ�ֽṹ�ڴ�,�������������ڴ�ӳ���ļ�ӳ��
    ConstructObjectName(szResult, 'Optex_MMF_', fUnicode, pszName);
    m_hfm := CreateFileMappingA(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TSharedInfo), szResult);
    m_psi := MapViewOfFile(m_hfm, FILE_MAP_WRITE, 0, 0, 0);
  end;
  /// ѭ������
  SetSpinCount(dwSpinCount);
end;

destructor TOptex.Destroy();
begin
  /// �����̶���,�������߳�ӵ����ʱ,�����ͷ�,��ǿ���˳�
  if IsSingleProcessOptex() and (m_psi.m_dwThreadId <> 0) then
    Exit;
  /// ����̶���. �����߳�ӵ����ʱ,�����ͷ�
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
  // �ദ��������
  if (sm_fUniprocessorHost = 0) then
    InterlockedExchange(Integer(m_psi.m_dwSpinCount), Integer(dwSpinCount));
end;

procedure TOptex.Enter;
var
  dwThreadId: DWORD;
begin
  /// ѭ�����ѳɹ�����
  if TryEnter then
    Exit;
  ///��ȡ��ǰ�����ø������߳�ID
  dwThreadId := GetCurrentThreadId;
  /// û���߳�ӵ�и���,��ʱm_lLockCount���һ������
  if (InterlockedIncrement(m_psi.m_lLockCount) = 1) then
  begin
    m_psi.m_dwThreadId := dwThreadId;
    m_psi.m_lRecurseCount := 1;
  end
  else
  begin
    /// ӵ��������֮ǰ���߳�,����ȴ�
    if (m_psi.m_dwThreadId = dwThreadId) then
    begin
      /// ����ӵ�м���
      Inc(m_psi.m_lRecurseCount);
    end
    else
    begin
      /// �ȴ������߳��뿪
      WaitForSingleObject(m_hevt, INFINITE);
      /// ��ʱ�ſ�ӵ�ж���
      m_psi.m_dwThreadId := dwThreadId;
      m_psi.m_lRecurseCount := 1;
    end;
  end;
end;

function TOptex.TryEnter: Boolean;
var
  dwThreadId, dwSpinCount: DWORD;
begin
  ///��ȡ��ͼӵ�и������߳�ID
  dwThreadId := GetCurrentThreadId();
  /// ��ȡѭ��������
  dwSpinCount := m_psi.m_dwSpinCount;
  repeat
    /// �� m_lLockCount = 0, �� m_lLockCount := 1, �� Result = TRUE m_psi.m_lLockCount
    Result := (InterlockedCompareExchange(m_psi.m_lLockCount, 1, 0) = 0);
    /// ��δ��ӵ��
    if (Result) then
    begin
      m_psi.m_dwThreadId := dwThreadId;
      m_psi.m_lRecurseCount := 1;
    end
    else
    begin
      if (m_psi.m_dwThreadId = dwThreadId) then
      begin
        InterlockedIncrement(m_psi.m_lLockCount);   ///����
        Inc(m_psi.m_lRecurseCount);
        Result := True;
      end;
    end;
    ///����ѭ������������˳�dwSpinCount=(0 -1)=$FFFFFFFF
    Dec(dwSpinCount);
  until (Result) or (dwSpinCount = $FFFFFFFF);
end;

procedure TOptex.Leave;
begin
  if (GetCurrentThreadId <> m_psi.m_dwThreadId) then
    Exit;
  /// �������ü���
  Dec(m_psi.m_lRecurseCount);
  if (m_psi.m_lRecurseCount > 0) then
  begin
    /// ��Ȼӵ�ж���
    InterlockedDecrement(m_psi.m_lLockCount);
  end
  else
  begin
    /// ����ӵ�ж���,���ٽ�����������������߳�
    m_psi.m_dwThreadId := 0;
    if (InterlockedDecrement(m_psi.m_lLockCount) > 0) then
      SetEvent(m_hevt);
  end;
end;

end.


