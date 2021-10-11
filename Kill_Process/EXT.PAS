unit ext;

interface

uses
  Windows, Sysutils;

function IsNT(var Value: Boolean): Boolean;
function GetFileSizeByName(FileName: String): Integer;
function WhenWinStartUp: String;
function HowManyWinStartUp: String;
function ExtractBaseName(fullpath: String): String;

implementation

function IsNT(var Value: Boolean): Boolean;
var Ver: TOSVersionInfo;
    BRes: Boolean;
begin
  Ver.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  BRes := GetVersionEx(Ver);
  if not BRes then
  begin
    Result := False;
    Exit;
  end else
    Result := True;

  case Ver.dwPlatformId of
    VER_PLATFORM_WIN32_NT       : Value := True;  //Windows NT - подходит
    VER_PLATFORM_WIN32_WINDOWS  : Value := False; //Windows 9x-Me - подходит
    VER_PLATFORM_WIN32s         : Result := False //Windows 3.x - не подходит
  end;
end;

function GetFileSizeByName(FileName: String): Integer;
var
  FindData: TWin32FindData;
  hFind: THandle;
begin
  Result := -1;
  hFind := FindFirstFile(PChar(FileName), FindData);
  if hFind <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(hFind);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.nFileSizeLow;
  end;
end;

function WhenWinStartUp: String;
var
  ndays: Double;
  ticks: LongInt;
  btime: TDateTime;
begin
  ticks := GetTickCount;
  ndays := ticks / 86400000;
  bTime := now-ndays;

  result:=FormatDateTime('"Windows стартовала в" dddd, mmmm d, yyyy, ' +
                         '"в" hh:nn:ss AM/PM', bTime);
end;

function HowManyWinStartUp: String;
var
  ndays: Double;
  ticks: LongInt;
  btime: TDateTime;
begin
  ticks := GetTickCount;
  ndays := ticks / 86400000;
  bTime := now-ndays;

  result:='Прошло времени: ' + IntToStr(Trunc(nDays)) + ' дней,' +
          FormatDateTime(' h "часов," n "минут," s "секунд"',ndays)
end;

function ExtractBaseName(fullpath: String): String;
var
  nm: String;
  ps: Integer;
begin
  nm:=ExtractFileName(fullpath);
  ps:=pos('.',nm);
  nm:=copy(nm,0,ps+3);
  while nm[Length(nm)] = ' ' do
    Delete(nm,Length(nm),1);
  result:=nm;
end;

end.
 