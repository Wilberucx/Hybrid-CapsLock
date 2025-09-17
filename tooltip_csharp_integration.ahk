; ===================================================================
; INTEGRACIÓN C# TOOLTIP PARA HYBRIDCAPSLOCK v2
; ===================================================================
; Archivo de integración para reemplazar tooltips básicos con C# + WPF
; Incluir este archivo en HybridCapsLock.ahk con: #Include tooltip_csharp_integration.ahk

; ===================================================================
; VARIABLES GLOBALES NECESARIAS
; ===================================================================

; Definir rutas de configuración si no están definidas
if (!IsSet(ConfigIni)) {
    global ConfigIni := A_ScriptDir . "\config\configuration.ini"
}
if (!IsSet(ProgramsIni)) {
    global ProgramsIni := A_ScriptDir . "\config\programs.ini"
}
if (!IsSet(InfoIni)) {
    global InfoIni := A_ScriptDir . "\config\information.ini"
}
if (!IsSet(TimestampsIni)) {
    global TimestampsIni := A_ScriptDir . "\config\timestamps.ini"
}

; Variables globales para configuración de tooltips
global tooltipConfig := ReadTooltipConfig()

; ===================================================================
; FUNCIONES DE CONFIGURACIÓN
; ===================================================================

; Función para leer configuración de tooltips desde configuration.ini
ReadTooltipConfig() {
    global ConfigIni
    
    config := {}
    
    ; Función helper para limpiar valores leídos (remover comentarios)
    CleanIniValue(value) {
        ; Remover comentarios (todo después de ;)
        if (InStr(value, ";")) {
            value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
        }
        return Trim(value)
    }
    
    ; Leer y limpiar valores
    enabledValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "enable_csharp_tooltips", "true"))
    config.enabled := enabledValue = "true"
    
    optionsTimeoutValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "options_menu_timeout", "10000"))
    config.optionsTimeout := Integer(optionsTimeoutValue)
    
    statusTimeoutValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", "2000"))
    config.statusTimeout := Integer(statusTimeoutValue)
    
    autoHideValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "auto_hide_on_action", "true"))
    config.autoHide := autoHideValue = "true"
    
    persistentValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "persistent_menus", "false"))
    config.persistent := persistentValue = "true"
    
    fadeAnimationValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_fade_animation", "true"))
    config.fadeAnimation := fadeAnimationValue = "true"
    
    clickThroughValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_click_through", "true"))
    config.clickThrough := clickThroughValue = "true"
    
    return config
}

; Función para recargar configuración de tooltips
ReloadTooltipConfig() {
    global tooltipConfig
    tooltipConfig := ReadTooltipConfig()
}

; ===================================================================
; FUNCIONES PRINCIPALES DE TOOLTIP C#

; Helper: Build items string from commands.ini [MenuDisplay] using a key prefix
BuildCommandItemsFromIni(prefix, maxLines := 20) {
    global CommandsIni
    items := ""
    Loop maxLines {
        lineContent := IniRead(CommandsIni, "MenuDisplay", prefix . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            cleanLine := RegExReplace(lineContent, "\s{2,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            for _, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    if (StrLen(key) = 1 && RegExMatch(key, "^[A-Za-z0-9]$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    return items
}

; New helpers: build items from new schema ([Categories] / [<key>_category])
BuildCommandsMainItemsFromCategories() {
    global CommandsIni
    items := ""
    order := IniRead(CommandsIni, "Categories", "order", "")
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            title := IniRead(CommandsIni, k . "_category", "title", "")
            if (title = "" || title = "ERROR")
                title := IniRead(CommandsIni, "Categories", k, "")
            if (title != "" && title != "ERROR") {
                if (items != "")
                    items .= "|"
                items .= k . ":" . title
            }
        }
    }
    return items
}

BuildCommandItemsFromCategoryKey(catKey) {
    global CommandsIni
    items := ""
    section := catKey . "_category"
    order := IniRead(CommandsIni, section, "order", "")
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            title := IniRead(CommandsIni, section, k, "")
            if (title != "" && title != "ERROR") {
                if (items != "")
                    items .= "|"
                items .= k . ":" . title
            }
        }
    }
    return items
}

; ===================================================================

