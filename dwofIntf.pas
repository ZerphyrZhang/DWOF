{ Invokable interface Idwof }

unit dwofIntf;

interface

uses
  Soap.InvokeRegistry, System.Types, Soap.XSBuiltIns, System.Classes, System.Generics.Collections;

type

  { Invokable interfaces must derive from IInvokable }
  Idwof = interface(IInvokable)
    ['{FD8953DC-A4B6-4FBF-86A0-EC01B2EC758B}']
    function _A4B64FBF(pJson: string; pSession: string): string; //新增
    function _B8C6FFBE(pJson: string; pSession: string): string; //修改
    function _A5D2BE4F(pJson: string; pSession: string): string; //删除
    function _C12DBE4F(pJson: string; pSession: string): string; //多笔查询
    function _B1C6FFBE(pJson: string; pSession: string): string; //单笔查询
    function _E4A5D2BA(pJson: string): string; //登录
    function _D112DBCD(PJson: string; pSession: string): string; //存储过程
    function _EC12DB3D(PJson: string): string; //获取目录

    function _EC12DB3E(PJson: string; pSession: string): string; //do_seltables
    function _EC12DB3F(PJson: string; pSession: string): string; //do_selindexs
    function _EC12DB3S(PJson: string; pSession: string): string; //do_selfields

    function _EC12DB3T(PJson: string; pSession: string): string; //do_tabfields

    function _EC12DB3R(PJson: string; pSession: string): string; //do_exprot
    function _EC12DB4R(PJson: string; pSession: string): string; //do_files

    { Methods of Invokable interface must not use the default }
    { calling convention; stdcall is recommended }
  end;

implementation

initialization
  { Invokable interfaces must be registered }
  InvRegistry.RegisterInterface(TypeInfo(Idwof));

end.

