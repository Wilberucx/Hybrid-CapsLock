; Test script para probar la integración C# Tooltip
#NoEnv
#SingleInstance Force

; Include C# Tooltip Integration
#Include tooltip_csharp\autohotkey_integration.ahk

; Start C# Tooltip Application
StartTooltipApp()

; Wait a moment for app to start
Sleep, 1000

; Test Leader Menu
F1::
    items := "w:Windows|p:Programs|t:Time|c:Commands|i:Information|n:Excel"
    navigation := "ESC: Exit|ENTER: Select"
    ShowCSharpTooltip("🎯 TEST LEADER MENU", items, navigation, 5000)
return

; Test Program Menu
F2::
    items := "v:Visual Studio|c:Chrome|n:Notepad++|t:Terminal|f:Firefox|e:Explorer"
    navigation := "Backspace: Back|ESC: Exit"
    ShowCSharpTooltip("🚀 PROGRAM LAUNCHER", items, navigation, 5000)
return

; Test Window Menu
F3::
    items := "2:Split 50/50|3:Split 33/67|x:Close|m:Maximize|-:Minimize|d:Draw"
    navigation := "Enter: Apply|Backspace: Back"
    ShowCSharpTooltip("🪟 WINDOW MANAGER", items, navigation, 5000)
return

; Hide tooltip
F4::
    HideCSharpTooltip()
return

; Exit test
Esc::ExitApp

; Show instructions
ToolTip, F1: Leader Menu | F2: Programs | F3: Windows | F4: Hide | ESC: Exit, 10, 10
SetTimer, RemoveInstructions, 5000

RemoveInstructions:
    SetTimer, RemoveInstructions, Off
    ToolTip
return