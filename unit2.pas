unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, WindowFinder, FGL, Windows, VKeys, IRC;

type
  THWNDList = Specialize TFPGList<HWND>;
  TCharMap = Specialize TFPGMap<String, String>;
  TControlMode = (Anarchy, Democracy);

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    ConnectToggle: TToggleBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioGroup1: TRadioGroup;
    VKeysComboBox: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    CharMapListBox: TListBox;
    WindowListBox: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CharMapListBoxSelectionChange(Sender: TObject; User: boolean);
    procedure CheckBox1Change(Sender: TObject);
    procedure ConnectToggleChange(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
    procedure VKeysComboBoxChange(Sender: TObject);
    procedure WindowListBoxSelectionChange(Sender: TObject; User: boolean);

  private
     CommandsCounter: Integer;
     ControlMode: TControlMode;
     AllowModeSwitching: Boolean;

  public
    IRC: TIRCClient;
    WindowList: THWNDList;
    CharMap: TCharMap;
    procedure ReloadWindows;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button3Click(Sender: TObject);
begin
  ReloadWindows;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  if CharMapListBox.ItemIndex > -1 then begin
    CharMap.Remove(CharMapListBox.Items[CharMapListBox.ItemIndex]);
    CharMapListBox.Items.Delete(CharMapListBox.ItemIndex);
    Edit3.Text := '';
    Edit3.Enabled := False;
    VKeysComboBox.Enabled := False;
    VKeysComboBox.Text := '';
    Button4.Enabled := False;
  end;
end;

procedure TForm2.CharMapListBoxSelectionChange(Sender: TObject; User: boolean);
begin
  if CharMapListBox.ItemIndex > -1 then begin
    Edit3.Text := CharMapListBox.Items[CharMapListBox.ItemIndex];
    Edit3.Enabled := True;
    VKeysComboBox.Enabled := True;
    Button4.Enabled := True;
    VKeysComboBox.ItemIndex := VKeysComboBox.Items.IndexOf(CharMap[Edit3.Text]);
  end
end;

procedure TForm2.CheckBox1Change(Sender: TObject);
begin
  AllowModeSwitching := CheckBox1.Checked;
  RadioGroup1.Enabled := not CheckBox1.Checked;

  if CheckBox1.Checked then ControlMode := Anarchy
  else begin
    if RadioButton1.Checked then ControlMode := Anarchy
    else ControlMode := Democracy;
  end;
end;

procedure TForm2.ConnectToggleChange(Sender: TObject);
begin
  if ConnectToggle.Checked then begin
    ConnectToggle.Caption := 'Connected';
    IRC.Nick := 'superdisk_';
    IRC.PassWord := 'oauth:4pj4n3k8444hw1aanr4ffyqyywg4tp';
		IRC.Connect;
    IRC.Join('#' + LowerCase(Edit2.Text));

    Edit2.Enabled := False;
    Button4.Enabled := False;
    Button1.Enabled := False;
    WindowListBox.Enabled := False;
    Edit3.Enabled := False;
    VKeysComboBox.Enabled := False;
    CharMapListBox.Enabled := False;
    Button3.Enabled := False;
  end;

  if not ConnectToggle.Checked then begin
    ConnectToggle.Caption := 'Connect';
    IRC.Disconnect;
    Edit2.Enabled := True;

    Edit2.Enabled := True;
    Button1.Enabled := True;
    WindowListBox.Enabled := True;
    CharMapListBox.Enabled := True;
    Button3.Enabled := True;
  end;
end;

procedure TForm2.Edit3Change(Sender: TObject);
var
  Caret: TPoint;
begin
  Caret.x := Edit3.CaretPos.X;
  Caret.y := 0;

  Edit3.Text := UpperCase(Edit3.Text);
  Edit3.CaretPos := Caret;
  if Edit3.Text <> '' then begin
    try
      CharMap.Add(Edit3.Text, CharMap[CharMapListBox.Items[CharMapListBox.ItemIndex]]);
      CharMap.Remove(CharMapListBox.Items[CharMapListBox.ItemIndex]);
    except
      on EListError do begin end;
    end;

    CharMapListBox.Items[CharMapListBox.ItemIndex] := Edit3.Text;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  CharMapListBox.Items.Add('COMMAND STRING ' + IntToStr(CommandsCounter));
  CharMap.Add('COMMAND STRING ' + IntToStr(CommandsCounter), '0');
  CommandsCounter += 1;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  CharMap := TCharMap.Create;
  IRC := TIRCClient.Create(IpFromHostName('irc.twitch.tv'));
  ControlMode := Anarchy;
end;

procedure TForm2.RadioButton1Change(Sender: TObject);
begin
  ControlMode := Anarchy;
end;

procedure TForm2.RadioButton2Change(Sender: TObject);
begin
  ControlMode := Democracy;
end;

procedure TForm2.VKeysComboBoxChange(Sender: TObject);
begin
  CharMap[Edit3.Text] := VKeysComboBox.Items[VKeysComboBox.ItemIndex];
end;

procedure TForm2.WindowListBoxSelectionChange(Sender: TObject; User: boolean);
begin
  ConnectToggle.Enabled := True;
end;

procedure TForm2.ReloadWindows;
var
  WinList: TWinList;
  i: Integer;
  WinName: String;

begin
  WindowListbox.Clear;

  if Self.WindowList <> Nil then Self.WindowList.Free;
  Self.WindowList := THWNDList.Create;

  WinList := GetWindows;
  for i := 0 to Length(WinList) do begin
    if WinList[i] <> 0 then begin
      WinName := GetWindowName(WinList[i]);
      if (WinName <> '') and
      (WinName <> 'Tooltip') and
      (WinName <> 'Default IME') and
      (WinName <> 'Msg') and
      (Winname <> 'MSCTFIME UI')
      then begin
        WindowListBox.Items.Add(WinName);
        Self.WindowList.Add(WinList[i]);
      end;
    end;
  end;
end;

end.

