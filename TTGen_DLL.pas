library TTGen_DLL;

uses
  Classes, TTGen_Base, LazFileUtils
  { you can add units after this };

procedure PluginStart( AOwner: TComponent ); stdcall;
begin
  RunMe;
end;

procedure PluginFinalize; stdcall;
begin
  DeleteFileUTF8('Vehicles\Timetables\Script\Timetable.osc');
end;

procedure AccessStringVariable( varindex: word; var value: PWideChar; var write: boolean ); stdcall;
begin

end;

procedure AccessSystemVariable( varindex: word; var value: single; var write: boolean ); stdcall;
begin

end;

procedure AccessVariable( varindex: word; var value: single; var write: boolean ); stdcall;
begin

end;

procedure AccessTrigger( triggerindex: word; var active: boolean ); stdcall;
begin

end;

exports
AccessVariable,
AccessTrigger,
AccessSystemVariable,
AccessStringVariable,
PluginStart,
PluginFinalize;

begin
end.

