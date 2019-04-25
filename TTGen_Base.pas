unit TTGen_Base;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Timetable, OscWriter, GenGetKursVisitor,
  TimetableLoader, Registers, LazFileUtils, FileUtil, GenGetKursByDep;

type TFahrplanTree = specialize TTimetableTree<TFahrplan>;
procedure WriteFahrplanNode(Writer: TOscWriter; FahrplanTree: TFahrplanTree; Index: integer);
procedure RunMe;


implementation

procedure WriteFahrplanNode(Writer: TOscWriter; FahrplanTree: TFahrplanTree; Index: integer);
begin
  if (FahrplanTree.Find(Index + 1) <> nil) then
    Writer.WriteOp('$d');
  Writer.WriteConst(FahrplanTree.Find(Index).Name);
  Writer.WriteOp('$=');
  Writer.BeginIf;
  Writer.WriteConst(Index);
  Writer.SaveVar(FloatVar, VarTimetableID);
  if (FahrplanTree.Find(Index + 1) <> nil) then
  begin
    Writer.BeginElse;
    WriteFahrplanNode(Writer, FahrplanTree, Index + 1);
  end;
  Writer.EndIf;
end;

procedure RunMe;
var
  FahrplanTree: TFahrplanTree;
  FahrplanTemp: TFahrplan;
  Writer: TOscWriter;
  Files: TStringList;
  FName: string;
  Iter: Integer;
begin
  FahrplanTree := TFahrplanTree.Create;
  Files := FindAllFiles('Vehicles\Timetables\', '*.xml', False);
  Iter := 0;
  for FName in Files do
  begin
    FahrplanTemp := LoadTimetableXML(FName);
    FahrplanTemp.Name := ExtractFileNameOnly(FName);
    FahrplanTemp.Id := Iter;
    Iter := Iter + 1;
    FahrplanTree.Insert(FahrplanTemp);
  end;
  Files.Free;

  Writer := TOscWriter.Create;
  Writer.Comment('WARNING: This file is overwritten automatically at each '
    + 'game launch. To edit the timetable contents, use the corresponding '
    + 'XML files.');

  GenGetKursTree(Writer, FahrplanTree);

  GenGetKursByDepTree(Writer, FahrplanTree);

  Writer.Comment(TimetableInit + ': Call this macro from your {init} block.');
  Writer.Comment('Input/Output: None');

  Writer.BeginMacro('Timetable_Init');
  Writer.WriteConst(-1);
  Writer.SaveVar(FloatVar, VarTimetableID);
  Writer.NewLine;
  if (FahrplanTree.GetRoot <> nil) then
  begin
    Writer.WriteConst(TTGlobalString);
    Writer.WriteOp('(M.V.GetDepotStringGlobal)');
    WriteFahrplanNode(Writer, FahrplanTree, 0);
  end;
  Writer.EndMacro;
  Writer.SaveCode('Vehicles\Timetables\Script\Timetable.osc');
  Writer.Free;
  FahrplanTree.Free;
end;

end.

