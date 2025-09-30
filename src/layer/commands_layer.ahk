; ==============================
; Commands Layer (main menu only - step 1)
; ==============================
; Builds and shows the Commands main menu. Category handling will be added in step 2.
; Depends on: globals (CommandsIni), ui (tooltips), core/config (GetEffectiveTimeout)

BuildCommandsMainMenuText() {
    global CommandsIni
    text := ""
    order := IniRead(CommandsIni, "Categories", "order", "")
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            name := IniRead(CommandsIni, k . "_category", "title", "")
            if (name = "" || name = "ERROR")
                name := IniRead(CommandsIni, "Categories", k, "")
            if (name != "" && name != "ERROR")
                text .= k . " - " . name . "`n"
        }
    }
    return text
}

ShowCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "COMMAND PALETTE`n`n"
        configText := BuildCommandsMainMenuText()
        if (configText != "") {
            menuText .= configText
        } else {
            hasConfigMenu := false
            Loop 20 {
                lineContent := IniRead(CommandsIni, "MenuDisplay", "main_line" . A_Index, "")
                if (lineContent != "" && lineContent != "ERROR") {
                    menuText .= lineContent . "`n"
                    hasConfigMenu := true
                }
            }
            if (!hasConfigMenu) {
                menuText .= "s - System Commands`n"
                menuText .= "n - Network Commands`n"
                menuText .= "g - Git Commands`n"
                menuText .= "m - Monitoring Commands`n"
                menuText .= "f - Folder Commands`n"
                menuText .= "w - Windows Commands`n"
                menuText .= "o - Power Options`n"
                menuText .= "a - ADB Tools`n"
                menuText .= "v - VaultFlow`n"
                menuText .= "h - Hybrid Management`n"
            }
        }
        menuText .= "`n[\\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ---- Dynamic category menu (new schema) ----
ShowDynamicCommandsMenu(catKey) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ; In C# mode, category menus are handled by *_CS functions
        return
    }
    global CommandsIni
    sec := catKey . "_category"
    title := IniRead(CommandsIni, sec, "title", "COMMANDS")
    order := IniRead(CommandsIni, sec, "order", "")
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 100
    menuText := title . "`n`n"
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            itemTitle := IniRead(CommandsIni, sec, k, "")
            if (itemTitle != "" && itemTitle != "ERROR")
                menuText .= k . " - " . itemTitle . "`n"
        }
    }
    menuText .= "`n[\\: Back] [Esc: Exit]"
    ToolTip(menuText, ToolTipX, ToolTipY, 2)
}

; ---- Category submenus (step 2: System + Network) ----
ShowSystemCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowSystemCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "SYSTEM COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "system_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowNetworkCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowNetworkCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 70
        menuText := "NETWORK COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "network_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowGitCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowGitCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "GIT COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "git_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowMonitoringCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMonitoringCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "MONITORING COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "monitoring_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ---- Executors ----
ShowCommandExecuted(category, command) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCommandExecutedCS(category, command)
    } else {
        ShowCenteredToolTip(category . " command executed: " . command)
        SetTimer(() => RemoveToolTip(), -2000)
    }
}

ExecuteSystemCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "s": Run("cmd.exe /k systeminfo")
        case "t": Run("taskmgr.exe")
        case "v": Run("services.msc")
        case "e": Run("eventvwr.msc")
        case "d": Run("devmgmt.msc")
        case "c": Run("cleanmgr.exe")
        default:
            ShowCenteredToolTip("Unknown system command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("System", cmd)
}

ExecuteNetworkCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "i": Run("cmd.exe /k ipconfig /all")
        case "p": Run("cmd.exe /k ping google.com")
        case "n": Run("cmd.exe /k netstat -an")
        default:
            ShowCenteredToolTip("Unknown network command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Network", cmd)
}

