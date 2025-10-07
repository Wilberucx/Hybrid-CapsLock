; ===================================================================
; HOME ROW MODS - Dual Function Home Row Keys
; Uses KeyWait-based tap-hold detection (same as CapsLock)
; ===================================================================

; ===================================================================
; GLOBAL STATE
; ===================================================================
global homeRowEnabled := false
global homeRowTapThreshold := 250
global homeRowDebug := false
global homeRowPermissiveHold := false

; Per-key state tracking
global homeRowState := Map(
    "a", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Win"},
    "s", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Alt"},
    "d", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Shift"},
    "f", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Ctrl"},
    "j", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Ctrl"},
    "k", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Shift"},
    "l", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Alt"},
    "semicolon", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Win"}
)

; Excluded apps
global homeRowExcludedApps := []

; ===================================================================
; INITIALIZATION
; ===================================================================
InitHomeRowMods() {
    global homeRowEnabled, homeRowTapThreshold, homeRowDebug
    global homeRowPermissiveHold, homeRowState, homeRowExcludedApps

    ; Read from main configuration file
    mainConfigFile := A_ScriptDir "\config\configuration.ini"
    homeRowConfigFile := A_ScriptDir "\config\homerow_mods.ini"

    ; Check if enabled in main config
    homeRowEnabled := (IniRead(mainConfigFile, "Layers", "home_row_mods_enabled", "false") = "true")

    if (!homeRowEnabled) {
        OutputDebug("[HOMEROW] Home row mods disabled in main configuration`n")
        return
    }

    ; Check if detailed config file exists
    if (!FileExist(homeRowConfigFile)) {
        OutputDebug("[HOMEROW] Detailed config file not found, using defaults`n")
        ; Use default values
        homeRowDebug := false
        homeRowTapThreshold := 250
        homeRowPermissiveHold := false
    } else {
        ; Load detailed settings from homerow_mods.ini
        homeRowDebug := (IniRead(homeRowConfigFile, "General", "debug_mode", "false") = "true")
        homeRowTapThreshold := Integer(IniRead(homeRowConfigFile, "Timing", "tap_threshold_ms", "250"))
        homeRowPermissiveHold := (IniRead(homeRowConfigFile, "Timing", "permissive_hold", "false") = "true")
    }

    ; Load modifiers (from detailed config or defaults)
    if (FileExist(homeRowConfigFile)) {
        ; Load from detailed config
        homeRowState["a"].modifier := IniRead(homeRowConfigFile, "LeftHand", "a_modifier", "Win")
        homeRowState["s"].modifier := IniRead(homeRowConfigFile, "LeftHand", "s_modifier", "Alt")
        homeRowState["d"].modifier := IniRead(homeRowConfigFile, "LeftHand", "d_modifier", "Shift")
        homeRowState["f"].modifier := IniRead(homeRowConfigFile, "LeftHand", "f_modifier", "Ctrl")
        homeRowState["j"].modifier := IniRead(homeRowConfigFile, "RightHand", "j_modifier", "Ctrl")
        homeRowState["k"].modifier := IniRead(homeRowConfigFile, "RightHand", "k_modifier", "Shift")
        homeRowState["l"].modifier := IniRead(homeRowConfigFile, "RightHand", "l_modifier", "Alt")
        homeRowState["semicolon"].modifier := IniRead(homeRowConfigFile, "RightHand", "semicolon_modifier", "Win")

        ; Load exclusions
        excludedStr := IniRead(homeRowConfigFile, "Exclusions", "excluded_apps", "")
        if (excludedStr != "") {
            homeRowExcludedApps := StrSplit(excludedStr, ",")
            for index, app in homeRowExcludedApps {
                homeRowExcludedApps[index] := Trim(app)
            }
        }
    } else {
        ; Use default modifier assignments
        homeRowState["a"].modifier := "Win"
        homeRowState["s"].modifier := "Alt"
        homeRowState["d"].modifier := "Shift"
        homeRowState["f"].modifier := "Ctrl"
        homeRowState["j"].modifier := "Ctrl"
        homeRowState["k"].modifier := "Shift"
        homeRowState["l"].modifier := "Alt"
        homeRowState["semicolon"].modifier := "Win"

        ; No excluded apps by default
        homeRowExcludedApps := []
    }

    ; Register simple hotkeys like NVIM layer
    RegisterSimpleHomeRowHotkeys()
    
    if (homeRowDebug)
        OutputDebug("[HOMEROW] Initialized with simple hotkeys, threshold=" homeRowTapThreshold "ms`n")
}

