object DBModule: TDBModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 513
  Width = 920
  object ADOStoredProc1: TADOStoredProc
    Parameters = <>
    Left = 104
    Top = 80
  end
  object cm1: TComm
    CommName = 'COM5'
    BaudRate = 115200
    ParityCheck = False
    Outx_CtsFlow = False
    Outx_DsrFlow = False
    DtrControl = DtrEnable
    DsrSensitivity = False
    TxContinueOnXoff = True
    Outx_XonXoffFlow = True
    Inx_XonXoffFlow = True
    ReplaceWhenParityError = False
    IgnoreNullChar = False
    RtsControl = RtsEnable
    XonLimit = 500
    XoffLimit = 500
    ByteSize = _8
    Parity = None
    StopBits = _1
    XonChar = #17
    XoffChar = #19
    ReplacedChar = #0
    ReadIntervalTimeout = 100
    ReadTotalTimeoutMultiplier = 0
    ReadTotalTimeoutConstant = 0
    WriteTotalTimeoutMultiplier = 0
    WriteTotalTimeoutConstant = 0
    Left = 489
    Top = 144
  end
  object ADOQuery1: TADOQuery
    Parameters = <>
    Left = 104
    Top = 168
  end
  object ADOConnection1: TADOConnection
    Provider = 'MSDASQL.1'
    Left = 104
    Top = 256
  end
  object ADOConnection2: TADOConnection
    ConnectionString = 
      'Provider=MSDAORA.1;Password=limsadmin;User ID=limsv4;Data Source' +
      '=orcl;Persist Security Info=True'
    LoginPrompt = False
    Provider = 'MSDAORA.1'
    Left = 592
    Top = 208
  end
end
