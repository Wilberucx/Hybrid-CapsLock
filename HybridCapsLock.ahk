;===============================================================================
; SCRIPT: Hybrid CapsLock Productivity (Vim Style)
; AUTHOR: Wilber Canto (Vibe Codding)
; VERSION: 6.2 (Robust and Safe App Launcher)
;===============================================================================
;
; _DOC: This script transforms the CapsLock key into a powerful productivity
;       tool with a hybrid behavior.
;
; V6.0 CHANGELOG:
; - The app launcher (leader 'p') no longer relies on the system PATH.
; - It now automatically finds executables (wt.exe, code.exe, etc.) by
;   looking them up in the Windows Registry ("App Paths").
; - This fixes issues where the script, running as Admin, could not find
;   programs in the standard user's PATH.
;
;===============================================================================

;-------------------------------------------------------------------------------
; SECTION 1: INITIAL CONFIGURATION
;-------------------------------------------------------------------------------
#SingleInstance, Force
#NoEnv
#Warn
StringCaseSense, On
SendMode, Input

; Ensure we're on AutoHotkey v1.x
if (SubStr(A_AhkVersion, 1, 1) != "1") {
    MsgBox, 16, HybridCapsLock, This script requires AutoHotkey v1.x.`nYou are running v%A_AhkVersion%.`nInstall AutoHotkey v1.1 and try again.
    ExitApp
}


; _DOC: Run as admin to prevent permission issues.
;if not A_IsAdmin {
;    Run *RunAs "%A_ScriptFullPath%"
;    ExitApp
;}

; _DOC: Permanently disable the native CapsLock function.
; Startup banner to confirm correct script loaded
ShowCenteredToolTip("HybridCapsLock loaded`n" . A_ScriptFullPath)
SetTimer, RemoveToolTip, 1500
SetCapsLockState, AlwaysOff

; _DOC: Global variables to control layer states.
global isNvimLayerActive := false
global VisualMode := false
; Leader state flags
global leaderActive := false
; Global variables for temporary status tracking
global currentTempStatus := ""
global tempStatusExpiry := 0
; Excel/Accounting layer state
global excelLayerActive := false
; Variable to track if CapsLock was held beyond the threshold
global capsLockWasHeld := false
; Click derecho sostenido state
global rightClickHeld := false
; Scroll mode state
global scrollModeActive := false
; Timestamp functionality moved to dedicated timestamps.ini system
; Persist settings across sessions
global ConfigIni := A_ScriptDir . "\configuration.ini"
global ProgramsIni := A_ScriptDir . "\programs.ini"
global TimestampsIni := A_ScriptDir . "\timestamps.ini"
global InfoIni := A_ScriptDir . "\information.ini"
global CommandsIni := A_ScriptDir . "\commands.ini"
; Layer status file for Zebar integration
global LayerStatusFile := A_ScriptDir . "\layer_status.json"
; Guard para operador yank secuencial
global _yankAwait := false
; Toggle to let CapsLock behave as original toggle key
global capsActsNormal := false

;-------------------------------------------------------------------------------
; SECTION 2: MODIFIER MODE (HOLD - QUICK SHORTCUTS)
;-------------------------------------------------------------------------------

; ----- Custom & Window Functions -----
CapsLock & 1::WinMinimize, A
; CapsLock+` para minimizar todas las ventanas (alternativa a Shift+1)
CapsLock & `::Send, #m
CapsLock & 2::Send, ^+!{2}
CapsLock & 3::Send, !a
CapsLock & 4::Send, !s
CapsLock & q::Send, !{F4}
CapsLock & f::
    WinGet, winState, MinMax, A
    if (winState = 1)
        WinRestore, A
    else
        WinMaximize, A
return
CapsLock & Tab::
    ; Mantener Alt mientras se navega con Tab; garantizar que no contamos el Tab inicial dos veces
    Send, {Alt down}{Tab}
    ; Esperar a que se suelte el Tab que disparó el hotkey
    KeyWait, Tab
    While GetKeyState("CapsLock", "P") {
        if GetKeyState("Tab", "P") {
            Send, {Tab}
            KeyWait, Tab
        }
        Sleep, 10
    }
    Send, {Alt up}
return

; ----- Quick Navigation (Vim Style) -----
CapsLock & h::Send, {Left}
CapsLock & j::Send, {Down}
CapsLock & k::Send, {Up}
CapsLock & l::Send, {Right}

; ----- Smooth Scrolling (Added in Hold Mode) -----
CapsLock & e::Send, {WheelDown}{WheelDown}{WheelDown}
CapsLock & d::Send, {WheelUp}{WheelUp}{WheelUp}
; ----- Touchpad Scroll Mode -----
CapsLock & Shift::
    ; Activar modo scroll con touchpad
    scrollModeActive := true
    SetTempStatus("SCROLL MODE ACTIVE", 2000)
    ShowScrollModeStatus(true)
    SetTimer, RemoveToolTip, 1500
    
    ; Variables para tracking del mouse
    MouseGetPos, startX, startY
    
    ; Loop mientras se mantenga presionada CapsLock o Shift
    while (GetKeyState("CapsLock", "P") || GetKeyState("Shift", "P")) {
        MouseGetPos, currentX, currentY
        
        ; Calcular diferencia desde la posición inicial
        deltaX := currentX - startX
        deltaY := currentY - startY
        
        ; Umbral mínimo para evitar scroll accidental
        threshold := 3
        
        ; Scroll vertical (más sensible) - EJES INVERTIDOS
        if (Abs(deltaY) > threshold) {
            if (deltaY > 0) {
                ; Movimiento hacia abajo = scroll up (invertido)
                Send, {WheelUp}
            } else {
                ; Movimiento hacia arriba = scroll down (invertido)
                Send, {WheelDown}
            }
            ; Actualizar posición de referencia para scroll continuo
            startY := currentY
        }
        
        ; Scroll horizontal (menos sensible) - EJES INVERTIDOS
        if (Abs(deltaX) > threshold * 2) {
            if (deltaX > 0) {
                ; Movimiento hacia derecha = scroll left (invertido)
                Send, {WheelLeft}
            } else {
                ; Movimiento hacia izquierda = scroll right (invertido)
                Send, {WheelRight}
            }
            ; Actualizar posición de referencia para scroll continuo
            startX := currentX
        }
        
        Sleep, 10 ; Pequeña pausa para suavizar el scroll
    }
    
    ; Cleanup al soltar las teclas
    scrollModeActive := false
    ShowScrollModeStatus(false)
    SetTempStatus("SCROLL MODE OFF", 800)
    SetTimer, RemoveToolTip, 800
return

; ----- Common Shortcuts (Ctrl Style) -----
CapsLock & s::Send, ^s 
CapsLock & c::
    Send, ^c
    ShowCopyNotification()
return
CapsLock & v::Send, ^v
CapsLock & x::Send, ^x
CapsLock & z::Send, ^z
CapsLock & a::Send, ^a
; CapsLock & n ahora es click derecho - movido arriba
CapsLock & o::Send, ^o
CapsLock & t::Send, ^t
CapsLock & r::Send, {F5}
; CapsLock & /::Send, ^f  ; Moved to make space for scroll mode
CapsLock & g::Send, ^!+g

;Manage Windows in glazewm