; ===================================================================
; REGISTER SIMPLE HOTKEYS - Same pattern as NVIM layer
; ===================================================================
RegisterSimpleHomeRowHotkeys() {
    global homeRowState, homeRowDebug, homeRowEnabled

    if (!homeRowEnabled) {
        if (homeRowDebug)
            OutputDebug("[HOMEROW] Home row mods disabled - no hotkeys registered`n")
        return
    }

    for key, state in homeRowState {
        if (state.modifier = "none") {
            if (homeRowDebug)
                OutputDebug("[HOMEROW] Skipping " key " (modifier=none)`n")
            continue
        }

        actualKey := (key = "semicolon") ? ";" : key

        try {
            ; Register down/up explicitly without tilde to suppress base key
            Hotkey("*" actualKey, (*) => OnHomeRowDown(key))
            Hotkey("*" actualKey " up", (*) => OnHomeRowUp(key))

            if (homeRowDebug)
                OutputDebug("[HOMEROW] Registered: *" actualKey " (down/up) -> " state.modifier "`n")
        } catch as err {
            OutputDebug("[HOMEROW] Failed to register " actualKey ": " err.Message "`n")
        }
    }
}

; ===================================================================
; HANDLE TAP-HOLD via explicit down/up handlers (no KeyWait)
; ===================================================================
OnHomeRowDown(key) {
    global homeRowState, homeRowDebug
    if (IsInExcludedApp()) {
        ; passthrough: do nothing here, base key suppressed but will be decided on up
    }
    state := homeRowState[key]
    state.pressed := true
    state.pressTime := A_TickCount
    state.usedAsMod := false
    if (homeRowDebug)
        OutputDebug("[HOMEROW] " ((key="semicolon")?";":key) " DOWN`n")
}

OnHomeRowUp(key) {
    global homeRowState, homeRowTapThreshold, homeRowDebug, homeRowPermissiveHold
    state := homeRowState[key]
    actualKey := (key = "semicolon") ? ";" : key
    if (!state.pressed) {
        return
    }
    ; Exclusions: pass through as normal key
    if (IsInExcludedApp()) {
        Send("{" actualKey "}")
        state.pressed := false
        return
    }
    duration := A_TickCount - state.pressTime
    if (homeRowDebug)
        OutputDebug("[HOMEROW] " actualKey " UP - dur=" duration "ms, usedAsMod=" state.usedAsMod "`n")

    if (!state.usedAsMod) {
        if (duration < homeRowTapThreshold) {
            Send("{" actualKey "}")
            if (homeRowDebug)
                OutputDebug("[HOMEROW] TAP -> send " actualKey "`n")
        } else if (homeRowPermissiveHold) {
            Send("{" actualKey "}")
            if (homeRowDebug)
                OutputDebug("[HOMEROW] HOLD unused (permissive) -> send " actualKey "`n")
        } else {
            if (homeRowDebug)
                OutputDebug("[HOMEROW] HOLD unused (strict) -> no send`n")
        }
    }
    state.pressed := false
}

; ===================================================================
; CHECK IF ANY HOME ROW KEY IS HELD
; ===================================================================
IsAnyHomeRowKeyHeld() {
    global homeRowState

    for key, state in homeRowState {
        actualKey := (key = "semicolon") ? ";" : key
        if (GetKeyState(actualKey, "P"))
            return true
    }

    return false
}

