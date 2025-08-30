;===============================================================================
; SCRIPT: Hybrid CapsLock Productivity (Elevated Service Version)
; AUTHOR: Wilber Canto (Vibe Codding)
; VERSION: 6.2-Elevated (Works with elevated apps but launches normal apps)
;===============================================================================
;
; _DOC: This version runs with elevated privileges to work with elevated apps
;       but uses special techniques to launch applications with normal privileges
;
; FEATURES:
; - Works with elevated applications (like Windhawk)
; - Launches applications with normal user privileges
; - Full HybridCapsLock functionality everywhere
;
;===============================================================================

;-------------------------------------------------------------------------------
; SECTION 1: ELEVATED SERVICE CONFIGURATION
;-------------------------------------------------------------------------------
#SingleInstance, Force
#NoEnv
#Warn
StringCaseSense, On
SendMode, Input

; Service logging function
ServiceLog(message) {
    FileAppend, %A_Now% - %message%`n, service_elevated.log
}

; Ensure we're on AutoHotkey v1.x
if (SubStr(A_AhkVersion, 1, 1) != "1") {
    ServiceLog("ERROR: This script requires AutoHotkey v1.x. Running v" . A_AhkVersion)
    MsgBox, 16, HybridCapsLock, This script requires AutoHotkey v1.x.`nYou are running v%A_AhkVersion%.`nInstall AutoHotkey v1.1 and try again.
    ExitApp
}

ServiceLog("HybridCapsLock Elevated Service Version starting...")

; Wait for desktop to be available
WaitForDesktop()

; _DOC: Permanently disable the native CapsLock function.
ServiceLog("Disabling CapsLock and showing startup banner...")
ShowCenteredToolTip("HybridCapsLock Elevated Service Active`n" . A_ScriptFullPath)
SetTimer, RemoveToolTip, 2000
SetCapsLockState, AlwaysOff

; Load configuration files
ServiceLog("Loading configuration files...")
LoadConfiguration()

; _DOC: Global variables to control layer states.
global isNvimLayerActive := false
global VisualMode := false
; Leader state flags
global LeaderMode := false
global WindowsLayerActive := false
global ProgramLayerActive := false
global TimestampLayerActive := false
global ExcelLayerActive := false
global YankMode := false

; Configuration file paths
global ProgramsIni := A_ScriptDir . "\programs.ini"
global TimestampsIni := A_ScriptDir . "\timestamps.ini"
global GeneralIni := A_ScriptDir . "\general.ini"

ServiceLog("Initialization complete. Elevated script ready.")

;-------------------------------------------------------------------------------
; ELEVATED SERVICE-SPECIFIC FUNCTIONS
;-------------------------------------------------------------------------------

WaitForDesktop() {
    ; Wait for an interactive desktop session
    ServiceLog("Waiting for interactive desktop session...")
    
    Loop {
        ; Check if we can access the desktop
        WinGet, activeWindow, ID, A
        if (activeWindow) {
            ServiceLog("Desktop session detected, proceeding...")
            break
        }
        
        ServiceLog("No desktop session detected, waiting...")
        Sleep, 5000  ; Wait 5 seconds before checking again
    }
}

LoadConfiguration() {
    ; Ensure configuration files exist
    if (!FileExist(ProgramsIni)) {
        ServiceLog("WARNING: programs.ini not found, creating default...")
        CreateDefaultProgramsIni()
    }
    
    if (!FileExist(TimestampsIni)) {
        ServiceLog("WARNING: timestamps.ini not found, creating default...")
        CreateDefaultTimestampsIni()
    }
    
    if (!FileExist(GeneralIni)) {
        ServiceLog("WARNING: general.ini not found, creating default...")
        CreateDefaultGeneralIni()
    }
}

CreateDefaultProgramsIni() {
    defaultContent := "; Default programs.ini for elevated service`n[Programs]`nExplorer=explorer.exe`nNotepad=notepad.exe`n`n[ProgramMapping]`nkey_e=Explorer`nkey_n=Notepad`n`n[MenuDisplay]`nline1=e - Explorer    n - Notepad"
    FileAppend, %defaultContent%, %ProgramsIni%
}

CreateDefaultTimestampsIni() {
    defaultContent := "; Default timestamps.ini for elevated service`n[Timestamps]`n; Add timestamp configurations here"
    FileAppend, %defaultContent%, %TimestampsIni%
}

CreateDefaultGeneralIni() {
    defaultContent := "; Default general.ini for elevated service`n[General]`n; Add general configurations here"
    FileAppend, %defaultContent%, %GeneralIni%
}

;-------------------------------------------------------------------------------
; PRIVILEGE DROPPING FUNCTIONS
;-------------------------------------------------------------------------------

; Include the privilege dropper functions
#Include privilege_dropper.ahk

LaunchAppAsUser(appPath, args := "") {
    ; Launch application with normal user privileges even from elevated context
    ServiceLog("Launching app as user: " . appPath . " with args: " . args)
    
    ; Use the advanced privilege dropping function
    method := LaunchWithDroppedPrivileges(appPath, args)
    ServiceLog("Launch method used: " . method)
    
    ; Log success based on method
    if (method = "CreateProcessAsUser") {
        ServiceLog("SUCCESS: Launched with dropped privileges via CreateProcessAsUser")
        return true
    } else if (method = "Explorer") {
        ServiceLog("SUCCESS: Launched with dropped privileges via Explorer")
        return true
    } else {
        ServiceLog("WARNING: Launched via fallback (may have elevated privileges)")
        return false
    }
}

;-------------------------------------------------------------------------------
; MODIFIED LAUNCH FUNCTIONS
;-------------------------------------------------------------------------------

LaunchApp(appName, exeNameOrUri) {
    ; Universal app launcher that drops privileges
    ServiceLog("LaunchApp called: " . appName . " -> " . exeNameOrUri)
    global ProgramsIni
    _path := ""

    ; Handle special cases like "ms-settings:" which are URIs, not files.
    if (!InStr(exeNameOrUri, ".exe") && !InStr(exeNameOrUri, ".lnk")) {
        LaunchAppAsUser(exeNameOrUri)
        return
    }

    ; 1. Prioritize user-defined path from programs.ini file.
    IniRead, _userPath, %ProgramsIni%, Programs, %appName%
    if (_userPath && _userPath != "ERROR") {
        ; Expand environment variables like %USERPROFILE%
        _expandedPath := _userPath
        ; Replace %USERPROFILE% with actual user profile path
        EnvGet, UserProfilePath, USERPROFILE
        StringReplace, _expandedPath, _expandedPath, `%USERPROFILE`%, %UserProfilePath%, All
        if (FileExist(_expandedPath)) {
            LaunchAppAsUser(_expandedPath)
            return
        }
    }

    ; 2. If no user path, try to resolve the executable automatically.
    _resolvedPath := _ResolveExecutable(exeNameOrUri)
    if (_resolvedPath) {
        LaunchAppAsUser(_resolvedPath)
        return
    }

    ; 3. If all searches fail, show a user-friendly tooltip.
    ShowCenteredToolTip(appName . " not found.\nAdd the path to programs.ini\n[Programs]")
    SetTimer, RemoveToolTip, 3500
    return
}

_ResolveExecutable(exeName) {
    ; Safely finds a full, verifiable path to an executable.
    ; 1. Check App Paths registry.
    _path := _FindExecutablePath(exeName)
    if (FileExist(_path)) {
        return _path
    }
    
    ; 2. Check System PATH environment variable.
    EnvGet, systemPath, Path
    Loop, parse, systemPath, `;
    {
        _checkPath := A_LoopField . "\" . exeName
        if (FileExist(_checkPath)) {
            return _checkPath
        }
    }
    
    return "" ; Return empty if not found anywhere.
}

_FindExecutablePath(exeName) {
    ; Check Windows Registry App Paths
    RegRead, appPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exeName%
    if (!ErrorLevel && FileExist(appPath)) {
        return appPath
    }
    return ""
}

;-------------------------------------------------------------------------------
; SECTION 2: CAPSLOCK BEHAVIOR (HOLD MODE)
;-------------------------------------------------------------------------------

; _DOC: CapsLock key behavior when held down (modifier mode)
CapsLock & q::
    ServiceLog("CapsLock+q: Closing active window")
    WinClose, A
return

CapsLock & f::
    ServiceLog("CapsLock+f: Toggling window maximize")
    WinGet, winState, MinMax, A
    if (winState = 1) {
        WinRestore, A
    } else {
        WinMaximize, A
    }
return

CapsLock & s::
    ServiceLog("CapsLock+s: Save command")
    Send, ^s
return

CapsLock & c::
    ServiceLog("CapsLock+c: Copy command")
    Send, ^c
return

CapsLock & v::
    ServiceLog("CapsLock+v: Paste command")
    Send, ^v
return

CapsLock & x::
    ServiceLog("CapsLock+x: Cut command")
    Send, ^x
return

CapsLock & z::
    ServiceLog("CapsLock+z: Undo command")
    Send, ^z
return

; Navigation keys
CapsLock & h::
    ServiceLog("CapsLock+h: Left arrow")
    Send, {Left}
return

CapsLock & j::
    ServiceLog("CapsLock+j: Down arrow")
    Send, {Down}
return

CapsLock & k::
    ServiceLog("CapsLock+k: Up arrow")
    Send, {Up}
return

CapsLock & l::
    ServiceLog("CapsLock+l: Right arrow")
    Send, {Right}
return

; Leader mode
CapsLock & Space::
    ServiceLog("CapsLock+Space: Leader mode activated")
    ShowProgramMenu()
return

;-------------------------------------------------------------------------------
; SECTION 3: CAPSLOCK UP BEHAVIOR (TOGGLE MODE)
;-------------------------------------------------------------------------------

CapsLock Up::
    ServiceLog("CapsLock released - checking for layer toggle")
    ; If no other key was pressed with CapsLock, toggle Nvim layer
    if (!GetKeyState("Shift", "P") && !GetKeyState("Ctrl", "P") && !GetKeyState("Alt", "P")) {
        ToggleNvimLayer()
    }
return

ToggleNvimLayer() {
    isNvimLayerActive := !isNvimLayerActive
    ServiceLog("Nvim layer toggled: " . (isNvimLayerActive ? "ON" : "OFF"))
    
    if (isNvimLayerActive) {
        ShowCenteredToolTip("NVIM Layer: ON")
    } else {
        ShowCenteredToolTip("NVIM Layer: OFF")
        VisualMode := false
    }
    
    SetTimer, RemoveToolTip, 1000
    UpdateLayerStatus()
}

;-------------------------------------------------------------------------------
; PROGRAM MENU FUNCTIONS
;-------------------------------------------------------------------------------

ShowProgramMenu() {
    ; Show program selection menu
    ToolTip, Programs Menu:`ne - Explorer    n - Notepad`nt - Terminal    v - VS Code`nPress a key..., A_ScreenWidth//2, A_ScreenHeight//2
    
    Input, key, L1 T5  ; Wait for 1 character, timeout 5 seconds
    ToolTip  ; Remove tooltip
    
    if (ErrorLevel = "Timeout") {
        return
    }
    
    ; Launch program based on key
    if (key = "e") {
        LaunchApp("Explorer", "explorer.exe")
    } else if (key = "n") {
        LaunchApp("Notepad", "notepad.exe")
    } else if (key = "t") {
        LaunchApp("Terminal", "wt.exe")
    } else if (key = "v") {
        LaunchApp("VisualStudio", "code.exe")
    }
}

;-------------------------------------------------------------------------------
; UTILITY FUNCTIONS
;-------------------------------------------------------------------------------

ShowCenteredToolTip(text) {
    ToolTip, %text%, A_ScreenWidth//2, A_ScreenHeight//2
}

RemoveToolTip:
    ToolTip
return

UpdateLayerStatus() {
    ; Update layer status for external monitoring
    statusJson := "{"
    statusJson .= """nvim"":" . (isNvimLayerActive ? "true" : "false") . ","
    statusJson .= """excel"":" . (ExcelLayerActive ? "true" : "false") . ","
    statusJson .= """visual"":" . (VisualMode ? "true" : "false") . ","
    statusJson .= """leader"":" . (LeaderMode ? "true" : "false") . ","
    statusJson .= """yank"":" . (YankMode ? "true" : "false")
    statusJson .= "}"
    
    FileDelete, layer_status.json
    FileAppend, %statusJson%, layer_status.json
    ServiceLog("Layer status updated: " . statusJson)
}

ServiceLog("HybridCapsLock Elevated Service Version loaded successfully")