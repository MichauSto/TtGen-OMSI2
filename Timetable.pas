unit Timetable;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Math;
type TTimetableVisitor = class;

type TTimetableItem = class
  public
    Id: Integer;
    procedure Accept(Visitor: TTimetableVisitor); virtual; abstract;
end;

type generic TTimetableListNode<T : TTimetableItem> = class
  private
    Item: T;
    class procedure Append(var Node: specialize TTimetableListNode<T>; NewItem: T); static;
  public
    Next: specialize TTimetableListNode<T>;
    constructor Create(NewItem: T);
    function GetItem: T;
    destructor Destroy; override;
end;

type generic TTimetableList<T : TTimetableItem> = class
  private
    type TNode = specialize TTimetableListNode<T>;
  private
    Root: TNode;
  public
    constructor Create;
    function GetRoot: TNode;
    procedure Append(Item: T);
    destructor Destroy; override;
end;

type generic TTimetableNode<T : TTimetableItem> = class
  private
    Item: T;
    class function GetHeight(var Node: specialize TTimetableNode<T>): Integer; static;
    class function GetBalance(var Node: specialize TTimetableNode<T>): Integer; static;
    class procedure Insert(var Node: specialize TTimetableNode<T>; NewItem: T); static;
    class function Find(var Node: specialize TTimetableNode<T>; Key: Integer): T; static;
    class procedure RotateLeft(var X: specialize TTimetableNode<T>); static;
    class procedure RotateRight(var Y: specialize TTimetableNode<T>); static;
    class function Count(var Node: specialize TTimetableNode<T>): Integer; static;
    class function GetMin(var Node: specialize TTimetableNode<T>): T; static;
  public
    Right: specialize TTimetableNode<T>;
    Left: specialize TTimetableNode<T>; 
    constructor Create(NewItem: T);
    function GetItem: T;
    destructor Destroy; override;
end;

type generic TTimetableTree<T : TTimetableItem> = class
  private
    type TNode = specialize TTimetableNode<T>;
  private
    Root: TNode;
  public
    constructor Create;
    function GetRoot: TNode;
    function GetMin: T;
    function Find(Key: Integer): T;
    function Count: Integer;
    procedure Insert(Item: T);
    destructor Destroy; override;
end;

type TKurs = class(TTimetableItem)
  public
    Code: Integer;
    Start: Integer;
    constructor Create(Index: Integer; Beginn: Integer; NewCode: Integer);
    procedure Accept(Visitor: TTimetableVisitor); override;
    //destructor Destroy; override;
end;

type TAbfahrt = class(TTimetableItem)
  public
    Kurs: Integer;
    constructor Create(Index: Integer; Beginn: Integer);
    procedure Accept(Visitor: TTimetableVisitor); override;
    //destructor Destroy; override;
end;

type TFahrtag = class(TTimetableItem)
  private
    type TKursTree = specialize TTimetableTree<TKurs>;
    type TAbfahrtTree = specialize TTimetableTree<TAbfahrt>;
  public
    Kurse: TKursTree;
    Abfahrten: TAbfahrtTree;
    constructor Create(Mask: Integer);
    procedure Accept(Visitor: TTimetableVisitor); override;
    destructor Destroy; override;
end;

type TUmlauf = class(TTimetableItem)
  private
    type TFahrtagList = specialize TTimetableList<TFahrtag>;
  public
    Fahrtage: TFahrtagList;
    constructor Create(Nummer: Integer);
    procedure Accept(Visitor: TTimetableVisitor); override;
    destructor Destroy; override;
end;

type TLinie = class(TTimetableItem)
  private
    type TUmlaufTree = specialize TTimetableTree<TUmlauf>;
  public
    Umlaeufe: TUmlaufTree;
    constructor Create(Nummer: Integer);
    procedure Accept(Visitor: TTimetableVisitor); override;
    destructor Destroy; override;
end;

