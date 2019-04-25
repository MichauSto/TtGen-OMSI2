unit Registers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const LinieRegister = 0;
const UmlaufRegister = 1;
const KursRegister = 2;
const CodeRegister = 3;
const BeginnRegister = 4;
const CountRegister = 5;
const TimeRegister = 7;

const RangeVarMin = -2;
const RangeVarMax = 3;

const TTGlobalString = 5;

const VarTimetableID = 'Timetable_ID';
const VarDayType = 'Day_Type';

const GetKursInfoByID = 'GetKursInfoByID';
const GetKursByDepTime = 'GetKursByDepTime';
const TimetableInit = 'Timetable_Init';

const VarKursID = 'Kurs_ID';
const VarKursCount = 'Kurs_Count';

function CodeVar(I: Integer): string;
function DepartureVar(I: Integer): string;

function CodeVar: string;
function DepartureVar: string;

implementation

function CodeVar(I: Integer): string;
begin;
  Result := 'K' + IntToStr(I - RangeVarMin) + '_C';
end;

function CodeVar: string;
begin;
  Result := 'K[' + IntToStr(0) + ':' + IntToStr(-RangeVarMin) + ':' + IntToStr(RangeVarMax - RangeVarMin) + ']_C';
end;

function DepartureVar(I: Integer): string;
begin;
  Result := 'K' + IntToStr(I - RangeVarMin) + '_D';
end;

function DepartureVar: string;
begin;
  Result := 'K[' + IntToStr(0) + ':' + IntToStr(-RangeVarMin) + ':'+ IntToStr(RangeVarMax - RangeVarMin) + ']_D';
end;

end.

