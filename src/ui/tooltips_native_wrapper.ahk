; ==============================
; UI native wrapper and status helpers
; ==============================
; Provides fallback UI when C# tooltips are disabled or unavailable.
; Exposes unified functions used by core/confirmations and layers.

; Basic tooltip centered on screen
ShowCenteredToolTip(Text) {
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip(Text, ToolTipX, ToolTipY)
}

; Remove any active tooltip
RemoveToolTip() {
    ToolTip()
}

; Temporary status setter (shared with UI status)
SetTempStatus(status, duration) {
    global currentTempStatus, tempStatusExpiry
    currentTempStatus := status
    tempStatusExpiry := A_TickCount + duration
}

; Status helpers using either C# or native fallback
ShowCopyNotification() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCopyNotificationCS()
    } else {
        ShowCenteredToolTip("COPIED")
        SetTimer(() => RemoveToolTip(), -800)
    }
}

ShowLeftClickStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("MOUSE", isActive ? "LEFT CLICK HELD" : "LEFT CLICK RELEASED")
    } else {
        ShowCenteredToolTip(isActive ? "LEFT CLICK HELD" : "LEFT CLICK RELEASED")
    }
}

ShowRightClickStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("MOUSE", "RIGHT CLICK")
    } else {
        ShowCenteredToolTip("RIGHT CLICK")
    }
}

ShowCapsLockStatus(isNormal) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("CAPSLOCK", isNormal ? "NORMAL MODE" : "HYBRID MODE")
    } else {
        ShowCenteredToolTip(isNormal ? "CAPSLOCK NORMAL MODE" : "CAPSLOCK HYBRID MODE")
    }
}

ShowProcessTerminated() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowProcessTerminatedCS()
    } else {
        ShowCenteredToolTip("PROCESS TERMINATED")
    }
}

ShowNvimLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowNvimLayerStatusCS(isActive)
    } else {
        ShowCenteredToolTip(isActive ? "NVIM LAYER ON" : "NVIM LAYER OFF")
    }
}

ShowVisualModeStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        if (isActive) {
            ShowVisualStatus()
        } else {
            HideVisualStatus()
        }
    } else {
        ShowCenteredToolTip(isActive ? "VISUAL MODE ON" : "VISUAL MODE OFF")
    }
}

ShowDeleteMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowDeleteMenuCS()
    } else {
        ShowCenteredToolTip("DELETE: w=word, d=line, a=all")
    }
}

ShowYankMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowYankMenuCS()
    } else {
        ShowCenteredToolTip("YANK: y=line, w=word, a=all, p=paragraph")
    }
}