; ===================================================================
; GET ACTIVE MODIFIERS FROM HELD HOME ROW KEYS
; ===================================================================
GetActiveHomeRowModifiers() {
    global homeRowState
    modifiers := ""

    for key, state in homeRowState {
        actualKey := (key = "semicolon") ? ";" : key

        if (GetKeyState(actualKey, "P")) {
            ; Mark as used
            state.usedAsMod := true

            ; Build modifier string
            switch state.modifier {
                case "Win":
                    modifiers .= "#"
                case "Alt":
                    modifiers .= "!"
                case "Shift":
                    modifiers .= "+"
                case "Ctrl":
                    modifiers .= "^"
            }
        }
    }

    return modifiers
}

; ===================================================================
; MARK HOME ROW KEY AS USED (called by other keys)
; ===================================================================
MarkHomeRowAsModifier(key) {
    global homeRowState, homeRowDebug

    if (homeRowState.Has(key)) {
        homeRowState[key].usedAsMod := true

        if (homeRowDebug)
            OutputDebug("[HOMEROW] Marked " key " as used modifier`n")
    }
}

; ===================================================================
; CHECK IF IN EXCLUDED APP
; ===================================================================
IsInExcludedApp() {
    global homeRowExcludedApps

    if (homeRowExcludedApps.Length = 0)
        return false

    activeExe := WinGetProcessName("A")

    for app in homeRowExcludedApps {
        if (InStr(activeExe, app))
            return true
    }

    return false
}

; ===================================================================
; CONTEXT HOTKEYS - Other keys mark home row as used
; ===================================================================
; These need to be defined for every other key on the keyboard
; to detect when home row is used as modifier

#HotIf homeRowEnabled && !IsInExcludedApp() && IsAnyHomeRowKeyHeld()

; Letters (excluding home row)
b::SendWithHomeRowMod("b")
c::SendWithHomeRowMod("c")
e::SendWithHomeRowMod("e")
g::SendWithHomeRowMod("g")
h::SendWithHomeRowMod("h")
i::SendWithHomeRowMod("i")
m::SendWithHomeRowMod("m")
n::SendWithHomeRowMod("n")
o::SendWithHomeRowMod("o")
p::SendWithHomeRowMod("p")
q::SendWithHomeRowMod("q")
r::SendWithHomeRowMod("r")
t::SendWithHomeRowMod("t")
u::SendWithHomeRowMod("u")
v::SendWithHomeRowMod("v")
w::SendWithHomeRowMod("w")
x::SendWithHomeRowMod("x")
y::SendWithHomeRowMod("y")
z::SendWithHomeRowMod("z")

; Numbers
1::SendWithHomeRowMod("1")
2::SendWithHomeRowMod("2")
3::SendWithHomeRowMod("3")
4::SendWithHomeRowMod("4")
5::SendWithHomeRowMod("5")
6::SendWithHomeRowMod("6")
7::SendWithHomeRowMod("7")
8::SendWithHomeRowMod("8")
9::SendWithHomeRowMod("9")
0::SendWithHomeRowMod("0")

; Special keys
Space::SendWithHomeRowMod("Space")
Enter::SendWithHomeRowMod("Enter")
Tab::SendWithHomeRowMod("Tab")
Backspace::SendWithHomeRowMod("Backspace")
Delete::SendWithHomeRowMod("Delete")
Escape::SendWithHomeRowMod("Escape")

; Arrows
Left::SendWithHomeRowMod("Left")
Right::SendWithHomeRowMod("Right")
Up::SendWithHomeRowMod("Up")
Down::SendWithHomeRowMod("Down")

#HotIf

; ===================================================================
; SEND WITH HOME ROW MODIFIER
; ===================================================================
SendWithHomeRowMod(key) {
    global homeRowDebug

    ; Get active modifiers
    mods := GetActiveHomeRowModifiers()

    if (homeRowDebug)
        OutputDebug("[HOMEROW] Sending: " mods "{" key "}`n")

    ; Send with modifiers
    Send(mods "{" key "}")
}

; ===================================================================
; CLEANUP ON EXIT (No longer needed - simple hotkeys clean themselves)
; ===================================================================