; Función principal para mostrar tooltip C# (con timeout personalizado)
ShowCSharpTooltip(title, items, navigation := "", timeout := 0) {
    global tooltipConfig
    
    ; Si no se especifica timeout, usar el de opciones por defecto
    if (timeout = 0) {
        timeout := tooltipConfig.optionsTimeout
    }
    
    ; Si persistent_menus está habilitado, usar timeout muy largo
    if (tooltipConfig.persistent) {
        timeout := 300000  ; 5 minutos (prácticamente infinito)
    }
    ; Construir JSON para items
    itemsJson := ""
    itemArray := StrSplit(items, "|")
    
    for index, item in itemArray {
        if (index > 1)
            itemsJson .= ","
        
        ; Separar key y description (formato: "key:description")
        itemParts := StrSplit(item, ":")
        key := itemParts[1]
        desc := itemParts[2]
        
        itemsJson .= '{"key": "' . key . '", "description": "' . desc . '"}'
    }
    
    ; Construir JSON para navegación
    navJson := ""
    if (navigation != "") {
        navArray := StrSplit(navigation, "|")
        for index, navItem in navArray {
            if (index > 1)
                navJson .= ","
            navJson .= '"' . navItem . '"'
        }
    } else {
        navJson := '"HybridCapsLock Ready"'
    }
    
    ; Construir JSON completo
    jsonData := "{"
    jsonData .= '"tooltip_type": "leader",'
    jsonData .= '"title": "' . title . '",'
    jsonData .= '"items": [' . itemsJson . '],'
    jsonData .= '"navigation": [' . navJson . '],'
    jsonData .= '"timeout_ms": ' . timeout . ','
    jsonData .= '"show": true'
    jsonData .= "}"
    
    ; Escribir archivo JSON (sobrescribir contenido)
    try {
        FileDelete("tooltip_commands.json")
    }
    FileAppend(jsonData, "tooltip_commands.json")
}

; Función para ocultar tooltip C#
HideCSharpTooltip() {
    jsonData := '{"show": false}'
    ; Sobrescribir archivo con show: false
    try {
        FileDelete("tooltip_commands.json")
    }
    FileAppend(jsonData, "tooltip_commands.json")
}

; Función específica para tooltips de OPCIONES/MENÚS (duración larga)
ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    if (timeout = 0) {
        timeout := tooltipConfig.optionsTimeout
    }
    global tooltipConfig
    ShowCSharpTooltip(title, items, navigation, timeout)
}

; Función específica para tooltips de ESTADO/NOTIFICACIONES (duración corta)
ShowCSharpStatusNotification(title, message) {
    global tooltipConfig
    items := "status:" . message
    ShowCSharpTooltip(title, items, "Esc: Close", tooltipConfig.statusTimeout)
}

; Función para iniciar la aplicación C# tooltip
StartTooltipApp() {
    ; Verificar si ya está ejecutándose
    if (!ProcessExist("TooltipApp.exe")) {
        ; Intentar ejecutar desde diferentes ubicaciones
        tooltipPaths := [
            "tooltip_csharp\\bin\\Debug\\net6.0-windows\\TooltipApp.exe",
            "tooltip_csharp\\bin\\Release\\net6.0-windows\\win-x64\\publish\\TooltipApp.exe",
            "tooltip_csharp\\bin\\Release\\net6.0-windows\\TooltipApp.exe"
        ]
        
        for index, path in tooltipPaths {
            if (FileExist(path)) {
                try {
                    Run('"' . path . '"', , "Hide")
                    Sleep(500)
                    break
                }
            }
        }
    }
    return true
}

; Función separada para iniciar todas las aplicaciones de estado
StartStatusApp() {
    statusScripts := [
        "tooltip_csharp\\StatusWindow_Nvim.ps1",
        "tooltip_csharp\\StatusWindow_Visual.ps1", 
        "tooltip_csharp\\StatusWindow_Yank.ps1",
        "tooltip_csharp\\StatusWindow_Excel.ps1"
    ]
    
    allStarted := true
    for index, script in statusScripts {
        if (FileExist(script)) {
            try {
                Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' . script . '"', , "Hide")
                Sleep(200)  ; Pequeño delay entre cada inicio
            } catch {
                allStarted := false
            }
        } else {
            MsgBox("No se encontró " . script, "Error", "IconX")
            allStarted := false
        }
    }
    
    if (allStarted) {
        Sleep(500)  ; Tiempo adicional para que todas inicien
    }
    return allStarted
}

