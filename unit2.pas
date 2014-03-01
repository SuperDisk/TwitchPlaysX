unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, WindowFinder, FGL, Windows, VKeys, IRC, INIfiles;

type
  THWNDList = Specialize TFPGList<HWND>;
  TCharMap = Specialize TFPGMap<String, String>;
  TReverseCharMap = Specialize TFPGMap<String, String>;
  TControlMode = (Anarchy, Democracy);

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    SaveButton: TButton;
    Button3: TButton;
    Button4: TButton;
    LoadButton: TButton;
    CheckBox1: TCheckBox;
    ConnectToggle: TToggleBox;
    AnarchyRadioButton: TRadioButton;
    DemocracyRadioButton: TRadioButton;
    RadioGroup1: TRadioGroup;
    SaveDialog1: TSaveDialog;
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
    procedure AnarchyRadioButtonChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CharMapListBoxSelectionChange(Sender: TObject; User: boolean);
    procedure CheckBox1Change(Sender: TObject);
    procedure ConnectToggleChange(Sender: TObject);
    procedure DemocracyRadioButtonChange(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
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

uses Unit1;

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
    if AnarchyRadioButton.Checked then ControlMode := Anarchy
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

procedure TForm2.DemocracyRadioButtonChange(Sender: TObject);
begin
  if DemocracyRadioButton.Checked then begin
    ControlMode := Democracy;
    TForm1(Owner).DemocracyModeSwitch;
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

procedure TForm2.AnarchyRadioButtonChange(Sender: TObject);
begin
  if AnarchyRadioButton.Checked then begin
    ControlMode := Anarchy;
    TForm1(Owner).AnarchyModeSwitch;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  CharMap := TCharMap.Create;
  IRC := TIRCClient.Create(IpFromHostName('irc.twitch.tv'));
  ControlMode := Anarchy;
end;

procedure TForm2.LoadButtonClick(Sender: TObject);
var
  FileName, WinTitle, ModeStr: String;
  INI: TINIFile;
  I: Integer;
  ValList, KeyVal: TStringList;
begin
  OpenDialog1.Execute;
  FileName := OpenDialog1.FileName;

  INI := TINIFile.Create(FileName, False);

  Edit1.Text := INI.ReadString('TPX', 'GameName', '');
  WinTitle := INI.ReadString('TPX', 'WindowTitle', '');

  if (WinTitle <> 'NIL') and (WindowListBox.Items.IndexOf(WinTitle) <> 0) then
    WindowListBox.ItemIndex := WindowListBox.Items.IndexOf(WinTitle);

  CheckBox1.Checked := StrToBool(INI.ReadString('TPX', 'AllowModeSwitch', 'False'));

  ModeStr := INI.ReadString('TPX', 'Mode', 'Anarchy');
  if ModeStr = 'Anarchy' then Form2.AnarchyRadioButton.Checked := True;
  if ModeStr = 'Democracy' then Form2.DemocracyRadioButton.Checked := True;

  Edit2.Text := INI.ReadString('IRC', 'Channel', '');

  ValList := TStringList.Create;
  INI.ReadSectionValues('KEYMAPS', ValList);

  for I := 0 to ValList.Count-1 do begin
    Split(ValList[I], '=', KeyVal);
    WriteLN(ValList[I]);
  end;

  INI.Free;
end;

procedure TForm2.SaveButtonClick(Sender: TObject);
var
  FileName: String;
  INI: TINIFile;
  I: Integer;
begin
  SaveDialog1.Execute;
  FileName := SaveDialog1.FileName;

  INI := TINIFile.Create(FileName, False);

  INI.WriteString('TPX', 'GameName', Edit1.Text);
  if WindowListBox.ItemIndex > 0 then
    INI.WriteString('TPX', 'WindowTitle', WindowListBox.Items[WindowListBox.ItemIndex])
  else INI.WriteString('TPX', 'WindowTitle', 'NIL');

  INI.WriteString('TPX', 'AllowModeSwitch', BoolToStr(CheckBox1.Checked));

  if AnarchyRadioButton.Checked then INI.WriteString('TPX', 'Mode', 'Anarchy');
  if DemocracyRadioButton.Checked then INI.WriteString('TPX', 'Mode', 'Democracy');

  INI.WriteString('IRC', 'Channel', Edit2.Text);

  for I := 0 to CharMapListBox.Items.Count-1 do
    INI.WriteString('KEYMAPS', CharMapListBox.Items[I], CharMap[CharMapListBox.Items[I]]);

  INI.Free;
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

