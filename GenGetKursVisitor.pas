unit GenGetKursVisitor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Timetable, OscWriter, Registers;

procedure GenGetKursTree(Writer: TOscWriter; Tree: specialize TTimetableTree<TFahrplan>);

type TGenGetKursVisitor = class(TTimetableVisitor)
private
  procedure FahrplanTreeHelper(Node: specialize TTimetableNode<TLinie>);
  procedure FahrtagTreeHelper(Node: specialize TTimetableNode<TKurs>);
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
  
  procedure GenGetKursTree(Visitor: TGenGetKursVisitor; Node: specialize TTimetableNode<TFahrplan>);
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
        GenGetKursTree(Visitor, Node.Right);
        Writer.EndIf;
        if (Node.Left <> nil) then
        begin
          Writer.BeginElse;
          GenGetKursTree(Visitor, Node.Left);
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
        GenGetKursTree(Visitor, Node.Left);
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

  procedure GenGetKursTree(Writer: TOscWriter; Tree: specialize TTimetableTree<TFahrplan>);
  var
    Visitor: TGenGetKursVisitor;
  begin;
    Writer.Comment(GetKursInfoByID + ': Get departure time and '
      + 'destination code based on Linie, Umlauf and Kurs indices.');
    Writer.Comment('Input:');
    Writer.Comment(LinieRegister, 'Liniennummer');
    Writer.Comment(UmlaufRegister, 'Umlaufnummer');
    Writer.Comment(KursRegister, 'Kursnummer');
    Writer.Comment('Output:');
    Writer.Comment(CodeRegister, 'Destination code');
    Writer.Comment(BeginnRegister, 'Departure time');
    Writer.BeginMacro(GetKursInfoByID);
    Writer.WriteConst(-1);
    Writer.SaveReg(CodeRegister);
    Writer.SaveReg(BeginnRegister);
    Writer.NewLine;
    if (Tree.GetRoot <> nil) then
    begin
      Visitor := TGenGetKursVisitor.Create(Writer);
      GenGetKursTree(Visitor, Tree.GetRoot);
      Visitor.Free;
    end;
    Writer.EndMacro;
  end;

  procedure TGenGetKursVisitor.Visit(Instance: TFahrplan);
  begin;
    if (Instance.Linien.GetRoot <> nil) then
      FahrplanTreeHelper(Instance.Linien.GetRoot);
  end;

  procedure TGenGetKursVisitor.Visit(Instance: TLinie);
  begin;
    if (Instance.Umlaeufe.GetRoot <> nil) then
      LinieTreeHelper(Instance.Umlaeufe.GetRoot);
  end;

  procedure TGenGetKursVisitor.UmlaufListHelper(Node: specialize TTimetableListNode<TFahrtag>);
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

  procedure TGenGetKursVisitor.LinieTreeHelper(Node: specialize TTimetableNode<TUmlauf>);
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

  procedure TGenGetKursVisitor.FahrplanTreeHelper(Node: specialize TTimetableNode<TLinie>);
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

  procedure TGenGetKursVisitor.FahrtagTreeHelper(Node: specialize TTimetableNode<TKurs>);
  begin
    Writer.LoadReg(KursRegister);
    Writer.WriteConst(Node.GetItem.Id);
    if (Node.Right <> nil) then
    begin
      Writer.WriteOp('>=');
      Writer.BeginIf;
      Writer.LoadReg(KursRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      FahrtagTreeHelper(Node.Right);
      Writer.EndIf;
      if (Node.Left <> nil) then
      begin
        Writer.BeginElse;
        FahrtagTreeHelper(Node.Left);
      end;
      Writer.EndIf;
    end
    else if(Node.Left <> nil) then
    begin
      Writer.WriteOp('<=');
      Writer.BeginIf;
      Writer.LoadReg(KursRegister);
      Writer.WriteConst(Node.GetItem.Id);
      Writer.WriteOp('=');
      Writer.BeginIf;
      Node.GetItem.Accept(Self);
      Writer.BeginElse;
      FahrtagTreeHelper(Node.Left);
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

  procedure TGenGetKursVisitor.Visit(Instance: TUmlauf);
  begin;
    if (Instance.Fahrtage.GetRoot <> nil) then
    begin
      UmlaufListHelper(Instance.Fahrtage.GetRoot);
    end;
  end;

  procedure TGenGetKursVisitor.Visit(Instance: TKurs);
  begin;
    Writer.WriteConst(Instance.Start);
    Writer.SaveReg(BeginnRegister);
    Writer.NewLine;
    Writer.WriteConst(Instance.Code);
    Writer.SaveReg(CodeRegister);
  end; 

  procedure TGenGetKursVisitor.Visit(Instance: TFahrtag);
  begin;
    if (Instance.Kurse.GetRoot <> nil) then
    begin
      FahrtagTreeHelper(Instance.Kurse.GetRoot);
    end;
  end;

  procedure TGenGetKursVisitor.Visit(Instance: TAbfahrt);
  begin;

  end;

  constructor TGenGetKursVisitor.Create(NewWriter: TOscWriter);
  begin;
    Writer := NewWriter;
  end;

end.

