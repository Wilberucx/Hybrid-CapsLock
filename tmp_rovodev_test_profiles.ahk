; Test script para verificar el sistema de perfiles de aplicación
; Este script temporal prueba las nuevas funciones

; Incluir las funciones del script principal (simuladas para testing)
ConfigIni := A_ScriptDir . "\config\configuration.ini"
ProgramsIni := A_ScriptDir . "\config\programs.ini"

; Simular algunas funciones básicas para el test
ReadConfigValue(section, key, defaultValue := "") {
    global ConfigIni
    IniRead, value, %ConfigIni%, %section%, %key%
    if (value = "ERROR" || value = "") {
        return defaultValue
    }
    return value
}

; Copiar las funciones nuevas aquí para testing
GetActiveApplicationName() {
    WinGet, processName, ProcessName, A
    if (processName = "") {
        return ""
    }
    
    global ProgramsIni
    IniRead, sections, %ProgramsIni%, Programs
    if (sections != "ERROR") {
        Loop, Parse, sections, `n
        {
            if (A_LoopField = "") continue
            IniRead, executablePath, %ProgramsIni%, Programs, %A_LoopField%
            if (executablePath != "ERROR") {
                SplitPath, executablePath, executableName
                executableName := StrReplace(executableName, """", "")
                if (executableName = processName) {
                    return A_LoopField
                }
            }
        }
    }
    
    return processName
}

ReadApplicationProfile(appName, settingName, defaultValue := "") {
    global ConfigIni
    
    IniRead, profileSettings, %ConfigIni%, ApplicationProfiles, %appName%
    if (profileSettings = "ERROR" || profileSettings = "") {
        return defaultValue
    }
    
    Loop, Parse, profileSettings, `,
    {
        if (A_LoopField = "") continue
        
        StringSplit, settingParts, A_LoopField, =
        if (settingParts0 >= 2) {
            currentSettingName := Trim(settingParts1)
            currentSettingValue := Trim(settingParts2)
            
            if (currentSettingName = settingName) {
                return currentSettingValue
            }
        }
    }
    
    return defaultValue
}

GetApplicationSpecificSetting(settingType, settingName, defaultValue := "") {
    activeApp := GetActiveApplicationName()
    if (activeApp != "") {
        appValue := ReadApplicationProfile(activeApp, settingName, "")
        if (appValue != "") {
            return appValue
        }
    }
    
    if (settingType = "layer") {
        return ReadConfigValue("Layers", settingName, defaultValue)
    } else if (settingType = "behavior") {
        return ReadConfigValue("Behavior", settingName, defaultValue)
    } else if (settingType = "ui") {
        return ReadConfigValue("UI", settingName, defaultValue)
    } else {
        return ReadConfigValue("General", settingName, defaultValue)
    }
}

; Función de test
TestApplicationProfiles() {
    ; Obtener aplicación activa
    activeApp := GetActiveApplicationName()
    
    ; Probar diferentes configuraciones
    nvimEnabled := GetApplicationSpecificSetting("layer", "nvim_layer_enabled", "true")
    globalTimeout := GetApplicationSpecificSetting("behavior", "global_timeout_seconds", "7")
    tooltipDuration := GetApplicationSpecificSetting("ui", "tooltip_duration_default", "1500")
    
    ; Mostrar resultados
    result := "=== APPLICATION PROFILES TEST ===`n"
    result .= "Active App: " . activeApp . "`n"
    result .= "Nvim Layer: " . nvimEnabled . "`n"
    result .= "Global Timeout: " . globalTimeout . "`n"
    result .= "Tooltip Duration: " . tooltipDuration . "`n"
    result .= "`nPress Ctrl+Shift+T to test again"
    
    MsgBox, 0, Application Profiles Test, %result%
}

; Hotkey para ejecutar el test
^+t::TestApplicationProfiles()

; Mostrar mensaje de inicio
MsgBox, 0, Test Ready, Application Profiles Test loaded!`n`nPress Ctrl+Shift+T to test`n`nSwitch to different applications and test again to see profile changes.