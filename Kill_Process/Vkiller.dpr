program vkiller;

uses
  Forms,
  ext,
  Windows,
  vkill in 'vkill.pas' {Main},
  execform in 'execform.pas' {Exec},
  wait in 'wait.pas' {Form1};

{$R *.RES}

var
  vl: Boolean;
begin
  if not IsNT(vl) then
  begin
    MessageBox(0,'Very old Windows version','error',MB_ICONSTOP);
    PostQuitMessage(0);
  end;
  Application.Initialize;
  Application.Title:='VKSoft - vkiller 1.0';
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TExec, Exec);
  Application.Run;
end.
