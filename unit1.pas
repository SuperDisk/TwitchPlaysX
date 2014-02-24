unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Unit2, IRC, VKeys;

type
  TKeyUpEvent = record
    KeyCode: Integer;
    Stale: Integer;
  end;

  TKeyUpSet = array[0..255] of TKeyUpEvent;

  { TForm1 }
  TForm1 = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    TwitchPlaysX: TStaticText;
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ScheduleKeyUp(Key: Integer);

  private
    Form2: TForm2;
    KeyUpSet: TKeyUpSet;
    KeysDownCount: Integer;

  public
    { public declarations }
  end;

function PrintWindow(SourceWindow: hwnd; Destination: hdc; nFlags: cardinal): bool; stdcall; external 'user32.dll' name 'PrintWindow';

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
var
  ActiveWindow: HWND;
  ActiveDC, OurDC: HDC;
  Buffer: HBITMAP;
  WindowRect: RECT;
  W, H, I: Integer;
  Message: TMessage;
  SendKey: Integer;
  KeyUpEvent: TKeyUpEvent;

begin
  Label1.Caption := Self.Form2.Edit1.Text;

  if Form2.WindowListBox.ItemIndex > 0 then begin
    ActiveWindow := Form2.WindowList[Form2.WindowListBox.ItemIndex];

    GetWindowRect(ActiveWindow, @WindowRect);
    W := WindowRect.Right - WindowRect.Left;
    H := WindowRect.Bottom - WindowRect.Top;

    try
      ActiveDC := GetDC(ActiveWindow);
      Buffer := CreateCompatibleBitmap(ActiveDC, W, H);
      OurDC := CreateCompatibleDC(ActiveDC);
      SelectObject(OurDC, Buffer);

      BitBlt(OurDC, 0, 0, W, H, ActiveDC, 0, 0, SRCCOPY);

    finally
      DeleteDC(OurDC);
      ReleaseDC(ActiveWindow, ActiveDC);
      DeleteObject(Image1.Picture.Bitmap.Handle);
    end;

    Image1.Picture.Bitmap.Handle := Buffer;
  end;

  //Keyup all of the previous keypresses
  for I := KeysDownCount downto 0 do begin
    KeyUpEvent := KeyUpSet[I];
    if KeyUpEvent.Stale = 0 then begin
      SendMessage(ActiveWindow, WM_KEYUP, KeyUpEvent.KeyCode, 0);
      WriteLn('Decreasing keysdowncount');
      KeysDownCount -= 1;
    end
    else begin
      KeyUpEvent.Stale -= 1;
      Writeln('decreasting stale ' + IntToStr(KeyUpEvent.Stale));
      KeyUpSet[I] := KeyUpEvent;
    end;
  end;

  if Form2.ConnectToggle.Checked then begin
    Form2.IRC.Listen;
    while Form2.IRC.HasMessages do begin
    	Message := Form2.IRC.GetMessage;
      if (Form2.CharMapListBox.Items.IndexOf(UpperCase(Message.Content)) <> -1) then begin
    		Memo1.Append(Message.Sender + ': ' + Message.Content);
        SendKey := VKMap[Form2.CharMap[UpperCase(Message.Content)]];
        Writeln('Posting ' + Message.Content + ' | ' + IntToStr(SendKey));
				SendMessage(ActiveWindow, WM_KEYDOWN, SendKey, 0);

        ScheduleKeyUp(SendKey);
      end;
    end;
  end;

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AllocConsole;      // in Windows unit
  IsConsole := True; // in System unit
  SysInitStdIO;

  Self.Form2 := TForm2.Create(Nil);
  Self.Form2.Show;

  Self.Form2.ReloadWindows;
  KeysDownCount := -1;
end;

procedure TForm1.ScheduleKeyUp(Key: Integer);
var
  KUp: TKeyUpEvent;
begin
  KUp.KeyCode := Key;
  KUp.Stale := 25;

  KeysDownCount += 1;
  KeyUpSet[KeysDownCount] := KUp;
end;

end.

