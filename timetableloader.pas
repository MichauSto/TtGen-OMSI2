unit TimetableLoader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Timetable, laz2_XMLRead, laz2_DOM;

function LoadTimetableXML(FileName: string): TFahrplan;

implementation

function ParseTime(TimeString: String): Integer;
var
  Time: TDateTime;
  Hour: Word;
  Minute: Word;
  Second: Word;
  Millisecond: Word;
begin
  Time := StrToDateTime(TimeString);
  DecodeTime(Time, Hour, Minute, Second, Millisecond);
  Result := (Hour * 3600) + (Minute * 60) + Second;
end;

function LoadKursXML(KursNode: TDOMNode; Index: Integer): TKurs;
begin
  Result := TKurs.Create(Index,
                         ParseTime(KursNode.Attributes.GetNamedItem('Beginn').TextContent),
                         StrToInt(KursNode.Attributes.GetNamedItem('Code').TextContent));
end;

procedure LoadUmlaufXML(UmlaufNode: TDOMNode; UmlaufTree: specialize TTimetableTree<TUmlauf>);
var
  ChildNode: TDOMNode;
  Umlauf: TUmlauf;
  Fahrtag: TFahrtag;
  Index: Integer;
  KursTemp: TKurs;
begin
  Umlauf := UmlaufTree.Find(StrToInt(UmlaufNode.Attributes.GetNamedItem('Nr').TextContent));
  if (Umlauf = nil) then
  begin
    Umlauf := TUmlauf.Create(StrToInt(UmlaufNode.Attributes.GetNamedItem('Nr').TextContent));
    UmlaufTree.Insert(Umlauf);
  end;
  Fahrtag := TFahrtag.Create(StrToInt(UmlaufNode.Attributes.GetNamedItem('Tag').TextContent));
  ChildNode := UmlaufNode.FirstChild;
  Index := 0;
  while Assigned(ChildNode) do
  begin
    if (ChildNode.NodeName = 'Kurs') then
    begin
      KursTemp := LoadKursXML(ChildNode, Index);
      Fahrtag.Kurse.Insert(KursTemp);
      Fahrtag.Abfahrten.Insert(TAbfahrt.Create(KursTemp.Id, KursTemp.Start));
    end;
    ChildNode := ChildNode.NextSibling;
    Index := Index + 1;
  end;
  Umlauf.Fahrtage.Append(Fahrtag);
end;

function LoadLinieXML(LinieNode: TDOMNode): TLinie;
var
  ChildNode: TDOMNode;
begin
  Result := TLinie.Create(StrToInt(LinieNode.Attributes.GetNamedItem('Nr').TextContent));
  ChildNode := LinieNode.FirstChild;
  while Assigned(ChildNode) do
  begin
    if (ChildNode.NodeName = 'Umlauf') then
    begin
      LoadUmlaufXML(ChildNode, Result.Umlaeufe);
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function LoadTimetableXML(FileName: string): TFahrplan;
var
  ChildNode: TDOMNode;
  Doc: TXMLDocument;
begin;
  try
    ReadXMLFile(Doc, FileName);
    ChildNode := Doc.DocumentElement.FirstChild;
    Result := TFahrplan.Create;
    while Assigned(ChildNode) do
    begin
      if (ChildNode.NodeName = 'Linie') then
      begin
        Result.Linien.Insert(LoadLinieXML(ChildNode));
      end;
      ChildNode := ChildNode.NextSibling;
    end;
    Doc.Free;
  except
    Result := nil;
  end;
end;

end.

