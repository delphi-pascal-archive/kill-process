unit vkill;

interface

uses
  Windows,SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, tlhelp32, ExtCtrls, psapi, WinSVC, ext,
  adCpuUsage;

{$R XPManifest.res}

function OpenThread(dwDesiredAccess: DWORD;
                    bInheritHandle: BOOL;
                    dwThread: DWORD): SC_HANDLE;  external 'kernel32.dll';

type
  TMain = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    ListView2: TListView;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    StatusBar1: TStatusBar;
    CheckBox1: TCheckBox;
    Button2: TButton;
    Label5: TLabel;
    Label6: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
        
type
   TEXEInfo = record
     name:    String;
     place:   String;
     size:    Longint;
   end;

type
   TProcessInfo = record
     name: String;
     priority: DWORD;
     location: String;
     size: Longint;
   end;

var
  Main: TMain;
  prcss,exs: Integer;
  b: Boolean;

const
  MAX_PROCESSES = 256;
  PROCESS_TERMINATE = $0001;
  PRC_SERVICE: String = '<SERVICE>';

const
  SERVICE_CANT_STOP           = 2;
  SERVICE_CANT_GET_INFO       = 4;
  SERVICE_CANT_OPEN           = 8;
  SERVICE_CANT_ENUMERATE      = 16;
  SERVICE_CANT_ACCESS_MANAGER = 32;
  SERVICE_NO_MEMORY           = 64;
  SERVICE_NOT_FOUND           = 100;
  SERVICE_GENERAL_ERROR       = 128;

var
  exe,collect: array [1..MAX_PROCESSES] of TEXEInfo;
  ProcCount: Integer;
  areNT: Boolean;

implementation

uses execform, wait;

{$R *.DFM}

function NTGetPathOfExe(nm: String): String;
var
  i: Integer;
begin
   for i := 1 to ProcCount do
   if LowerCase(collect[i].name) = LowerCase(nm) then
   begin
     result:=collect[i].place;
     break;
   end;
end;

procedure CollectPathsOfExe;
var
  PIDArray: array [0..1023] of DWORD;
  cb: DWORD;
  I: Integer;
  hMod: HMODULE;
  hProcess: THandle;
  pstr: array [0..255] of Char;
  ModuleName: array [0..300] of Char;
begin
  try
    EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
    ProcCount := cb div SizeOf(DWORD);
    for i := 1 to ProcCount do
    begin
      hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PIDArray[I]);
      if (hProcess <> 0) then begin
        EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
        GetModuleBaseName(hProcess,hMod,@pstr,SizeOf(pstr));
        GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
        collect[i].name:=pstr;
        collect[i].place:=ModuleName;
        CloseHandle(hProcess);
      end;
    end;
  except
  end;
end;

procedure FillInfo(var s: TProcessInfo; pr: TProcessEntry32);
begin
  s.name:=ExtractFileName(pr.szExeFile);
  s.priority:=pr.th32ProcessID;
  if b then
    s.location:=NTGetPathOfExe(s.name)
  else
    s.location:=LowerCase(pr.szExeFile);
  s.size:=GetFileSizeByName(s.location);
  if s.size = -1 then s.location:=PRC_SERVICE;
end;

function VEnumProcesses(LV: TListView): Integer;
var
  pr: TProcessEntry32;
  hss: THandle;
  loop: BOOL;
  ff, i: Integer;
  s: array [1..MAX_PROCESSES] of TProcessInfo;
