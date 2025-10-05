; ==============================
; Nvim Layer (toggle on CapsLock tap)
; ==============================
; Provides a lightweight Vim-like navigation layer toggled by a clean CapsLock tap.
; - Toggle: clean tap on CapsLock (not used as modifier)
; - Context: Active when isNvimLayerActive is true and CapsLock is not physically pressed
; - Visual Mode: simple ON/OFF indicator
; Depends on: core/globals (isNvimLayerActive, VisualMode, capsLockUsedAsModifier),
;             core/persistence (SaveLayerState), ui/tooltips_native_wrapper (status)

; ---- Toggle via CapsLock clean tap (KeyWait-based, Claude-style) ----
; Block until release, then decide by duration and whether CapsLock was used as modifier.
~*CapsLock:: {
    global nvimLayerEnabled, isNvimLayerActive, VisualMode
    global capsTapThresholdMs, capsLockUsedAsModifier
    if (!nvimLayerEnabled)
        return
    capsLockUsedAsModifier := false ; reset at down
    downTick := A_TickCount
    KeyWait("CapsLock") ; wait for release
    dur := A_TickCount - downTick
    OutputDebug "[NVIM] KeyWait dur=" dur ", usedAsMod=" capsLockUsedAsModifier ", thr=" capsTapThresholdMs "\n"
    if (capsLockUsedAsModifier)
        return ; used as modifier, do not toggle
    if (dur >= capsTapThresholdMs)
        return ; long hold, ignore
    ; Toggle
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


; Try dynamic mappings if available (Normal mode)
try {
    global nvimMappings
    nvimMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Normal", "order")
    if (nvimMappings.Count > 0)
        ApplyGenericMappings("nvim_normal", nvimMappings, (*) => (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Try dynamic mappings for Visual mode
try {
    global nvimVisualMappings
    nvimVisualMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Visual", "order")
    if (nvimVisualMappings.Count > 0)
        ApplyGenericMappings("nvim_visual", nvimVisualMappings, (*) => (isNvimLayerActive && VisualMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Try dynamic mappings for Insert mode
try {
    global nvimInsertMappings
    nvimInsertMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Insert", "order")
    if (nvimInsertMappings.Count > 0)
        ApplyGenericMappings("nvim_insert", nvimInsertMappings, (*) => (_tempEditMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; ---- Context hotkeys ----
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

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

; Exit Insert mode (if mapped dynamically)
Esc:: {
    global _tempEditMode
    if (_tempEditMode) {
        ReactivateNvimAfterInsert()
    } else {
        Send("{Escape}")
    }
}

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

; ---- App filter for Nvim layer ----
NvimLayerAppAllowed() {
   try {
       ini := A_ScriptDir . "\\config\\nvim_layer.ini"
       wl := IniRead(ini, "Settings", "whitelist", "")
       bl := IniRead(ini, "Settings", "blacklist", "")
       proc := WinGetProcessName("A")
       if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
           return false
       if (wl = "")
           return true
       return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
   } catch {
       return true
   }
}

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
NvimCapsHoldGuard() {
    global capsHoldDetected
    if GetKeyState("CapsLock", "P")
        capsHoldDetected := true
}

NvimHandleDeleteMenu() {
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

NvimHandleYankMenu() {
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

ReactivateNvimAfterReplace() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        SetTimer(() => RemoveToolTip(), -1000)
    }
}
