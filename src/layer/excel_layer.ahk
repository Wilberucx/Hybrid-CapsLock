; ==============================
; Excel/Accounting Layer (persistent)
; ==============================
; Hotkeys active only when excelLayerActive is true and CapsLock is not physically pressed.
; Depends on: core/globals (excelLayerActive flag), ui wrapper (ShowExcelLayerStatus, SetTempStatus).

; Try dynamic mappings if available
try {
    global excelMappings
    excelMappings := LoadExcelMappings(A_ScriptDir . "\\config\\excel_layer.ini")
    if (excelMappings.Count > 0)
        ApplyExcelMappings(excelMappings)
} catch {
}

#InputLevel 1
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive) : false)

; === NUMPAD SECTION ===
; New numeric pad: 123 (top), QWE (middle), ASD (bottom), X as 0
1::Send("{Numpad1}")
2::Send("{Numpad2}")
3::Send("{Numpad3}")

q::Send("{Numpad4}")
w::Send("{Numpad5}")
e::Send("{Numpad6}")

a::Send("{Numpad7}")
s::Send("{Numpad8}")
d::Send("{Numpad9}")

; Zero
x::Send("{Numpad0}")

; Decimal and comma
,::Send("{NumpadComma}")
.::Send("{NumpadDot}")

; Operations
o::Send("{NumpadAdd}")  ; Moved from p to o
`;::Send("{NumpadSub}")
/::Send("{NumpadDiv}")

; === NAVIGATION SECTION ===
; Arrow keys (Vim HJKL) - disabled when VVModeActive
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")

; Tab navigation
[::Send("+{Tab}")
]::Send("{Tab}")

; === EXCEL FUNCTIONS ===
i::Send("{F2}")         ; Edit cell
f::Send("^f")           ; Find
u::Send("^z")           ; Undo
r::Send("^y")           ; Redo
g::Send("^{Home}")      ; Go to beginning
; Capital G handled in main context
+g::Send("^{End}")      ; Go to end (Shift+g = G)
m::Send("^g")           ; Go to specific cell
y::Send("^c")           ; Yank (copy) - disabled when VVModeActive
p::Send("^v")           ; Paste - disabled when VVModeActive
; c removed - duplicates y (yank)
; Note: y, p are also defined in VV mode with different behavior

; === EXIT EXCEL LAYER ===
+n:: {
    global excelLayerActive
    excelLayerActive := false
    ShowExcelLayerStatus(false)
    SetTempStatus("EXCEL LAYER OFF", 2000)
}

; === SELECTION FUNCTIONS (MINICAPAS) ===
; v prefix for selection functions (like GLogic in nvim)
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive && !VVModeActive) : false)
v::VLogicStart()
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive) : false)

; === HELP (toggle with ?) ===
+vkBF:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
+SC035:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
?:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())

#HotIf

; === MINICAPA V LOGIC (vr, vc, vv) ===
#InputLevel 2
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && VLogicActive) : false)
*r:: {
    VLogicCancel()
    ; Alternative approach for row selection
    Send("{Home}")      ; Go to beginning of row first
    Send("+{Space}")    ; Then select entire row
    ToolTip("ROW SELECTED - Home+Shift+Space")
    SetTimer(() => ToolTip(), -2000)
}

*c:: {
    VLogicCancel()
    Send("^{Space}") ; Ctrl+Space = select entire column
    ToolTip("COLUMN SELECTED")
    SetTimer(() => ToolTip(), -1000)
}

*v:: {
    global VVModeActive
    VLogicCancel()
    VVModeActive := true
    ToolTip("VISUAL SELECTION MODE ON - VVModeActive=" . VVModeActive . "`nPress hjkl to select, Esc/Enter to exit")
    OutputDebug("VV Mode Activated: VVModeActive=" . VVModeActive)
    ; No timeout for VV mode - tooltip stays until action
}

*Esc::VLogicCancel()

; Debug hotkey: Check VV state with F9
*F9:: {
    global VVModeActive, excelLayerActive, excelStaticEnabled
    msg := "DEBUG STATUS:`n"
    msg .= "VVModeActive: " . VVModeActive . "`n"
    msg .= "excelLayerActive: " . excelLayerActive . "`n"
    msg .= "excelStaticEnabled: " . excelStaticEnabled . "`n"
    msg .= "CapsLock: " . GetKeyState("CapsLock", "P") . "`n"
    msg .= "ExcelLayerAppAllowed: " . ExcelLayerAppAllowed()
    ToolTip(msg)
    OutputDebug(msg)
    SetTimer(() => ToolTip(), -5000)
}

