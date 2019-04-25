unit OscWriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils;

type TOscVarType = (StringVar, SystemVar, FloatVar);
type TOscMacroType = (LocalMacro, SystemMacro);

type TOscWriter = class
    private
      Code: string;
      IndentDepth: Integer;
      procedure WriteToken(Content: string);
    public
      Compact: boolean;
      procedure NewLine;
      procedure BeginMacro(Name: string);
      procedure EndMacro;
      procedure BeginIf;
      procedure BeginElse;
      procedure EndIf;
      procedure Comment(Content: string); 
      procedure Comment(Reg: Integer; Content: string);
      procedure Comment(Variable: String; Content: string);
      procedure CallMacro(MacroType: TOscMacroType; Name: string);
      procedure LoadVar(VarType: TOscVarType; Name: string);
      procedure SaveVar(VarType: TOscVarType; Name: string);
      procedure LoadReg(Number: Integer);
      procedure SaveReg(Number: Integer);
      procedure WriteOp(Content: string);
      procedure WriteConst(Content: string);
      procedure WriteConst(Content: single);
      procedure WriteConst(Content: Integer);
      procedure SaveCode(FileName: string);
      function GetCode: string;
      constructor Create;
end;

implementation
const OscVarTypeStr: array[TOscVarType] of string = ('$', 'S', 'L');
const OscMacroTypeStr: array[TOscMacroType] of string = ('L', 'V');

procedure TOscWriter.NewLine;
begin
  if (not compact) and (Code.Length > 0) and (AnsiLastChar(code) <> #10) then
    code := code + #13#10;
end;

procedure TOscWriter.WriteToken(Content: string);
begin
  if (Code.Length > 0) and (AnsiLastChar(code) = #10) then
    Code := Code + DupeString('  ', IndentDepth);
  Code := Code + Content + ' ';
end;

procedure TOscWriter.BeginMacro(Name: string);
begin
  NewLine;
  WriteToken('{macro:' + Name + '}');
  NewLine;
  IndentDepth := IndentDepth + 1;
end;

procedure TOscWriter.EndMacro;
begin
  IndentDepth := IndentDepth - 1;
  NewLine;
  WriteToken('{end}');
  NewLine;
end;

procedure TOscWriter.BeginIf;
begin
  NewLine;
  WriteToken('{if}');
  NewLine;
  IndentDepth := IndentDepth + 1;
end;

procedure TOscWriter.BeginElse;
begin
  IndentDepth := IndentDepth - 1;
  NewLine;
  WriteToken('{else}');
  NewLine;
  IndentDepth := IndentDepth + 1;
end;

procedure TOscWriter.EndIf;
begin
  IndentDepth := IndentDepth - 1;
  NewLine;
  WriteToken('{endif}');
  NewLine;
end;

procedure TOscWriter.Comment(Content: string);
begin
  // Begin new line independent of `compact` setting
  if (Code.Length > 0) and (AnsiLastChar(code) <> #10) then
    code := code + #13#10;
  Code := Code + ''' ' + Content + #13#10;
end;

procedure TOscWriter.Comment(Reg: Integer; Content: string);
begin
  Comment('  reg' + IntToStr(Reg) + ': ' + Content);
end;

procedure TOscWriter.Comment(Variable: string; Content: string);
begin
  Comment('  ' + Variable + ': ' + Content);
end;

procedure TOscWriter.CallMacro(MacroType: TOscMacroType; Name: string);
begin
  WriteToken('(M.' + OscMacroTypeStr[MacroType] + '.' + Name + ')');
end;

procedure TOscWriter.LoadVar(VarType: TOscVarType; Name: string);
begin
  WriteToken('(L.' + OscVarTypeStr[VarType] + '.' + Name + ')');
end;

procedure TOscWriter.SaveVar(VarType: TOscVarType; Name: string);
begin
  WriteToken('(S.' + OscVarTypeStr[VarType] + '.' + Name + ')');
end;

procedure TOscWriter.LoadReg(Number: Integer);
begin
  WriteToken('l' + IntToStr(Number));
end;

procedure TOscWriter.SaveReg(Number: Integer);
begin
  WriteToken('s' + IntToStr(Number));
end;

procedure TOscWriter.WriteOp(Content: string);
begin
  WriteToken(Content);
end;


procedure TOscWriter.WriteConst(Content: string);
begin;
  WriteToken('"' + Content + '"');
end;

procedure TOscWriter.WriteConst(Content: single);
begin;
  WriteToken(FloatToStr(Content));
end;

procedure TOscWriter.WriteConst(Content: Integer);
begin;
  WriteToken(IntToStr(Content));
end;

procedure TOscWriter.SaveCode(FileName: string);
var
  OutFile: TextFile;
begin;
  AssignFile(OutFile, Filename);
  try
    rewrite(OutFile);
    write(OutFile, Code);
    CloseFile(OutFile);
  finally
  end;
end;

function TOscWriter.GetCode: string;
begin;
  GetCode := Code;
end;

constructor TOscWriter.Create;
begin;
  Code := '';
  IndentDepth := 0;
  Compact := true;
end;

end.