begin
  pr.dwSize:=SizeOf(ProcessEntry32);
  hss:=CreateToolhelp32Snapshot(TH32CS_SNAPALL,0);
  if not BOOL(hss) then begin
                   result:=-1;
                   exit
                   end;
  try
    ff:=0;
    if b then CollectPathsOfExe;
    loop:=Process32First(hss, pr);
    while loop do
    begin
      loop:=Process32Next(hss, pr);
      if loop then begin
              inc(ff);
              FillInfo(s[ff],pr);
      end;
    end;

    repeat
      if LV.Items.Count > ff then
         LV.Items[ff].Delete;
      if LV.Items.Count < ff then
         LV.Items.Add.Caption:='';
    until ff = LV.Items.Count;

    for i:=1 to ff do
    with LV.Items.Item[i-1] do
    begin
       Caption:=s[i].name;
       if Subitems.Count = 0 then begin
          Subitems.Add(IntToStr(s[i].priority));
          Subitems.Add(s[i].location);
          if s[i].size <> -1 then
            Subitems.Add(IntToStr(s[i].size div 1024)+'kb')
          else
            Subitems.Add('--');
       end else begin
          Subitems.Strings[0]:=(IntToStr(s[i].priority));
          Subitems.Strings[1]:=(s[i].location);
          if s[i].size <> -1 then
            Subitems.Strings[2]:=(IntToStr(s[i].size div 1024)+'kb')
          else
            Subitems.Strings[2]:=('--');
       end;
    end;

    result:=ff;
  except
    result:=-1;
  end;
  CloseHandle(hss);
end;

procedure WINKillProcess(prc: String);
var
  pr: TProcessEntry32;
  hss: THandle;
  loop: BOOL;
  hProcess: THandle;
  p_k: Boolean;
begin
  pr.dwSize:=SizeOf(ProcessEntry32);
  hss:=CreateToolhelp32Snapshot(TH32CS_SNAPALL,0);
  if not BOOL(hss) then exit;

  try
    loop:=Process32First(hss, pr);

    while loop do
    begin
      loop:=Process32Next(hss, pr);
      if loop then
      begin
        if LowerCase(ExtractFileName(pr.szExeFile)) = LOwerCase(prc) then
        begin
          hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,pr.th32ProcessID);
          if hProcess = 0 then begin
             Main.StatusBar1.Panels[0].Text:='Не могу открыть процесс';
             CloseHandle(hss);
             exit;
          end;

          p_k:=TerminateProcess(hProcess,0);

          if p_k then
             Main.StatusBar1.Panels[0].Text:='Процесс убит'
          else
             Main.StatusBar1.Panels[0].Text:='Невозможно завершить процесс';
          CloseHandle(hProcess);
        end
      end
    end;

  except
     Main.StatusBar1.SimpleText:='error!';
  end;
  CloseHandle(hss);
end;


procedure TMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Interval:=TrackBar1.Position*1000;
  Timer1.Enabled:=false;

  CollectCPUData;
  StatusBar1.Panels[1].Text:='Загрузка ЦП: '+
                             FloatToStr(Round(GetCPUUsage(0)*100))+'%';

  Label6.Caption:=HowManyWinStartUp;
  if CheckBox1.Checked then
  with ListView2.Items do begin
    BeginUpdate;
    prcss:=VEnumProcesses(ListView2);
    Label4.Caption:=IntToStr(prcss);
    EndUpdate;
  end;

  Timer1.Enabled:=true;
end;

procedure TMain.TrackBar1Change(Sender: TObject);
begin
  Label1.Caption:=IntToStr(TrackBar1.Position)+' c';
end;

function KillServiceByName(nm: String): Integer;
var
   schSCManager:  SC_HANDLE;
   enumBuffer: PEnumServiceStatus;
   lpS: Pointer;
   pcbBytesNeeded: DWORD;
   lpServicesReturned: DWORD;
   lpResumeHandle: DWORD;
   dwCurService: DWORD;
   ES, boo: BOOL;
   hService: THandle;
   info: PQueryServiceConfigA;
   need,ret: DWORD;
   QI, found: BOOL;
   pt: _SERVICE_STATUS;