#HotIf
#InputLevel 1

; === VV MODE (visual selection with arrows) ===
#InputLevel 2
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && VVModeActive) : false)

; Debug: Test if hotkeys are being registered
h:: {
    OutputDebug("h pressed in VV context")
    ExcelVVDirectionalSend("Left")
}
j:: {
    OutputDebug("j pressed in VV context")
    ExcelVVDirectionalSend("Down")
}
k:: {
    OutputDebug("k pressed in VV context")
    ExcelVVDirectionalSend("Up")
}
l:: {
    OutputDebug("l pressed in VV context")
    ExcelVVDirectionalSend("Right")
}

; Exit VV mode
*Esc:: {
    global VVModeActive
    VVModeActive := false
    ToolTip("VISUAL SELECTION OFF")
    SetTimer(() => ToolTip(), -1000)
}

*Enter:: {
    global VVModeActive
    VVModeActive := false
    ToolTip("VISUAL SELECTION OFF")
    SetTimer(() => ToolTip(), -1000)
}

; Opciones adicionales en VV mode
*y:: {
    global VVModeActive
    Send("^c")  ; Copy selection
    VVModeActive := false
    ToolTip("COPIED - VV MODE OFF")
    SetTimer(() => ToolTip(), -1000)
}

*d:: {
    global VVModeActive
    Send("{Delete}")  ; Delete selection
    VVModeActive := false
    ToolTip("DELETED - VV MODE OFF")
    SetTimer(() => ToolTip(), -1000)
}

*p:: {
    global VVModeActive
    Send("^v")  ; Paste over selection
    VVModeActive := false
    ToolTip("PASTED - VV MODE OFF")
    SetTimer(() => ToolTip(), -1000)
}

#HotIf
#InputLevel 1

; === Status helper ===
ExcelLayerAppAllowed() {
    return ExcelAppAllowedGuard()
}

ExcelAppAllowedGuard() {
    ; Whitelist/Blacklist by process name from excel_layer.ini
    try {
        ini := A_ScriptDir . "\\config\\excel_layer.ini"
        wl := IniRead(ini, "Settings", "whitelist", "")
        bl := IniRead(ini, "Settings", "blacklist", "")
        proc := WinGetProcessName("A")
        if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
            return false
        if (wl = "" )
            return true
        return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
    } catch {
        return true
    }
}

global ExcelHelpActive := false
global VLogicActive := false
global VVModeActive := false

ExcelShowHelp() {
    global tooltipConfig, ExcelHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ExcelHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ExcelHelpAutoClose, -to)
    try ShowExcelHelpCS()
}

ExcelHelpAutoClose() {
    global ExcelHelpActive
    if (ExcelHelpActive)
        ExcelCloseHelp()
}

ExcelCloseHelp() {
    global excelLayerActive, ExcelHelpActive
    try SetTimer(ExcelHelpAutoClose, 0)
    try HideCSharpTooltip()
    ExcelHelpActive := false
    if (excelLayerActive) {
        try ShowExcelLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

ShowExcelLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowExcelLayerToggleCS(isActive)
    } else {
        ToolTip(isActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF")
        SetTimer(() => ToolTip(), -1200)
    }
}

; === V LOGIC FUNCTIONS ===
VLogicStart() {
    global VLogicActive
    VLogicActive := true
    to := 3000 ; 3 segundos timeout
    SetTimer(VLogicTimeout, -to)
}

VLogicTimeout() {
    VLogicCancel()
}

VLogicCancel() {
    global VLogicActive
    VLogicActive := false
}

; === VV MODE HELPER FUNCTION ===
; Similar to NvimDirectionalSend but for Excel VV mode
; Always adds Shift to extend selection, and respects other modifiers
ExcelVVDirectionalSend(dir) {
    global VVModeActive
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("Shift", "P")
        mods .= "+"
    ; En VVModeActive, siempre asegurar que Shift esté presente para extender selección
    if (VVModeActive && !InStr(mods, "+"))
        mods .= "+"
    
    ; Debug output - both OutputDebug and visible tooltip
    OutputDebug("ExcelVV: VVMode=" . VVModeActive . " | mods='" . mods . "' | dir=" . dir)
    ToolTip("VV: " . mods . "{" . dir . "}")
    SetTimer(() => ToolTip(), -800)
    
    ; Use SendInput for more reliable delivery in Excel
    SendInput(mods . "{" . dir . "}")
}
