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

const VarKursID = 'Kurs_Index';  
const VarKursCount = 'Kurs_Anzahl';

function CodeVar(I: Integer): string;
function DepartureVar(I: Integer): string;

function CodeVar: string;
function DepartureVar: string;

implementation

function CodeVar(I: Integer): string;
begin;
  Result := 'Kurs_' + IntToStr(I) + '_Code';
end;

function CodeVar: string;
begin;
  Result := 'Kurs_[' + IntToStr(RangeVarMin) + ':' + IntToStr(RangeVarMax) + ']_Code';
end;

function DepartureVar(I: Integer): string;
begin;
  Result := 'Kurs_' + IntToStr(I) + '_Departure';
end;

function DepartureVar: string;
begin;
  Result := 'Kurs_[' + IntToStr(RangeVarMin) + ':' + IntToStr(RangeVarMax) + ']_Departure';
end;

end.

