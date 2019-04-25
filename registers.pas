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

const TTGlobalString = 5;

const VarTimetableID = 'Timetable_ID';
const VarDayType = 'Day_Type';

const GetKursInfoByID = 'GetKursInfoByID';
const GetKursByDepTime = 'GetKursByDepTime';
const TimetableInit = 'Timetable_Init';

implementation

end.

