;===============================================================================
; PRIVILEGE DROPPER - Windows API Functions for AutoHotkey
;===============================================================================
; This file contains functions to launch applications with normal user privileges
; even when the calling script is running with elevated privileges.
;===============================================================================

; Get the current user's token from explorer.exe
GetUserToken() {
    ; Find explorer.exe process (always runs as user)
    WinGet, explorerPID, PID, ahk_class Shell_TrayWnd
    if (!explorerPID) {
        ; Fallback: find any explorer.exe process
        Process, Exist, explorer.exe
        explorerPID := ErrorLevel
    }
    
    if (!explorerPID) {
        return 0
    }
    
    ; Open process with required access
    hProcess := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", explorerPID, "Ptr")
    if (!hProcess) {
        return 0
    }
    
    ; Open process token
    hToken := 0
    success := DllCall("advapi32\OpenProcessToken", "Ptr", hProcess, "UInt", 0x0002, "Ptr*", hToken)
    
    DllCall("CloseHandle", "Ptr", hProcess)
    
    if (!success || !hToken) {
        return 0
    }
    
    return hToken
}

; Duplicate token for creating new process
DuplicateUserToken(hToken) {
    hDupToken := 0
    success := DllCall("advapi32\DuplicateTokenEx"
        , "Ptr", hToken
        , "UInt", 0x10000000  ; MAXIMUM_ALLOWED
        , "Ptr", 0            ; lpTokenAttributes
        , "UInt", 2           ; SecurityImpersonation
        , "UInt", 1           ; TokenPrimary
        , "Ptr*", hDupToken)
    
    if (!success || !hDupToken) {
        return 0
    }
    
    return hDupToken
}

; Launch process as user using CreateProcessAsUser
LaunchAsUser(commandLine, workingDir := "") {
    ; Get user token
    hUserToken := GetUserToken()
    if (!hUserToken) {
        ; Fallback to normal Run
        Run, %commandLine%, %workingDir%
        return false
    }
    
    ; Duplicate token
    hDupToken := DuplicateUserToken(hUserToken)
    DllCall("CloseHandle", "Ptr", hUserToken)
    
    if (!hDupToken) {
        ; Fallback to normal Run
        Run, %commandLine%, %workingDir%
        return false
    }
    
    ; Prepare structures for CreateProcessAsUser
    VarSetCapacity(si, 68, 0)  ; STARTUPINFO
    NumPut(68, si, 0)          ; cb
    
    VarSetCapacity(pi, 16, 0)  ; PROCESS_INFORMATION
    
    ; Set working directory
    workingDirPtr := workingDir ? &workingDir : 0
    
    ; Create process as user
    success := DllCall("advapi32\CreateProcessAsUserW"
        , "Ptr", hDupToken        ; hToken
        , "Ptr", 0               ; lpApplicationName
        , "Str", commandLine     ; lpCommandLine
        , "Ptr", 0               ; lpProcessAttributes
        , "Ptr", 0               ; lpThreadAttributes
        , "Int", false           ; bInheritHandles
        , "UInt", 0x00000010     ; dwCreationFlags (CREATE_NEW_CONSOLE)
        , "Ptr", 0               ; lpEnvironment
        , "Ptr", workingDirPtr   ; lpCurrentDirectory
        , "Ptr", &si             ; lpStartupInfo
        , "Ptr", &pi)            ; lpProcessInformation
    
    ; Clean up
    if (success) {
        DllCall("CloseHandle", "Ptr", NumGet(pi, 0))  ; hProcess
        DllCall("CloseHandle", "Ptr", NumGet(pi, 4))  ; hThread
    }
    
    DllCall("CloseHandle", "Ptr", hDupToken)
    
    if (!success) {
        ; Fallback to normal Run
        Run, %commandLine%, %workingDir%
        return false
    }
    
    return true
}

; Simplified function to launch executable as user
RunAsNormalUser(exePath, args := "", workingDir := "") {
    ; Build command line
    if (args) {
        commandLine := """" . exePath . """ " . args
    } else {
        commandLine := """" . exePath . """"
    }
    
    ; Try to launch as user
    success := LaunchAsUser(commandLine, workingDir)
    
    return success
}

; Alternative method using explorer.exe
LaunchViaExplorer(target) {
    ; Use explorer.exe to launch (inherits user privileges)
    if (InStr(target, ".lnk") || InStr(target, ".url")) {
        ; For shortcuts, use explorer directly
        Run, explorer.exe "%target%"
        return true
    } else if (FileExist(target)) {
        ; For executables, use explorer
        Run, explorer.exe "%target%"
        return true
    } else {
        ; For URIs or system commands
        Run, %target%
        return false
    }
}

; Main function to launch with dropped privileges
LaunchWithDroppedPrivileges(target, args := "", workingDir := "") {
    ; Method 1: Try CreateProcessAsUser
    if (FileExist(target)) {
        success := RunAsNormalUser(target, args, workingDir)
        if (success) {
            return "CreateProcessAsUser"
        }
    }
    
    ; Method 2: Try via explorer.exe
    if (!args && !workingDir) {
        success := LaunchViaExplorer(target)
        if (success) {
            return "Explorer"
        }
    }
    
    ; Method 3: Fallback to normal Run (will be elevated)
    if (args) {
        if (workingDir) {
            Run, "%target%" %args%, %workingDir%
        } else {
            Run, "%target%" %args%
        }
    } else {
        if (workingDir) {
            Run, "%target%", %workingDir%
        } else {
            Run, "%target%"
        }
    }
    
    return "Fallback"
}