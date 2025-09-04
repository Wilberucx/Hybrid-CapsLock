; ==============================================================================
; OBSIDIAN INTEGRATION - SIMPLE VERSION
; ==============================================================================
; This is a simplified version to avoid conflicts
; Include this file in HybridCapsLock.ahk instead of the complex version

; Note: Global variables are declared in main HybridCapsLock.ahk file
; Ensure ObsidianIni is available in functions that need it

; ==============================================================================
; OBSIDIAN LAYER FUNCTIONS (SIMPLIFIED)
; ==============================================================================

ShowObsidianLayerMenu() {
    global ObsidianIni
    ToolTipX := A_ScreenWidth // 2 - 150
    ToolTipY := A_ScreenHeight // 2 - 100
    MenuText := "🚧 OBSIDIAN LAYER - EN DESARROLLO 🚧`n"
    MenuText .= "⚠️ Esta funcionalidad está siendo depurada ⚠️`n"
    MenuText .= "`n"
    
    ; Read tooltip lines from obsidian.ini
    Loop, 20 {
        IniRead, lineContent, %ObsidianIni%, TooltipDisplay, line%A_Index%
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }
    
    ; If no tooltip lines found, show default message
    if (MenuText = "OBSIDIAN LAYER`n`n") {
        MenuText .= "No commands configured yet`n"
        MenuText .= "Use <leader>+c+h+i to import from hotkeys.json`n"
    }
    
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ExecuteObsidianLayerCommand(key) {
    global ObsidianIni
    ; DEVELOPMENT MODE: Show clear status
    ShowObsidianStatus("🚧 DESARROLLO: Procesando tecla '" . key . "'`n⚠️ Funcionalidad en depuración")
    
    ; Check if Obsidian integration is enabled
    IniRead, enabled, %ObsidianIni%, Settings, enable_obsidian_layer
    if (enabled != "true") {
        ShowObsidianStatus("Obsidian layer disabled")
        return
    }
    
    ; Handle special keys
    if (key = "`") {
        ShowObsidianStatus("Overflow menu not implemented yet")
        return
    }
    
    ; Read the key combination from obsidian.ini
    IniRead, combination, %ObsidianIni%, ObsidianCommands, %key%
    if (combination = "ERROR" || combination = "") {
        ShowObsidianStatus("Key '" . key . "' not configured")
        return
    }
    
    ; Send the combination directly (no app verification needed)
    Send, %combination%
    
    ; Show feedback
    ShowObsidianStatus("Sent: " . key . " → " . combination)
    return
}

ShowObsidianStatus(message) {
    ToolTipX := A_ScreenWidth // 2 - 200
    ToolTipY := A_ScreenHeight // 2 - 50
    ToolTip, OBSIDIAN DEBUG:`n%message%, %ToolTipX%, %ToolTipY%, 1
    SetTimer, RemoveObsidianTooltip, 5000
    return
}

RemoveObsidianTooltip:
    SetTimer, RemoveObsidianTooltip, Off
    ToolTip, , , , 1
return

; ==============================================================================
; HYBRID MANAGEMENT FUNCTIONS (SIMPLIFIED)
; ==============================================================================

ShowHybridManagementMenu() {
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 80
    MenuText := "HYBRID-CAPSLOCK MANAGEMENT`n"
    MenuText .= "🚧 Obsidian Layer: EN DESARROLLO 🚧`n"
    MenuText .= "`n"
    MenuText .= "i - Import Obsidian Hotkeys`n"
    MenuText .= "u - Update Obsidian Hotkeys`n"
    MenuText .= "r - Reload HybridCapsLock`n"
    MenuText .= "f - Open HybridCapsLock Folder`n"
    MenuText .= "s - Show System Status`n"
    MenuText .= "e - Edit Obsidian Config`n"
    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip, %MenuText%, %ToolTipX%, %ToolTipY%, 2
    return
}

ExecuteHybridManagementCommand(cmd) {
    if (cmd = "i") {
        ImportObsidianHotkeys()
    } else if (cmd = "u") {
        UpdateObsidianHotkeys()
    } else if (cmd = "r") {
        ReloadHybridCapsLock()
    } else if (cmd = "f") {
        OpenHybridCapsLockFolder()
    } else if (cmd = "s") {
        ShowHybridSystemStatus()
    } else if (cmd = "e") {
        EditObsidianConfig()
    }
    return
}

ImportObsidianHotkeys() {
    scriptDir := A_ScriptDir
    hotkeyFile := scriptDir . "\hotkeys.json"
    pythonScript := scriptDir . "\obsidian_manager.py"
    
    if (!FileExist(hotkeyFile)) {
        ShowHybridStatus("ERROR: hotkeys.json not found!`nPlace your Obsidian hotkeys.json in:`n" . scriptDir)
        return
    }
    
    if (!FileExist(pythonScript)) {
        ShowHybridStatus("ERROR: obsidian_manager.py not found!")
        return
    }
    
    ShowHybridStatus("Importing Obsidian hotkeys...`nThis may take a moment...")
    
    RunWait, python.exe "%pythonScript%" --import --script-dir "%scriptDir%", %scriptDir%, Hide
    
    if (ErrorLevel = 0) {
        ShowHybridStatus("✅ Import completed successfully!`nObsidian layer is now available.`n`nReloading HybridCapsLock...")
        Sleep, 2000
        ReloadHybridCapsLock()
    } else {
        ShowHybridStatus("❌ Import failed!`nCheck that Python is installed and`nhotkeys.json is valid.")
    }
    return
}

UpdateObsidianHotkeys() {
    scriptDir := A_ScriptDir
    hotkeyFile := scriptDir . "\hotkeys.json"
    pythonScript := scriptDir . "\obsidian_manager.py"
    
    if (!FileExist(hotkeyFile)) {
        ShowHybridStatus("ERROR: hotkeys.json not found!`nPlace your updated Obsidian hotkeys.json in:`n" . scriptDir)
        return
    }
    
    ShowHybridStatus("Updating Obsidian hotkeys...`nPreserving your customizations...")
    
    RunWait, python.exe "%pythonScript%" --update --script-dir "%scriptDir%", %scriptDir%, Hide
    
    if (ErrorLevel = 0) {
        ShowHybridStatus("✅ Update completed successfully!`nCustomizations preserved.`n`nReloading HybridCapsLock...")
        Sleep, 2000
        ReloadHybridCapsLock()
    } else {
        ShowHybridStatus("❌ Update failed!`nCheck that Python is installed and`nhotkeys.json is valid.")
    }
    return
}

ReloadHybridCapsLock() {
    ShowHybridStatus("Reloading HybridCapsLock...")
    Sleep, 1000
    Reload
}

OpenHybridCapsLockFolder() {
    Run, explorer.exe "%A_ScriptDir%"
    ShowHybridStatus("Opened HybridCapsLock folder")
    return
}

ShowHybridSystemStatus() {
    global ObsidianIni
    scriptDir := A_ScriptDir
    obsidianIni := scriptDir . "\config\obsidian.ini"
    hotkeyFile := scriptDir . "\hotkeys.json"
    pythonScript := scriptDir . "\obsidian_manager.py"
    
    statusText := "HYBRID-CAPSLOCK SYSTEM STATUS`n"
    statusText .= "================================`n`n"
    
    statusText .= "📁 Files:`n"
    statusText .= "HybridCapsLock.ahk: ✅ Running`n"
    statusText .= "hotkeys.json: " . (FileExist(hotkeyFile) ? "✅ Found" : "❌ Missing") . "`n"
    statusText .= "obsidian_manager.py: " . (FileExist(pythonScript) ? "✅ Found" : "❌ Missing") . "`n"
    statusText .= "obsidian.ini: " . (FileExist(obsidianIni) ? "✅ Found" : "❌ Missing") . "`n`n"
    
    if (FileExist(obsidianIni)) {
        IniRead, enabled, %obsidianIni%, Settings, enable_obsidian_layer
        IniRead, devMode, %obsidianIni%, Settings, development_mode
        if (devMode = "true") {
            statusText .= "🚧 Obsidian Integration: EN DESARROLLO - NO FUNCIONAL`n"
        } else {
            statusText .= "🎯 Obsidian Integration: " . (enabled = "true" ? "✅ Enabled" : "❌ Disabled") . "`n"
        }
    }
    
    statusText .= "`n📍 Script location:`n" . scriptDir
    
    ShowHybridStatus(statusText)
    return
}

EditObsidianConfig() {
    global ObsidianIni
    obsidianIni := A_ScriptDir . "\config\obsidian.ini"
    
    if (FileExist(obsidianIni)) {
        Run, notepad.exe "%obsidianIni%"
        ShowHybridStatus("Opened obsidian.ini for editing")
    } else {
        ShowHybridStatus("obsidian.ini not found!`nUse Import to create it first.")
    }
    return
}

ShowHybridStatus(message) {
    ToolTipX := A_ScreenWidth // 2 - 150
    ToolTipY := A_ScreenHeight // 2 - 50
    ToolTip, %message%, %ToolTipX%, %ToolTipY%, 1
    SetTimer, RemoveHybridTooltip, 5000
    return
}

RemoveHybridTooltip:
    SetTimer, RemoveHybridTooltip, Off
    ToolTip, , , , 1
return