; ---- Dynamic category dispatcher (new schema) ----
HandleCommandCategory(catKey) {
    k := StrLower(Trim(catKey))
    ; Show dynamic category menu for native tooltips
    if (!(IsSet(tooltipConfig) && tooltipConfig.enabled)) {
        ShowDynamicCommandsMenu(k)
    }
    ih := InputHook("L1 T" . GetEffectiveTimeout("commands"), "{Escape}{Backspace}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey") {
        HideMenuTooltip()
        ih.Stop()
        return
    }
    key := ih.Input
    ih.Stop()
    if (key = "" || key = Chr(0))
        return

    categoryInternal := SymToInternal(k)
    if (categoryInternal = "") {
        HideMenuTooltip()
        ShowCenteredToolTip("Unknown category: '" . k . "'")
        SetTimer(() => RemoveToolTip(), -1200)
        return
    }

    ; First try dynamic action resolution based on new schema
    if (ResolveAndExecuteCustomAction(categoryInternal, key))
        return

    ; Fallback to hardcoded executors for migrated categories
    switch categoryInternal {
        case "system":
            ExecuteSystemCommand(key)
        case "network":
            ExecuteNetworkCommand(key)
        case "git":
            ExecuteGitCommand(key)
        case "monitoring":
            ExecuteMonitoringCommand(key)
        default:
            HideMenuTooltip()
            ShowCenteredToolTip("Category '" . categoryInternal . "' not implemented yet")
            SetTimer(() => RemoveToolTip(), -1200)
    }
}

ExecuteGitCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "s": Run("cmd.exe /k git status")
        case "l": Run("cmd.exe /k git log --oneline -10")
        case "b": Run("cmd.exe /k git branch -a")
        case "d": Run("cmd.exe /k git diff")
        case "a": Run("cmd.exe /k git add .")
        case "p": Run("cmd.exe /k git pull")
        default:
            ShowCenteredToolTip("Unknown git command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Git", cmd)
}

ExecuteMonitoringCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "p":
            Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "s":
            Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "d":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "m":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "c":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        default:
            ShowCenteredToolTip("Unknown monitoring command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Monitoring", cmd)
}

; ---- Helpers for dynamic commands (new schema) ----
SymToInternal(catSym) {
    switch catSym {
        case "s": return "system"
        case "n": return "network"
        case "g": return "git"
        case "m": return "monitoring"
        case "f": return "folder"
        case "w": return "windows"
        case "o": return "power"
        case "a": return "adb"
        case "h": return "hybrid"
        case "v": return "vaultflow"
        default: return ""
    }
}

ResolveAndExecuteCustomAction(categoryInternal, key) {
    global CommandsIni
    catSym := GetCategoryKeySymbol(categoryInternal)
    if (catSym = "")
        return false
    sec := catSym . "_category"
    action := IniRead(CommandsIni, sec, key . "_action", "")
    if (action = "" || action = "ERROR")
        return false

    ; Friendly label for confirmation/select feedback
    label := IniRead(CommandsIni, sec, key, key)

    ; Confirm according to rules
    if (ShouldConfirmCommand(categoryInternal, key)) {
        if (!ConfirmYN("Execute " . label . "?", "commands"))
            return true ; handled (cancelled)
    }

    ; Support indirection via @Name in [CustomCommands]
    name := ""
    cmdSpec := action
    if (SubStr(action, 1, 1) = "@") {
        name := SubStr(action, 2)
        cmdSpec := IniRead(CommandsIni, "CustomCommands", name, "")
        if (cmdSpec = "" || cmdSpec = "ERROR") {
            ShowCenteredToolTip("Custom command '@" . name . "' not found")
            SetTimer(() => RemoveToolTip(), -2000)
            return true
        }
    }

    colonPos := InStr(cmdSpec, ":")
    if (!colonPos) {
        ShowCenteredToolTip("Invalid command spec: " . cmdSpec)
        SetTimer(() => RemoveToolTip(), -2000)
        return true
    }

    cmdType := StrLower(Trim(SubStr(cmdSpec, 1, colonPos - 1)))
    payload := Trim(SubStr(cmdSpec, colonPos + 1))

    flags := (name != "") ? LoadCommandFlags(name) : {}
    payload := ExpandPlaceholders(payload)
    for k2, v2 in flags {
        flags[k2] := ExpandPlaceholders(v2)
    }

    ExecuteCustomCommand(cmdType, payload, flags)
    return true
}

