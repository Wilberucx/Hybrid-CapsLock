; ==============================
; Core mappings (dynamic hotkeys per layer)
; ==============================
; Utilities to load INI-based mappings and register hotkeys dynamically.

; ---- Parse action spec ----
ParseActionSpec(spec) {
    spec := Trim(spec)
    if (spec = "")
        return { type: "none" }
    colon := InStr(spec, ":")
    if (!colon) {
        return { type: "send", payload: spec }
    }
    kind := StrLower(Trim(SubStr(spec, 1, colon - 1)))
    payload := Trim(SubStr(spec, colon + 1))
    if (kind = "send")
        return { type: "send", payload: payload }
    if (kind = "func")
        return { type: "func", payload: payload }
    if (kind = "macro") {
        steps := []
        for part in StrSplit(payload, [";", "`n", "`r"]) {
            p := Trim(part)
            if (p != "")
                steps.Push(p)
        }
        return { type: "macro", steps: steps }
    }
    if (kind = "showmenu")
        return { type: "showmenu", payload: payload }
    if (kind = "notify")
        return { type: "notify", payload: payload }
    return { type: kind, payload: payload }
}

; ---- Execute action spec ----
ExecuteAction(layer, action) {
    if (!IsObject(action))
        action := ParseActionSpec(action)
    switch action.type {
        case "send":
            Send(action.payload)
        case "func":
            fn := action.payload
            %fn%()
        case "notify":
            if (StrLower(action.payload) = "copy")
                ShowCopyNotification()
        case "macro":
            for step in action.steps {
                sColon := InStr(step, ":")
                if (!sColon) {
                    continue
                }
                sk := StrLower(Trim(SubStr(step, 1, sColon - 1)))
                sv := Trim(SubStr(step, sColon + 1))
                if (sk = "send")
                    Send(sv)
                else if (sk = "sleep")
                    Sleep(Integer(sv))
                else if (sk = "tooltip") {
                    ShowCenteredToolTip(sv)
                    SetTimer(() => RemoveToolTip(), -1200)
                } else if (sk = "notify") {
                    if (StrLower(sv) = "copy")
                        ShowCopyNotification()
                } else if (sk = "func") {
                    fn := sv
                    %fn%()
                }
            }
        case "showmenu":
            ; delegate to layer-specific menu by name if available
            if (layer = "nvim") {
                if (StrLower(action.payload) = "delete")
                    ShowDeleteMenu()
                else if (StrLower(action.payload) = "yank")
                    ShowYankMenu()
            }
        default:
            ; Unknown: no-op
            return
    }
}

; ---- Generic layer mappings ----
_layerRegisteredHotkeys := {}

LoadSimpleMappings(iniPath, mapSection := "Map", orderKey := "order") {
    if (!FileExist(iniPath))
        return {}
    enable := StrLower(Trim(IniRead(iniPath, "Settings", "enable", "true")))
    if (enable = "false")
        return {}
    order := IniRead(iniPath, mapSection, orderKey, "")
    mappings := {}
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            spec := IniRead(iniPath, mapSection, k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    }
    return mappings
}

ApplyGenericMappings(layerName, mappings, contextFn, keyPrefix := "") {
    global _layerRegisteredHotkeys
    UnregisterGenericMappings(layerName)
    if (!IsSet(mappings) || mappings.Count = 0)
        return
    ; disable static per-layer if applicable
    if (layerName = "modifier") {
        global modifierStaticEnabled
        modifierStaticEnabled := false
    } else if (layerName = "excel") {
        global excelStaticEnabled
        excelStaticEnabled := false
    } else if (layerName = "nvim") {
        global nvimStaticEnabled
        try nvimStaticEnabled := false
    }
    HotIf(contextFn)
    for key, action in mappings.OwnProps() {
        hk := (keyPrefix = "") ? key : (keyPrefix . key)
        Hotkey(hk, (*) => ExecuteAction(layerName, action), "On")
        if (!_layerRegisteredHotkeys.Has(layerName))
            _layerRegisteredHotkeys[layerName] := []
        _layerRegisteredHotkeys[layerName].Push(hk)
    }
    HotIf()
}

UnregisterGenericMappings(layerName) {
    global _layerRegisteredHotkeys
    if (_layerRegisteredHotkeys.Has(layerName)) {
        for _, hk in _layerRegisteredHotkeys[layerName] {
            try Hotkey(hk, , "Off")
        }
        _layerRegisteredHotkeys.Delete(layerName)
    }
    ; re-enable static per-layer if applicable
    if (layerName = "modifier") {
        global modifierStaticEnabled
        modifierStaticEnabled := true
    } else if (layerName = "excel") {
        global excelStaticEnabled
        excelStaticEnabled := true
    } else if (layerName = "nvim") {
        global nvimStaticEnabled
        try nvimStaticEnabled := true
    }
}

; ---- Excel mappings ----
_excelRegisteredHotkeys := []

LoadExcelMappings(iniPath) {
    if (!FileExist(iniPath))
        return {}
    enable := StrLower(Trim(IniRead(iniPath, "Settings", "enable", "true")))
    if (enable = "false")
        return {}
    order := IniRead(iniPath, "Map", "order", "")
    mappings := {}
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            spec := IniRead(iniPath, "Map", k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    } else {
        ; fallback: try to read all known keys
        for k in ["7","8","9","u","i","o","j","k","l","m",",",".","p",";","/","w","a","s","d","[","]","Enter","Space","f","r"] {
            spec := IniRead(iniPath, "Map", k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    }
    return mappings
}

; register dynamic Excel hotkeys with context
ApplyExcelMappings(mappings) {
    global _excelRegisteredHotkeys
    ; unregister previous
    UnregisterExcelMappings()
    if (mappings.Count = 0)
        return
    ; disable static
    global excelStaticEnabled
    excelStaticEnabled := false
    ; context: excelLayerActive and CapsLock not physically pressed
    HotIf((*) => (excelLayerActive && !GetKeyState("CapsLock", "P")))
    for key, action in mappings.OwnProps() {
        hk := key
        Hotkey(hk, (*) => ExecuteAction("excel", action), "On")
        _excelRegisteredHotkeys.Push(hk)
    }
    HotIf()
}

UnregisterExcelMappings() {
    global _excelRegisteredHotkeys, excelStaticEnabled
    for _, hk in _excelRegisteredHotkeys {
        try Hotkey(hk, , "Off")
    }
    _excelRegisteredHotkeys := []
    ; re-enable static
    excelStaticEnabled := true
}
