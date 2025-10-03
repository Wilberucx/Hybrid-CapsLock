; ==============================
; Modifier Mode (CapsLock & key)
; ==============================
; Migrated core of Modifier Mode: window controls, navigation, scrolling, common shortcuts.
; Depends on: core/globals (MarkCapsLockAsModifier), ui (status/tooltip helpers)

; Try dynamic mappings if available (modifier)
try {
    global modifierMappings
    modifierMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\modifier_layer.ini")
    if (modifierMappings.Count > 0)
        ApplyGenericMappings("modifier", modifierMappings, (*) => modifierLayerEnabled, "CapsLock & ")
} catch {
}

#HotIf (modifierStaticEnabled ? (modifierLayerEnabled) : false)

; ----- Window Functions -----
CapsLock & 1::WinMinimize("A")
CapsLock & `::Send("#m")  ; Minimize all windows
CapsLock & q::Send("!{F4}")  ; Close window (Alt+F4)

; Maximize/Restore toggle
CapsLock & f:: {
    MarkCapsLockAsModifier()
    winState := WinGetMinMax("A")
    if (winState = 1)
        WinRestore("A")
    else
        WinMaximize("A")
}

; ----- Window Switcher / Custom -----
CapsLock & Tab:: {
    ; Enhanced Alt+Tab: hold CapsLock to keep cycling with Tab
    MarkCapsLockAsModifier()
    Send("{Alt down}{Tab}")
    KeyWait("Tab")
    while GetKeyState("CapsLock", "P") {
        if GetKeyState("Tab", "P") {
            Send("{Tab}")
            KeyWait("Tab")
        }
        Sleep(10)
    }
    Send("{Alt up}")
}
CapsLock & 2:: {
    MarkCapsLockAsModifier()
    Send("^!+2")
}

; ----- Basic Navigation (Vim Style) -----
; TODO(RovoDev): Future enhancement — hjkl modifier-aware arrows
; - Detect Ctrl/Alt/Shift/Win active and send modified arrows accordingly (e.g., Alt+h -> !{Left}, Shift+j -> +{Down})
; - Preserve reserved combos (Ctrl+a, Ctrl+c). Pending decision for Ctrl+Shift+c.
; - Consider a feature flag and a configurable exceptions list in configuration.ini/modifier_layer.ini

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
CapsLock & s:: {
    MarkCapsLockAsModifier()
    Send("^s")
} ; Save
CapsLock & c:: {
    MarkCapsLockAsModifier()
    Send("^c")
    ShowCopyNotification()
} ; Copy + notify
CapsLock & v:: {
    MarkCapsLockAsModifier()
    Send("^v")
} ; Paste
CapsLock & x:: {
    MarkCapsLockAsModifier()
    Send("^x")
} ; Cut
CapsLock & z:: {
    MarkCapsLockAsModifier()
    Send("^z")
} ; Undo
CapsLock & a:: {
    MarkCapsLockAsModifier()
    Send("^a")
} ; Select all

; ----- File/Tab Operations -----
CapsLock & o:: {
    MarkCapsLockAsModifier()
    Send("^o")
} ; Open
CapsLock & t:: {
    MarkCapsLockAsModifier()
    Send("^t")
} ; New tab
CapsLock & w:: {
    MarkCapsLockAsModifier()
    Send("^w")
} ; Close tab

; ----- Tabs Navigation -----
CapsLock & m:: {
    MarkCapsLockAsModifier()
    Send("^{PgDn}")
} ; Next tab
CapsLock & u:: {
    MarkCapsLockAsModifier()
    Send("^{PgUp}")
} ; Prev tab

; ----- Mouse-like -----
CapsLock & sc027:: {
    MarkCapsLockAsModifier()
    SendEvent("{LButton down}")
}
CapsLock & sc028::  {
    MarkCapsLockAsModifier()
    Click "Right"
}

; ----- Back / URL copy / Screenshot / Ctrl+Enter -----
CapsLock & Backspace:: {
    MarkCapsLockAsModifier()
    Send("!{Left}")
} ; Back
CapsLock & 5:: {
    MarkCapsLockAsModifier()
    Send("^l^c")
    ShowCopyNotification()
} ; Copy path/URL
CapsLock & 9:: {
    MarkCapsLockAsModifier()
    Send("#+s")
} ; Snip
CapsLock & Enter:: {
    MarkCapsLockAsModifier()
    Send("^{Enter}")
} ; Ctrl+Enter

; ----- Mouse release (click hold cleanup) -----
sc027 up:: {
    SendEvent("{LButton up}")
}
~CapsLock up:: {
    SendEvent("{LButton up}")
}

#HotIf
