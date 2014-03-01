unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Windows, Unit2, IRC, VKeys, FGL;

type
  TKeyUpEvent = record
    KeyCode: Integer;
    Stale: Integer;
  end;

  TKeyUpSet = array[0..255] of TKeyUpEvent;
  TKeyVoteMap = specialize TFPGMap<String, Integer>;

  { TForm1 }
  TForm1 = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    TwitchPlaysX: TStaticText;
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    Form2: TForm2;
    KeyUpSet: TKeyUpSet;
    KeysDownCount: Integer;
    ModeVotes: Integer;
    VoteMap: TKeyVoteMap;

  public
    procedure ScheduleKeyUp(Key: Integer);
    procedure VoteFor(Key: String);
    procedure AnarchyModeSwitch;
    procedure DemocracyModeSwitch;
    procedure RefreshDemocracyBox;
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

        //Execute immediately if in anarchy mode
				if Form2.AnarchyRadioButton.Checked then begin
          SendMessage(ActiveWindow, WM_KEYDOWN, SendKey, 0);
          ScheduleKeyUp(SendKey);
        end;

        //Add to vote list if in democracy mode
        if Form2.DemocracyRadioButton.Checked then begin
          VoteFor(UpperCase(Message.Content));
        end;
      end;
    end;
  end;

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Form2 := TForm2.Create(Self);
  Self.Form2.Show;

  Self.Form2.ReloadWindows;
  KeysDownCount := -1;

  VoteMap := TKeyVoteMap.Create;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  //Democracy vs anarchy
  PaintBox1.Canvas.Pen.Color := clGray;
  PaintBox1.Canvas.Brush.Color := clGray;
  PaintBox1.Canvas.Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);
  PaintBox1.Canvas.TextOut(5, 5, 'A');
  PaintBox1.Canvas.TextOut(PaintBox1.Width-14, 5, 'D');
  //PaintBox1.Canvas.Pen.Mode := pmXOR;
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

procedure TForm1.Timer1Timer(Sender: TObject);
var
  HighestVotes, I, Votes, SendKey: Integer;
  Command: String;
  ActiveWindow: HWND;
begin
  if Form2.WindowListBox.ItemIndex > 0 then begin
    try
      ActiveWindow := Form2.WindowList[Form2.WindowListBox.ItemIndex];

      //Execute most commonly voted for thing
      for I := 0 to VoteMap.Count-1 do begin
        if VoteMap.Data[I] > HighestVotes then begin
          HighestVotes := VoteMap.Data[I];
          Command := VoteMap.Keys[I];
        end;
      end;

      SendKey := VKMap[Form2.CharMap[Command]];

      //Send the key
      SendMessage(ActiveWindow, WM_KEYDOWN, SendKey, 0);
      ScheduleKeyUp(SendKey);

      Memo1.Append(Command + ' performed');

      //Clear out old democracy votes
      VoteMap.Free;
      VoteMap := TKeyVoteMap.Create;

    except
      on EInvalidPointer do Form2.WindowListBox.ItemIndex := -1;
    end;
  end;
end;

procedure TForm1.VoteFor(Key: String);
begin
  if VoteMap.IndexOf(Key) <> -1 then
    VoteMap[Key] := VoteMap[Key] + 1
  else VoteMap.Add(Key, 1);

  RefreshDemocracyBox;
end;

procedure TForm1.AnarchyModeSwitch;
begin
  Timer1.Enabled := False;
  Memo2.Top := Memo2.Top + Memo2.Height;
end;

procedure TForm1.DemocracyModeSwitch;
begin
  Timer1.Enabled := True;
  Memo2.Top := Memo2.Top - Memo2.Height;
end;

procedure TForm1.RefreshDemocracyBox;
var
  I: Integer;
begin
  Memo1.Text := '';
  for I := 0 to VoteMap.Count-1 do begin
    Memo1.Append(VoteMap.Keys[I] + ': ' + IntToStr(VoteMap.Data[I]));
  end;
end;

end.