LoadCommandFlags(name) {
    global CommandsIni
    flags := {}
    if (name = "")
        return flags
    sec := "CommandFlag." . name
    keys := ["terminal","keep_open","admin","working_dir","env","timeout","wt_shell"]
    for _, k in keys {
        v := IniRead(CommandsIni, sec, k, "")
        if (v != "" && v != "ERROR")
            flags[k] := Trim(v)
    }
    return flags
}

ExpandPlaceholders(text) {
    if (text = "")
        return text
    ; Predefined placeholders
    text := StrReplace(text, "{ScriptDir}", A_ScriptDir)
    text := StrReplace(text, "{UserProfile}", EnvGet("USERPROFILE"))
    text := StrReplace(text, "{Home}", EnvGet("USERPROFILE"))
    text := StrReplace(text, "{Clipboard}", A_Clipboard)
    ; CustomVars from commands.ini
    global CommandsIni
    while RegExMatch(text, "\{([A-Za-z0-9_]+)\}", &m) {
        varName := m[1]
        varVal := IniRead(CommandsIni, "CustomVars", varName, "")
        if (varVal = "" || varVal = "ERROR")
            break
        text := StrReplace(text, "{" . varName . "}", varVal)
    }
    ; Expand %ENV% variables
    while RegExMatch(text, "%([A-Za-z0-9_]+)%", &e) {
        ev := e[1]
        evv := EnvGet(ev)
        text := StrReplace(text, "%" . ev . "%", (evv != "") ? evv : "")
    }
    return text
}

ParseEnvList(envStr) {
    envMap := []
    if (envStr = "")
        return envMap
    for pair in StrSplit(envStr, [";", "`n", "`r"]) {
        pair := Trim(pair)
        if (pair = "")
            continue
        eq := InStr(pair, "=")
        if (!eq)
            continue
        k := Trim(SubStr(pair, 1, eq - 1))
        v := Trim(SubStr(pair, eq + 1))
        envMap.Push([k, v])
    }
    return envMap
}

ExecuteCustomCommand(cmdType, payload, flags) {
    opts := ""
    if (flags.HasOwnProp("working_dir"))
        opts := flags["working_dir"]
    runOpts := (flags.HasOwnProp("terminal") && StrLower(flags["terminal"]) = "hidden") ? "Hide" : ""
    admin := (flags.HasOwnProp("admin") && (StrLower(flags["admin"]) = "true"))

    try {
        switch cmdType {
            case "url":
                Run(payload)
            case "cmd":
                envPrefix := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envPrefix .= "set " . kv[1] . "=" . kv[2] . "&& "
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "false") = "true")
                args := (keepOpen ? "/k " : "/c ") . Chr(34) . envPrefix . payload . Chr(34)
                exe := "cmd.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "ps":
                envScript := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envScript := envScript . "$env:" . kv[1] . "='" . kv[2] . "';"
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "false") = "true")
                psCmd := envScript . payload
                args := (keepOpen ? "-NoExit " : "") . "-NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . psCmd . Chr(34)
                exe := "powershell.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "pwsh":
                envScript := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envScript := envScript . "$env:" . kv[1] . "='" . kv[2] . "';"
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "true") = "true")
                psCmd := envScript . payload
                args := (keepOpen ? "-NoExit " : "") . "-NoProfile -Command " . Chr(34) . psCmd . Chr(34)
                exe := "pwsh.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "wsl":
                exe := "wsl.exe " . payload
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "wt":
                wtShell := StrLower(flags.HasOwnProp("wt_shell") ? flags["wt_shell"] : "cmd")
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "true") = "true")
                if (wtShell = "cmd") {
                    inner := (keepOpen ? "/k " : "/c ") . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab cmd " . inner
                } else if (wtShell = "ps") {
                    inner := (keepOpen ? "-NoExit " : "") . "-NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab powershell " . inner
                } else {
                    inner := (keepOpen ? "-NoExit " : "") . "-NoProfile -Command " . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab pwsh " . inner
                }
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            default:
                ShowCenteredToolTip("Unknown cmd type: " . cmdType)
        }
    } catch as err {
        ShowCenteredToolTip("Command failed: " . err.Message)
        SetTimer(() => RemoveToolTip(), -2000)
    }
}