CapsLock & Left::Send, !+h
CapsLock & Up::Send, !+k
CapsLock & Down::Send, !+j
CapsLock & Right::Send, !+l

; ----- Added Shortcuts (User Requests) -----
CapsLock & `;::
    ; Inmediatamente iniciar click izquierdo sostenido
    Click, Left, Down
    rightClickHeld := true
    ShowLeftClickStatus(true)
    SetTempStatus("LEFT CLICK HELD", 1200)
    SetTimer, RemoveToolTip, 1200
    
    ; Esperar a que se suelte CapsLock o ;
    KeyWait, CapsLock
    KeyWait, `;
    
    ; Soltar click izquierdo
    Click, Left, Up
    rightClickHeld := false
    ShowLeftClickStatus(false)
    SetTimer, RemoveToolTip, 1200
return

; Click derecho simple en una tecla diferente
CapsLock & '::
    Click, Right
    ShowRightClickStatus(true)
    SetTempStatus("RIGHT CLICK", 1200)
    SetTimer, RemoveToolTip, 1200
return
CapsLock & i::Send, ^!k
CapsLock & w::Send, ^w
CapsLock & m::Send, ^{PgDn}
CapsLock & u::Send, ^{PgUp}
CapsLock & [::Send, ^!+{[}
CapsLock & ]::Send, ^!+{]}

; ----- Other Utilities -----
CapsLock & \::SendRaw, your.email@example.com
CapsLock & p::Send, +!p
CapsLock & Enter::Send, ^{Enter}
CapsLock & 9::Send, #+s
CapsLock & 6::Send, #{Left}
CapsLock & 7::Send, #{Right}
CapsLock & Backspace::Send, !{Left}

;-------------------------------------------------------------------------------
; SECTION 2B: ADVANCED LEADER KEY LOGIC
;-------------------------------------------------------------------------------
CapsLock & Space::
    ; _NEW_: Deactivate Nvim Layer if it's active when leader is called
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        VisualMode := false ; Also reset visual mode
        ShowNvimLayerStatus(false)
        UpdateLayerStatus()
        SetTimer, RemoveToolTip, 1200
        Sleep, 50 ; Brief pause to ensure state change is registered
    }
    leaderActive := true

    ; Main leader loop for navigation (back/exit)
    Loop {
        ; ----- LEVEL 1: Main Leader Menu -----
        ShowLeaderMenu()
        Input, _leaderKey, L1 T7, {Escape} ; 7-second timeout, Esc to exit

        if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
            break ; Exit loop on timeout or Esc
        }

        ; ----- LEVEL 2: Window Mode (Dual Mode Switching) -----
        if (_leaderKey = "w") {
            ShowWindowMenu()
            Input, _winAction, L1 T7, {Escape}{Backspace}, 2,3,4,x,m,-,j,k,h,l,d,z,c

            if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                break ; Exit leader loop
            }
            if (ErrorLevel = "EndKey:Backspace") {
                continue ; Back to main leader menu
            }

            _exitLeader := false
            Switch _winAction {
                ; --- Persistent Blind Switching ---
                Case "j", "k":
                    ToolTip, `n BLIND SWITCH MODE `n j/k: Cycle | Enter/Esc: Exit, , , 2
                    if (_winAction = "j")
                        Send, !{Tab}
                    else
                        Send, !+{Tab}
                    Loop {
                        Input, key, L1, {Enter}{Esc}, j,k
                        if (ErrorLevel = "EndKey:Enter" || ErrorLevel = "EndKey:Escape") {
                            _exitLeader := true
                            break
                        }
                        if (key = "j")
                            Send, !{Tab}
                        else if (key = "k")
                            Send, !+{Tab}
                    }
                    break

                ; --- Persistent Visual (Alt-Tab) Switching ---
                Case "l", "h":
                    if (_winAction = "l")
                        Send, {Alt down}{Tab}
                    else
                        Send, {Alt down}+{Tab}
                    ToolTip, ,,,2

                    Loop {
                        Input, key, L1, {Enter}{Esc}{Left}{Right}, l,h
                        if (ErrorLevel = "EndKey:Enter" || ErrorLevel = "EndKey:Escape") {
                            if (ErrorLevel = "EndKey:Escape")
                                Send, {Esc}
                            Send, {Alt up}
                            _exitLeader := true
                            break
                        }
                        if (key = "l" || ErrorLevel = "EndKey:Right")
                            Send, {Tab}
                        else if (key = "h" || ErrorLevel = "EndKey:Left")
                            Send, +{Tab}
                    }
                    break

                ; --- One-shot actions ---
                Case "x":
                    WinClose, A
                    _exitLeader := true
                Case "-":
                    WinMinimize, A
                    _exitLeader := true
                Case "m":
                    WinGet, winState, MinMax, A
                    if (winState = 1)
                        WinRestore, A
                    else
                        WinMaximize, A
                    _exitLeader := true
                Case "2":
                    GoSplitScreen(50)
                    _exitLeader := true
                Case "3":
                    GoSplitScreen(33)
                    _exitLeader := true
                Case "4":
                    WinMove, A, , 0, 0, A_ScreenWidth // 2, A_ScreenHeight // 2
                    _exitLeader := true
                Case "d":
                    Send, ^!+9  ; Draw
                    _exitLeader := true
                Case "z":
                    Send, ^!+1  ; Zoom
                    _exitLeader := true
                Case "c":
                    Send, ^!+4  ; Zoom with cursor
                    _exitLeader := true
            }

            if (_exitLeader)
                break
            else
                continue
        }

        ; ----- LEVEL 2: Program Launcher Mode -----
        if (_leaderKey = "p") {
            ShowProgramMenu()
            Input, _appKey, L1 T7, {Escape}{Backspace}, e,s,t,v,n,o,b,z,m,w,l,r,q,p

            if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                break ; Exit loop
            }
            if (ErrorLevel = "EndKey:Backspace") {
                continue ; Go back to the start of the main loop
            }

            ; Execute program launch dynamically from .ini
            LaunchProgramFromKey(_appKey)
            break ; Action taken, exit loop
        }

        ; ----- LEVEL 2: Timestamp Mode -----
        if (_leaderKey = "t") {
            ShowTimeMenu()
            Input, _tsKey, L1 T20, {Escape}{Backspace}, d,t,h

            if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                break
            }
            if (ErrorLevel = "EndKey:Backspace") {
                continue
            }

            ; ----- LEVEL 3: Timestamp Submenus -----
            if (_tsKey = "d") {
                ; Date formats submenu
                ShowDateFormatsMenu()
                Input, _dateKey, L1 T20, {Escape}{Backspace}, d,1,2,3,4,5,6
                
                if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                    break
                }
                if (ErrorLevel = "EndKey:Backspace") {
                    continue ; Back to timestamp main menu
                }
                
                WriteTimestampFromKey("date", _dateKey)
                break
            }
            
            if (_tsKey = "t") {
                ; Time formats submenu
                ShowTimeFormatsMenu()
                Input, _timeKey, L1 T20, {Escape}{Backspace}, t,1,2,3,4,5
                
                if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                    break
                }
                if (ErrorLevel = "EndKey:Backspace") {
                    continue ; Back to timestamp main menu
                }
                
                WriteTimestampFromKey("time", _timeKey)
                break
            }
            
            if (_tsKey = "h") {
                ; DateTime formats submenu
                ShowDateTimeFormatsMenu()
                Input, _datetimeKey, L1 T20, {Escape}{Backspace}, h,1,2,3,4,5
                
                if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                    break
                }
                if (ErrorLevel = "EndKey:Backspace") {
                    continue ; Back to timestamp main menu
                }
                
                WriteTimestampFromKey("datetime", _datetimeKey)
                break
            }
        }

        ; ----- LEVEL 2: Commands Mode -----
        if (_leaderKey = "c") {
            ShowCommandsMenu()
            Input, _cmdCategory, L1 T10, {Escape}{Backspace}, s,n,g,m,f,w,v,o,a

            if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                break ; Exit loop
            }
            if (ErrorLevel = "EndKey:Backspace") {
                continue ; Go back to main leader menu
            }

            ; ----- LEVEL 3: Category-specific commands -----
            _exitLeader := false
            Switch _cmdCategory {
                Case "s": ; System Commands
                    ShowSystemCommandsMenu()
                    Input, _sysCmd, L1 T10, {Escape}{Backspace}, s,t,v,e,d,c
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteSystemCommand(_sysCmd)
                        _exitLeader := true
                    }

                Case "n": ; Network Commands
                    ShowNetworkCommandsMenu()
                    Input, _netCmd, L1 T10, {Escape}{Backspace}, i,p,n
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteNetworkCommand(_netCmd)
                        _exitLeader := true
                    }

                Case "g": ; Git Commands
                    ShowGitCommandsMenu()
                    Input, _gitCmd, L1 T10, {Escape}{Backspace}, s,l,b,d,a,p
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteGitCommand(_gitCmd)
                        _exitLeader := true
                    }

                Case "m": ; Monitoring Commands
                    ShowMonitoringCommandsMenu()
                    Input, _monCmd, L1 T10, {Escape}{Backspace}, p,s,d,m,c
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteMonitoringCommand(_monCmd)
                        _exitLeader := true
                    }

                Case "f": ; Folder Access Commands
                    ShowFolderCommandsMenu()
                    Input, _folderCmd, L1 T10, {Escape}{Backspace}, t,a,p,u,d,s
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteFolderCommand(_folderCmd)
                        _exitLeader := true
                    }

                Case "w": ; Windows Commands
                    ShowWindowsCommandsMenu()
                    Input, _winCmd, L1 T10, {Escape}{Backspace}, h,r,e
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteWindowsCommand(_winCmd)
                        _exitLeader := true
                    }

                Case "v": ; VaultFlow Commands
                    ShowVaultFlowCommandsMenu()
                    Input, _vaultCmd, L1 T10, {Escape}{Backspace}, v
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteVaultFlowCommand(_vaultCmd)
                        _exitLeader := true
                    }

                Case "o": ; Power Options Commands
                    ShowPowerOptionsCommandsMenu()
                    Input, _powerCmd, L1 T10, {Escape}{Backspace}, s,h,r,u
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecutePowerOptionsCommand(_powerCmd)
                        _exitLeader := true
                    }

                Case "a": ; ADB Tools Commands (Simple ones only)
                    ShowADBCommandsMenu()
                    Input, _adbCmd, L1 T10, {Escape}{Backspace}, d,x,s,l,r
                    
                    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                        _exitLeader := true
                    } else if (ErrorLevel = "EndKey:Backspace") {
                        continue ; Back to commands menu
                    } else {
                        ExecuteADBCommand(_adbCmd)
                        _exitLeader := true
                    }
            }

            if (_exitLeader)
                break
            else
                continue
        }

        ; ----- LEVEL 2: Information Mode -----
        if (_leaderKey = "i") {
            ShowInformationMenu()
            Input, _infoKey, L1 T10, {Escape}{Backspace}, e,n,p,a,c,w,g,l

            if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
                break ; Exit loop
            }
            if (ErrorLevel = "EndKey:Backspace") {
                continue ; Go back to main leader menu
            }

            ; Insert information snippet dynamically from information.ini
            InsertInformationFromKey(_infoKey)
            break ; Action taken, exit loop
        }

        ; ----- LEVEL 2: Excel/Accounting Mode -----
        if (_leaderKey = "n") {
            ; Toggle excel layer
            excelLayerActive := !excelLayerActive
            ShowExcelStatus(excelLayerActive)
            UpdateLayerStatus()
            SetTimer, RemoveToolTip, 1500
            break ; Exit leader after toggling
        }

        ; If an invalid key was pressed at Level 1, the loop will just restart
    }

    ; Cleanup after loop exits
    leaderActive := false
    ToolTip
    ToolTip, , , , 1  ; Limpiar tooltip 1
    ToolTip, , , , 2  ; Limpiar tooltip 2