type TFahrplan = class(TTimetableItem)
  private
    type TLinieTree = specialize TTimetableTree<TLinie>;
  public
    Linien: TLinieTree;
    Name: string;
    constructor Create();
    procedure Accept(Visitor: TTimetableVisitor); override;
    destructor Destroy; override;
end;

type TTimetableVisitor = class
  public
    procedure Visit(Instance: TTimetableItem); virtual;
    procedure Visit(Instance: TFahrplan); virtual; abstract;
    procedure Visit(Instance: TLinie); virtual; abstract;
    procedure Visit(Instance: TUmlauf); virtual; abstract; 
    procedure Visit(Instance: TFahrtag); virtual; abstract;
    procedure Visit(Instance: TKurs); virtual; abstract;
    procedure Visit(Instance: TAbfahrt); virtual; abstract;
end;

implementation

{%Region Visitor pattern implementation}

procedure TTimetableVisitor.Visit(Instance: TTimetableItem);
begin;
  Instance.Accept(Self);
end;

procedure TFahrplan.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

procedure TLinie.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

procedure TUmlauf.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

procedure TKurs.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

procedure TAbfahrt.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

procedure TFahrtag.Accept(Visitor: TTimetableVisitor);
begin;
  Visitor.Visit(Self);
end;

{%Endregion}

{%Region Helper functions for Timetable AVL Tree}

class function TTimetableNode.Count(var Node: specialize TTimetableNode<T>) : Integer;
begin;
  if (Node = nil) then
    Result := 0
  else
    Result := 1 + Count(Node.Left) + Count(Node.Right);
end;

class function TTimetableNode.GetMin(var Node: specialize TTimetableNode<T>) : T;
begin;
  if (Node = nil) then
    exit(nil);
  if (Node.Left <> nil) then
    exit(GetMin(Node.Left));
  exit(Node.Item);
end;

class function TTimetableNode.Find(var Node: specialize TTimetableNode<T>; Key: Integer) : T;
begin;
  if (Node = nil) then
    exit(nil);
  if (Key < Node.Item.Id) then
    exit(Find(Node.Left, Key));
  if (Key > Node.Item.Id) then
    exit(Find(Node.Right, Key));
  exit(Node.Item);
end;

class procedure TTimetableNode.Insert(var Node: specialize TTimetableNode<T>; NewItem: T);
var
  Balance: Integer;
begin;
  if (Node = nil) then begin
    Node := Create(NewItem);
    exit;
  end;

  if (NewItem.Id < Node.Item.Id) then
    Insert(Node.Left, NewItem)
  else if(NewItem.Id > Node.Item.Id) then
    Insert(Node.Right, NewItem)
  else
    exit;

  Balance := GetBalance(Node);

  if (Balance > 1) and (NewItem.Id < Node.Left.Item.Id) then
  begin
    RotateRight(Node);
  end
  else if (Balance < -1) and (NewItem.Id > Node.Right.Item.Id) then
  begin
    RotateLeft(Node);
  end
  else if (Balance > 1) and (NewItem.Id > Node.Left.Item.Id) then
  begin
    RotateLeft(Node.Left);
    RotateRight(Node);
  end
  else if (Balance < -1) and (NewItem.Id < Node.Right.Item.Id) then
  begin
    RotateRight(Node.Right);
    RotateLeft(Node);
  end;
end;

class procedure TTimetableNode.RotateRight(var Y: specialize TTimetableNode<T>);
var
  X: specialize TTimetableNode<T>;
  T2: specialize TTimetableNode<T>;
begin;
  X := Y.Left;
  T2 := X.Right;

  X.Right := Y;
  Y.Left := T2;

  Y := X;
end;

class procedure TTimetableNode.RotateLeft(var X: specialize TTimetableNode<T>);
var
  Y: specialize TTimetableNode<T>;
  T2: specialize TTimetableNode<T>;
begin;
  Y := X.Right;
  T2 := Y.Left;

  Y.Left := X;
  X.Right := T2;

  X := Y;
end;

class function TTimetableNode.GetHeight(var Node: specialize TTimetableNode<T>): Integer;
begin;
  if (Node = nil) then
    Result := 0
  else
    Result := Max(GetHeight(Node.Left), GetHeight(Node.Right)) + 1;
