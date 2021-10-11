unit wait;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormActivate(Sender: TObject);
begin
  with Form1 do
    SetWindowPos(Handle,HWND_TOPMOST,Left,Top,Width,Height,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

end.