return

CapsLock & 5::
    WinGetClass, Class, A
    if (InStr(Class, "CabinetWClass") || InStr(Class, "ExploreWClass")) {
        Send, !d
        Sleep, 100
        Send, ^c
        Sleep, 50
        Send, {Esc}
    } else {
        Send, ^l
        Sleep, 100
        Send, ^c
        Sleep, 50
        Send, {Esc}
    }
return
CapsLock & F10::
    capsActsNormal := !capsActsNormal
    if (capsActsNormal) {
        SetCapsLockState, Off
        ShowCapsLockStatus(true)
    } else {
        SetCapsLockState, AlwaysOff
        ShowCapsLockStatus(false)
    }
    SetTimer, RemoveToolTip, 1200
return

CapsLock & F12::
    WinGet, activePid, PID, A
    if (activePid) {
        Process, Close, %activePid%
        ShowProcessTerminated()
        SetTimer, RemoveToolTip, 1500
    }
return

; Suprimir escritura de '/' cuando scroll mode está activo
;/::
;    if (scrollModeActive) {
;        ; No hacer nada, suprimir el carácter
;        return
;    } else {
;        ; Comportamiento normal, enviar el carácter
;        Send, /
;    }
;return

;-------------------------------------------------------------------------------
; SECTION 3: HYBRID LOGIC (TAP VS HOLD)
;-------------------------------------------------------------------------------
CapsLock::
    if (capsActsNormal) {
        Send, {CapsLock}
        return
    }
    ; Reset the hold flag when key is pressed
    capsLockWasHeld := false
    KeyWait, CapsLock, T0.2
    if (ErrorLevel) { ; User is HOLDING the key beyond threshold
        capsLockWasHeld := true
    }
return

CapsLock Up::
    if (capsActsNormal) {
        return
    }
    ; Only activate Nvim layer if it was a tap (not held beyond threshold)
    if (!capsLockWasHeld) {
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
        SetTimer, RemoveToolTip, 1500
    }
    ; Reset the flag for next use
    capsLockWasHeld := false
return

;-------------------------------------------------------------------------------
; SECTION 4: NVIM LAYER (CONTEXT-SENSITIVE HOTKEYS)
;-------------------------------------------------------------------------------
#If (isNvimLayerActive && !GetKeyState("CapsLock","P"))

;----------------------------------
; SECTION 4A: NVIM LAYER SPECIALS
;----------------------------------

