#Requires AutoHotkey v2.0
#SingleInstance Force

; ===================================================================
; TEST: Home Row Mod - Solo tecla 'a'
; Propósito: Probar si el hook de Windows puede suprimir auto-repeats
; 
; Comportamiento esperado:
; - Tap rápido (< 250ms): Envía 'a'
; - Hold sin usar (>= 250ms): NO envía nada
; - Hold + otra tecla: Envía Win+tecla (NO implementado en este test)
; ===================================================================

; ===================================================================
; CONFIGURACIÓN
; ===================================================================
global TAP_THRESHOLD := 250  ; milisegundos
global DEBUG := true         ; Mostrar logs en DebugView

; ===================================================================
; ESTADO
; ===================================================================
global aPressed := false
global aPressTime := 0
global aUsedAsMod := false

; ===================================================================
; CONSTANTES DE WINDOWS
; ===================================================================
global WH_KEYBOARD_LL := 13
global WM_KEYDOWN := 0x0100
global WM_KEYUP := 0x0101
global WM_SYSKEYDOWN := 0x0104
global WM_SYSKEYUP := 0x0105
global VK_A := 0x41

; ===================================================================
; HOOK GLOBALS
; ===================================================================
global hHook := 0
global hookCallback := 0

; ===================================================================
; STARTUP
; ===================================================================
OutputDebug("`n========================================`n")
OutputDebug("HOME ROW TEST - Starting...`n")
OutputDebug("Testing key 'a' only`n")
OutputDebug("========================================`n")

if (InstallHook()) {
    OutputDebug("✓ Hook installed successfully!`n")
    OutputDebug("  hHook = " hHook "`n")
    OutputDebug("  hookCallback = " hookCallback "`n")
    OutputDebug("`nPress 'a' to test:`n")
    OutputDebug("  - Quick tap: Should produce one 'a'`n")
    OutputDebug("  - Hold 500ms: Should produce nothing`n")
    OutputDebug("`nPress ESC to exit`n")
    OutputDebug("========================================`n")
    
    ToolTip("Home Row Test Active`nPress 'a' to test`nESC to exit", 10, 10)
} else {
    OutputDebug("✗ FAILED to install hook!`n")
    MsgBox("Failed to install keyboard hook!`nCheck if running as admin.", "Error", "Icon!")
    ExitApp
}

; ESC to exit
Esc:: {
    OutputDebug("`n========================================`n")
    OutputDebug("Exiting...`n")
    ExitApp
}

; ===================================================================
; INSTALL HOOK
; ===================================================================
InstallHook() {
    global hHook, hookCallback, WH_KEYBOARD_LL
    
    OutputDebug("[INSTALL] Creating callback...`n")
    
    ; Create callback function
    hookCallback := CallbackCreate(KeyboardProc, "Fast", 3)
    
    if (!hookCallback) {
        OutputDebug("[INSTALL] ✗ CallbackCreate failed!`n")
        OutputDebug("[INSTALL]   Error: " A_LastError "`n")
        return false
    }
    
    OutputDebug("[INSTALL] ✓ Callback created: " hookCallback "`n")
    
    ; Get module handle
    hModule := DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
    OutputDebug("[INSTALL]   Module handle: " hModule "`n")
    
    ; Install the hook
    OutputDebug("[INSTALL] Installing SetWindowsHookEx...`n")
    
    hHook := DllCall("SetWindowsHookEx"
        , "Int", WH_KEYBOARD_LL    ; idHook
        , "Ptr", hookCallback       ; lpfn
        , "Ptr", hModule           ; hmod
        , "UInt", 0                ; dwThreadId (0 = all threads)
        , "Ptr")
    
    if (!hHook) {
        error := DllCall("GetLastError", "UInt")
        OutputDebug("[INSTALL] ✗ SetWindowsHookEx failed!`n")
        OutputDebug("[INSTALL]   Error code: " error "`n")
        CallbackFree(hookCallback)
        return false
    }
    
    OutputDebug("[INSTALL] ✓ Hook installed: " hHook "`n")
    return true
}

; ===================================================================
; UNINSTALL HOOK
; ===================================================================
UninstallHook() {
    global hHook, hookCallback
    
    OutputDebug("[UNINSTALL] Removing hook...`n")
    
    if (hHook) {
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
        OutputDebug("[UNINSTALL] ✓ Hook removed`n")
        hHook := 0
    }
    
    if (hookCallback) {
        CallbackFree(hookCallback)
        OutputDebug("[UNINSTALL] ✓ Callback freed`n")
        hookCallback := 0
    }
}