begin
  try
  lpResumeHandle := 0;
  dwCurService := 0;
  result:=0;
  found:=false;

  schSCManager:=OpenSCManager(nil,nil,SC_MANAGER_ENUMERATE_SERVICE);

  if schSCManager = 0 then
  begin
    result:=SERVICE_CANT_ACCESS_MANAGER;
    exit;
  end;

  lpS := HeapAlloc(GetProcessHeap, 0, 65535);

  if lpS = nil then
  begin
    result:=SERVICE_NO_MEMORY;
    CloseServiceHandle(schSCManager);
    exit;
  end;

  while true do
  begin
    lpResumeHandle := dwCurService;
    enumBuffer := lpS;

    ES:=EnumServicesStatus(schSCManager, SERVICE_WIN32,
                           SERVICE_ACTIVE,
                           enumBuffer^,65535,pcbBytesNeeded,
                           lpServicesReturned,lpResumeHandle);
    if ES = false then
    begin
       result:=SERVICE_CANT_ENUMERATE;
       break;
    end;

    inc(dwCurService);

    hService:=OpenService(schSCManager,enumBuffer.lpServiceName,
                          SERVICE_ALL_ACCESS);

    if hService = 0 then
    begin
      result:=SERVICE_CANT_OPEN;
      break;
    end;

    QueryServiceConfig(hService, nil, 0, need);

    info := HeapAlloc(GetProcessHeap, 0, need);
    QI:=QueryServiceConfig(hService,info,need,ret);

    if not QI then
    begin
      result:=SERVICE_CANT_GET_INFO;
      break;
    end;

    if ExtractBaseName(info.lpBinaryPathName) = nm then
    begin
      boo:=ControlService(hService,SERVICE_CONTROL_STOP,pt);
      if not boo then result:=SERVICE_CANT_STOP;
      found:=true;

      CloseServiceHandle(hService);
      break;
    end;

    CloseServiceHandle(hService);

    if lpResumeHandle <> 0 then
    begin
      result:=0;
      break;
    end;
  end;

  if not found then
    result:=SERVICE_NOT_FOUND;

  CloseServiceHandle(schSCManager);
  except
    result:=SERVICE_GENERAL_ERROR;
  end;
end;

procedure NTKillService(name: String);
var
  res: Integer;
begin
   Form1.Show;
   Application.ProcessMessages;
   res:=KillServiceByName(name);
   Form1.Hide;
   if res = 0 then
         Main.StatusBar1.Panels[0].Text:='Сервис убит'
   else
   with Main.StatusBar1.Panels[0] do
   case res of
     SERVICE_CANT_STOP: Text:='Не возможно остановить сервис';
     SERVICE_CANT_GET_INFO: Text:='Не возможно получить данные сервиса';
     SERVICE_CANT_OPEN: Text:='Нет доступа к сервису';
     SERVICE_CANT_ENUMERATE: Text:='Нет доступа к перечислению сервисов';
     SERVICE_CANT_ACCESS_MANAGER: Text:='Нет доступа к БД сервисов';
     SERVICE_NO_MEMORY: Text:='Не хватает памяти для завершения!';
     SERVICE_NOT_FOUND: Text:='Сервис не найден!';
     SERVICE_GENERAL_ERROR: Text:='Завершение невозможно, общая ошибка';
   end;
end;

procedure TMain.Button1Click(Sender: TObject);
begin
  with ListView2.Selected do
  if ListView2.Selected <> nil then
  begin
    if Caption <> '' then
    begin
      if b and (SubItems.Strings[1] = PRC_SERVICE) then
        NTKillService(Caption)
      else
        WINKillProcess(Caption);
    end
  end
  else
  MessageBox(Main.Handle,'Сперва выберите процесс из списка', 'error',MB_ICONSTOP);
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  IsNT(b);
  Timer1Timer(self);
  Label4.Caption:=IntToStr(prcss);
  Label5.Caption:=WhenWinStartUp;
  Form1:=TForm1.Create(self);
end;

procedure TMain.FormShow(Sender: TObject);
begin
  with Main do
    SetWindowPos(Handle,HWND_TOPMOST,Left,Top,Width,Height,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TMain.Button2Click(Sender: TObject);
begin
  Exec.Show;
end;

end.
