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

; ---- Category dispatcher (step 2: s + n) ----
HandleCommandCategory(catKey) {
    ; Normalize to lower
    k := StrLower(catKey)
    if (k = "s") {
        Loop {
            ShowSystemCommandsMenu()
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
            ExecuteSystemCommand(key)
            return
        }
    } else if (k = "n") {
        Loop {
            ShowNetworkCommandsMenu()
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
            ExecuteNetworkCommand(key)
            return
        }
    } else {
        HideMenuTooltip()
        ShowCenteredToolTip("Commands: '" . catKey . "' selected (not implemented yet)")
        SetTimer(() => RemoveToolTip(), -1200)
    }
}