; ===================================================================
; KEYBOARD HOOK PROCEDURE
; ===================================================================
KeyboardProc(nCode, wParam, lParam) {
    global VK_A, aPressed, aPressTime, aUsedAsMod, TAP_THRESHOLD
    global WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP
    static callCount := 0
    static HC_ACTION := 0
    
    ; Increment call counter (for debugging)
    callCount++
    
    ; Must call CallNextHookEx if nCode < 0
    if (nCode < 0) {
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
    }
    
    ; Only process HC_ACTION
    if (nCode != HC_ACTION) {
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
    }
    
    ; Read KBDLLHOOKSTRUCT
    vkCode := NumGet(lParam + 0, "UInt")
    scanCode := NumGet(lParam + 4, "UInt")
    flags := NumGet(lParam + 8, "UInt")
    time := NumGet(lParam + 12, "UInt")
    
    ; Only handle 'a' key
    if (vkCode != VK_A) {
        ; Pass through all other keys
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
    }
    
    ; Determine event type
    isKeyDown := (wParam = WM_KEYDOWN || wParam = WM_SYSKEYDOWN)
    isKeyUp := (wParam = WM_KEYUP || wParam = WM_SYSKEYUP)
    
    ; Check if it's a repeat (transition state bit)
    ; Bit 30: Previous key state (1 = was down, 0 = was up)
    wasDown := (flags & 0x40000000) != 0
    
    if (isKeyDown) {
        ; ============================================================
        ; KEY DOWN EVENT
        ; ============================================================
        
        if (aPressed || wasDown) {
            ; This is an auto-repeat - BLOCK IT
            OutputDebug("[HOOK #" callCount "] 'a' AUTO-REPEAT BLOCKED (wasDown=" wasDown ")`n")
            
            ; Return 1 to suppress the keystroke
            return 1
        }
        
        ; First press
        aPressed := true
        aPressTime := A_TickCount
        aUsedAsMod := false
        
        OutputDebug("[HOOK #" callCount "] 'a' DOWN - First press at " aPressTime "`n")
        
        ; Block the original keystroke
        return 1
    }
    else if (isKeyUp) {
        ; ============================================================
        ; KEY UP EVENT
        ; ============================================================
        
        if (!aPressed) {
            ; UP without DOWN, shouldn't happen but ignore
            OutputDebug("[HOOK #" callCount "] 'a' UP without DOWN - ignoring`n")
            return 1
        }
        
        ; Calculate duration
        duration := A_TickCount - aPressTime
        
        OutputDebug("[HOOK #" callCount "] 'a' UP`n")
        OutputDebug("  Duration: " duration "ms`n")
        OutputDebug("  Threshold: " TAP_THRESHOLD "ms`n")
        OutputDebug("  Used as mod: " (aUsedAsMod ? "YES" : "NO") "`n")
        
        ; Decision logic
        shouldSend := false
        
        if (!aUsedAsMod) {
            if (duration < TAP_THRESHOLD) {
                ; TAP: Send the letter
                shouldSend := true
                OutputDebug("  → DECISION: TAP - Will send 'a'`n")
            }
            else {
                ; HOLD unused: Don't send anything
                OutputDebug("  → DECISION: HOLD without use - No send`n")
            }
        }
        else {
            OutputDebug("  → DECISION: Was used as modifier - No send`n")
        }
        
        ; Reset state
        aPressed := false
        
        ; Send the key if needed
        if (shouldSend) {
            ; Use SetTimer to send asynchronously (don't block the hook)
            SetTimer(SendA, -1)
        }
        
        OutputDebug("========================================`n")
        
        ; Block the original keystroke
        return 1
    }
    
    ; Pass through (shouldn't reach here for 'a' key)
    return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
}

; ===================================================================
; SEND 'a' ASYNCHRONOUSLY
; ===================================================================
SendA() {
    OutputDebug("[SEND] Sending 'a' now...`n")
    
    ; CRITICAL: Temporarily disable hook to avoid blocking our own Send
    global hHook
    
    if (hHook) {
        ; Unhook temporarily
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
        OutputDebug("[SEND] Hook temporarily disabled`n")
    }
    
    ; Send the key
    Send("{a}")
    OutputDebug("[SEND] 'a' sent`n")
    
    ; Re-install hook
    if (hHook) {
        Sleep(10)  ; Small delay to ensure Send completed
        
        ; Re-create the hook
        global hookCallback, WH_KEYBOARD_LL
        hModule := DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
        hHook := DllCall("SetWindowsHookEx"
            , "Int", WH_KEYBOARD_LL
            , "Ptr", hookCallback
            , "Ptr", hModule
            , "UInt", 0
            , "Ptr")
        
        OutputDebug("[SEND] Hook re-enabled: " hHook "`n")
    }
}

; ===================================================================
; CLEANUP ON EXIT
; ===================================================================
OnExit((*) => UninstallHook())

; ===================================================================
; INFO DISPLAY (F1)
; ===================================================================
F1:: {
    info := "HOME ROW TEST - Info`n"
    info .= "==================`n`n"
    info .= "Hook Status:`n"
    info .= "  hHook: " hHook "`n"
    info .= "  hookCallback: " hookCallback "`n`n"
    info .= "Current State:`n"
    info .= "  aPressed: " (aPressed ? "YES" : "NO") "`n"
    info .= "  aPressTime: " aPressTime "`n"
    info .= "  aUsedAsMod: " (aUsedAsMod ? "YES" : "NO") "`n`n"
    info .= "Config:`n"
    info .= "  TAP_THRESHOLD: " TAP_THRESHOLD "ms`n"
    info .= "  DEBUG: " (DEBUG ? "ON" : "OFF") "`n`n"
    info .= "Press ESC to exit"
    
    MsgBox(info, "Test Info", "Iconi")
}

; ===================================================================
; TOGGLE DEBUG (F2)
; ===================================================================
F2:: {
    global DEBUG
    DEBUG := !DEBUG
    ToolTip("Debug: " (DEBUG ? "ON" : "OFF"), 10, 50)
    SetTimer(() => ToolTip(), -1500)
}
