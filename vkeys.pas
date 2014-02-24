unit VKeys;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, FGL;

type
  TVKMap = Specialize TFPGMap<String, Integer>;

var
  VKMap: TVKMap;

implementation

begin
  VKMap := TVKMap.Create;
  VKMap.Add('0', VK_0);
  VKMap.Add('1', VK_1);
  VKMap.Add('2', VK_2);
  VKMap.Add('3', VK_3);
  VKMap.Add('4', VK_4);
  VKMap.Add('5', VK_5);
  VKMap.Add('6', VK_6);
  VKMap.Add('7', VK_7);
  VKMap.Add('8', VK_8);
  VKMap.Add('9', VK_9);
  VKMap.Add('A', VK_A);
  VKMap.Add('ADD', VK_ADD);
  VKMap.Add('B', VK_B);
  VKMap.Add('BACK', VK_BACK);
  VKMap.Add('C', VK_C);
  VKMap.Add('CANCEL', VK_CANCEL);
  VKMap.Add('CAPITAL', VK_CAPITAL);
  VKMap.Add('CLEAR', VK_CLEAR);
  VKMap.Add('CONTROL', VK_CONTROL);
  VKMap.Add('CONVERT', VK_CONVERT);
  VKMap.Add('D', VK_D);
  VKMap.Add('DECIMAL', VK_DECIMAL);
  VKMap.Add('DELETE', VK_DELETE);
  VKMap.Add('DIVIDE', VK_DIVIDE);
  VKMap.Add('DOWN', VK_DOWN);
  VKMap.Add('E', VK_E);
  VKMap.Add('END', VK_END);
  VKMap.Add('ESCAPE', VK_ESCAPE);
  VKMap.Add('F', VK_F);
  VKMap.Add('F1', VK_F1);
  VKMap.Add('F10', VK_F10);
  VKMap.Add('F11', VK_F11);
  VKMap.Add('F12', VK_F12);
  VKMap.Add('F13', VK_F13);
  VKMap.Add('F14', VK_F14);
  VKMap.Add('F15', VK_F15);
  VKMap.Add('F16', VK_F16);
  VKMap.Add('F17', VK_F17);
  VKMap.Add('F18', VK_F18);
  VKMap.Add('F19', VK_F19);
  VKMap.Add('F2', VK_F2);
  VKMap.Add('F20', VK_F20);
  VKMap.Add('F21', VK_F21);
  VKMap.Add('F22', VK_F22);
  VKMap.Add('F23', VK_F23);
  VKMap.Add('F24', VK_F24);
  VKMap.Add('F3', VK_F3);
  VKMap.Add('F4', VK_F4);
  VKMap.Add('F5', VK_F5);
  VKMap.Add('F6', VK_F6);
  VKMap.Add('F7', VK_F7);
  VKMap.Add('F8', VK_F8);
  VKMap.Add('F9', VK_F9);
  VKMap.Add('G', VK_G);
  VKMap.Add('H', VK_H);
  VKMap.Add('HOME', VK_HOME);
  VKMap.Add('I', VK_I);
  VKMap.Add('INSERT', VK_INSERT);
  VKMap.Add('J', VK_J);
  VKMap.Add('K', VK_K);
  VKMap.Add('L', VK_L);
  VKMap.Add('LBUTTON', VK_LBUTTON);
  VKMap.Add('LCONTROL', VK_LCONTROL);
  VKMap.Add('LEFT', VK_LEFT);
  VKMap.Add('LMENU', VK_LMENU);
  VKMap.Add('LSHIFT', VK_LSHIFT);
  VKMap.Add('LWIN', VK_LWIN);
  VKMap.Add('M', VK_M);
  VKMap.Add('MBUTTON', VK_MBUTTON);
  VKMap.Add('MULTIPLY', VK_MULTIPLY);
  VKMap.Add('N', VK_N);
  VKMap.Add('NUMLOCK', VK_NUMLOCK);
  VKMap.Add('NUMPAD0', VK_NUMPAD0);
  VKMap.Add('NUMPAD1', VK_NUMPAD1);
  VKMap.Add('NUMPAD2', VK_NUMPAD2);
  VKMap.Add('NUMPAD3', VK_NUMPAD3);
  VKMap.Add('NUMPAD4', VK_NUMPAD4);
  VKMap.Add('NUMPAD5', VK_NUMPAD5);
  VKMap.Add('NUMPAD6', VK_NUMPAD6);
  VKMap.Add('NUMPAD7', VK_NUMPAD7);
  VKMap.Add('NUMPAD8', VK_NUMPAD8);
  VKMap.Add('NUMPAD9', VK_NUMPAD9);
  VKMap.Add('O', VK_O);
  VKMap.Add('P', VK_P);
  VKMap.Add('PA1', VK_PA1);
  VKMap.Add('Q', VK_Q);
  VKMap.Add('R', VK_R);
  VKMap.Add('RBUTTON', VK_RBUTTON);
  VKMap.Add('RCONTROL', VK_RCONTROL);
  VKMap.Add('RETURN', VK_RETURN);
  VKMap.Add('RIGHT', VK_RIGHT);
  VKMap.Add('RMENU', VK_RMENU);
  VKMap.Add('RSHIFT', VK_RSHIFT);
  VKMap.Add('RWIN', VK_RWIN);
  VKMap.Add('S', VK_S);
  VKMap.Add('SCROLL', VK_SCROLL);
  VKMap.Add('SELECT', VK_SELECT);
  VKMap.Add('SHIFT', VK_SHIFT);
  VKMap.Add('SPACE', VK_SPACE);
  VKMap.Add('SUBTRACT', VK_SUBTRACT);
  VKMap.Add('T', VK_T);
  VKMap.Add('TAB', VK_TAB);
  VKMap.Add('U', VK_U);
  VKMap.Add('UP', VK_UP);
  VKMap.Add('V', VK_V);
  VKMap.Add('W', VK_W);
  VKMap.Add('X', VK_X);
  VKMap.Add('XBUTTON1', VK_XBUTTON1);
  VKMap.Add('XBUTTON2', VK_XBUTTON2);
  VKMap.Add('Y', VK_Y);
  VKMap.Add('Z', VK_Z);
end.