end;

class function TTimetableNode.GetBalance(var Node: specialize TTimetableNode<T>): Integer;
begin;
  if (Node = nil) then
    Result := 0
  else
    Result := GetHeight(Node.Left) - GetHeight(Node.Right);
end;

{%Endregion}

{%Region Constructors for Timetable AVL Tree}

constructor TTimetableNode.Create(NewItem: T);
begin;
  Item := NewItem;
  Left := nil;
  Right := nil;
end;

constructor TTimetableTree.Create;
begin;
  Root := nil;
end;

destructor TTimetableNode.Destroy;
begin;
  Left.Free;
  Right.Free;
  Item.Free;
  inherited Destroy;
end;

destructor TTimetableTree.Destroy;
begin;
  Root.Free;
  inherited Destroy;
end;

{%Endregion}

{%Region Timetable List}

class procedure TTimetableListNode.Append(var Node: specialize TTimetableListNode<T>; NewItem: T);
begin;
  if (Node = nil) then begin
    Node := Create(NewItem);
    exit;
  end;
  Append(Node.Next, NewItem);
end;

procedure TTimetableList.Append(Item: T);
begin
  TNode.Append(Root, Item);
end;

function TTimetableList.GetRoot: specialize TTimetableListNode<T>;
begin
  Result := Root;
end;

function TTimetableListNode.GetItem: T;
begin;
  Result := Item;
end;

constructor TTimetableListNode.Create(NewItem: T);
begin;
  Item := NewItem;
  Next := nil;
end;

destructor TTimetableListNode.Destroy;
begin;
  Next.Free;
  Item.Free;
  inherited Destroy;
end;

constructor TTimetableList.Create;
begin;
  Root := nil;
end;

destructor TTimetableList.Destroy;
begin;
  Root.Free;
  inherited Destroy;
end;

{%Endregion}
     
{%Region Public functions for Timetable AVL Tree}

function TTimetableNode.GetItem: T;
begin;
  Result := Item;
end;

function TTimetableTree.GetRoot: specialize TTimetableNode<T>;
begin
  Result := Root;
end;

procedure TTimetableTree.Insert(Item: T);
begin
  TNode.Insert(Root, Item);
end;

function TTimetableTree.Count: Integer;
begin
  Result := TNode.Count(Root);
end;

function TTimetableTree.GetMin: T;
begin;
  Result := TNode.GetMin(Root);
end;

function TTimetableTree.Find(Key: Integer): T;
begin;
  Result := TNode.Find(Root, Key);
end;

{%Endregion}

constructor TFahrplan.Create;
begin;
  Linien := TLinieTree.Create;
end;

destructor TFahrplan.Destroy;
begin;
  Linien.Free;
  inherited Destroy;
end;

constructor TLinie.Create(Nummer: Integer);
begin;
  Umlaeufe := TUmlaufTree.Create;
  Id := Nummer;
end;

destructor TLinie.Destroy;
begin;
  Umlaeufe.Free;
  inherited Destroy;
end;

constructor TUmlauf.Create(Nummer: Integer);
begin;
  Fahrtage := TFahrtagList.Create;
  Id := Nummer;
end;

destructor TUmlauf.Destroy;
begin;
  Fahrtage.Free;
  inherited Destroy;
end;

constructor TFahrtag.Create(Mask: Integer);
begin;
  Id := Mask;
  Kurse := TKursTree.Create;
  Abfahrten := TAbfahrtTree.Create;
end;

destructor TFahrtag.Destroy;
begin;
  Kurse.Free;
  Abfahrten.Free;
  inherited Destroy;
end;

constructor TAbfahrt.Create(Index: Integer; Beginn: Integer);
begin;
  Id := Beginn;
  Kurs := Index;
end;

constructor TKurs.Create(Index: Integer; Beginn: Integer; NewCode: Integer);
begin;
  Id := Index;
  Start := Beginn;
  Code := NewCode;
end;

end.

