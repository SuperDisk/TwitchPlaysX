unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Windows, Unit2, IRC, VKeys;

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
    PaintBox1: TPaintBox;
    TwitchPlaysX: TStaticText;
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ScheduleKeyUp(Key: Integer);

  private
    Form2: TForm2;
    KeyUpSet: TKeyUpSet;
    KeysDownCount: Integer;
    ModeVotes: Integer;

  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
var
  ActiveWindow: HWND;
  ActiveDC: HDC;
  WindowRect: RECT;
  W, H, I: Integer;
  Message: TMessage;
  SendKey: Integer;
  KeyUpEvent: TKeyUpEvent;

begin
  Label1.Caption := Self.Form2.Edit1.Text;
  PaintBox1.Visible := Form2.CheckBox1.Checked;

  if Form2.CheckBox1.Checked then Memo1.AnchorSide[akTop].Control := PaintBox1
  else Memo1.AnchorSide[akTop].Control := Label1;

  if Form2.WindowListBox.ItemIndex > 0 then begin
    ActiveWindow := Form2.WindowList[Form2.WindowListBox.ItemIndex];

    try
    GetWindowRect(ActiveWindow, @WindowRect);
    W := WindowRect.Right - WindowRect.Left;
    H := WindowRect.Bottom - WindowRect.Top;

    Image1.Picture.Bitmap.SetSize(W, H);
    {Image1.Picture.Bitmap.Canvas.Width := W;
    Image1.Picture.Bitmap.Canvas.Height := H;}

    WriteLN(IntToSTr(Image1.Width) + ' ' + inttoStr(image1.height));
    try
      ActiveDC := GetDC(ActiveWindow);
      BitBlt(Image1.Picture.Bitmap.Canvas.Handle, 0, 0, W, H, ActiveDC, 0, 0, SRCCOPY);
      Image1.Refresh;
    finally
      ReleaseDC(ActiveWindow, ActiveDC);
    end;

    except
      on EInvalidPointer do Form2.WindowListBox.ItemIndex := -1;
    end;
  end;

  //Keyup all of the previous keypresses
  for I := KeysDownCount downto 0 do begin
    KeyUpEvent := KeyUpSet[I];
    if KeyUpEvent.Stale = 0 then begin
      SendMessage(ActiveWindow, WM_KEYUP, KeyUpEvent.KeyCode, 0);
      KeysDownCount -= 1;
    end
    else begin
      KeyUpEvent.Stale -= 1;
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
				SendMessage(ActiveWindow, WM_KEYDOWN, SendKey, 0);

        ScheduleKeyUp(SendKey);
      end;
    end;
  end;

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Form2 := TForm2.Create(Nil);
  Self.Form2.Show;

  Self.Form2.ReloadWindows;
  KeysDownCount := -1;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  //Democracy vs anarchy
  PaintBox1.Canvas.Pen.Color := clGray;
  PaintBox1.Canvas.Brush.Color := clGray;
  PaintBox1.Canvas.Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);
  PaintBox1.Canvas.TextOut(5, 5, 'A');
  PaintBox1.Canvas.TextOut(PaintBox1.Width-14, 5, 'D');
  PaintBox1.Canvas.Pen.Mode := pmXOR;
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

