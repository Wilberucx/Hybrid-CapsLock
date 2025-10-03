; ==============================
; Nvim Layer (toggle on CapsLock tap)
; ==============================
; Provides a lightweight Vim-like navigation layer toggled by a clean CapsLock tap.
; - Toggle: clean tap on CapsLock (not used as modifier)
; - Context: Active when isNvimLayerActive is true and CapsLock is not physically pressed
; - Visual Mode: simple ON/OFF indicator
; Depends on: core/globals (isNvimLayerActive, VisualMode, capsLockUsedAsModifier),
;             core/persistence (SaveLayerState), ui/tooltips_native_wrapper (status)

; ---- Toggle via CapsLock clean tap ----
; We keep CapsLock AlwaysOff; a clean tap (not used as modifier) toggles Nvim Layer
~CapsLock up:: {
    global nvimLayerEnabled, isNvimLayerActive, VisualMode, capsLockUsedAsModifier
    if (!nvimLayerEnabled)
        return
    ; If CapsLock was used as a modifier for any combo, do not toggle
    if (capsLockUsedAsModifier) {
        capsLockUsedAsModifier := false
        return
    }
    ; Toggle Nvim layer
    isNvimLayerActive := !isNvimLayerActive
    if (isNvimLayerActive) {
        ShowNvimLayerStatus(true)
        SetTempStatus("NVIM LAYER ON", 1500)
    } else {
        VisualMode := false
        ShowNvimLayerStatus(false)
        SetTempStatus("NVIM LAYER OFF", 1500)
    }
    try SaveLayerState()
}

; ---- Context hotkeys ----
#HotIf (isNvimLayerActive && !GetKeyState("CapsLock", "P"))

; Visual Mode toggle
v:: {
    global VisualMode
    VisualMode := !VisualMode
    ShowVisualModeStatus(VisualMode)
    SetTimer(() => RemoveToolTip(), -1000)
}

; Basic navigation (hjkl)
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")

; Delete menu (d → w/d/a)
d:: {
    global VisualMode
    if (VisualMode) {
        Send("{Delete}")
        return
    }
    ShowDeleteMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "w": DeleteCurrentWord()
        case "d": DeleteCurrentLine()
        case "a": DeleteAll()
    }
}

; Yank menu (y → y/w/a/p)
y:: {
    global VisualMode
    if (VisualMode) {
        Send("^c")
        ShowCopyNotification()
        return
    }
    ShowYankMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "y": CopyCurrentLine()
        case "w": CopyCurrentWord()
        case "a": Send("^a^c"), ShowCopyNotification()
        case "p": CopyCurrentParagraph()
    }
}

; Paste
p::Send("^v")
+p::PastePlain()

; End of word (e)
e::Send("^{Right}{Left}")

; Smooth scrolling
+e::Send("{WheelDown 3}")
+y::Send("{WheelUp 3}")

; Insert mode (temporary disable layer)
i:: {
    global isNvimLayerActive, _tempEditMode
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("INSERT MODE", 3000)
    SetTimer(ReactivateNvimAfterInsert, -3000)
}

; Replace mode (delete char, temporary disable)
r:: {
    global isNvimLayerActive, _tempEditMode
    Send("{Delete}")
    isNvimLayerActive := false
    _tempEditMode := true
    ShowNvimLayerStatus(false)
    SetTempStatus("REPLACE: Type char then press ESC", 3000)
    SetTimer(ReactivateNvimAfterReplace, -3000)
}

; Quick exit
q:: {
    global isNvimLayerActive, VisualMode
    isNvimLayerActive := false
    VisualMode := false
    ShowNvimLayerStatus(false)
    SetTimer(() => RemoveToolTip(), -800)
    try SaveLayerState()
}

#HotIf

; ---- Helpers ----
DeleteCurrentWord() {
    Send("^{Right}^+{Left}{Delete}")
    ShowCenteredToolTip("WORD DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
DeleteCurrentLine() {
    Send("{Home}+{End}{Delete}")
    ShowCenteredToolTip("LINE DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
DeleteAll() {
    Send("^a{Delete}")
    ShowCenteredToolTip("ALL DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
CopyCurrentLine() {
    Send("{Home}+{End}^c")
    ShowCenteredToolTip("LINE COPIED")
    SetTimer(() => RemoveToolTip(), -800)
}
CopyCurrentWord() {
    Send("^{Right}^+{Left}^c")
    ShowCopyNotification()
}
CopyCurrentParagraph() {
    Send("^{Up}^+{Down}^c")
    ShowCenteredToolTip("PARAGRAPH COPIED")
    SetTimer(() => RemoveToolTip(), -800)
}
PastePlain() {
    Send("^+v")
}
ReactivateNvimAfterInsert() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        SetTimer(() => RemoveToolTip(), -1000)
    }
}
ReactivateNvimAfterReplace() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        SetTimer(() => RemoveToolTip(), -1000)
    }
}
