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
    global leaderActive
    leaderActive := true

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
            LeaderWindowsMenuLoop()
            continue
        } else if (key = "p" || key = "P") {
            LeaderProgramsMenuLoop()
            continue
        } else if (key = "t" || key = "T") {
            ; Minimal timestamps handler: show main time menu and route to sub-mode
            ShowTimeMenu()
            ihTs := InputHook("L1 T" . GetEffectiveTimeout("timestamps"), "{Escape}{Backspace}")
            ihTs.Start()
            ihTs.Wait()
            if (ihTs.EndReason = "EndKey") {
                ihTs.Stop()
                continue
            }
            tsKey := ihTs.Input
            ihTs.Stop()
            if (tsKey = "" || tsKey = Chr(0))
                continue
            HandleTimestampMode(tsKey)
            continue
        } else if (key = "i" || key = "I") {
            ; Minimal information handler: show info menu and insert/preview by key
            ShowInformationMenu()
            ihInfo := InputHook("L1 T" . GetEffectiveTimeout("information"), "{Escape}{Backspace}")
            ihInfo.Start()
            ihInfo.Wait()
            if (ihInfo.EndReason = "EndKey") {
                ihInfo.Stop()
                continue
            }
            infoKey := ihInfo.Input
            ihInfo.Stop()
            if (infoKey = "" || infoKey = Chr(0))
                continue
            InsertInformationFromKey(infoKey)
            continue
        } else if (key = "n" || key = "N") {
            ; Toggle Excel layer on/off
            global excelLayerEnabled, excelLayerActive
            if (!excelLayerEnabled) {
                ShowCenteredToolTip("EXCEL LAYER DISABLED")
                SetTimer(() => RemoveToolTip(), -1000)
                continue
            }
            excelLayerActive := !excelLayerActive
            ShowExcelLayerStatus(excelLayerActive)
            SetTempStatus(excelLayerActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF", 1500)
            continue
        } else if (key = "c" || key = "C") {
            ; Commands main menu
            ShowCommandsMenu()
            ihCmd := InputHook("L1 T" . GetEffectiveTimeout("commands"), "{Escape}{Backspace}")
            ihCmd.Start()
            ihCmd.Wait()
            if (ihCmd.EndReason = "EndKey") {
                if (ihCmd.EndKey = "Escape" || ihCmd.EndKey = "Backspace") {
                    HideAllTooltips()
                    ihCmd.Stop()
                    leaderActive := false
                    return
                }
            }
            catKey := ihCmd.Input
            ihCmd.Stop()
            if (catKey = "" || catKey = Chr(0))
                continue
            HandleCommandCategory(catKey)
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
                ih.Stop()
                return
            }
            if (ih.EndKey = "Backspace") {
                ih.Stop()
                return
            }
        }
        key := ih.Input
        ih.Stop()
        if (key = "" || key = Chr(0))
            return
        ExecuteWindowAction(key)
        HideAllTooltips()
        return
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
                ih.Stop()
                return
            }
            if (ih.EndKey = "Backspace") {
                ih.Stop()
                return
            }
        }
        key := ih.Input
        ih.Stop()
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
