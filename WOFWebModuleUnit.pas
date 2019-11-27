unit WOFWebModuleUnit;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Soap.InvokeRegistry, Soap.WSDLIntf,
  System.TypInfo, Soap.WebServExp, Soap.WSDLBind, Xml.XMLSchema, Soap.WSDLPub,
  Soap.SOAPPasInv, Soap.SOAPHTTPPasInv, Soap.SOAPHTTPDisp, Soap.WebBrokerSOAP;

type
  TWebModule1 = class(TWebModule)
    HTTPSoapDispatcher1: THTTPSoapDispatcher;
    HTTPSoapPascalInvoker1: THTTPSoapPascalInvoker;
    WSDLHTMLPublish1: TWSDLHTMLPublish;
    procedure WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

uses
  CommonUtil;
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  WSDLHTMLPublish1.ServiceInfo(Sender, Request, Response, Handled);
end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  AsTmp: string;
begin
//  Request.
//  _log(Request.From);
end;

end.

