unit GenGetKursByDep;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Timetable, OscWriter, Registers;

procedure GenGetKursByDepTree(Writer: TOscWriter; Tree: specialize TTimetableTree<TFahrplan>);

type TGenGetKursByDepVisitor = class(TTimetableVisitor)
private 
  Iter: Integer;
  procedure FahrplanTreeHelper(Node: specialize TTimetableNode<TLinie>);
  procedure FahrtagTreeHelper(Node: specialize TTimetableNode<TAbfahrt>; Tree: specialize TTimetableTree<TKurs>);
  procedure LinieTreeHelper(Node: specialize TTimetableNode<TUmlauf>);
  procedure UmlaufListHelper(Node: specialize TTimetableListNode<TFahrtag>);
public
  Writer: TOscWriter;
  constructor Create(NewWriter: TOscWriter);
  procedure Visit(Instance: TFahrplan); override;
  procedure Visit(Instance: TLinie); override;
  procedure Visit(Instance: TUmlauf); override;
  procedure Visit(Instance: TKurs); override;
  procedure Visit(Instance: TFahrtag); override;
  procedure Visit(Instance: TAbfahrt); override;
end;

implementation
  
  procedure GenGetKursByDepTree(Visitor: TGenGetKursByDepVisitor; Node: specialize TTimetableNode<TFahrplan>);
  begin;
    with Visitor do
    begin
      Writer.LoadVar(FloatVar, VarTimetableID);
      Writer.WriteConst(Node.GetItem.Id);
      if (Node.Right <> nil) then
      begin
        Writer.WriteOp('>=');
        Writer.BeginIf;
        Writer.LoadVar(FloatVar, VarTimetableID);
        Writer.WriteConst(Node.GetItem.Id);
        Writer.WriteOp('=');
        Writer.BeginIf;
        Node.GetItem.Accept(Visitor);
        Writer.BeginElse;
        GenGetKursByDepTree(Visitor, Node.Right);
        Writer.EndIf;
        if (Node.Left <> nil) then
        begin
          Writer.BeginElse;
          GenGetKursByDepTree(Visitor, Node.Left);
        end;
        Writer.EndIf;
      end
      else if(Node.Left <> nil) then
      begin
        Writer.WriteOp('<=');
        Writer.BeginIf;
        Writer.LoadVar(FloatVar, VarTimetableID);
        Writer.WriteConst(Node.GetItem.Id);
        Writer.WriteOp('=');
        Writer.BeginIf;
        Node.GetItem.Accept(Visitor);
        Writer.BeginElse;
        GenGetKursByDepTree(Visitor, Node.Left);
        Writer.EndIf;
        Writer.EndIf;
      end
      else
      begin
        Writer.WriteOp('=');
        Writer.BeginIf;
        Node.GetItem.Accept(Visitor);
        Writer.EndIf;
      end;
    end;
  end;

  procedure GenGetKursByDepTree(Writer: TOscWriter; Tree: specialize TTimetableTree<TFahrplan>);
  var
    Visitor: TGenGetKursByDepVisitor;
  begin;
    Writer.Comment(GetKursByDepTime + ': Get the upcoming Kurs index for a given Linie and Umlauf.');
    Writer.Comment('Input:');
    Writer.Comment(LinieRegister, 'Liniennummer');
    Writer.Comment(UmlaufRegister, 'Umlaufnummer');
    Writer.Comment('Output:');
    Writer.Comment(VarKursID, 'Kursnummer');
    Writer.Comment(CodeVar, 'Destination code');
    Writer.Comment(DepartureVar, 'Departure time');
    Writer.Comment(VarKursCount, 'Kursanzahl');
    Writer.BeginMacro(GetKursByDepTime);
    Writer.WriteConst(-1);
    Writer.SaveReg(KursRegister);
    Writer.SaveReg(CodeRegister);
    Writer.SaveReg(BeginnRegister);
    Writer.SaveReg(CountRegister);
    Writer.NewLine;
    if (Tree.GetRoot <> nil) then
    begin
      Writer.LoadVar(SystemVar, 'Time');
      Writer.SaveReg(TimeRegister);
      Writer.NewLine;
      Visitor := TGenGetKursByDepVisitor.Create(Writer);
      GenGetKursByDepTree(Visitor, Tree.GetRoot);
      Visitor.Free;
    end;
    Writer.EndMacro;
  end;

  procedure TGenGetKursByDepVisitor.Visit(Instance: TFahrplan);
  begin;
    if (Instance.Linien.GetRoot <> nil) then
      FahrplanTreeHelper(Instance.Linien.GetRoot);
  end;

  procedure TGenGetKursByDepVisitor.Visit(Instance: TLinie);
  begin;
    if (Instance.Umlaeufe.GetRoot <> nil) then
      LinieTreeHelper(Instance.Umlaeufe.GetRoot);
  end;

  procedure TGenGetKursByDepVisitor.UmlaufListHelper(Node: specialize TTimetableListNode<TFahrtag>);
  begin
    Writer.LoadVar(FloatVar, VarDayType);
    Writer.WriteConst(Node.GetItem.Id);
    Writer.WriteOp('=');
    Writer.BeginIf;
    Node.GetItem.Accept(Self);
    if Node.Next <> nil then
    begin
      Writer.BeginElse;
      UmlaufListHelper(Node.Next);
    end;
    Writer.EndIf;
  end;

  procedure TGenGetKursByDepVisitor.LinieTreeHelper(Node: specialize TTimetableNode<TUmlauf>);
  begin
    Writer.LoadReg(UmlaufRegister);
    Writer.WriteConst(Node.GetItem.Id);
    if (Node.Right <> nil) then
    begin
      Writer.WriteOp('>=');
      Writer.BeginIf;
      Writer.LoadReg(UmlaufRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      LinieTreeHelper(Node.Right);
      Writer.EndIf;
      if (Node.Left <> nil) then
      begin
        Writer.BeginElse;
        LinieTreeHelper(Node.Left);
      end;
      Writer.EndIf;
    end
    else if(Node.Left <> nil) then
    begin
      Writer.WriteOp('<=');
      Writer.BeginIf;
      Writer.LoadReg(UmlaufRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      LinieTreeHelper(Node.Left);
      Writer.EndIf;
      Writer.EndIf;
    end
    else
    begin
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.EndIf;
    end;
  end;

  procedure TGenGetKursByDepVisitor.FahrplanTreeHelper(Node: specialize TTimetableNode<TLinie>);
  begin
    Writer.LoadReg(LinieRegister);
    Writer.WriteConst(Node.GetItem.Id);
    if (Node.Right <> nil) then
    begin
      Writer.WriteOp('>=');
      Writer.BeginIf;
      Writer.LoadReg(LinieRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      FahrplanTreeHelper(Node.Right);
      Writer.EndIf;
      if (Node.Left <> nil) then
      begin
        Writer.BeginElse;
        FahrplanTreeHelper(Node.Left);
      end;
      Writer.EndIf;
    end
    else if(Node.Left <> nil) then
    begin
      Writer.WriteOp('<=');
      Writer.BeginIf;
      Writer.LoadReg(LinieRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      FahrplanTreeHelper(Node.Left);
      Writer.EndIf;
      Writer.EndIf;
    end
    else
    begin
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.EndIf;
    end;
  end;

  function Clamp(Value: Integer; Max: Integer): Integer;
  begin;
    while(Value >= Max) do
      Value := Value - Max;
    while(Value < 0) do
      Value := Value + Max;
    Result := Value;
  end;

  procedure TGenGetKursByDepVisitor.FahrtagTreeHelper(Node: specialize TTimetableNode<TAbfahrt>; Tree: specialize TTimetableTree<TKurs>);
  var
    Index: Integer;
    I: Integer;
  begin
    Index := Tree.IndexOf(Node.GetItem.Kurs);
    Writer.LoadReg(TimeRegister);
    Writer.WriteConst(Node.GetItem.Id);
    Writer.WriteOp('<=');
    Writer.BeginIf;

    Writer.WriteConst(Index);
    Writer.SaveVar(FloatVar, VarKursID);
    Writer.NewLine;
    for I := RangeVarMin to RangeVarMax do
    begin
      Iter := I;
      Tree.GetIndexth(Clamp(Index + Iter, Tree.Count)).Accept(Self)
    end;

    if(Node.Left <> nil) then
    begin
      FahrtagTreeHelper(Node.Left, Tree);
    end;
    if (Node.Left <> nil) then
    begin
      Writer.BeginElse;
      FahrtagTreeHelper(Node.Right, Tree);
    end;
    Writer.EndIf;
  end;

  procedure TGenGetKursByDepVisitor.Visit(Instance: TUmlauf);
  begin;
    if (Instance.Fahrtage.GetRoot <> nil) then
    begin
      UmlaufListHelper(Instance.Fahrtage.GetRoot);
    end;
  end;

  procedure TGenGetKursByDepVisitor.Visit(Instance: TKurs);
  begin;
    Writer.WriteConst(Instance.Start);
    Writer.SaveVar(FloatVar, DepartureVar(Iter));
    Writer.NewLine;
    Writer.WriteConst(Instance.Code);
    Writer.SaveVar(FloatVar, CodeVar(Iter));
    Writer.NewLine;
  end; 

  procedure TGenGetKursByDepVisitor.Visit(Instance: TFahrtag);
  var
    I: Integer;
  begin;
    if (Instance.Kurse.GetRoot <> nil) then
    begin
      Writer.WriteConst(Instance.Kurse.Count);
      Writer.SaveVar(FloatVar, VarKursCount);
      Writer.NewLine;
      Writer.WriteConst(0);
      Writer.SaveVar(FloatVar, VarKursID);
      Writer.NewLine;
      for I := RangeVarMin to RangeVarMax do
      begin
        Iter := I;
        Instance.Kurse.GetIndexth(Clamp(Iter, Instance.Kurse.Count)).Accept(Self)
      end;
      Writer.NewLine;
      FahrtagTreeHelper(Instance.Abfahrten.GetRoot, Instance.Kurse);
    end;
  end;

  procedure TGenGetKursByDepVisitor.Visit(Instance: TAbfahrt);
  begin;

  end;

  constructor TGenGetKursByDepVisitor.Create(NewWriter: TOscWriter);
  begin;
    Writer := NewWriter;
  end;

end.

