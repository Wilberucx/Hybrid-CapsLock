;===============================================================================
; SCRIPT: Hybrid CapsLock Productivity (Vim Style) - AutoHotkey v2
; AUTHOR: Wilber Canto (Vibe Codding)
; VERSION: 2.0 (AutoHotkey v2)
;===============================================================================
;
; _DOC: This script transforms the CapsLock key into a powerful productivity
;       tool with a hybrid behavior. Migrated to AutoHotkey v2 for improved
;       performance and modern syntax.
;
; V2.0 CHANGELOG:
; - Migrated from AutoHotkey v1 to v2
; - Added 4 new command categories (Power Options, ADB Tools, VaultFlow, Hybrid Management)
; - Improved syntax and performance
; - Enhanced navigation with hierarchical menu system
; - Maintained full compatibility with existing .ini configuration files
;
;===============================================================================

;-------------------------------------------------------------------------------
; SECTION 1: INITIAL CONFIGURATION (v2)
;-------------------------------------------------------------------------------
#SingleInstance Force
#Warn All
; SendMode Input  ; v2 uses Input mode by default, no need to set explicitly
; Note: A_StringCaseSense is read-only in v2 and defaults to true

; Ensure we're on AutoHotkey v2.x
if (SubStr(A_AhkVersion, 1, 1) != "2") {
    MsgBox("This script requires AutoHotkey v2.x.`nYou are running v" . A_AhkVersion . ".`nInstall AutoHotkey v2.0+ and try again.", "HybridCapsLock v2", "IconX")
    ExitApp()
}

; _DOC: Global variables to control layer states - MUST BE DECLARED FIRST
global isNvimLayerActive := false
global _tempEditMode := false
global VisualMode := false

; Leader state flags
global leaderActive := false

; Ensure all layer variables are properly initialized
global excelLayerActive := false
global capsLockWasHeld := false
global capsLockUsedAsModifier := false
global rightClickHeld := false
global scrollModeActive := false
global _yankAwait := false
global _deleteAwait := false
global capsActsNormal := false

; Global variables for temporary status tracking
global currentTempStatus := ""
global tempStatusExpiry := 0

; Include C# tooltip integration after global variables
#Include tooltip_csharp_integration.ahk