; f: Ctrl+Alt+k y desactivar capa nvim inmediatamente
f::
    ; Desactivar primero la capa nvim
    isNvimLayerActive := false
    VisualMode := false
    ShowNvimLayerStatus(false)
    UpdateLayerStatus()
    SetTimer, RemoveToolTip, 800
    ; Pequeña pausa para salir del contexto #If
    Sleep, 30
    ; Enviar Ctrl+Alt+k
    SendInput, ^!k
return

; Timestamp writer (,) y formato (.) en capa nvim
; Timestamp functionality removed - use CapsLock + Space → t instead

;----------------------------------
; SECTION 4B: NVIM LAYER MAIN KEYS
;----------------------------------
v:: ; Visual Mode Toggle
    VisualMode := !VisualMode
    if (VisualMode) {
        ShowVisualModeStatus(true)
    } else {
        ShowVisualModeStatus(false)
    }
    UpdateLayerStatus()
    SetTimer, RemoveToolTip, 1000
return

; ----- Basic Navigation (hjkl) -----
h::
    if (VisualMode)
        Send, +{Left}
    else
        Send, {Left}
return
j::
    if (VisualMode)
        Send, +{Down}
    else
        Send, {Down}
return
k::
    if (VisualMode)
        Send, +{Up}
    else
        Send, {Up}
return
l::
    if (VisualMode)
        Send, +{Right}
    else
        Send, {Right}
return

; ----- Extended Navigation -----
b::
    if (VisualMode)
        Send, ^+{Left}
    else
        Send, ^{Left}
return
w::
    if (VisualMode)
        Send, ^+{Right}
    else
        Send, ^{Right}
return
0::
    if (VisualMode)
        Send, +{Home}
    else
        Send, {Home}
return
4::
    if (VisualMode)
        Send, +{End}
    else
        Send, {End}
return
u::
    if (VisualMode)
        Send, +{PgUp}
    else
        Send, {PgUp}
return
d::
    if (VisualMode)
        Send, +{PgDn}
    else
        Send, {PgDn}
return

; ----- Editing Actions -----
x::Send, {Delete}
8::Send, {End}{Enter}

; New line below/above similar to Vim o/O
o::
    ; Insert new line below and move cursor there
    Send, {End}{Enter}
return
+o::
    ; Insert new line above and move cursor there
    Send, {Home}{Enter}{Up}
return
; ----- Click Functions (moved from B and N) -----
`;::
    ; Click izquierdo sostenido en capa nvim
    Click, Left, Down
    rightClickHeld := true
    ShowLeftClickStatus(true)
    SetTempStatus("LEFT CLICK HELD", 1200)
    SetTimer, RemoveToolTip, 1200
    
    ; Esperar a que se suelte la tecla
    KeyWait, `;
    
    ; Soltar click izquierdo
    Click, Left, Up
    rightClickHeld := false
    ShowLeftClickStatus(false)
    SetTimer, RemoveToolTip, 1200
return

'::
    ; Click derecho simple en capa nvim
    Click, Right
    ShowRightClickStatus(true)
    SetTempStatus("RIGHT CLICK", 1200)
    SetTimer, RemoveToolTip, 1200
return

; ----- Copy/Paste (Vim-like Yank/Paste) -----
y::
   if (VisualMode) {
       Send, ^c
       ShowCopyNotification()
       _yankAwait := false
       return
   }
   if (_yankAwait) {
       _yankAwait := false
       CopyCurrentLine()
       Gosub, RemoveToolTip
       return
   }
   _yankAwait := true
   ShowYankMenu()
   SetTimer, __YankTimeout, -600
return

p::
    if (_yankAwait) {
        _yankAwait := false
        CopyCurrentParagraph()
        Gosub, RemoveToolTip
        return
    }
    Send, ^v
    return
+p::
   PastePlain()
return

a::
    if (_yankAwait) {
        _yankAwait := false
        Send, ^a^c
        ShowCopyNotification()
        Gosub, RemoveToolTip
    }
return

; ----- Smooth Scrolling -----
+e::Send, {WheelDown}{WheelDown}{WheelDown}
+y::Send, {WheelUp}{WheelUp}{WheelUp}
e::Send, {WheelDown}{WheelDown}{WheelDown}

; ----- Touchpad Scroll Mode (Nvim Layer) -----
LShift::
RShift::
    ; Verificar que estamos en la capa NVIM y no hay otras capas activas
    if (!isNvimLayerActive || excelLayerActive || leaderActive) {
        ; Si no estamos en NVIM o hay conflictos, comportamiento normal de Shift
        if (A_ThisHotkey = "LShift")
            Send, {LShift down}
        else
            Send, {RShift down}
        KeyWait, % SubStr(A_ThisHotkey, 1)
        if (A_ThisHotkey = "LShift")
            Send, {LShift up}
        else
            Send, {RShift up}
        return
    }
    
    ; Activar modo scroll con touchpad en capa nvim
    scrollModeActive := true
    SetTempStatus("SCROLL MODE ACTIVE", 2000)
    ShowScrollModeStatus(true)
    UpdateLayerStatus()
    SetTimer, RemoveToolTip, 1500
    
    ; Variables para tracking del mouse
    MouseGetPos, startX, startY
    
    ; Loop mientras se mantenga presionada cualquier tecla Shift
    while (GetKeyState("LShift", "P") || GetKeyState("RShift", "P")) {
        MouseGetPos, currentX, currentY
        
        ; Calcular diferencia desde la posición inicial
        deltaX := currentX - startX
        deltaY := currentY - startY
        
        ; Umbral mínimo para evitar scroll accidental
        threshold := 3
        
        ; Scroll vertical (más sensible) - EJES INVERTIDOS
        if (Abs(deltaY) > threshold) {
            if (deltaY > 0) {
                ; Movimiento hacia abajo = scroll up (invertido)
                Send, {WheelUp}
            } else {
                ; Movimiento hacia arriba = scroll down (invertido)
                Send, {WheelDown}
            }
            ; Actualizar posición de referencia para scroll continuo
            startY := currentY
        }
        
        ; Scroll horizontal (menos sensible) - EJES INVERTIDOS
        if (Abs(deltaX) > threshold * 2) {
            if (deltaX > 0) {
                ; Movimiento hacia derecha = scroll left (invertido)
                Send, {WheelLeft}
            } else {
                ; Movimiento hacia izquierda = scroll right (invertido)
                Send, {WheelRight}
            }
            ; Actualizar posición de referencia para scroll continuo
            startX := currentX
        }
        
        Sleep, 10 ; Pequeña pausa para suavizar el scroll
    }
    
    ; Cleanup al soltar las teclas
    scrollModeActive := false
    ShowScrollModeStatus(false)
    SetTempStatus("SCROLL MODE OFF", 800)
    UpdateLayerStatus()
    SetTimer, RemoveToolTip, 800
return

#If ; End of Nvim Layer context

;-------------------------------------------------------------------------------
; SECTION 5: EXCEL/ACCOUNTING LAYER (PERSISTENT EXCEL PRODUCTIVITY)
;-------------------------------------------------------------------------------
#If (excelLayerActive && !GetKeyState("CapsLock","P"))

