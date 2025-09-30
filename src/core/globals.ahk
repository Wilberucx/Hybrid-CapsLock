; ==============================
; Core global variables (paths)
; ==============================
; Define INI paths early so any included module can read configuration safely

global ConfigIni := A_ScriptDir . "\config\configuration.ini"
global ProgramsIni := A_ScriptDir . "\config\programs.ini"
global TimestampsIni := A_ScriptDir . "\config\timestamps.ini"
global InfoIni := A_ScriptDir . "\config\information.ini"
global CommandsIni := A_ScriptDir . "\config\commands.ini"
