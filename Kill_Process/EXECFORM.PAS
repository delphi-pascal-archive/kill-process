unit execform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellApi;

type
  TExec = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Exec: TExec;

implementation

{$R *.DFM}

procedure TExec.FormShow(Sender: TObject);
begin      with Exec do
    SetWindowPos(Handle,HWND_TOPMOST,Left,Top,Width,Height,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);

  end;

procedure ExecExe(nm: String);
var
  dir, exe: String;
begin
  dir:=ExtractFileDir(nm);
  exe:=ExtractFileName(nm);

  if ShellExecute(0,'open',PChar(exe),nil,
                  PChar(dir),SW_SHOWNORMAL) = 0 then
   ShowMessage('An error occured!');
end;

procedure TExec.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
     Edit1.Text:=OpenDialog1.FileName;
end;

procedure TExec.Button1Click(Sender: TObject);
begin
  ExecExe(Edit1.Text);
  Button2Click(self);
end;

procedure TExec.Button2Click(Sender: TObject);
begin
  Edit1.Text:='';
  Exec.Hide;
end;

procedure TExec.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Button2Click(self);
  Action:=caNone;
end;

procedure TExec.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
     Button1Click(Self);
end;

end.