; Excel/Accounting layout mapping:
; NUMPAD SECTION:
; 7 8 9    ->    7 8 9
; u i o    ->    4 5 6  
; j k l    ->    1 2 3
; m        ->    0
; ,        ->    , (numpad comma)
; .        ->    . (numpad dot)
; p        ->    + (plus)
; ;        ->    - (minus)
; /        ->    / (divide)
;
; NAVIGATION SECTION:
; w a s d  ->    ↑ ← ↓ → (arrows)
; [        ->    Shift+Tab
; ]        ->    Tab
;
; EXCEL FUNCTIONS:
; Enter    ->    Ctrl+Enter (fill down)
; Space    ->    F2 (edit cell)
; f        ->    Ctrl+F (find)
; r        ->    Ctrl+R (fill right)

; === NUMPAD SECTION ===
; Top row (7, 8, 9)
7::Send, {Numpad7}
8::Send, {Numpad8}
9::Send, {Numpad9}

; Middle row (4, 5, 6)
u::Send, {Numpad4}
i::Send, {Numpad5}
o::Send, {Numpad6}

; Bottom row (1, 2, 3)
j::Send, {Numpad1}
k::Send, {Numpad2}
l::Send, {Numpad3}

; Zero
m::Send, {Numpad0}

; Decimal and comma
,::Send, {NumpadComma}  ; Numpad comma
.::Send, {NumpadDot}    ; Numpad dot