; ===================================================================
; REEMPLAZOS DE FUNCIONES EXISTENTES
; ===================================================================

; Reemplazar ShowLeaderModeMenu() original
ShowLeaderModeMenuCS() {
    items := "p:Programs|t:Timestamps|c:Commands|i:Information|w:Windows|n:Excel/Numbers"
    ShowCSharpOptionsMenu("LEADER MODE", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowProgramMenu() original  
ShowProgramMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde programs.ini
    Loop 10 {
        lineContent := IniRead(ProgramsIni, "MenuDisplay", "line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            ; Primero, reemplazar múltiples espacios con un delimitador único
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            
            ; Dividir por el delimitador
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una sola letra
                    if (StrLen(key) = 1 && RegExMatch(key, "^[a-z]$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "e:Explorer|i:Settings|t:Terminal|v:VS Code|n:Notepad|o:Obsidian|b:Vivaldi|z:Zen Browser"
    }
    
    ShowCSharpOptionsMenu("PROGRAM LAUNCHER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowWindowMenu() original
ShowWindowMenuCS() {
    items := "2:Split 50/50|3:Split 33/67|4:Quarter Split|x:Close|m:Maximize|-:Minimize|d:Draw|z:Zoom|c:Zoom with cursor|j:Next Window|k:Previous Window"
    ShowCSharpOptionsMenu("WINDOW MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowTimeMenu() original
ShowTimeMenuCS() {
    items := "d:Date Formats|t:Time Formats|h:Date+Time Formats"
    ShowCSharpOptionsMenu("TIMESTAMP MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowInformationMenu() original
ShowInformationMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde information.ini
    Loop 10 {
        lineContent := IniRead(InfoIni, "MenuDisplay", "info_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Extraer key y description del formato "key - description"
            if (InStr(lineContent, " - ")) {
                parts := StrSplit(lineContent, " - ")
                key := parts[1]
                desc := parts[2]
                if (items != "")
                    items .= "|"
                items .= key . ":" . desc
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "n:Name|e:Email|p:Phone|a:Address|c:Company|w:Website"
    }
    
    ShowCSharpOptionsMenu("INFORMATION MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowCommandsMenu() original
ShowCommandsMenuCS() {
    items := BuildCommandItemsFromIni("main_line")
    if (items = "") {
        items := "s:System Commands|n:Network Commands|g:Git Commands|m:Monitoring Commands|f:Folder Commands|w:Windows Commands|o:Power Options|a:ADB Tools|v:VaultFlow|h:Hybrid Management"
    }
    ShowCSharpOptionsMenu("COMMAND PALETTE", items, "\\: Back|ESC: Exit")
}

; ===================================================================
; SUBMENÚS DE TIMESTAMP CON C#
; ===================================================================

; Reemplazar ShowDateFormatsMenu() original
ShowDateFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "date_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "d:Default|1:yyyy-MM-dd|2:dd/MM/yyyy|3:MM/dd/yyyy|4:dd-MMM-yyyy|5:ddd, dd MMM yyyy|6:yyyyMMdd"
    }
    
    ShowCSharpOptionsMenu("DATE FORMATS", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowTimeFormatsMenu() original
ShowTimeFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "time_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "t:Default|1:HH:mm:ss|2:HH:mm|3:hh:mm tt|4:HHmmss|5:HH.mm.ss"
    }
    
    ShowCSharpOptionsMenu("TIME FORMATS", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowDateTimeFormatsMenu() original
ShowDateTimeFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "datetime_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "h:Default|1:yyyy-MM-dd HH:mm:ss|2:dd/MM/yyyy HH:mm|3:yyyy-MM-dd HH:mm:ss|4:yyyyMMddHHmmss|5:ddd, dd MMM yyyy HH:mm"
    }
    
    ShowCSharpOptionsMenu("DATE+TIME FORMATS", items, "\\: Back|ESC: Exit")
}

; ===================================================================
; FUNCIONES DE ESTADO PERSISTENTE (VENTANA INDEPENDIENTE)
; ===================================================================

; Función para mostrar estado persistente específico
ShowPersistentStatus(statusText, statusType) {
    jsonData := "{"
    jsonData .= '"show": true,'
    jsonData .= '"status": "' . statusText . '",'
    jsonData .= '"type": "' . statusType . '"'
    jsonData .= "}"
    
    ; Escribir archivo JSON específico para cada tipo de estado
    statusFile := "status_" . statusType . "_commands.json"
    try {
        FileDelete(statusFile)
    }
    FileAppend(jsonData, statusFile)
}

; Función para ocultar estado persistente específico
HidePersistentStatus(statusType) {
    jsonData := '{"show": false}'
    statusFile := "status_" . statusType . "_commands.json"
    try {
        FileDelete(statusFile)
    }
    FileAppend(jsonData, statusFile)
}

; Funciones específicas para cada estado persistente
ShowNvimStatus() {
    ShowPersistentStatus("NVIM", "nvim")
}

HideNvimStatus() {
    HidePersistentStatus("nvim")
}

ShowVisualStatus() {
    ShowPersistentStatus("VISUAL", "visual")
}

HideVisualStatus() {
    HidePersistentStatus("visual")
}

ShowYankStatus() {
    ShowPersistentStatus("YANK", "yank")
}

HideYankStatus() {
    HidePersistentStatus("yank")
}

ShowExcelStatus() {
    ShowPersistentStatus("EXCEL", "excel")
}

HideExcelStatus() {
    HidePersistentStatus("excel")
}

; ===================================================================
; FUNCIONES DE NOTIFICACIÓN MEJORADAS (TEMPORALES)
; ===================================================================

; Reemplazar ShowCenteredToolTip() con versión C#
ShowCenteredToolTipCS(text, duration := 0) {
    ; Usar duración de configuración si no se especifica
    if (duration = 0) {
        ShowCSharpStatusNotification("STATUS", text)
    } else {
        items := "info:" . text
        ShowCSharpTooltip("STATUS", items, "", duration)
    }
}

; Notificaciones específicas mejoradas
ShowCopyNotificationCS() {
    ShowCSharpStatusNotification("CLIPBOARD", "COPIED")
}

ShowNvimLayerStatusCS(isActive) {
    if (isActive) {
        ShowNvimStatus()
    } else {
        HideNvimStatus()
    }
}

ShowExcelLayerStatusCS(isActive) {
    if (isActive) {
        ShowExcelStatus()
    } else {
        HideExcelStatus()
    }
}

ShowProcessTerminatedCS() {
    ShowCSharpStatusNotification("SYSTEM", "PROCESS TERMINATED")
}

ShowCommandExecutedCS(category, command) {
    ShowCSharpStatusNotification("COMMAND EXECUTED", category . " command executed: " . command)
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA NVIM LAYER OPTIONS
; ===================================================================


; Menú de opciones Visual (v)
ShowVisualMenuCS() {
    items := "v:Visual Mode|l:Visual Line|b:Visual Block"
    ShowCSharpOptionsMenu("VISUAL MODE", items, "ESC: Cancel")
}

; Menú de opciones Insert (i)
ShowInsertMenuCS() {
    items := "i:Insert Mode|a:Insert After|o:Insert New Line"
    ShowCSharpOptionsMenu("INSERT MODE", items, "ESC: Cancel")
}

; Menú de opciones Replace (r)
ShowReplaceMenuCS() {
    items := "r:Replace Character|R:Replace Mode|s:Substitute"
    ShowCSharpOptionsMenu("REPLACE OPTIONS", items, "ESC: Cancel")
}

; Menú de opciones Yank (y) - Actualizado para mostrar opciones
ShowYankMenuCS() {
    items := "y:Yank Line|w:Yank Word|a:Yank All|p:Yank Paragraph"
    ShowCSharpOptionsMenu("YANK OPTIONS", items, "ESC: Cancel")
}

; Menú de opciones Delete (d) - Actualizado para mostrar opciones  
ShowDeleteMenuCS() {
    items := "d:Delete Line|w:Delete Word|a:Delete All"
    ShowCSharpOptionsMenu("DELETE OPTIONS", items, "ESC: Cancel")
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA SUBMENÚS DE COMANDOS
; ===================================================================

; Submenú System Commands (leader → c → s)
ShowSystemCommandsMenuCS() {
    items := BuildCommandItemsFromIni("system_line")
    if (items = "") {
        items := "s:System Info|t:Task Manager|v:Services|e:Event Viewer|d:Device Manager|c:Disk Cleanup"
    }
    ShowCSharpOptionsMenu("SYSTEM COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Network Commands (leader → c → n)
ShowNetworkCommandsMenuCS() {
    items := BuildCommandItemsFromIni("network_line")
    if (items = "") {
        items := "i:IP Config|p:Ping Google|n:Netstat"
    }
    ShowCSharpOptionsMenu("NETWORK COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Git Commands (leader → c → g)
ShowGitCommandsMenuCS() {
    items := BuildCommandItemsFromIni("git_line")
    if (items = "") {
        items := "s:Status|l:Log|b:Branches|d:Diff|a:Add All|p:Pull"
    }
    ShowCSharpOptionsMenu("GIT COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Monitoring Commands (leader → c → m)
ShowMonitoringCommandsMenuCS() {
    items := BuildCommandItemsFromIni("monitoring_line")
    if (items = "") {
        items := "p:Processes|s:Services|d:Disk Usage|m:Memory|c:CPU Usage"
    }
    ShowCSharpOptionsMenu("MONITORING COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Folder Commands (leader → c → f)
ShowFolderCommandsMenuCS() {
    items := BuildCommandItemsFromIni("folder_line")
    if (items = "") {
        items := "t:Temp|a:AppData|p:Program Files|u:User Profile|d:Desktop|s:System32"
    }
    ShowCSharpOptionsMenu("FOLDER ACCESS", items, "\\: Back|ESC: Exit")
}

; Submenú Windows Commands (leader → c → w)
ShowWindowsCommandsMenuCS() {
    items := BuildCommandItemsFromIni("windows_line")
    if (items = "") {
        items := "h:Toggle Hidden Files|r:Registry Editor|e:Environment Variables"
    }
    ShowCSharpOptionsMenu("WINDOWS COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Power Options (leader → c → o)
ShowPowerOptionsCommandsMenuCS() {
    items := "s:Sleep|h:Hibernate|r:Restart|S:Shutdown|l:Lock Screen|o:Sign Out"
    ShowCSharpOptionsMenu("POWER OPTIONS", items, "\\: Back|ESC: Exit")
}

; Submenú ADB Tools (leader → c → a)
ShowADBCommandsMenuCS() {
    items := "d:List Devices|i:Install APK|u:Uninstall Package|l:Logcat|s:Shell|r:Reboot Device|c:Clear App Data"
    ShowCSharpOptionsMenu("ADB TOOLS", items, "\\: Back|ESC: Exit")
}

; Submenú Hybrid Management (leader → c → h)
ShowHybridManagementMenuCS() {
    items := "R:Reload Script|e:Exit Script|c:Open Config Folder|l:View Log File|v:Show Version Info|r:Reload Config"
    ShowCSharpOptionsMenu("HYBRID MANAGEMENT", items, "\\: Back|ESC: Exit")
}

; Submenú VaultFlow Commands (leader → c → v)
ShowVaultFlowCommandsMenuCS() {
    items := BuildCommandItemsFromIni("vaultflow_line")
    if (items = "") {
        items := "v:Run VaultFlow|s:VaultFlow Status|l:List Vaults|h:VaultFlow Help"
    }
    ShowCSharpOptionsMenu("VAULTFLOW COMMANDS", items, "\\: Back|ESC: Exit")
}

; ===================================================================
; FUNCIÓN DE LIMPIEZA
; ===================================================================

; Función para cerrar las aplicaciones C#
StopTooltipApp() {
    try {
        ProcessClose("TooltipApp.exe")
    }
    ; Cerrar todos los PowerShell que ejecutan StatusWindow
    statusTypes := ["Nvim", "Visual", "Yank", "Excel"]
    for index, statusType in statusTypes {
        try {
            RunWait("powershell.exe -Command `"Get-Process | Where-Object {`$_.ProcessName -eq 'powershell' -and `$_.CommandLine -like '*StatusWindow_" . statusType . "*'} | Stop-Process -Force`"", , "Hide")
        }
    }
    ; Limpiar archivos JSON
    try {
        FileDelete("tooltip_commands.json")
        FileDelete("status_nvim_commands.json")
        FileDelete("status_visual_commands.json")
        FileDelete("status_yank_commands.json")
        FileDelete("status_excel_commands.json")
    }
}

; ===================================================================
; INICIALIZACIÓN AUTOMÁTICA
; ===================================================================

; Iniciar automáticamente la aplicación tooltip al cargar este archivo
; (Comentar la siguiente línea si prefieres iniciar manualmente)
; StartTooltipApp()