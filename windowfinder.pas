unit WindowFinder;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows;

type
  TWinList = array[0..1000] of HWND;

function GetWindows: TWinList;
function GetWindowName(hound: HWND): String;

implementation

var
  WinList: TWinList;
  Counter: Integer;

function EnumWindowsCallback(hound: HWND; lp: LPARAM): LongBool; stdcall;
begin
  WinList[Counter] := hound;
  Counter += 1;
  EnumWindowsCallback := True;
end;

function GetWindows: TWinList;
begin
  Counter := 0;
  EnumWindows(@EnumWindowsCallback, 0);
  GetWindows := WinList;
end;

function GetWindowName(hound: HWND): String;
var
  Output: PChar;
  ReturnVal: String;
begin
  GetMem(Output, 9999);
  GetWindowText(hound, Output, 999999);
  ReturnVal := String(Output);
  FreeMem(Output);
  GetWindowName := ReturnVal;
end;

end.

