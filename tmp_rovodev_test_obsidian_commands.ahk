; ==============================================================================
; TEST OBSIDIAN COMMANDS - QUICK DEBUG
; ==============================================================================
; Press F11 to test Obsidian commands directly
; This helps debug if the issue is with the layer system or the commands themselves

#SingleInstance Force

; Test a few commands directly
F11::
    ; Test command 's' (Save file - Ctrl+S)
    Send, ^s
    ToolTip, Sent Ctrl+S (Save), 100, 100
    SetTimer, RemoveTestTooltip, 2000
return

F10::
    ; Test command 'f' (Global search - Ctrl+F) 
    Send, ^f
    ToolTip, Sent Ctrl+f (Global Search), 100, 100
    SetTimer, RemoveTestTooltip, 2000
return

F9::
    ; Test command 'c' (Switcher - Ctrl+E)
    Send, ^E
    ToolTip, Sent Ctrl+E (Switcher), 100, 100
    SetTimer, RemoveTestTooltip, 2000
return

F8::
    ; Test command 'P' (Command Palette - Alt+Shift+P)
    Send, !+P
    ToolTip, Sent Alt+Shift+P (Command Palette), 100, 100
    SetTimer, RemoveTestTooltip, 2000
return

RemoveTestTooltip:
    SetTimer, RemoveTestTooltip, Off
    ToolTip
return

; Show instructions
MsgBox, 64, Obsidian Command Test, Test script loaded!`n`nOpen Obsidian and test:`nF11 - Save (Ctrl+S)`nF10 - Global Search (Ctrl+F)`nF9 - Switcher (Ctrl+E)`nF8 - Command Palette (Alt+Shift+P)`n`nThis will help verify if the commands work directly.