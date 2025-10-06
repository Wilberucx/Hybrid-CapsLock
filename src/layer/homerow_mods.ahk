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

    configFile := A_ScriptDir "\config\homerow_mods.ini"

    if (!FileExist(configFile)) {
        OutputDebug("[HOMEROW] Config file not found, home row mods disabled`n")
        return
    }

    ; Load general settings
    homeRowEnabled := (IniRead(configFile, "General", "enabled", "false") = "true")
    homeRowDebug := (IniRead(configFile, "General", "debug_mode", "false") = "true")

    if (!homeRowEnabled) {
        OutputDebug("[HOMEROW] Home row mods disabled in config`n")
        return
    }

    ; Load timing
    homeRowTapThreshold := Integer(IniRead(configFile, "Timing", "tap_threshold_ms", "250"))
    homeRowPermissiveHold := (IniRead(configFile, "Timing", "permissive_hold", "false") = "true")

    ; Load left hand modifiers
    homeRowState["a"].modifier := IniRead(configFile, "LeftHand", "a_modifier", "Win")
    homeRowState["s"].modifier := IniRead(configFile, "LeftHand", "s_modifier", "Alt")
    homeRowState["d"].modifier := IniRead(configFile, "LeftHand", "d_modifier", "Shift")
    homeRowState["f"].modifier := IniRead(configFile, "LeftHand", "f_modifier", "Ctrl")

    ; Load right hand modifiers
    homeRowState["j"].modifier := IniRead(configFile, "RightHand", "j_modifier", "Ctrl")
    homeRowState["k"].modifier := IniRead(configFile, "RightHand", "k_modifier", "Shift")
    homeRowState["l"].modifier := IniRead(configFile, "RightHand", "l_modifier", "Alt")
    homeRowState["semicolon"].modifier := IniRead(configFile, "RightHand", "semicolon_modifier", "Win")

    ; Load exclusions
    excludedStr := IniRead(configFile, "Exclusions", "excluded_apps", "")
    if (excludedStr != "") {
        homeRowExcludedApps := StrSplit(excludedStr, ",")
        for index, app in homeRowExcludedApps {
            homeRowExcludedApps[index] := Trim(app)
        }
    }

    ; Register hotkeys for enabled keys
    RegisterHomeRowHotkeys()

    if (homeRowDebug)
        OutputDebug("[HOMEROW] Initialized with threshold=" homeRowTapThreshold "ms`n")
}

; ===================================================================
; REGISTER HOTKEYS DYNAMICALLY
; ===================================================================
RegisterHomeRowHotkeys() {
    global homeRowState, homeRowDebug

    for key, state in homeRowState {
        if (state.modifier = "none") {
            if (homeRowDebug)
                OutputDebug("[HOMEROW] Skipping " key " (modifier=none)`n")
            continue
        }

        ; Register the hotkey
        actualKey := (key = "semicolon") ? ";" : key

        try {
            Hotkey("~*" actualKey, (*) => HandleHomeRowKey(key))
            if (homeRowDebug)
                OutputDebug("[HOMEROW] Registered: " actualKey " -> " state.modifier "`n")
        } catch as err {
            OutputDebug("[HOMEROW] Failed to register " actualKey ": " err.Message "`n")
        }
    }
}

; ===================================================================
; CORE HANDLER - Same pattern as CapsLock
; ===================================================================
HandleHomeRowKey(key) {
    global homeRowState, homeRowTapThreshold, homeRowDebug
    global homeRowPermissiveHold, homeRowExcludedApps

    ; Check if in excluded app
    if (IsInExcludedApp()) {
        if (homeRowDebug)
            OutputDebug("[HOMEROW] In excluded app, passthrough`n")
        return
    }

    state := homeRowState[key]

    ; Initialize state
    state.pressed := true
    state.pressTime := A_TickCount
    state.usedAsMod := false

    actualKey := (key = "semicolon") ? ";" : key

    if (homeRowDebug)
        OutputDebug("[HOMEROW] " actualKey " DOWN`n")

    ; CRITICAL: KeyWait ignores auto-repeats
    KeyWait(actualKey)

    ; Calculate duration
    duration := A_TickCount - state.pressTime

    if (homeRowDebug) {
        OutputDebug("[HOMEROW] " actualKey " UP - dur=" duration
                    "ms, usedAsMod=" state.usedAsMod
                    ", threshold=" homeRowTapThreshold "ms`n")
    }

    ; Decision logic
    if (state.usedAsMod) {
        ; Was used as modifier, do nothing
        if (homeRowDebug)
            OutputDebug("[HOMEROW] " actualKey " was used as modifier`n")
    }
    else if (duration < homeRowTapThreshold) {
        ; TAP: Send the letter
        if (homeRowDebug)
            OutputDebug("[HOMEROW] " actualKey " TAP - sending letter`n")
        Send("{" actualKey "}")
    }
    else {
        ; HOLD without use
        if (homeRowPermissiveHold) {
            ; Send the letter anyway (permissive)
            if (homeRowDebug)
                OutputDebug("[HOMEROW] " actualKey " HOLD unused - sending letter (permissive)`n")
            Send("{" actualKey "}")
        } else {
            ; Do nothing (strict, like CapsLock)
            if (homeRowDebug)
                OutputDebug("[HOMEROW] " actualKey " HOLD unused - no action (strict)`n")
        }
    }

    ; Reset state
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

#HotIf IsAnyHomeRowKeyHeld()

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