; _DOC: Run as admin to prevent permission issues.
; Uncomment the following lines if admin privileges are required:
;if (!A_IsAdmin) {
;    Run("*RunAs `"" . A_ScriptFullPath . "`"")
;    ExitApp()
;}

; _DOC: Permanently disable the native CapsLock function.
; Startup banner to confirm correct script loaded
if (tooltipConfig.enabled) {
    StartTooltipApp()
    StartStatusApp()  ; Iniciar aplicación de estado por separado
    Sleep(500)  ; Give time for apps to start
    ShowCenteredToolTipCS("HybridCapsLock v2.0 loaded`n" . A_ScriptFullPath, 1500)
} else {
    ShowCenteredToolTip("HybridCapsLock v2.0 loaded`n" . A_ScriptFullPath)
    SetTimer(RemoveToolTip, -1500)
}
SetCapsLockState("AlwaysOff")

;-------------------------------------------------------------------------------
; SECTION 2: ADDITIONAL GLOBAL VARIABLES (v2)
;-------------------------------------------------------------------------------

; Helper function to mark CapsLock as used as modifier
MarkCapsLockAsModifier() {
    global capsLockUsedAsModifier
    capsLockUsedAsModifier := true
}


; Configuration file paths - maintain compatibility with v1
global ConfigIni := A_ScriptDir . "\config\configuration.ini"
global ProgramsIni := A_ScriptDir . "\config\programs.ini"
global TimestampsIni := A_ScriptDir . "\config\timestamps.ini"
global InfoIni := A_ScriptDir . "\config\information.ini"
global CommandsIni := A_ScriptDir . "\config\commands.ini"
global ObsidianIni := A_ScriptDir . "\config\obsidian.ini"

; Layer status file for Zebar integration
global LayerStatusFile := A_ScriptDir . "\data\layer_status.json"

;-------------------------------------------------------------------------------
; SECTION 3: HELPER FUNCTIONS (v2 - Enhanced with C# Tooltips)
;-------------------------------------------------------------------------------

; Basic tooltip function for startup
ShowCenteredToolTip(Text) {
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip(Text, ToolTipX, ToolTipY)
}

; Timer function to remove tooltip
RemoveToolTip() {
    ToolTip()
}


; Configuration reading function
ReadConfigValue(section, key, defaultValue := "") {
    if (section = "Hybrid" && key = "tap_timeout") {
        return "200"
    }
    if (section = "Hybrid" && key = "leader_timeout") {
        return "5000"
    }
    if (section = "Advanced" && key = "nvim_shift_touchpad_scroll") {
        return "false"
    }
    return defaultValue
}

; Status notification functions (Enhanced with C# tooltips)
ShowCopyNotification() {
    if (tooltipConfig.enabled) {
        ShowCopyNotificationCS()
    } else {
        ShowCenteredToolTip("COPIED")
        SetTimer(RemoveToolTip, -800)
    }
}

ShowLeftClickStatus(isActive) {
    if (tooltipConfig.enabled) {
        if (isActive) {
            ShowCSharpStatusNotification("MOUSE", "LEFT CLICK HELD")
        } else {
            ShowCSharpStatusNotification("MOUSE", "LEFT CLICK RELEASED")
        }
    } else {
        if (isActive) {
            ShowCenteredToolTip("LEFT CLICK HELD")
        } else {
            ShowCenteredToolTip("LEFT CLICK RELEASED")
        }
    }
}

ShowRightClickStatus(isActive) {
    if (tooltipConfig.enabled) {
        ShowCSharpStatusNotification("MOUSE", "RIGHT CLICK")
    } else {
        ShowCenteredToolTip("RIGHT CLICK")
    }
}

ShowCapsLockStatus(isNormal) {
    if (tooltipConfig.enabled) {
        if (isNormal) {
            ShowCSharpStatusNotification("CAPSLOCK", "NORMAL MODE")
        } else {
            ShowCSharpStatusNotification("CAPSLOCK", "HYBRID MODE")
        }
    } else {
        if (isNormal) {
            ShowCenteredToolTip("CAPSLOCK NORMAL MODE")
        } else {
            ShowCenteredToolTip("CAPSLOCK HYBRID MODE")
        }
    }
}

ShowProcessTerminated() {
    if (tooltipConfig.enabled) {
        ShowProcessTerminatedCS()
    } else {
        ShowCenteredToolTip("PROCESS TERMINATED")
    }
}

SetTempStatus(status, duration) {
    global currentTempStatus, tempStatusExpiry
    currentTempStatus := status
    tempStatusExpiry := A_TickCount + duration
}

; Nvim Layer status functions (Enhanced with C# tooltips)
ShowNvimLayerStatus(isActive) {
    if (tooltipConfig.enabled) {
        ShowNvimLayerStatusCS(isActive)
    } else {
        if (isActive) {
            ShowCenteredToolTip("NVIM LAYER ON")
        } else {
            ShowCenteredToolTip("NVIM LAYER OFF")
        }
    }
}

; Visual mode status function (Enhanced with C# status windows)
ShowVisualModeStatus(isActive) {
    if (tooltipConfig.enabled) {
        if (isActive) {
            ShowVisualStatus()
        } else {
            HideVisualStatus()
        }
    } else {
        if (isActive) {
            ShowCenteredToolTip("VISUAL MODE ON")
        } else {
            ShowCenteredToolTip("VISUAL MODE OFF")
        }
    }
}

; Delete menu function (Enhanced with C# options)
ShowDeleteMenu() {
    if (tooltipConfig.enabled) {
        ShowDeleteMenuCS()  ; Mostrar opciones de delete
    } else {
        ShowCenteredToolTip("DELETE: w=word, d=line, a=all")
    }
}

; Yank menu function (Enhanced with C# options)
ShowYankMenu() {
    if (tooltipConfig.enabled) {
        ShowYankMenuCS()  ; Mostrar opciones de yank
    } else {
        ShowCenteredToolTip("YANK: y=line, w=word, a=all, p=paragraph")
    }
}

; Nvim helper functions (Phase 4 implementation)
DeleteCurrentWord() {
    Send("^{Right}^+{Left}{Delete}")
    ShowCenteredToolTip("WORD DELETED")
    SetTimer(RemoveToolTip, -800)
}

DeleteCurrentLine() {
    Send("{Home}+{End}{Delete}")
    ShowCenteredToolTip("LINE DELETED")
    SetTimer(RemoveToolTip, -800)
}

DeleteAll() {
    Send("^a{Delete}")
    ShowCenteredToolTip("ALL DELETED")
    SetTimer(RemoveToolTip, -800)
}

CopyCurrentLine() {
    Send("{Home}+{End}^c")
    ShowCenteredToolTip("LINE COPIED")
    SetTimer(RemoveToolTip, -800)
}

CopyCurrentParagraph() {
    Send("^{Up}^+{Down}^c")
    ShowCenteredToolTip("PARAGRAPH COPIED")
    SetTimer(RemoveToolTip, -800)
}

PastePlain() {
    ; Paste as plain text (implementation depends on application)
    Send("^+v")  ; Common shortcut for paste plain text
}

; Timer functions for Nvim layer
DeleteTimeout() {
    global _deleteAwait
    _deleteAwait := false
    if (tooltipConfig.enabled) {
        ; No ocultar automáticamente - las opciones permanecen hasta completar operación
        HideCSharpTooltip()  ; Solo ocultar tooltip de opciones
    } else {
        SetTimer(RemoveToolTip, -100)
    }
}

YankTimeout() {
    global _yankAwait
    _yankAwait := false
    if (tooltipConfig.enabled) {
        ; No ocultar automáticamente - las opciones permanecen hasta completar operación
        HideCSharpTooltip()  ; Solo ocultar tooltip de opciones
    } else {
        SetTimer(RemoveToolTip, -100)
    }
}

ReactivateNvimAfterInsert() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        UpdateLayerStatus()
        SetTimer(RemoveToolTip, -1000)
    }
}

ReactivateNvimAfterReplace() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        UpdateLayerStatus()
        SetTimer(RemoveToolTip, -1000)
    }
}

;-------------------------------------------------------------------------------
; SECTION 8: SPECIALIZED LAYERS (v2 - Phase 6)
;-------------------------------------------------------------------------------

; Excel/Accounting layer - only active when excelLayerActive is true
#HotIf (excelLayerActive && !GetKeyState("CapsLock", "P"))

; === NUMPAD SECTION ===
; Top row (7, 8, 9)
7::Send("{Numpad7}")
8::Send("{Numpad8}")
9::Send("{Numpad9}")

; Middle row (4, 5, 6)
u::Send("{Numpad4}")
i::Send("{Numpad5}")
o::Send("{Numpad6}")

; Bottom row (1, 2, 3)
j::Send("{Numpad1}")
k::Send("{Numpad2}")
l::Send("{Numpad3}")

; Zero
m::Send("{Numpad0}")

; Decimal and comma
,::Send("{NumpadComma}")
.::Send("{NumpadDot}")

; Operations
p::Send("{NumpadAdd}")
`;::Send("{NumpadSub}")
/::Send("{NumpadDiv}")

; === NAVIGATION SECTION ===
; Arrow keys (WASD)
w::Send("{Up}")
a::Send("{Left}")
s::Send("{Down}")
d::Send("{Right}")

; Tab navigation
[::Send("+{Tab}")
]::Send("{Tab}")

; === EXCEL FUNCTIONS ===
Enter::Send("^{Enter}")  ; Fill down
Space::Send("{F2}")      ; Edit cell
f::Send("^f")           ; Find
r::Send("^r")           ; Fill right

; === EXIT EXCEL LAYER ===
+n:: {
    ; Shift+n to exit Excel layer
    global excelLayerActive
    excelLayerActive := false
    ShowExcelLayerStatus(false)
    SetTempStatus("EXCEL LAYER OFF", 2000)
    UpdateLayerStatus()
    SetTimer(RemoveToolTip, -2000)
}

; End of Excel Layer context
#HotIf

; Specialized layer helper functions (Enhanced with C# tooltips)
ShowExcelLayerStatus(isActive) {
    if (tooltipConfig.enabled) {
        ShowExcelLayerStatusCS(isActive)
    } else {
        if (isActive) {
            ShowCenteredToolTip("EXCEL LAYER ON")
        } else {
            ShowCenteredToolTip("EXCEL LAYER OFF")
        }
    }
}

ShowWindowMenu() {
    if (tooltipConfig.enabled) {
        ShowWindowMenuCS()
    } else {
        ; Fallback to native tooltips
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "WINDOW MANAGER`n`n"
        menuText .= "SPLITS:`n"
        menuText .= "2 - Split 50/50    3 - Split 33/67`n"
        menuText .= "4 - Quarter Split`n`n"
        menuText .= "ACTIONS:`n"
        menuText .= "x - Close          m - Maximize`n"
        menuText .= "- - Minimize`n`n"
        menuText .= "ZOOM TOOLS:`n"
        menuText .= "d - Draw           z - Zoom`n"
        menuText .= "c - Zoom with cursor`n`n"
        menuText .= "WINDOW SWITCHING:`n"
        menuText .= "j/k - Persistent Window Switch`n`n"
        menuText .= "[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowTimeMenu() {
    if (tooltipConfig.enabled) {
        ShowTimeMenuCS()
    } else {
        ; Fallback to native tooltips
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 80
        menuText := "TIMESTAMP MANAGER`n`n"
        menuText .= "d - Date Formats`n"
        menuText .= "t - Time Formats`n"
        menuText .= "h - Date+Time Formats`n`n"
        menuText .= "[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowInformationMenu() {
    if (tooltipConfig.enabled) {
        ShowInformationMenuCS()
    } else {
        ; Fallback to native tooltips
        global InfoIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "INFORMATION MANAGER`n`n"
        
        ; Read menu lines dynamically from information.ini
        Loop 10 {
            lineContent := IniRead(InfoIni, "MenuDisplay", "info_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; Window action executor
ExecuteWindowAction(action) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch action {
        case "2":
            ; Split 50/50
            Send("#{Left}")
            Sleep(100)
            Send("#{Right}")
            ShowCenteredToolTip("SPLIT 50/50")
            SetTimer(RemoveToolTip, -1500)
        case "3":
            ; Split 33/67
            Send("#{Left}")
            Sleep(100)
            Send("#{Right}")
            Sleep(100)
            Send("#{Left}")
            ShowCenteredToolTip("SPLIT 33/67")
            SetTimer(RemoveToolTip, -1500)
        case "4":
            ; Quarter split
            Send("#{Up}")
            Sleep(100)
            Send("#{Left}")
            ShowCenteredToolTip("QUARTER SPLIT")
            SetTimer(RemoveToolTip, -1500)
        case "x":
            ; Close window
            Send("!{F4}")
            ShowCenteredToolTip("WINDOW CLOSED")
            SetTimer(RemoveToolTip, -1500)
        case "m":
            ; Maximize
            Send("#{Up}")
            ShowCenteredToolTip("MAXIMIZED")
            SetTimer(RemoveToolTip, -1500)
        case "-":
            ; Minimize
            Send("#{Down}")
            ShowCenteredToolTip("MINIMIZED")
            SetTimer(RemoveToolTip, -1500)
        case "d":
            ; Draw (from v1: Ctrl+Alt+Shift+9)
            Send("^!+9")
            ShowCenteredToolTip("DRAW MODE")
            SetTimer(RemoveToolTip, -1500)
        case "z":
            ; Zoom (from v1: Ctrl+Alt+Shift+1)
            Send("^!+1")
            ShowCenteredToolTip("ZOOM MODE")
            SetTimer(RemoveToolTip, -1500)
        case "c":
            ; Zoom with cursor (from v1: Ctrl+Alt+Shift+4)
            Send("^!+4")
            ShowCenteredToolTip("ZOOM CURSOR")
            SetTimer(RemoveToolTip, -1500)
        case "j":
            ; Persistent blind switch - start mode
            StartPersistentBlindSwitch()
        case "k":
            ; This will be handled in persistent mode
            StartPersistentBlindSwitch()
        default:
            ShowCenteredToolTip("Unknown action: " . action)
            SetTimer(RemoveToolTip, -1500)
    }
}

; Persistent blind switch mode (no taskbar, instant switching)
StartPersistentBlindSwitch() {
    ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
    
    ; Persistent loop for blind switching
    Loop {
        ; Simple InputHook without complex options
        ih := InputHook("L1 T10")
        ih.Start()
        ih.Wait()
        
        ; Check what happened
        if (ih.EndReason = "Timeout") {
            ih.Stop()  ; Clean up InputHook
            ShowCenteredToolTip("BLIND SWITCH TIMEOUT")
            SetTimer(RemoveToolTip, -1000)
            break
        }
        
        ; Get the input character
        key := ih.Input
        ih.Stop()  ; Clean up InputHook after getting input
        
        ; Handle the key
        if (key = "j") {
            ; Next window
            Send("!{Tab}")
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        }
        else if (key = "k") {
            ; Previous window
            Send("!+{Tab}")
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        }
        else if (key = Chr(13) || key = Chr(10)) {  ; Enter (try both CR and LF)
            ShowCenteredToolTip("BLIND SWITCH ENDED")
            SetTimer(RemoveToolTip, -1000)
            break
        }
        else if (key = Chr(27)) {  ; Escape
            ShowCenteredToolTip("BLIND SWITCH CANCELLED")
            SetTimer(RemoveToolTip, -1000)
            break
        }
        ; For any other key, just continue the loop
    }
}

; Visual window switch function removed - using only blind switch j/k

; Timestamp mode handler
HandleTimestampMode(mode) {
    switch mode {
        case "d":
            ; Date formats submenu
            Loop {
                ShowDateFormatsMenu()
                dateInput := InputHook("L1 T10")
                dateInput.Start()
                dateInput.Wait()
                
                if (dateInput.EndReason = "Timeout" || dateInput.Input = Chr(27)) {  ; Escape
                    dateInput.Stop()  ; Clean up InputHook
                    return  ; Exit timestamp mode
                }
                if (dateInput.Input = Chr(8)) {  ; Backspace
                    dateInput.Stop()  ; Clean up InputHook
                    break  ; Back to timestamp menu
                }
                
                WriteTimestampFromKey("date", dateInput.Input)
                return  ; Exit after inserting timestamp
            }
        case "t":
            ; Time formats submenu
            Loop {
                ShowTimeFormatsMenu()
                timeInput := InputHook("L1 T10")
                timeInput.Start()
                timeInput.Wait()
                
                if (timeInput.EndReason = "Timeout" || timeInput.Input = Chr(27)) {  ; Escape
                    timeInput.Stop()  ; Clean up InputHook
                    return  ; Exit timestamp mode
                }
                if (timeInput.Input = Chr(8)) {  ; Backspace
                    timeInput.Stop()  ; Clean up InputHook
                    break  ; Back to timestamp menu
                }
                
                WriteTimestampFromKey("time", timeInput.Input)
                return  ; Exit after inserting timestamp
            }
        case "h":
            ; DateTime formats submenu
            Loop {
                ShowDateTimeFormatsMenu()
                datetimeInput := InputHook("L1 T10")
                datetimeInput.Start()
                datetimeInput.Wait()
                
                if (datetimeInput.EndReason = "Timeout" || datetimeInput.Input = Chr(27)) {  ; Escape
                    datetimeInput.Stop()  ; Clean up InputHook
                    return  ; Exit timestamp mode
                }
                if (datetimeInput.Input = Chr(8)) {  ; Backspace
                    datetimeInput.Stop()  ; Clean up InputHook
                    break  ; Back to timestamp menu
                }
                
                WriteTimestampFromKey("datetime", datetimeInput.Input)
                return  ; Exit after inserting timestamp
            }
        default:
            ShowCenteredToolTip("Unknown timestamp mode: " . mode)
            SetTimer(RemoveToolTip, -1500)
    }
}

; Information insertion from key
InsertInformationFromKey(keyPressed) {
    global InfoIni, tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    ; Read the information name mapped to this key
    keyName := "key_" . keyPressed
    infoName := IniRead(InfoIni, "InfoMapping", keyName, "")
    
    ; If no mapping found, show error
    if (infoName = "" || infoName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to information.ini`n[InfoMapping]")
        SetTimer(RemoveToolTip, -3500)
        return
    }
    
    ; Read the information content for this key
    infoContent := IniRead(InfoIni, "PersonalInfo", infoName, "")
    if (infoContent = "" || infoContent = "ERROR") {
        ShowCenteredToolTip(infoName . " not found in [PersonalInfo].`nAdd content to information.ini")
        SetTimer(RemoveToolTip, -3500)
        return
    }
    
    ; Insert the information content
    SendText(infoContent)
    ShowInformationInserted(infoName)
}

ShowInformationInserted(infoName) {
    ShowCenteredToolTip(infoName . " INSERTED")
    SetTimer(RemoveToolTip, -1500)
}

; Timestamp menu functions
ShowDateFormatsMenu() {
    if (tooltipConfig.enabled) {
        ShowDateFormatsMenuCS()
    } else {
        ; Fallback to native tooltips
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "DATE FORMATS`n`n"
        
        ; Read menu lines dynamically from timestamps.ini
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "date_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowTimeFormatsMenu() {
    if (tooltipConfig.enabled) {
        ShowTimeFormatsMenuCS()
    } else {
        ; Fallback to native tooltips
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "TIME FORMATS`n`n"
        
        ; Read menu lines dynamically from timestamps.ini
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "time_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowDateTimeFormatsMenu() {
    if (tooltipConfig.enabled) {
        ShowDateTimeFormatsMenuCS()
    } else {
        ; Fallback to native tooltips
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 140
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "DATE+TIME FORMATS`n`n"
        
        ; Read menu lines dynamically from timestamps.ini
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "datetime_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; Timestamp writer function
WriteTimestampFromKey(mode, keyPressed) {
    global TimestampsIni, tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    ; Determine format key name based on mode and key pressed
    if (mode = "date") {
        if (keyPressed = "d") {
            ; Use default format
            defaultNum := IniRead(TimestampsIni, "DateFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateFormats"
    } else if (mode = "time") {
        if (keyPressed = "t") {
            ; Use default format
            defaultNum := IniRead(TimestampsIni, "TimeFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "TimeFormats"
    } else if (mode = "datetime") {
        if (keyPressed = "h") {
            ; Use default format
            defaultNum := IniRead(TimestampsIni, "DateTimeFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateTimeFormats"
    }
    
    ; Read the format string
    formatString := IniRead(TimestampsIni, sectionName, formatKey, "")
    
    ; If format not found, show error
    if (formatString = "" || formatString = "ERROR") {
        ShowCenteredToolTip("Format '" . keyPressed . "' not found in " . sectionName)
        SetTimer(RemoveToolTip, -3500)
        return
    }
    
    ; Generate and insert timestamp
    timestamp := FormatTime(, formatString)
    SendText(timestamp)
    ShowCenteredToolTip("TIMESTAMP: " . timestamp)
    SetTimer(RemoveToolTip, -2000)
}

;-------------------------------------------------------------------------------
; SECTION 9: COMMANDS LAYER (v2 - Phase 7)
;-------------------------------------------------------------------------------

; Commands layer implementation - accessed via Leader mode (CapsLock + Space → c)

; Main commands menu
ShowCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "COMMAND PALETTE`n`n"
        
        ; Try to read from commands.ini, fallback to hardcoded menu
        hasConfigMenu := false
        Loop 20 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "main_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
                hasConfigMenu := true
            }
        }
        
        ; If no config found, show hardcoded menu with all options
        if (!hasConfigMenu) {
            menuText .= "s - System Commands`n"
            menuText .= "n - Network Commands`n"
            menuText .= "g - Git Commands`n"
            menuText .= "m - Monitoring Commands`n"
            menuText .= "f - Folder Commands`n"
            menuText .= "w - Windows Commands`n"
            menuText .= "o - Power Options`n"
            menuText .= "a - ADB Tools`n"
            menuText .= "v - VaultFlow`n"
            menuText .= "h - Hybrid Management`n"
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; Command category handler
HandleCommandCategory(category) {
    switch category {
        case "s":
            ; System Commands
            Loop {
                ShowSystemCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteSystemCommand(categoryInput.Input)
                categoryInput.Stop()  ; Clean up InputHook
                return  ; Exit after executing command
            }
        case "n":
            ; Network Commands
            Loop {
                ShowNetworkCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteNetworkCommand(categoryInput.Input)
                categoryInput.Stop()  ; Clean up InputHook
                return  ; Exit after executing command
            }
        case "g":
            ; Git Commands
            Loop {
                ShowGitCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    categoryInput.Stop()  ; Clean up InputHook
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteGitCommand(categoryInput.Input)
                categoryInput.Stop()  ; Clean up InputHook
                return  ; Exit after executing command
            }
        case "m":
            ; Monitoring Commands
            Loop {
                ShowMonitoringCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteMonitoringCommand(categoryInput.Input)
                return  ; Exit after executing command
            }
        case "f":
            ; Folder Commands
            Loop {
                ShowFolderCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteFolderCommand(categoryInput.Input)
                return  ; Exit after executing command
            }
        case "w":
            ; Windows Commands
            Loop {
                ShowWindowsCommandsMenu()
                categoryInput := InputHook("L1 T10")
                categoryInput.Start()
                categoryInput.Wait()
                
                if (categoryInput.EndReason = "Timeout" || categoryInput.Input = Chr(27)) {  ; Escape
                    return  ; Exit command category
                }
                if (categoryInput.Input = Chr(8)) {  ; Backspace
                    return  ; Back to commands menu (exit this category)
                }
                
                ExecuteWindowsCommand(categoryInput.Input)
                return  ; Exit after executing command
            }
        default:
            ShowCenteredToolTip("Unknown command category: " . category)
            SetTimer(RemoveToolTip, -1500)
    }
}

; Command menu functions
ShowSystemCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowSystemCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "SYSTEM COMMANDS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "system_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowNetworkCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowNetworkCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 70
        menuText := "NETWORK COMMANDS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "network_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowGitCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowGitCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "GIT COMMANDS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "git_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowMonitoringCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowMonitoringCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "MONITORING COMMANDS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "monitoring_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowFolderCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowFolderCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "FOLDER ACCESS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "folder_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowWindowsCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowWindowsCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "WINDOWS COMMANDS`n`n"
        
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "windows_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowPowerOptionsCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowPowerOptionsCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "POWER OPTIONS`n`n"
        menuText .= "s - Sleep`n"
        menuText .= "h - Hibernate`n"
        menuText .= "r - Restart`n"
        menuText .= "S - Shutdown`n"
        menuText .= "l - Lock Screen`n"
        menuText .= "o - Sign Out`n"
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowADBCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowADBCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "ADB TOOLS`n`n"
        menuText .= "d - List Devices`n"
        menuText .= "i - Install APK`n"
        menuText .= "u - Uninstall Package`n"
        menuText .= "l - Logcat`n"
        menuText .= "s - Shell`n"
        menuText .= "r - Reboot Device`n"
        menuText .= "c - Clear App Data`n"
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowHybridManagementMenu() {
    if (tooltipConfig.enabled) {
        ShowHybridManagementMenuCS()
    } else {
        ; Fallback to native tooltips
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 80
        menuText := "HYBRID MANAGEMENT`n`n"
        menuText .= "r - Reload Script`n"
        menuText .= "e - Exit Script`n"
        menuText .= "c - Open Config Folder`n"
        menuText .= "l - View Log File`n"
        menuText .= "v - Show Version Info`n"
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowVaultFlowCommandsMenu() {
    if (tooltipConfig.enabled) {
        ShowVaultFlowCommandsMenuCS()
    } else {
        ; Fallback to native tooltips
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 60
        menuText := "VAULTFLOW COMMANDS`n`n"
        
        ; Try to read from commands.ini first
        hasConfigMenu := false
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "vaultflow_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
                hasConfigMenu := true
            }
        }
        
        ; If no config found, show hardcoded menu
        if (!hasConfigMenu) {
            menuText .= "v - Run VaultFlow`n"
            menuText .= "s - VaultFlow Status`n"
            menuText .= "l - List Vaults`n"
            menuText .= "h - VaultFlow Help`n"
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; Command execution functions
ExecuteSystemCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "s":
            Run("cmd.exe /k systeminfo")
        case "t":
            Run("taskmgr.exe")
        case "v":
            Run("services.msc")
        case "e":
            Run("eventvwr.msc")
        case "d":
            Run("devmgmt.msc")
        case "c":
            Run("cleanmgr.exe")
        default:
            ShowCenteredToolTip("Unknown system command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
    ShowCommandExecuted("System", cmd)
}

ExecuteNetworkCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "i":
            Run("cmd.exe /k ipconfig /all")
        case "p":
            Run("cmd.exe /k ping google.com")
        case "n":
            Run("cmd.exe /k netstat -an")
        default:
            ShowCenteredToolTip("Unknown network command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
    ShowCommandExecuted("Network", cmd)
}

ExecuteGitCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "s":
            Run("cmd.exe /k git status")
        case "l":
            Run("cmd.exe /k git log --oneline -10")
        case "b":
            Run("cmd.exe /k git branch -a")
        case "d":
            Run("cmd.exe /k git diff")
        case "a":
            Run("cmd.exe /k git add .")
        case "p":
            Run("cmd.exe /k git pull")
        default:
            ShowCenteredToolTip("Unknown git command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
    ShowCommandExecuted("Git", cmd)
}

ExecuteMonitoringCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "p":
            Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "s":
            Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "d":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "m":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "c":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        default:
            ShowCenteredToolTip("Unknown monitoring command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
    ShowCommandExecuted("Monitoring", cmd)
}

ExecuteFolderCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "t":
            Run('explorer.exe "' . EnvGet("TEMP") . '"')
        case "a":
            Run('explorer.exe "' . EnvGet("APPDATA") . '"')
        case "p":
            Run('explorer.exe "C:\Program Files"')
        case "u":
            Run('explorer.exe "' . EnvGet("USERPROFILE") . '"')
        case "d":
            Run('explorer.exe "' . EnvGet("USERPROFILE") . '\Desktop"')
        case "s":
            Run('explorer.exe "C:\Windows\System32"')
        default:
            ShowCenteredToolTip("Unknown folder command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
    ShowCommandExecuted("Folder", cmd)
}

ExecuteWindowsCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "h":
            ToggleHiddenFiles()
        case "r":
            Run("regedit.exe")
            ShowCommandExecuted("Windows", "Registry Editor")
        case "e":
            Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
            ShowCommandExecuted("Windows", "Environment Variables")
        default:
            ShowCenteredToolTip("Unknown windows command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
}

ExecutePowerOptionsCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "s":
            ; Sleep
            DllCall("PowrProf.dll\SetSuspendState", "int", 0, "int", 0, "int", 0)
            ShowCommandExecuted("Power", "Sleep")
        case "h":
            ; Hibernate
            DllCall("PowrProf.dll\SetSuspendState", "int", 1, "int", 0, "int", 0)
            ShowCommandExecuted("Power", "Hibernate")
        case "r":
            ; Restart
            Run("shutdown.exe /r /t 0")
            ShowCommandExecuted("Power", "Restart")
        case "S":
            ; Shutdown (Shift+s)
            Run("shutdown.exe /s /t 0")
            ShowCommandExecuted("Power", "Shutdown")
        case "l":
            ; Lock Screen
            DllCall("user32.dll\LockWorkStation")
            ShowCommandExecuted("Power", "Lock Screen")
        case "o":
            ; Sign Out
            Run("shutdown.exe /l")
            ShowCommandExecuted("Power", "Sign Out")
        default:
            ShowCenteredToolTip("Unknown power command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
}

ExecuteADBCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "d":
            Run("cmd.exe /k adb devices")
            ShowCommandExecuted("ADB", "List Devices")
        case "i":
            Run("cmd.exe /k echo Select APK file to install && pause && adb install")
            ShowCommandExecuted("ADB", "Install APK")
        case "u":
            Run("cmd.exe /k echo Enter package name to uninstall && pause && adb uninstall")
            ShowCommandExecuted("ADB", "Uninstall Package")
        case "l":
            Run("cmd.exe /k adb logcat")
            ShowCommandExecuted("ADB", "Logcat")
        case "s":
            Run("cmd.exe /k adb shell")
            ShowCommandExecuted("ADB", "Shell")
        case "r":
            Run("cmd.exe /k adb reboot")
            ShowCommandExecuted("ADB", "Reboot Device")
        case "c":
            Run("cmd.exe /k echo Enter package name to clear data && pause && adb shell pm clear")
            ShowCommandExecuted("ADB", "Clear App Data")
        default:
            ShowCenteredToolTip("Unknown ADB command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
}

ExecuteHybridManagementCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "r":
            ; Reload Script
            ShowCenteredToolTip("RELOADING SCRIPT...")
            SetTimer(RemoveToolTip, -1000)
            Sleep(1000)
            ; Use A_ScriptFullPath to reload the current script regardless of name or location
            Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"')
            ExitApp()
        case "e":
            ; Exit Script
            ShowCenteredToolTip("EXITING SCRIPT...")
            SetTimer(RemoveToolTip, -1000)
            Sleep(1000)
            ExitApp()
        case "c":
            ; Open Config Folder
            Run('explorer.exe "' . A_ScriptDir . '\config"')
            ShowCommandExecuted("Hybrid", "Config Folder")
        case "l":
            ; View Log File (if exists)
            logFile := A_ScriptDir . "\hybrid_log.txt"
            if (FileExist(logFile)) {
                Run('notepad.exe "' . logFile . '"')
            } else {
                ShowCenteredToolTip("No log file found")
                SetTimer(RemoveToolTip, -2000)
                return
            }
            ShowCommandExecuted("Hybrid", "Log File")
        case "v":
            ; Show Version Info
            ShowCenteredToolTip("HybridCapsLock v2`nAutoHotkey " . A_AhkVersion . "`nScript: " . A_ScriptName)
            SetTimer(RemoveToolTip, -3000)
            return
        default:
            ShowCenteredToolTip("Unknown hybrid command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
}

ExecuteVaultFlowCommand(cmd) {
    global tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    switch cmd {
        case "v":
            ; Run VaultFlow
            Run("powershell.exe -Command `"vaultflow`"")
            ShowCommandExecuted("VaultFlow", "Run VaultFlow")
        case "s":
            ; VaultFlow Status
            Run("cmd.exe /k vaultflow status")
            ShowCommandExecuted("VaultFlow", "Status")
        case "l":
            ; List Vaults
            Run("cmd.exe /k vaultflow list")
            ShowCommandExecuted("VaultFlow", "List Vaults")
        case "h":
            ; VaultFlow Help
            Run("cmd.exe /k vaultflow --help")
            ShowCommandExecuted("VaultFlow", "Help")
        default:
            ShowCenteredToolTip("Unknown VaultFlow command: " . cmd)
            SetTimer(RemoveToolTip, -1500)
            return
    }
}

; Helper functions for commands
ShowCommandExecuted(category, command) {
    if (tooltipConfig.enabled) {
        ShowCommandExecutedCS(category, command)
    } else {
        ShowCenteredToolTip(category . " command executed: " . command)
        SetTimer(RemoveToolTip, -2000)
    }
}

ToggleHiddenFiles() {
    ; Toggle hidden files visibility in Explorer
    try {
        RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
        currentValue := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
        newValue := (currentValue = 1) ? 2 : 1
        RegWrite(newValue, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
        
        ; Refresh Explorer windows
        Send("{F5}")
        
        statusText := (newValue = 1) ? "HIDDEN FILES SHOWN" : "HIDDEN FILES HIDDEN"
        ShowCenteredToolTip(statusText)
        SetTimer(RemoveToolTip, -2000)
    } catch Error as err {
        ShowCenteredToolTip("Error toggling hidden files")
        SetTimer(RemoveToolTip, -2000)
    }
}

; Leader mode menu function (Enhanced with C# tooltips)
ShowLeaderModeMenu() {
    if (tooltipConfig.enabled) {
        ShowLeaderModeMenuCS()
    } else {
        ; Fallback to native tooltips
        menuText := "`n LEADER MODE `n"
        menuText .= "p - Programs`n"
        menuText .= "t - Timestamps`n" 
        menuText .= "c - Commands`n"
        menuText .= "i - Information`n"
        menuText .= "w - Windows`n"
        menuText .= "n - Excel/Numbers`n"
        menuText .= "`n\\ - Back | ESC - Exit`n"
        
        ToolTipX := A_ScreenWidth // 2 - 100
        ToolTipY := A_ScreenHeight // 2 - 100
        ToolTip(menuText, ToolTipX, ToolTipY)
    }
}

; Enhanced UpdateLayerStatus function
UpdateLayerStatus() {
    ; Update JSON file with current layer states for Zebar integration
    currentTime := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    
    ; Check if temporary status has expired
    if (A_TickCount > tempStatusExpiry) {
        global currentTempStatus := ""
    }
    
    jsonContent := "{"
    jsonContent .= '"nvim_layer": ' . (isNvimLayerActive ? "true" : "false") . ","
    jsonContent .= '"excel_layer": ' . (excelLayerActive ? "true" : "false") . ","
    jsonContent .= '"visual_mode": ' . (VisualMode ? "true" : "false") . ","
    jsonContent .= '"leader_active": ' . (leaderActive ? "true" : "false") . ","
    jsonContent .= '"temp_status": "' . currentTempStatus . '",'
    jsonContent .= '"last_updated": "' . currentTime . '"'
    jsonContent .= "}"
    
    ; Write to JSON file for Zebar integration
    try {
        FileDelete(LayerStatusFile)
        FileAppend(jsonContent, LayerStatusFile)
    } catch Error as err {
        ; Silent fail - don't interrupt workflow if file can't be written
    }
}

;-------------------------------------------------------------------------------
; SECTION 4: MODIFIER MODE HOTKEYS (v2 - Phase 2)
;-------------------------------------------------------------------------------

; ----- Window Functions -----
CapsLock & 1::WinMinimize("A")
CapsLock & `::Send("#m")  ; Minimize all windows
CapsLock & q::Send("!{F4}")  ; Close window (Alt+F4)

; Maximize/Restore toggle
CapsLock & f:: {
    winState := WinGetMinMax("A")
    if (winState = 1)
        WinRestore("A")
    else
        WinMaximize("A")
}

; ----- Basic Navigation (Vim Style) -----
CapsLock & h:: {
    MarkCapsLockAsModifier()
    Send("{Left}")
}
CapsLock & j:: {
    MarkCapsLockAsModifier()
    Send("{Down}")
}
CapsLock & k:: {
    MarkCapsLockAsModifier()
    Send("{Up}")
}
CapsLock & l:: {
    MarkCapsLockAsModifier()
    Send("{Right}")
}

; ----- Smooth Scrolling -----
CapsLock & e:: {
    MarkCapsLockAsModifier()
    Send("{WheelDown 3}")
}
CapsLock & d:: {
    MarkCapsLockAsModifier()
    Send("{WheelUp 3}")
}

; ----- Common Shortcuts (Ctrl equivalents) -----
CapsLock & a:: {
    MarkCapsLockAsModifier()
    Send("^a")  ; Select all
}
CapsLock & s:: {
    MarkCapsLockAsModifier()
    Send("^s")  ; Save
}
CapsLock & c:: {
    MarkCapsLockAsModifier()
    Send("^c")  ; Copy
    ShowCopyNotification()
}
CapsLock & v:: {
    MarkCapsLockAsModifier()
    Send("^v")  ; Paste
}
CapsLock & x:: {
    MarkCapsLockAsModifier()
    Send("^x")  ; Cut
}
CapsLock & z:: {
    MarkCapsLockAsModifier()
    Send("^z")  ; Undo
}
CapsLock & o:: {
    MarkCapsLockAsModifier()
    Send("^o")  ; Open
}
CapsLock & t:: {
    MarkCapsLockAsModifier()
    Send("^t")  ; New tab
}
CapsLock & r:: {
    MarkCapsLockAsModifier()
    Send("{F5}")  ; Refresh
}

; ----- Enhanced Alt+Tab -----
CapsLock & Tab:: {
    global capsLockUsedAsModifier
    ; Mark that CapsLock was used as a modifier
    capsLockUsedAsModifier := true
    
    ; Start Alt+Tab sequence
    Send("{Alt down}{Tab}")
    
    ; Wait for Tab to be released
    KeyWait("Tab")
    
    ; Continue Alt+Tab while CapsLock is held
    while GetKeyState("CapsLock", "P") {
        if GetKeyState("Tab", "P") {
            Send("{Tab}")
            KeyWait("Tab")
        }
        Sleep(10)
    }
    
    ; Release Alt
    Send("{Alt up}")
}

; ----- Click Functions -----
CapsLock & `;:: {
    global rightClickHeld, capsLockUsedAsModifier
    ; Mark that CapsLock was used as a modifier
    capsLockUsedAsModifier := true
    
    ; Start left click hold
    Click("Left", , , 1, 0, "D")  ; Down
    rightClickHeld := true
    ShowLeftClickStatus(true)
    SetTempStatus("LEFT CLICK HELD", 1200)
    SetTimer(RemoveToolTip, -1200)
    
    ; Wait for release
    KeyWait("CapsLock")
    KeyWait(";")
    
    ; Release left click
    Click("Left", , , 1, 0, "U")  ; Up
    rightClickHeld := false
    ShowLeftClickStatus(false)
    SetTimer(RemoveToolTip, -1200)
}

CapsLock & ':: {
    global capsLockUsedAsModifier
    ; Mark that CapsLock was used as a modifier
    capsLockUsedAsModifier := true
    
    ; Simple right click
    Click("Right")
    ShowRightClickStatus(true)
    SetTempStatus("RIGHT CLICK", 1200)
    SetTimer(RemoveToolTip, -1200)
}

; ----- Additional Shortcuts -----
CapsLock & 2:: {
    MarkCapsLockAsModifier()
    Send("^+!{2}")
}
CapsLock & 3:: {
    MarkCapsLockAsModifier()
    Send("!a")
}
CapsLock & 4:: {
    MarkCapsLockAsModifier()
    Send("!s")
}
CapsLock & i:: {
    MarkCapsLockAsModifier()
    Send("^!k")
}
CapsLock & w:: {
    MarkCapsLockAsModifier()
    Send("^w")
}
CapsLock & m:: {
    MarkCapsLockAsModifier()
    Send("^{PgDn}")
}
CapsLock & u:: {
    MarkCapsLockAsModifier()
    Send("^{PgUp}")
}
CapsLock & g:: {
    MarkCapsLockAsModifier()
    Send("^!+g")  ; Missing hotkey from v1
}
CapsLock & [:: {
    MarkCapsLockAsModifier()
    Send("^!+{[}")
}
CapsLock & ]:: {
    MarkCapsLockAsModifier()
    Send("^!+{]}")
}

; ----- Window Management (GlazeWM) -----
CapsLock & Left:: {
    MarkCapsLockAsModifier()
    Send("!+h")
}
CapsLock & Up:: {
    MarkCapsLockAsModifier()
    Send("!+k")
}
CapsLock & Down:: {
    MarkCapsLockAsModifier()
    Send("!+j")
}
CapsLock & Right:: {
    MarkCapsLockAsModifier()
    Send("!+l")
}

; ----- Utility Functions -----
CapsLock & \::SendText("your.email@example.com")
CapsLock & p::Send("+!p")
CapsLock & Enter::Send("^{Enter}")
CapsLock & 9::Send("#+s")
CapsLock & 6::Send("#{Left}")
CapsLock & 7::Send("#{Right}")
CapsLock & Backspace::Send("!{Left}")

; ----- Address Bar Copy (CapsLock & 5) -----
CapsLock & 5:: {
    winClass := WinGetClass("A")
    if (InStr(winClass, "CabinetWClass") || InStr(winClass, "ExploreWClass")) {
        Send("!d")
        Sleep(100)
        Send("^c")
        Sleep(50)
        Send("{Esc}")
    } else {
        Send("^l")
        Sleep(100)
        Send("^c")
        Sleep(50)
        Send("{Esc}")
    }
}

; ----- CapsLock Toggle (F10) -----
CapsLock & F10:: {
    global capsActsNormal
    capsActsNormal := !capsActsNormal
    if (capsActsNormal) {
        SetCapsLockState("Off")
        ShowCapsLockStatus(true)
    } else {
        SetCapsLockState("AlwaysOff")
        ShowCapsLockStatus(false)
    }
    SetTimer(RemoveToolTip, -1200)
}

; ----- Process Termination (F12) -----
CapsLock & F12:: {
    activePid := WinGetPID("A")
    if (activePid) {
        ProcessClose(activePid)
        ShowProcessTerminated()
        SetTimer(RemoveToolTip, -1500)
    }
}

;-------------------------------------------------------------------------------
; SECTION 5: HYBRID LOGIC (v2 - Phase 3)
;-------------------------------------------------------------------------------

; Core hybrid functionality: CapsLock tap vs hold detection
CapsLock:: {
    global capsActsNormal, capsLockWasHeld, capsLockUsedAsModifier
    
    ; If CapsLock is in normal mode, act as regular CapsLock
    if (capsActsNormal) {
        Send("{CapsLock}")
        return
    }
    
    ; Reset the flags when key is pressed
    capsLockWasHeld := false
    capsLockUsedAsModifier := false
    
    ; Wait for key release with timeout (0.2 seconds)
    ; If timeout expires, user is HOLDING the key
    if (!KeyWait("CapsLock", "T0.2")) {
        ; Timeout expired - user is holding CapsLock
        capsLockWasHeld := true
        ; Wait for final release
        KeyWait("CapsLock")
    }
}

CapsLock Up:: {
    global capsActsNormal, capsLockWasHeld, capsLockUsedAsModifier, isNvimLayerActive, VisualMode
    
    ; If CapsLock is in normal mode, do nothing
    if (capsActsNormal) {
        return
    }
    
    ; Only activate Nvim layer if it was a clean TAP (not held and not used as modifier)
    if (!capsLockWasHeld && !capsLockUsedAsModifier) {
        ; Toggle Nvim layer on clean tap
        isNvimLayerActive := !isNvimLayerActive
        
        if (isNvimLayerActive) {
            ShowNvimLayerStatus(true)
            SetTempStatus("NVIM LAYER ON", 1500)
        } else {
            ShowNvimLayerStatus(false)
            SetTempStatus("NVIM LAYER OFF", 1500)
            VisualMode := false
        }
        
        UpdateLayerStatus()
        SetTimer(RemoveToolTip, -1500)
    }
    
    ; Reset the flags for next use
    capsLockWasHeld := false
    capsLockUsedAsModifier := false
}

; Leader Mode: CapsLock + Space activates command palette
CapsLock & Space:: {
    global leaderActive, isNvimLayerActive, VisualMode, capsLockUsedAsModifier
    
    ; Mark that CapsLock was used as a modifier
    capsLockUsedAsModifier := true
    
    ; Deactivate Nvim Layer if it's active when leader is called
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        VisualMode := false
        ShowNvimLayerStatus(false)
        UpdateLayerStatus()
        SetTimer(RemoveToolTip, -1200)
        Sleep(50)  ; Brief pause to ensure state change is registered
    }
    
    leaderActive := true
    
    ; Navigation stack to track menu hierarchy
    menuStack := []
    currentMenu := "main"
    
    ; Main leader loop with proper back navigation
    Loop {
        ; Show current menu based on stack
        switch currentMenu {
            case "main":
                ShowLeaderModeMenu()
            case "programs":
                ShowProgramMenu()
            case "windows":
                ShowWindowMenu()
            case "timestamps":
                ShowTimeMenu()
            case "information":
                ShowInformationMenu()
            case "commands":
                ShowCommandsMenu()
            default:
                ; Handle submenu cases
                if (InStr(currentMenu, "commands_")) {
                    category := StrReplace(currentMenu, "commands_", "")
                    ; Show the appropriate command category menu
                    switch category {
                        case "system":
                            ShowSystemCommandsMenu()
                        case "network":
                            ShowNetworkCommandsMenu()
                        case "git":
                            ShowGitCommandsMenu()
                        case "monitoring":
                            ShowMonitoringCommandsMenu()
                        case "folder":
                            ShowFolderCommandsMenu()
                        case "windows":
                            ShowWindowsCommandsMenu()
                        case "power":
                            ShowPowerOptionsCommandsMenu()
                        case "adb":
                            ShowADBCommandsMenu()
                        case "hybrid":
                            ShowHybridManagementMenu()
                        case "vaultflow":
                            ShowVaultFlowCommandsMenu()
                    }
                } else if (InStr(currentMenu, "timestamps_")) {
                    mode := StrReplace(currentMenu, "timestamps_", "")
                    ; Show the appropriate timestamp menu
                    switch mode {
                        case "date":
                            ShowDateFormatsMenu()
                        case "time":
                            ShowTimeFormatsMenu()
                        case "datetime":
                            ShowDateTimeFormatsMenu()
                    }
                }
        }
        
        userInput := InputHook("L1 T10")
        userInput.KeyOpt("{Backspace}", "+")  ; Enable Backspace detection
        userInput.KeyOpt("{Escape}", "+")     ; Enable Escape detection
        userInput.Start()
        userInput.Wait()
        
        if (userInput.EndReason = "Timeout") {
            userInput.Stop()  ; Clean up InputHook
            break  ; Exit completely
        }
        
        ; Check if it was a special key
        if (userInput.EndReason = "KeyDown") {
            if (userInput.EndKey = "Escape") {
                userInput.Stop()
                break  ; Exit completely
            }
        }
        
        _key := userInput.Input
        userInput.Stop()  ; Clean up InputHook after getting input
        
        ; Check for Escape via input (backup method)
        if (_key = Chr(27)) {  ; Escape
            break  ; Exit completely
        }
        
        ; Use backslash (\) as temporary back navigation key
        if (_key = "\") {
            if (menuStack.Length > 0) {
                currentMenu := menuStack.Pop()  ; Go back to previous menu
                continue
            } else {
                break  ; Exit if at main menu
            }
        }
        
        ; Handle navigation based on current menu
        switch currentMenu {
            case "main":
                ; Main menu navigation
                switch _key {
                    case "p":
                        menuStack.Push(currentMenu)
                        currentMenu := "programs"
                    case "w":
                        menuStack.Push(currentMenu)
                        currentMenu := "windows"
                    case "t":
                        menuStack.Push(currentMenu)
                        currentMenu := "timestamps"
                    case "i":
                        menuStack.Push(currentMenu)
                        currentMenu := "information"
                    case "c":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands"
                    case "n":
                        ; Excel layer toggle (direct action)
                        global excelLayerActive
                        excelLayerActive := !excelLayerActive
                        if (excelLayerActive) {
                            ShowExcelLayerStatus(true)
                            SetTempStatus("EXCEL LAYER ON", 2000)
                        } else {
                            ShowExcelLayerStatus(false)
                            SetTempStatus("EXCEL LAYER OFF", 2000)
                        }
                        UpdateLayerStatus()
                        SetTimer(RemoveToolTip, -2000)
                        break  ; Exit after toggle
                    default:
                        ShowCenteredToolTip("Unknown option: " . _key)
                        SetTimer(RemoveToolTip, -1000)
                }
            
            case "programs":
                ; Programs menu - launch program and exit
                LaunchProgramFromKey(_key)
                break
            
            case "windows":
                ; Windows menu - execute action and exit
                ExecuteWindowAction(_key)
                break
            
            case "information":
                ; Information menu - insert info and exit
                InsertInformationFromKey(_key)
                break
            
            case "timestamps":
                ; Timestamps menu navigation
                switch _key {
                    case "d":
                        menuStack.Push(currentMenu)
                        currentMenu := "timestamps_date"
                    case "t":
                        menuStack.Push(currentMenu)
                        currentMenu := "timestamps_time"
                    case "h":
                        menuStack.Push(currentMenu)
                        currentMenu := "timestamps_datetime"
                    default:
                        ShowCenteredToolTip("Unknown timestamp option: " . _key)
                        SetTimer(RemoveToolTip, -1000)
                }
            
            case "commands":
                ; Commands menu navigation
                switch _key {
                    case "s":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_system"
                    case "n":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_network"
                    case "g":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_git"
                    case "m":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_monitoring"
                    case "f":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_folder"
                    case "w":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_windows"
                    case "o":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_power"
                    case "a":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_adb"
                    case "h":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_hybrid"
                    case "v":
                        menuStack.Push(currentMenu)
                        currentMenu := "commands_vaultflow"
                    default:
                        ShowCenteredToolTip("Unknown command category: " . _key)
                        SetTimer(RemoveToolTip, -1000)
                }
            
            default:
                ; Handle submenu actions
                if (InStr(currentMenu, "commands_")) {
                    category := StrReplace(currentMenu, "commands_", "")
                    ; Execute command based on category
                    switch category {
                        case "system":
                            ExecuteSystemCommand(_key)
                        case "network":
                            ExecuteNetworkCommand(_key)
                        case "git":
                            ExecuteGitCommand(_key)
                        case "monitoring":
                            ExecuteMonitoringCommand(_key)
                        case "folder":
                            ExecuteFolderCommand(_key)
                        case "windows":
                            ExecuteWindowsCommand(_key)
                        case "power":
                            ExecutePowerOptionsCommand(_key)
                        case "adb":
                            ExecuteADBCommand(_key)
                        case "hybrid":
                            ExecuteHybridManagementCommand(_key)
                        case "vaultflow":
                            ExecuteVaultFlowCommand(_key)
                    }
                    break  ; Exit after executing command
                } else if (InStr(currentMenu, "timestamps_")) {
                    mode := StrReplace(currentMenu, "timestamps_", "")
                    WriteTimestampFromKey(mode, _key)
                    break  ; Exit after inserting timestamp
                }
        }
    }
    
    LeaderExit:
    leaderActive := false
    ToolTip()  ; Clear all tooltips
    ToolTip("", , , 1)
    ToolTip("", , , 2)
}

; Helper function to show command category menus
ShowCommandCategoryMenu(category) {
    switch category {
        case "system":
            ShowSystemCommandsMenu()
        case "network":
            ShowNetworkCommandsMenu()
        case "git":
            ShowGitCommandsMenu()
        case "monitoring":
            ShowMonitoringCommandsMenu()
        case "folder":
            ShowFolderCommandsMenu()
        case "windows":
            ShowWindowsCommandsMenu()
    }
}

; Helper function to show timestamp mode menus
ShowTimestampModeMenu(mode) {
    switch mode {
        case "date":
            ShowDateFormatsMenu()
        case "time":
            ShowTimeFormatsMenu()
        case "datetime":
            ShowDateTimeFormatsMenu()
    }
}

; Helper function to execute commands by category
ExecuteCommandByCategory(category, key) {
    switch category {
        case "system":
            ExecuteSystemCommand(key)
        case "network":
            ExecuteNetworkCommand(key)
        case "git":
            ExecuteGitCommand(key)
        case "monitoring":
            ExecuteMonitoringCommand(key)
        case "folder":
            ExecuteFolderCommand(key)
        case "windows":
            ExecuteWindowsCommand(key)
    }
}

;-------------------------------------------------------------------------------
; SECTION 6: NVIM LAYER CONTEXT-SENSITIVE (v2 - Phase 4)
;-------------------------------------------------------------------------------

; Nvim layer hotkeys - only active when isNvimLayerActive is true and CapsLock is not held
#HotIf (isNvimLayerActive && !GetKeyState("CapsLock", "P"))

;----------------------------------
; SECTION 6A: NVIM LAYER SPECIALS
;----------------------------------

; f: Ctrl+Alt+k and immediately deactivate nvim layer
f:: {
    global isNvimLayerActive, VisualMode
    ; Deactivate nvim layer first
    isNvimLayerActive := false
    VisualMode := false
    ShowNvimLayerStatus(false)
    UpdateLayerStatus()
    SetTimer(RemoveToolTip, -800)
    ; Small pause to exit #HotIf context
    Sleep(30)
    ; Send Ctrl+Alt+k
    Send("^!k")
}

;----------------------------------
; SECTION 6B: NVIM LAYER MAIN KEYS
;----------------------------------

; v: Visual Mode Toggle
v:: {
    global VisualMode
    VisualMode := !VisualMode
    if (VisualMode) {
        ShowVisualModeStatus(true)
    } else {
        ShowVisualModeStatus(false)
    }
    UpdateLayerStatus()
    SetTimer(RemoveToolTip, -1000)
}

; ----- Basic Navigation (hjkl) -----
h:: {
    global VisualMode
    if (VisualMode)
        Send("+{Left}")
    else
        Send("{Left}")
}

j:: {
    global VisualMode
    if (VisualMode)
        Send("+{Down}")
    else
        Send("{Down}")
}

k:: {
    global VisualMode
    if (VisualMode)
        Send("+{Up}")
    else
        Send("{Up}")
}

l:: {
    global VisualMode
    if (VisualMode)
        Send("+{Right}")
    else
        Send("{Right}")
}

; ----- Extended Navigation -----
b:: {
    global VisualMode
    if (VisualMode)
        Send("^+{Left}")
    else
        Send("^{Left}")
}

w:: {
    global VisualMode, _deleteAwait
    if (_deleteAwait) {
        _deleteAwait := false
        DeleteCurrentWord()
        SetTimer(RemoveToolTip, -100)
        return
    }
    if (VisualMode)
        Send("^+{Right}")
    else
        Send("^{Right}")
}

0:: {
    global VisualMode
    if (VisualMode)
        Send("+{Home}")
    else
        Send("{Home}")
}

+4:: {
    global VisualMode
    if (VisualMode)
        Send("+{End}")
    else
        Send("{End}")
}

; ----- Editing Actions -----
u:: {
    ; u = undo in nvim
    Send("^z")
}

+u:: {
    ; U = redo in nvim (Ctrl+Y in most editors)
    Send("^y")
}

x::Send("{Delete}")
+x::Send("{Backspace}")  ; X = delete backwards in nvim

; ESC hotkey to reactivate nvim layer after replace/insert modes (Nvim context only)
~Esc:: {
    global isNvimLayerActive, _tempEditMode
    
    ; Reactivate Nvim layer if in temp edit mode
    if (!isNvimLayerActive && _tempEditMode) {
        SetTimer(ReactivateNvimAfterReplace, 0)
        _tempEditMode := false
        isNvimLayerActive := true
        ShowNvimLayerStatus(true)
        SetTempStatus("NVIM LAYER ON", 1000)
        UpdateLayerStatus()
        SetTimer(RemoveToolTip, -1000)
    }
}

; ----- Delete Operations -----
d:: {
    global VisualMode, _deleteAwait
    if (VisualMode) {
        Send("{Delete}")
        _deleteAwait := false
        return
    }
    if (_deleteAwait) {
        _deleteAwait := false
        DeleteCurrentLine()
        SetTimer(RemoveToolTip, -100)
        return
    }
    _deleteAwait := true
    ShowDeleteMenu()
    SetTimer(DeleteTimeout, -10000)
}

; ----- Yank (Copy) Operations -----
y:: {
    global VisualMode, _yankAwait
    if (VisualMode) {
        Send("^c")
        ShowCopyNotification()
        _yankAwait := false
        return
    }
    if (_yankAwait) {
        _yankAwait := false
        CopyCurrentLine()
        SetTimer(RemoveToolTip, -100)
        return
    }
    _yankAwait := true
    ShowYankMenu()
    SetTimer(YankTimeout, -10000)
}

; ----- Paste Operations -----
p:: {
    global _yankAwait
    if (_yankAwait) {
        _yankAwait := false
        CopyCurrentParagraph()
        SetTimer(RemoveToolTip, -100)
        return
    }
    Send("^v")
}

+p::PastePlain()

; ----- All Operations (Select All) -----
a:: {
    global _deleteAwait, _yankAwait
    if (_deleteAwait) {
        _deleteAwait := false
        DeleteAll()
        SetTimer(RemoveToolTip, -100)
        return
    }
    if (_yankAwait) {
        _yankAwait := false
        Send("^a^c")
        ShowCopyNotification()
        SetTimer(RemoveToolTip, -100)
    }
}

; ----- Insert Mode -----
i:: {
    global isNvimLayerActive, _tempEditMode
    ; i = insert mode in nvim (temporarily disable nvim layer)
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("INSERT MODE", 3000)
    UpdateLayerStatus()
    SetTimer(ReactivateNvimAfterInsert, -3000)
}

; ----- Replace Mode -----
r:: {
    global isNvimLayerActive, _tempEditMode
    ; r = replace character in nvim - simplified approach
    Send("{Delete}")
    ; Temporarily disable nvim layer to allow normal typing
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("REPLACE: Type character then press ESC", 3000)
    UpdateLayerStatus()
    SetTimer(ReactivateNvimAfterReplace, -3000)
}

; ----- Smooth Scrolling -----
+e::Send("{WheelDown 3}")
+y::Send("{WheelUp 3}")

e:: {
    ; e = end of word in nvim (like w but to end)
    Send("^{Right}{Left}")
}

; ----- Open Line Operations (Vim-style) -----
o:: {
    global isNvimLayerActive, _tempEditMode
    ; o = open line below cursor and enter insert mode (like vim)
    Send("{End}{Enter}")
    ; Temporarily disable nvim layer to allow normal typing
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("INSERT MODE (o)", 3000)
    UpdateLayerStatus()
    SetTimer(ReactivateNvimAfterInsert, -3000)
}

+o:: {
    global isNvimLayerActive, _tempEditMode
    ; O (Shift+o) = open line above cursor and enter insert mode (like vim)
    Send("{Home}{Enter}{Up}")
    ; Temporarily disable nvim layer to allow normal typing
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("INSERT MODE (O)", 3000)
    UpdateLayerStatus()
    SetTimer(ReactivateNvimAfterInsert, -3000)
}

; End of Nvim Layer context
#HotIf

;-------------------------------------------------------------------------------
; SECTION 7: PROGRAMS LAYER (v2 - Phase 5)
;-------------------------------------------------------------------------------

; Programs layer implementation - accessed via Leader mode (CapsLock + Space → p)

; Enhanced Leader Mode Menu with Programs option (moved to avoid conflicts)

; Programs menu display
ShowProgramMenu() {
    if (tooltipConfig.enabled) {
        ShowProgramMenuCS()
    } else {
        ; Fallback to native tooltips
        global ProgramsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 150
        menuText := "PROGRAM LAUNCHER`n`n"
        
        ; Read menu lines dynamically from programs.ini
        Loop 10 {
            lineContent := IniRead(ProgramsIni, "MenuDisplay", "line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR") {
                menuText .= lineContent . "`n"
            }
        }
        
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; Main application launcher function
LaunchApp(appName, exeNameOrUri) {
    global ProgramsIni
    _path := ""

    ; Handle special cases like "ms-settings:" which are URIs, not files
    if (!InStr(exeNameOrUri, ".exe") && !InStr(exeNameOrUri, ".lnk")) {
        try {
            Run(exeNameOrUri)
        } catch Error as err {
            ShowCenteredToolTip("Failed to launch: " . appName)
            SetTimer(RemoveToolTip, -3000)
        }
        return
    }

    ; 1. Prioritize user-defined path from programs.ini file
    _userPath := IniRead(ProgramsIni, "Programs", appName, "")
    if (_userPath != "" && _userPath != "ERROR") {
        ; Expand environment variables like %USERPROFILE%
        _expandedPath := ExpandEnvironmentStrings(_userPath)
        if (FileExist(_expandedPath)) {
            try {
                Run('"' . _expandedPath . '"')
                return
            } catch Error as err {
                ; Continue to next method
            }
        }
    }

    ; 2. If no user path, try to resolve the executable automatically
    _resolvedPath := ResolveExecutable(exeNameOrUri)
    if (_resolvedPath != "") {
        try {
            Run('"' . _resolvedPath . '"')
            return
        } catch Error as err {
            ; Continue to error message
        }
    }

    ; 3. If all searches fail, show user-friendly tooltip
    ShowCenteredToolTip(appName . " not found.`nAdd the path to programs.ini`n[Programs]")
    SetTimer(RemoveToolTip, -3500)
}

; Resolve executable path using Windows Registry (App Paths)
ResolveExecutable(exeName) {
    ; Try to find executable in Windows Registry App Paths
    try {
        appPath := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" . exeName, "")
        if (appPath != "" && FileExist(appPath)) {
            return appPath
        }
    } catch Error as err {
        ; Registry key not found, continue
    }
    
    ; Try current user registry
    try {
        appPath := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" . exeName, "")
        if (appPath != "" && FileExist(appPath)) {
            return appPath
        }
    } catch Error as err {
        ; Registry key not found, continue
    }
    
    ; Try system PATH
    try {
        envPath := EnvGet("PATH")
        Loop Parse, envPath, ";"
        {
            testPath := A_LoopField . "\" . exeName
            if (FileExist(testPath)) {
                return testPath
            }
        }
    } catch Error as err {
        ; PATH search failed
    }
    
    return ""  ; Not found
}

; Expand environment variables in paths
ExpandEnvironmentStrings(inputPath) {
    ; Replace common environment variables
    expandedPath := inputPath
    
    ; Replace %USERPROFILE%
    try {
        userProfile := EnvGet("USERPROFILE")
        expandedPath := StrReplace(expandedPath, "%USERPROFILE%", userProfile)
    }
    
    ; Replace %PROGRAMFILES%
    try {
        programFiles := EnvGet("PROGRAMFILES")
        expandedPath := StrReplace(expandedPath, "%PROGRAMFILES%", programFiles)
    }
    
    ; Replace %PROGRAMFILES(X86)%
    try {
        programFilesX86 := EnvGet("PROGRAMFILES(X86)")
        expandedPath := StrReplace(expandedPath, "%PROGRAMFILES(X86)%", programFilesX86)
    }
    
    ; Replace %LOCALAPPDATA%
    try {
        localAppData := EnvGet("LOCALAPPDATA")
        expandedPath := StrReplace(expandedPath, "%LOCALAPPDATA%", localAppData)
    }
    
    return expandedPath
}

; Specific application launcher functions (Phase 5 implementation)
LaunchExplorer() {
    LaunchApp("Explorer", "explorer.exe")
}

LaunchSettings() {
    LaunchApp("Settings", "ms-settings:")
}

LaunchTerminal() {
    LaunchApp("Terminal", "wt.exe")
}

LaunchVisualStudio() {
    LaunchApp("VisualStudio", "code.exe")
}

LaunchObsidian() {
    LaunchApp("Obsidian", "obsidian.exe")
}

LaunchVivaldi() {
    LaunchApp("Vivaldi", "vivaldi.exe")
}

LaunchZen() {
    LaunchApp("Zen", "zen.exe")
}

LaunchThunderbird() {
    LaunchApp("Thunderbird", "thunderbird.exe")
}

LaunchWezTerm() {
    LaunchApp("WezTerm", "wezterm-gui.exe")
}

LaunchWSL() {
    LaunchApp("WSL", "wsl.exe")
}

LaunchBeeper() {
    LaunchApp("Beeper", "Beeper.exe")
}

LaunchBitwarden() {
    LaunchApp("Bitwarden", "bitwarden.exe")
}

LaunchNotepad() {
    LaunchApp("Notepad", "notepad.exe")
}

; Special case launcher for QuickShare
LaunchQuickShare() {
    ; QuickShare is a special case, often a .lnk or Store app
    _quickShareLnk := "C:\ProgramData\Microsoft\Windows\Start Menu\Quick Share.lnk"
    if (FileExist(_quickShareLnk)) {
        try {
            Run('"' . _quickShareLnk . '"')
            Sleep(1500)
            WinActivate("Quick Share")
            if (!WinActive("Quick Share")) {
                WinActivate("ahk_exe NearbyShare.exe")
            }
            return
        } catch Error as err {
            ; Continue to next method
        }
    }
    
    try {
        Run("explorer.exe shell:appsFolder\NearbyShare_21hpf16v5xp10!NearbyShare")
        Sleep(1500)
        WinActivate("Quick Share")
        if (!WinActive("Quick Share")) {
            WinActivate("ahk_exe NearbyShare.exe")
        }
        return
    } catch Error as err {
        ShowCenteredToolTip("Quick Share not found.`nPlease verify it is installed.")
        SetTimer(RemoveToolTip, -3000)
    }
}

; Dynamic program launcher that reads mapping from programs.ini
LaunchProgramFromKey(keyPressed) {
    global ProgramsIni, tooltipConfig
    
    ; Hide tooltip immediately if auto_hide_on_action is enabled
    if (tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    
    ; Read the program name mapped to this key
    keyName := "key_" . keyPressed
    programName := IniRead(ProgramsIni, "ProgramMapping", keyName, "")
    
    ; If no mapping found, show error
    if (programName = "" || programName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to programs.ini`n[ProgramMapping]")
        SetTimer(RemoveToolTip, -3500)
        return
    }
    
    ; Read the executable path for this program
    executablePath := IniRead(ProgramsIni, "Programs", programName, "")
    if (executablePath = "" || executablePath = "ERROR") {
        ShowCenteredToolTip(programName . " not found in [Programs].`nAdd path to programs.ini")
        SetTimer(RemoveToolTip, -3500)
        return
    }
    
    ; Handle special cases (like QuickShare) that need custom logic
    if (programName = "QuickShare") {
        LaunchQuickShare()
        return
    }
    
    ; Launch the program using the universal launcher
    LaunchApp(programName, executablePath)
}

;===============================================================================
; CLEANUP AND EXIT HANDLING
;===============================================================================

; Global Escape key to hide C# tooltips
~Esc:: {
    if (tooltipConfig.enabled) {
        HideCSharpTooltip()
    }
}

; Function to clean up C# tooltip app on exit
OnExit(CleanupTooltips)

CleanupTooltips(*) {
    if (tooltipConfig.enabled) {
        HideCSharpTooltip()
        StopTooltipApp()
    }
}
