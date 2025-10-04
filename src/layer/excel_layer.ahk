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

#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed()) : false)

; === NUMPAD SECTION ===
; Top row (7, 8, 9)
7::Send("{Numpad7}")
8::Send("{Numpad8}")
9::Send("{Numpad9}")

; Middle row (4, 5, 6)
u::Send("{Numpad4}")
i::Send("{Numpad5}")
o::Send("{Numpad6}")

; Bottom row (1, 2, 3)
j::Send("{Numpad1}")
k::Send("{Numpad2}")
l::Send("{Numpad3}")

; Zero
m::Send("{Numpad0}")

; Decimal and comma
,::Send("{NumpadComma}")
.::Send("{NumpadDot}")

; Operations
p::Send("{NumpadAdd}")
`;::Send("{NumpadSub}")
/::Send("{NumpadDiv}")

; === NAVIGATION SECTION ===
; Arrow keys (WASD)
w::Send("{Up}")
a::Send("{Left}")
s::Send("{Down}")
d::Send("{Right}")

; Tab navigation
[::Send("+{Tab}")
]::Send("{Tab}")

; === EXCEL FUNCTIONS ===
Enter::Send("^{Enter}")  ; Fill down
Space::Send("{F2}")      ; Edit cell
f::Send("^f")           ; Find
r::Send("^r")           ; Fill right

; === EXIT EXCEL LAYER ===
+n:: {
    global excelLayerActive
    excelLayerActive := false
    ShowExcelLayerStatus(false)
    SetTempStatus("EXCEL LAYER OFF", 2000)
}

#HotIf

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

ShowExcelLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowExcelLayerStatusCS(isActive)
    } else {
        ToolTip(isActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF")
        SetTimer(() => ToolTip(), -1200)
    }
}
