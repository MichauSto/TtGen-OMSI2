program TTGen_EXE;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, TTGen_Base
  { you can add units after this };

type

  { TTGen }

  TTGen = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TTGen }

procedure TTGen.DoRun;
begin
  RunMe;
  Terminate;
end;

constructor TTGen.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TTGen.Destroy;
begin
  inherited Destroy;
end;

procedure TTGen.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TTGen;
begin
  Application:=TTGen.Create(nil);
  Application.Title:='OMSI 2 Timetable Generator';
  Application.Run;
  Application.Free;
end.

