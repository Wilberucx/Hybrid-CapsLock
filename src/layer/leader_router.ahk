; ==============================
; Leader Router (leader -> w, p)
; ==============================
; Activates leader and routes to Windows/Programs submenus.
; Hotkey: CapsLock & Space
;
; Depends on: core/config (GetEffectiveTimeout), ui (tooltips),
; windows_layer (ShowWindowMenu, ExecuteWindowAction)

#HotIf (leaderLayerEnabled)
CapsLock & Space:: {
    ; Mark CapsLock as used as modifier so CapsLock tap does not toggle NVIM
    MarkCapsLockAsModifier()
    TryActivateLeader()
}
#HotIf

TryActivateLeader() {
    global leaderActive, isNvimLayerActive
    leaderActive := true
    ; If NVIM layer is active, deactivate it before showing Leader to avoid keymap conflicts
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        try ShowNvimLayerToggleCS(false)
        try ShowNvimLayerStatus(false)
    }

    Loop {
        ShowLeaderMenu()
        if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.handleInput) {
            ; Let tooltip hotkeys handle input; wait for timeout/escape only
            ih := InputHook("T" . GetEffectiveTimeout("leader"), "{Escape}")
            ih.Start()
            ih.Wait()
            if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
                HideAllTooltips()
                ih.Stop()
                leaderActive := false
                return
            }
            ; If timeout without selection, fall through to default continue
            ih.Stop()
            continue
        }
        ih := InputHook("L1 T" . GetEffectiveTimeout("leader"), "{Escape}")
        ih.Start()
        ih.Wait()
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            HideAllTooltips()
            ih.Stop()
            leaderActive := false
            return
        }
        key := ih.Input
        ih.Stop()
        if (key = "" || key = Chr(0)) {
            leaderActive := false
            return
        }
        if (key = "w" || key = "W") {
            res := LeaderWindowsMenuLoop()
            if (res = "BACK")
                continue
            leaderActive := false
            return
        } else if (key = "p" || key = "P") {
            res := LeaderProgramsMenuLoop()
            if (res = "BACK")
                continue
            leaderActive := false
            return
        } else if (key = "t" || key = "T") {
            ; Timestamps menu with proper Back/Esc handling
            ShowTimeMenu()
            ihTs := InputHook("L1 T" . GetEffectiveTimeout("timestamps"), "{Escape}{Backspace}")
            ihTs.Start()
            ihTs.Wait()
            if (ihTs.EndReason = "EndKey") {
                if (ihTs.EndKey = "Escape") {
                    HideAllTooltips()
                    ihTs.Stop()
                    leaderActive := false
                    return
                }
                if (ihTs.EndKey = "Backspace") {
                    ihTs.Stop()
                    ; Back to Leader menu
                    continue
                }
            }
            tsKey := ihTs.Input
            ihTs.Stop()
            if (tsKey = "\\")
                continue
            if (tsKey = "" || tsKey = Chr(0))
                continue
            HandleTimestampMode(tsKey)
            HideAllTooltips()
            leaderActive := false
            return
        } else if (key = "i" || key = "I") {
            ; Information menu with proper Back/Esc handling
            ShowInformationMenu()
            ihInfo := InputHook("L1 T" . GetEffectiveTimeout("information"), "{Escape}{Backspace}")
            ihInfo.Start()
            ihInfo.Wait()
            if (ihInfo.EndReason = "EndKey") {
                if (ihInfo.EndKey = "Escape") {
                    HideAllTooltips()
                    ihInfo.Stop()
                    leaderActive := false
                    return
                }
                if (ihInfo.EndKey = "Backspace") {
                    ihInfo.Stop()
                    ; Back to Leader menu
                    continue
                }
            }
            infoKey := ihInfo.Input
            ihInfo.Stop()
            if (infoKey = "\\")
                continue
            if (infoKey = "" || infoKey = Chr(0))
                continue
            InsertInformationFromKey(infoKey)
            HideAllTooltips()
            leaderActive := false
            return
        } else if (key = "s" || key = "S") {
            global scrollLayerEnabled, scrollLayerActive
            if (!IsSet(scrollLayerEnabled))
                scrollLayerEnabled := true
            if (!IsSet(scrollLayerActive))
                scrollLayerActive := false
            scrollLayerActive := !scrollLayerActive
            try HideAllTooltips()
            try HideCSharpTooltip()
            Sleep 30
            ShowScrollLayerStatus(scrollLayerActive)
            SetTempStatus(scrollLayerActive ? "SCROLL LAYER ON" : "SCROLL LAYER OFF", 1500)
            ; Exit Leader to avoid re-showing its menu on next iteration
            leaderActive := false
            return
        } else if (key = "n" || key = "N") {
            ; Toggle Excel layer on/off
            global excelLayerEnabled, excelLayerActive
            if (!excelLayerEnabled) {
                ShowCenteredToolTip("EXCEL LAYER DISABLED")
                SetTimer(() => RemoveToolTip(), -1000)
                continue
            }
            excelLayerActive := !excelLayerActive
            ; Hide Leader tooltip to avoid overlap before showing Excel status
            try HideAllTooltips()
            try HideCSharpTooltip()
            Sleep 30
            ShowExcelLayerStatus(excelLayerActive)
            SetTempStatus(excelLayerActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF", 1500)
            ; Exit Leader to avoid re-showing its menu on next loop iteration
            leaderActive := false
            return
        } else if (key = "c" || key = "C") {
            res := LeaderCommandsMenuLoop()
            if (res = "EXIT") {
                HideAllTooltips()
                leaderActive := false
                return
            }
            ; BACK or finished -> return to Leader loop
            continue
        } else {
            ShowCenteredToolTip("Unknown: " . key)
            SetTimer(() => RemoveToolTip(), -800)
            continue
        }
    }
}

ShowLeaderMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowLeaderModeMenuCS()
    } else {
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "LEADER MENU`n`n"
        menuText .= "w - Windows`n"
        menuText .= "p - Programs`n"
        menuText .= "c - Commands`n"
        menuText .= "t - Timestamps`n"
        menuText .= "i - Information`n"
        menuText .= "n - Excel/Numbers`n"
        menuText .= "`n[Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

LeaderWindowsMenuLoop() {
    global isNvimLayerActive
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        ShowNvimLayerStatus(false)
        SetTimer(() => RemoveToolTip(), -800)
    }

    Loop {
        ShowWindowMenu()
        ih := InputHook("L1 T" . GetEffectiveTimeout("windows"), "{Escape}{Backspace}")
        ih.Start()
        ih.Wait()
        if (ih.EndReason = "EndKey") {
            if (ih.EndKey = "Escape") {
                HideAllTooltips()
                ih.Stop()
                return "EXIT"
            }
            if (ih.EndKey = "Backspace") {
                ih.Stop()
                return "BACK"
            }
        }
        key := ih.Input
        ih.Stop()
        if (key = "\\")
            return "BACK"
        if (key = "" || key = Chr(0))
            return
        ExecuteWindowAction(key)
        HideAllTooltips()
        return
    }
}

LeaderCommandsMenuLoop() {
    ; Loop that keeps user inside Commands main and subcategories
    Loop {
        ShowCommandsMenu()
        ihCmd := InputHook("L1 T" . GetEffectiveTimeout("commands"), "{Escape}{Backspace}")
        ihCmd.Start()
        ihCmd.Wait()
        if (ihCmd.EndReason = "EndKey") {
            if (ihCmd.EndKey = "Escape") {
                ihCmd.Stop()
                return "EXIT"
            }
            if (ihCmd.EndKey = "Backspace") {
                ihCmd.Stop()
                return "BACK"
            }
        }
        catKey := ihCmd.Input
        ihCmd.Stop()
        if (catKey = "\\")
            return "BACK"
        if (catKey = "" || catKey = Chr(0))
            return "BACK"
        res := HandleCommandCategory(catKey)
        if (res = "EXIT")
            return "EXIT"
        if (res = "BACK")
            continue
        ; After executing a command or closing submenu, leave Commands entirely
        return "EXIT"
    }
}

LeaderProgramsMenuLoop() {
    global ProgramsIni
    Loop {
        ShowProgramMenu()
        ih := InputHook("L1 T" . GetEffectiveTimeout("programs"), "{Escape}{Backspace}")
        ih.Start()
        ih.Wait()
        if (ih.EndReason = "EndKey") {
            if (ih.EndKey = "Escape") {
                HideAllTooltips()
                ih.Stop()
                return "EXIT"
            }
            if (ih.EndKey = "Backspace") {
                ih.Stop()
                return "BACK"
            }
        }
        key := ih.Input
        ih.Stop()
        if (key = "\\")
            return "BACK"
        if (key = "" || key = Chr(0))
            return
        autoLaunch := CleanIniBool(IniRead(ProgramsIni, "Settings", "auto_launch", "true"), true)
        if (!autoLaunch) {
            ShowProgramDetails(key)
            return
        }
        LaunchProgramFromKey(key)
        HideAllTooltips()
        return
    }
}
