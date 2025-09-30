; ==============================
; Leader Router (leader -> w, p)
; ==============================
; Activates leader and routes to Windows/Programs submenus.
; Hotkey: CapsLock & Space
;
; Depends on: core/config (GetEffectiveTimeout), ui (tooltips),
; windows_layer (ShowWindowMenu, ExecuteWindowAction)

CapsLock & Space:: {
    TryActivateLeader()
}

TryActivateLeader() {
    global leaderActive
    leaderActive := true

    Loop {
        ShowLeaderMenu()
        ih := InputHook("L1 T" . GetEffectiveTimeout("leader"), "{Escape}")
        ih.Start()
        ih.Wait()
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
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
        return
    }
}

LeaderProgramsMenuLoop() {
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
        return
    }
}