; Operations
p::Send, {NumpadAdd}    ; Plus
`;::Send, {NumpadSub}   ; Minus (semicolon)
/::Send, {NumpadDiv}    ; Divide (moved from Shift to avoid conflicts)

; === NAVIGATION SECTION ===
; Arrow keys (WASD)
w::Send, {Up}           ; Up arrow
a::Send, {Left}         ; Left arrow  
s::Send, {Down}         ; Down arrow
d::Send, {Right}        ; Right arrow

; Tab navigation
[::Send, +{Tab}         ; Shift+Tab
]::Send, {Tab}          ; Tab

; === EXCEL FUNCTIONS ===
; Cell editing and filling
Enter::Send, ^{Enter}   ; Ctrl+Enter (fill down)
Space::Send, {F2}       ; F2 (edit cell)
f::Send, ^f             ; Ctrl+F (find)
r::Send, ^r             ; Ctrl+R (fill right)

; Additional Excel shortcuts
h::Send, ^h             ; Ctrl+H (find & replace)
g::Send, ^g             ; Ctrl+G (go to)
t::Send, ^t             ; Ctrl+T (create table)
n::Send, ^n             ; Ctrl+N (new workbook)
v::Send, ^v             ; Ctrl+V (paste)
c::Send, ^c             ; Ctrl+C (copy)
x::Send, ^x             ; Ctrl+X (cut)
z::Send, ^z             ; Ctrl+Z (undo)
y::Send, ^y             ; Ctrl+Y (redo)

; Escape to exit excel layer
Esc::
    excelLayerActive := false
    ShowExcelStatus(false)
    UpdateLayerStatus()
    SetTimer, RemoveToolTip, 1200
return

#If ; End of Excel Layer context

__YankTimeout:
    _yankAwait := false
    Gosub, RemoveToolTip
return

;-------------------------------------------------------------------------------
; SECTION 5: HELPER FUNCTIONS
;-------------------------------------------------------------------------------
ShowCenteredToolTip(Text) {
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip, %Text%, %ToolTipX%, %ToolTipY%
	return
}

ShowNvimLayerStatus(isActive) {
    ; Tooltip simple y limpio para la capa Nvim con más espacio
    ToolTipX := A_ScreenWidth // 2 - 60
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isActive) {
        ToolTip, `n  NVIM LAYER ON `n  `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n NVIM LAYER OFF `n  `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowVisualModeStatus(isActive) {
    ; Tooltip para Visual Mode con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 60
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isActive) {
        ToolTip, `n VISUAL MODE ON `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n VISUAL MODE OFF `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowCapsLockStatus(isActive) {
    ; Tooltip para CapsLock toggle con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 60
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isActive) {
        ToolTip, `n CAPSLOCK ON `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n CAPSLOCK OFF `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowRightClickStatus(isHeld) {
    ; Tooltip para Right Click sostenido con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 70
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isHeld) {
        ToolTip, `n RIGHT CLICK HELD `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n RIGHT CLICK RELEASED `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowLeftClickStatus(isHeld) {
    ; Tooltip para Left Click sostenido con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 70
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isHeld) {
        ToolTip, `n LEFT CLICK HELD `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n LEFT CLICK RELEASED `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowScrollModeStatus(isActive) {
    ; Tooltip para Scroll Mode con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isActive) {
        ToolTip, `n SCROLL MODE ACTIVE `n Move touchpad to scroll `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n SCROLL MODE OFF `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

ShowCopyStatus() {
    ; Tooltip para notificación de copiado con estilo consistente
    ToolTipX := A_ScreenWidth // 2 - 40
    ToolTipY := A_ScreenHeight // 2 - 30
    ToolTip, `n COPIED `n, %ToolTipX%, %ToolTipY%, 1
	return
}

; Timestamp format functions removed - functionality moved to timestamps.ini system

; ShowTSFormatStatus removed - timestamp functionality moved to timestamps.ini system

ShowExcelStatus(isActive) {
    ; Tooltip para estado de la capa Excel/Accounting
    ToolTipX := A_ScreenWidth // 2 - 70
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isActive) {
        ToolTip, `n EXCEL LAYER ON `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n EXCEL LAYER OFF `n, %ToolTipX%, %ToolTipY%, 1
    }
	return
}

UpdateLayerStatus() {
    ; Update JSON file with current layer states for Zebar integration
    FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
    
    ; Check if temporary status has expired
    if (A_TickCount > tempStatusExpiry) {
        currentTempStatus := ""
    }
    
    JsonContent := "{"
    JsonContent .= """nvim_layer"": " . (isNvimLayerActive ? "true" : "false") . ","
    JsonContent .= """excel_layer"": " . (excelLayerActive ? "true" : "false") . ","
    JsonContent .= """visual_mode"": " . (VisualMode ? "true" : "false") . ","
    JsonContent .= """leader_active"": " . (leaderActive ? "true" : "false") . ","
    JsonContent .= """yank_await"": " . (_yankAwait ? "true" : "false") . ","
    JsonContent .= """right_click_held"": " . (rightClickHeld ? "true" : "false") . ","
    JsonContent .= """scroll_mode"": " . (scrollModeActive ? "true" : "false") . ","
    JsonContent .= """caps_normal"": " . (capsActsNormal ? "true" : "false") . ","
    JsonContent .= """temp_status"": """ . currentTempStatus . ""","
    JsonContent .= """temp_status_active"": " . (currentTempStatus != "" ? "true" : "false") . ","
    JsonContent .= """last_updated"": """ . CurrentTime . """"
    JsonContent .= "}"
    
    ; Write to local file
    FileDelete, %LayerStatusFile%
    FileAppend, %JsonContent%, %LayerStatusFile%
    
    ; Copy to Zebar widget folder if it exists
    EnvGet, UserProfile, USERPROFILE
    if (UserProfile) {
        ZebarWidgetPath := UserProfile . "\.glzr\zebar\capsLock-indicator\with-glazewm\layer_status.json"
        FileCopy, %LayerStatusFile%, %ZebarWidgetPath%, 1
    }
	return
}

SetTempStatus(statusText, durationMs) {
    ; Set a temporary status that will be shown in Zebar
    global currentTempStatus, tempStatusExpiry
    currentTempStatus := statusText
    tempStatusExpiry := A_TickCount + durationMs
    UpdateLayerStatus()
	return
}

ShowYankMenu() {
    ; Menu de yank en capa Nvim con estilo centrado
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 60
    MenuText := "YANK MODE`n"
    MenuText .= "`n"
    MenuText .= "y - Line`n"
    MenuText .= "p - Paragraph`n"
    MenuText .= "a - All`n"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 1
	return
}

ShowProcessTerminated() {
    ; Tooltip para proceso terminado
    ToolTipX := A_ScreenWidth // 2 - 70
    ToolTipY := A_ScreenHeight // 2 - 30
    ToolTip, `n PROCESS TERMINATED `n, %ToolTipX%, %ToolTipY%, 1
	return
}

ShowLeaderMenu() {
    ; Menu principal del Leader centrado
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 80
    MenuText := "LEADER MENU`n"
    MenuText .= "`n"
    MenuText .= "w - Windows`n"
    MenuText .= "p - Programs`n"
    MenuText .= "t - Time`n"
    MenuText .= "c - Commands`n"
    MenuText .= "i - Information`n"
    MenuText .= "n - Excel`n"
    MenuText .= "`n"
    MenuText .= "[Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowWindowMenu() {
    ; Menu de ventanas en formato lista vertical centrado
    ToolTipX := A_ScreenWidth // 2 - 110
    ToolTipY := A_ScreenHeight // 2 - 140
    MenuText := "WINDOW MANAGER`n"
    MenuText .= "`n"
    MenuText .= "SPLITS:`n"
    MenuText .= "2 - Split 50/50    3 - Split 33/67`n"
    MenuText .= "4 - Quarter Split`n"
    MenuText .= "`n"
    MenuText .= "ACTIONS:`n"
    MenuText .= "x - Close          m - Maximize`n"
    MenuText .= "- - Minimize`n"
    MenuText .= "`n"
    MenuText .= "ZOOM TOOLS:`n"
    MenuText .= "d - Draw           z - Zoom`n"
    MenuText .= "c - Zoom with cursor`n"
    MenuText .= "`n"
    MenuText .= "PERSISTENT SWITCH:`n"
    MenuText .= "j/k - Blind Switch (Next/Prev)`n"
    MenuText .= "l/h - Visual Switch (Next/Prev)`n"
    MenuText .= "`n"
    MenuText .= "[Enter/Esc: Exit Mode] [Backspace: Back]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowTimeMenu() {
    ; Menu principal de timestamp - lee desde timestamps.ini
    ToolTipX := A_ScreenWidth // 2 - 110
    ToolTipY := A_ScreenHeight // 2 - 80
    MenuText := "TIMESTAMP MANAGER`n"
    MenuText .= "`n"
    MenuText .= "d - Date Formats`n"
    MenuText .= "t - Time Formats`n"
    MenuText .= "h - Date+Time Formats`n"
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowDateFormatsMenu() {
    ; Menu de formatos de fecha - lee desde timestamps.ini
    global TimestampsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 100
    MenuText := "DATE FORMATS`n"
    MenuText .= "`n"
    
    ; Read menu lines dynamically from timestamps.ini
    Loop, 10 {
        IniRead, lineContent, %TimestampsIni%, MenuDisplay, date_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowTimeFormatsMenu() {
    ; Menu de formatos de hora - lee desde timestamps.ini
    global TimestampsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 100
    MenuText := "TIME FORMATS`n"
    MenuText .= "`n"
    
    ; Read menu lines dynamically from timestamps.ini
    Loop, 10 {
        IniRead, lineContent, %TimestampsIni%, MenuDisplay, time_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowDateTimeFormatsMenu() {
    ; Menu de formatos de fecha+hora - lee desde timestamps.ini
    global TimestampsIni
    ToolTipX := A_ScreenWidth // 2 - 140
    ToolTipY := A_ScreenHeight // 2 - 120
    MenuText := "DATE+TIME FORMATS`n"
    MenuText .= "`n"
    
    ; Read menu lines dynamically from timestamps.ini
    Loop, 10 {
        IniRead, lineContent, %TimestampsIni%, MenuDisplay, datetime_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

ShowProgramMenu() {
    ; Menu de programas en formato lista vertical centrado - lee desde programs.ini
    global ProgramsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 150
    MenuText := "PROGRAM LAUNCHER`n"
    MenuText .= "`n"
    
    ; Read menu lines dynamically from programs.ini
    Loop, 10 {
        IniRead, lineContent, %ProgramsIni%, MenuDisplay, line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
	return
}

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    ToolTip, , , , 1  ; Limpiar tooltip 1 (Nvim Layer)
    ToolTip, , , , 2  ; Limpiar tooltip 2 (Program Menu)
return

ShowCopyNotification() {
    ShowCopyStatus()
    SetTempStatus("COPIED", 800)
    SetTimer, RemoveToolTip, 800
	return
}

GoSplitScreen(percent) {
    WinGet, active_id, ID, A
    W_Left := (A_ScreenWidth * percent) // 100
    W_Right := A_ScreenWidth - W_Left
    H := A_ScreenHeight
    X_Right := W_Left

    WinMove, ahk_id %active_id%,, 0, 0, %W_Left%, %H%
    Send, !{Tab}
    WinWaitNotActive, ahk_id %active_id%,, 1
    WinMove, A, , %X_Right%, 0, %W_Right%, %H%
	return
}

CopyCurrentLine() {
    Send, {Home}+{End}^c
    Sleep, 50
    ShowCopyNotification()
	return
}

CopyCurrentParagraph() {
    Send, {Right}{Left} ; Clear selection
    Send, ^+{Up}^+{Down} ; Select paragraph
    Send, ^c
    ClipWait, 0.3
    Sleep, 60
    ShowCopyNotification()
	return
}

PastePlain() {
    ClipSaved := ClipboardAll
    Clipboard := Clipboard
    Send, ^v
    Sleep, 50
    Clipboard := Clipboard
    ClipSaved := ""
	return
}

WriteTimestampFromKey(mode, keyPressed) {
    ; Dynamic timestamp writer that reads formats from timestamps.ini
    global TimestampsIni
    
    ; Determine format key name based on mode and key pressed
    if (mode = "date") {
        if (keyPressed = "d") {
            ; Use default format
            IniRead, defaultNum, %TimestampsIni%, DateFormats, default
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateFormats"
    } else if (mode = "time") {
        if (keyPressed = "t") {
            ; Use default format
            IniRead, defaultNum, %TimestampsIni%, TimeFormats, default
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "TimeFormats"
    } else if (mode = "datetime") {
        if (keyPressed = "h") {
            ; Use default format
            IniRead, defaultNum, %TimestampsIni%, DateTimeFormats, default
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateTimeFormats"
    }
    
    ; Read the format string
    IniRead, formatString, %TimestampsIni%, %sectionName%, %formatKey%
    
    ; If format not found, show error
    if (formatString = "ERROR" || formatString = "") {
        ShowCenteredToolTip("Format '" . keyPressed . "' not found in " . sectionName)
        SetTimer, RemoveToolTip, 3500
        return
    }
    
    ; Generate and insert timestamp
    FormatTime, _out, , %formatString%
    SendRaw, %_out%
	return
}

; ----- Program Launcher Helpers -----

_FindExecutablePath(exeName) {
    ; Tries to find an executable's full path via the Windows Registry "App Paths".
    _path := ""
    try {
        RegRead, _path, HKCU, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exeName%
    }
    if (FileExist(_path)) {
        return _path
    }
    try {
        RegRead, _path, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exeName%
    }
    if (FileExist(_path)) {
        return _path
    }
    return ""
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

LaunchApp(appName, exeNameOrUri) {
    ; Universal app launcher with a safe, multi-step search strategy.
    global ProgramsIni
    _path := ""

    ; Handle special cases like "ms-settings:" which are URIs, not files.
    if (!InStr(exeNameOrUri, ".exe") && !InStr(exeNameOrUri, ".lnk")) {
        Run, %exeNameOrUri%
        return
    }

    ; 1. Prioritize user-defined path from programs.ini file.
    IniRead, _userPath, %ProgramsIni%, Programs, %appName%
    if (_userPath) {
        ; Expand environment variables like %USERPROFILE%
        _expandedPath := _userPath
        ; Replace %USERPROFILE% with actual user profile path
        EnvGet, UserProfilePath, USERPROFILE
        StringReplace, _expandedPath, _expandedPath, `%USERPROFILE`%, %UserProfilePath%, All
        if (FileExist(_expandedPath)) {
            Run, "%_expandedPath%"
            return
        }
    }

    ; 2. If no user path, try to resolve the executable automatically.
    _resolvedPath := _ResolveExecutable(exeNameOrUri)
    if (_resolvedPath) {
        Run, "%_resolvedPath%"
        return
    }

    ; 3. If all searches fail, show a user-friendly tooltip.
    ShowCenteredToolTip(appName . " not found.\nAdd the path to programs.ini\n[Programs]")
    SetTimer, RemoveToolTip, 3500
	return
}

LaunchExplorer() {
    LaunchApp("Explorer", "explorer.exe")
	return
}

LaunchSettings() {
    LaunchApp("Settings", "ms-settings:")
	return
}

LaunchTerminal() {
    LaunchApp("Terminal", "wt.exe")
	return
}

LaunchVisualStudio() {
    LaunchApp("VisualStudio", "code.exe")
	return
}

LaunchObsidian() {
    LaunchApp("Obsidian", "obsidian.exe")
	return
}

LaunchVivaldi() {
    LaunchApp("Vivaldi", "vivaldi.exe")
	return
}

LaunchZen() {
    LaunchApp("Zen", "zen.exe")
	return
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

LaunchQuickShare() {
    ; QuickShare is a special case, often a .lnk or Store app
    _quickShareLnk := "C:\ProgramData\Microsoft\Windows\Start Menu\Quick Share.lnk"
    if (FileExist(_quickShareLnk)) {
        Run, "%_quickShareLnk%"
        Sleep, 1500
        WinActivate, Quick Share
        if (!WinActive("Quick Share")) {
            WinActivate, ahk_exe NearbyShare.exe
        }
        return
    }
    
    Run, explorer.exe shell:appsFolder\NearbyShare_21hpf16v5xp10!NearbyShare, ,, errorLevel
    if (!errorLevel) {
        Sleep, 1500
        WinActivate, Quick Share
        if (!WinActive("Quick Share")) {
            WinActivate, ahk_exe NearbyShare.exe
        }
        return
    }
    
    ShowCenteredToolTip("Quick Share not found.\nPlease verify it is installed.")
    SetTimer, RemoveToolTip, 3000
}

LaunchBitwarden() {
    LaunchApp("Bitwarden", "bitwarden.exe")
}

LaunchProgramFromKey(keyPressed) {
    ; Dynamic program launcher that reads mapping from programs.ini file
    global ProgramsIni
    
    ; Read the program name mapped to this key
    keyName := "key_" . keyPressed
    IniRead, programName, %ProgramsIni%, ProgramMapping, %keyName%
    
    ; If no mapping found, show error
    if (programName = "ERROR" || programName = "") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.\nAdd to programs.ini\n[ProgramMapping]")
        SetTimer, RemoveToolTip, 3500
        return
    }
    
    ; Read the executable path for this program
    IniRead, executablePath, %ProgramsIni%, Programs, %programName%
    if (executablePath = "ERROR" || executablePath = "") {
        ShowCenteredToolTip(programName . " not found in [Programs].\nAdd path to programs.ini")
        SetTimer, RemoveToolTip, 3500
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

; ----- Commands Layer Functions -----

ShowCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 110
    ToolTipY := A_ScreenHeight // 2 - 100
    MenuText := "COMMAND PALETTE`n"
    MenuText .= "`n"
    
    Loop, 20 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, main_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowSystemCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "SYSTEM COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, system_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowNetworkCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 70
    MenuText := "NETWORK COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, network_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowGitCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "GIT COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, git_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowMonitoringCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "MONITORING COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, monitoring_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowFolderCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "FOLDER ACCESS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, folder_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowWindowsCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 70
    MenuText := "WINDOWS COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, windows_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

; ----- Command Execution Functions -----

ExecuteSystemCommand(cmd) {
    Switch cmd {
        Case "s":
            Run, cmd.exe /k systeminfo
        Case "t":
            Run, taskmgr.exe
        Case "v":
            Run, services.msc
        Case "e":
            Run, eventvwr.msc
        Case "d":
            Run, devmgmt.msc
        Case "c":
            Run, cleanmgr.exe
    }
    ShowCommandExecuted("System", cmd)
    return
}

ExecuteNetworkCommand(cmd) {
    Switch cmd {
        Case "i":
            Run, cmd.exe /k ipconfig /all
        Case "p":
            Run, cmd.exe /k ping google.com
        Case "n":
            Run, cmd.exe /k netstat -an
    }
    ShowCommandExecuted("Network", cmd)
    return
}

ExecuteGitCommand(cmd) {
    Switch cmd {
        Case "s":
            Run, cmd.exe /k git status
        Case "l":
            Run, cmd.exe /k git log --oneline -10
        Case "b":
            Run, cmd.exe /k git branch -a
        Case "d":
            Run, cmd.exe /k git diff
        Case "a":
            Run, cmd.exe /k git add .
        Case "p":
            Run, cmd.exe /k git pull
    }
    ShowCommandExecuted("Git", cmd)
    return
}

ExecuteMonitoringCommand(cmd) {
    Switch cmd {
        Case "p":
            Run, powershell.exe -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'"
        Case "s":
            Run, powershell.exe -Command "Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'"
        Case "d":
            Run, powershell.exe -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'"
        Case "m":
            Run, powershell.exe -Command "Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'"
        Case "c":
            Run, powershell.exe -Command "Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'"
    }
    ShowCommandExecuted("Monitoring", cmd)
    return
}

ExecuteFolderCommand(cmd) {
    Switch cmd {
        Case "t":
            Run, explorer.exe "%TEMP%"
        Case "a":
            Run, explorer.exe "%APPDATA%"
        Case "p":
            Run, explorer.exe "C:\Program Files"
        Case "u":
            Run, explorer.exe "%USERPROFILE%"
        Case "d":
            Run, explorer.exe "%USERPROFILE%\Desktop"
        Case "s":
            Run, explorer.exe "C:\Windows\System32"
    }
    ShowCommandExecuted("Folder", cmd)
    return
}

ExecuteWindowsCommand(cmd) {
    Switch cmd {
        Case "h":
            ToggleHiddenFiles()
        Case "r":
            Run, regedit.exe
            ShowCommandExecuted("Windows", "Registry Editor")
        Case "e":
            Run, rundll32.exe sysdm.cpl`,EditEnvironmentVariables
            ShowCommandExecuted("Windows", "Environment Variables")
    }
    return
}

ToggleHiddenFiles() {
    ; Toggle hidden files in Windows Explorer
    RegRead, HiddenFiles, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    
    if (HiddenFiles = 1) {
        ; Hide hidden files
        RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
        ShowHiddenFilesStatus(false)
    } else {
        ; Show hidden files
        RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
        ShowHiddenFilesStatus(true)
    }
    
    ; Refresh all explorer windows
    Send, {F5}
    return
}

ShowHiddenFilesStatus(isVisible) {
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 30
    if (isVisible) {
        ToolTip, `n HIDDEN FILES: VISIBLE `n, %ToolTipX%, %ToolTipY%, 1
    } else {
        ToolTip, `n HIDDEN FILES: HIDDEN `n, %ToolTipX%, %ToolTipY%, 1
    }
    SetTimer, RemoveToolTip, 2000
    return
}

ShowCommandExecuted(category, cmd) {
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 30
    ToolTip, `n %category% COMMAND EXECUTED `n, %ToolTipX%, %ToolTipY%, 1
    SetTimer, RemoveToolTip, 1500
    return
}

; ----- Custom Commands Layer Functions -----

ShowVaultFlowCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 50
    MenuText := "VAULTFLOW COMMANDS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, vaultflow_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowPowerOptionsCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 80
    MenuText := "POWER OPTIONS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, power_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ShowADBCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "ADB TOOLS`n"
    MenuText .= "`n"
    
    Loop, 10 {
        IniRead, lineContent, %CommandsIni%, MenuDisplay, adb_line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

; ----- Custom Command Execution Functions -----

ExecuteVaultFlowCommand(cmd) {
    Switch cmd {
        Case "v":
            Run, powershell.exe -Command "vaultflow"
    }
    ShowCommandExecuted("VaultFlow", cmd)
    return
}

ExecutePowerOptionsCommand(cmd) {
    Switch cmd {
        Case "s":
            Run, rundll32.exe powrprof.dll`,SetSuspendState 0`,1`,0
            ShowCommandExecuted("Power", "Sleep")
        Case "h":
            Run, rundll32.exe powrprof.dll`,SetSuspendState Hibernate
            ShowCommandExecuted("Power", "Hibernate")
        Case "r":
            Run, shutdown /r /t 0
            ShowCommandExecuted("Power", "Restart")
        Case "u":
            Run, shutdown /s /t 0
            ShowCommandExecuted("Power", "Shutdown")
    }
    return
}

ExecuteADBCommand(cmd) {
    Switch cmd {
        Case "d":
            Run, cmd.exe /k adb devices
        Case "x":
            Run, cmd.exe /k adb disconnect
        Case "s":
            Run, cmd.exe /k adb shell
        Case "l":
            Run, cmd.exe /k adb logcat
        Case "r":
            Run, cmd.exe /k adb reboot
    }
    ShowCommandExecuted("ADB", cmd)
    return
}

; ----- Information Layer Functions -----

ShowInformationMenu() {
    ; Menu de información dinámico que lee desde information.ini
    global InfoIni
    ToolTipX := A_ScreenWidth // 2 - 110
    ToolTipY := A_ScreenHeight // 2 - 80
    MenuText := "PERSONAL INFORMATION`n"
    MenuText .= "`n"
    
    ; Read menu lines dynamically from information.ini
    Loop, 10 {
        IniRead, lineContent, %InfoIni%, MenuDisplay, line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

InsertInformationFromKey(keyPressed) {
    ; Dynamic information inserter that reads mapping from information.ini file
    global InfoIni
    
    ; Read the information name mapped to this key
    keyName := "key_" . keyPressed
    IniRead, infoName, %InfoIni%, InfoMapping, %keyName%
    
    ; If no mapping found, show error
    if (infoName = "ERROR" || infoName = "") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.\nAdd to information.ini\n[InfoMapping]")
        SetTimer, RemoveToolTip, 3500
        return
    }
    
    ; Read the information content for this key
    IniRead, infoContent, %InfoIni%, PersonalInfo, %infoName%
    if (infoContent = "ERROR" || infoContent = "") {
        ShowCenteredToolTip(infoName . " not found in [PersonalInfo].\nAdd content to information.ini")
        SetTimer, RemoveToolTip, 3500
        return
    }
    
    ; Insert the information content
    SendRaw, %infoContent%
    ShowInformationInserted(infoName)
    return
}

ShowInformationInserted(infoName) {
    ToolTipX := A_ScreenWidth // 2 - 80
    ToolTipY := A_ScreenHeight // 2 - 30
    ToolTip, `n %infoName% INSERTED `n, %ToolTipX%, %ToolTipY%, 1
    SetTimer, RemoveToolTip, 1500
    return
}

; ----- Configuration Management Functions -----

ReadConfigValue(section, key, defaultValue := "") {
    ; Read configuration values from configuration.ini
    global ConfigIni
    IniRead, value, %ConfigIni%, %section%, %key%
    if (value = "ERROR" || value = "") {
        return defaultValue
    }
    return value
}

ReadLayerSettings(layerIni, settingKey, defaultValue := "") {
    ; Read settings from layer-specific .ini files
    IniRead, value, %layerIni%, Settings, %settingKey%
    if (value = "ERROR" || value = "") {
        return defaultValue
    }
    return value
}

GetTooltipDuration(layerType := "default") {
    ; Get tooltip duration based on configuration
    global ConfigIni
    
    ; Try to get layer-specific duration first
    if (layerType != "default") {
        layerFile := A_ScriptDir . "\" . layerType . ".ini"
        duration := ReadLayerSettings(layerFile, "feedback_duration", "")
        if (duration != "") {
            return duration
        }
    }
    
    ; Fall back to global configuration
    return ReadConfigValue("UI", "tooltip_duration_default", 1500)
}

GetLayerTimeout(layerType := "leader") {
    ; Get timeout for specific layer
    global ConfigIni
    
    ; Try layer-specific timeout first
    if (layerType != "leader") {
        layerFile := A_ScriptDir . "\" . layerType . ".ini"
        timeout := ReadLayerSettings(layerFile, "timeout_seconds", "")
        if (timeout != "") {
            return timeout
        }
    }
    
    ; Fall back to global configuration
    if (layerType = "leader") {
        return ReadConfigValue("Behavior", "leader_timeout_seconds", 7)
    } else {
        return ReadConfigValue("Behavior", "global_timeout_seconds", 7)
    }
}

IsLayerEnabled(layerName) {
    ; Check if a specific layer is enabled
    return ReadConfigValue("Layers", layerName . "_layer_enabled", "true") = "true"
}

IsFeatureEnabled(featureName) {
    ; Check if a specific feature is enabled
    return ReadConfigValue("General", featureName, "true") = "true"
}

