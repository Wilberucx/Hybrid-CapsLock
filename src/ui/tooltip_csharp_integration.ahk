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
if (!IsSet(CommandsIni)) {
    global CommandsIni := A_ScriptDir . "\config\commands.ini"
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
    
    ; Whether tooltip layer should also handle input (hotkeys) instead of InputHook
    handleInputValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_handles_input", "false"))
    config.handleInput := handleInputValue = "true"
    
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
; ESCRITURA ROBUSTA DEL JSON (ATÓMICA + THROTTLE)
; ===================================================================

; Ruta del archivo JSON principal (alineada a A_ScriptDir)
GetTooltipJsonPath() {
    return A_ScriptDir . "\tooltip_commands.json"
}

; Escritura atómica: escribe a .tmp y luego hace move para evitar lecturas parciales
WriteFileAtomic(path, content) {
    tmp := path . ".tmp"
    try {
        FileDelete(tmp)
    }
    FileAppend(content, tmp)
    ; Move con overwrite (1) para reemplazo seguro
    FileMove(tmp, path, 1)
}

; Estado para debounce de escritura
global tooltipJsonPending := ""
global tooltipDebounceMs := 100

ScheduleTooltipJsonWrite(json) {
    global tooltipJsonPending, tooltipDebounceMs
    tooltipJsonPending := json
    ; Reiniciar timer one-shot para consolidar múltiples escrituras
    SetTimer(DebouncedTooltipWrite, 0)
    SetTimer(DebouncedTooltipWrite, -tooltipDebounceMs)
}

DebouncedTooltipWrite() {
    global tooltipJsonPending
    if (tooltipJsonPending != "") {
        WriteFileAtomic(GetTooltipJsonPath(), tooltipJsonPending)
    }
}

; JSON Escape helper
JsonEscape(str) {
    if (!IsSet(str))
        return ""
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`t", "\t")
    return str
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
    
    ; Escribir JSON de forma atómica con debounce en A_ScriptDir
    ScheduleTooltipJsonWrite(jsonData)
}

; Función para ocultar tooltip C#
HideCSharpTooltip() {
    ; Resetear estado activo del menú
    global tooltipMenuActive, tooltipCurrentTitle
    tooltipMenuActive := false
    tooltipCurrentTitle := ""
    jsonData := '{"show": false}'
    ; Escribir JSON de forma atómica con debounce
    ScheduleTooltipJsonWrite(jsonData)
}

; Removed duplicate initial ShowCSharpOptionsMenu; stateful override defined later.

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
; INTERACTIVE MENU HANDLING (GENERIC KEY DISPATCH)
; ===================================================================

; Global state for menu interaction
global tooltipMenuActive := false
global tooltipCurrentTitle := ""

; Breadcrumb navigation stack for intelligent back
global tooltipNavStack := []

TooltipNavReset() {
    global tooltipNavStack
    tooltipNavStack := []
}

TooltipNavTop() {
    global tooltipNavStack
    return tooltipNavStack.Length ? tooltipNavStack[tooltipNavStack.Length] : ""
}

TooltipNavPush(menuId) {
    global tooltipNavStack
    if (!tooltipNavStack.Length || tooltipNavStack[tooltipNavStack.Length] != menuId) {
        tooltipNavStack.Push(menuId)
    }
}

TooltipShowById(menuId) {
    switch menuId {
        case "LEADER": ShowLeaderModeMenuCS()
        case "PROGRAMS": ShowProgramMenuCS()
        case "WINDOWS": ShowWindowMenuCS()
        case "TIMESTAMPS": ShowTimeMenuCS()
        case "INFORMATION": ShowInformationMenuCS()
        case "COMMANDS": ShowCommandsMenuCS()
        case "CMD_s": ShowSystemCommandsMenuCS()
        case "CMD_n": ShowNetworkCommandsMenuCS()
        case "CMD_g": ShowGitCommandsMenuCS()
        case "CMD_m": ShowMonitoringCommandsMenuCS()
        case "CMD_f": ShowFolderCommandsMenuCS()
        case "CMD_w": ShowWindowsCommandsMenuCS()
        case "CMD_o": ShowPowerOptionsCommandsMenuCS()
        case "CMD_a": ShowADBCommandsMenuCS()
        case "CMD_v": ShowVaultFlowCommandsMenuCS()
        case "CMD_h": ShowHybridManagementMenuCS()
        default:
            ; fallback to leader
            ShowLeaderModeMenuCS()
    }
}

TooltipNavBackCS() {
    global tooltipNavStack
    if (tooltipNavStack.Length > 1) {
        tooltipNavStack.Pop() ; remove current
        prev := tooltipNavStack[tooltipNavStack.Length]
        TooltipShowById(prev)
    } else {
        ; nothing to go back to, show leader for consistency
        ShowLeaderModeMenuCS()
    }
}

TooltipMenuIsActive() {
    global tooltipMenuActive
    return tooltipMenuActive
}

; Central dispatcher for option selection
HandleTooltipSelection(key) {
    global tooltipMenuActive, tooltipCurrentTitle

    ; Debug
    OutputDebug("[TOOLTIP] Selection - title=" tooltipCurrentTitle " key=" key "`n")

    if (key = "ESC") {
        HideCSharpTooltip()
        tooltipMenuActive := false
        return
    }

    if (tooltipCurrentTitle = "COMMAND PALETTE") {
        switch key {
            case "\\":
                TooltipNavBackCS()
                return
            case "s":
                ShowSystemCommandsMenuCS()
            case "n":
                ShowNetworkCommandsMenuCS()
            case "g":
                ShowGitCommandsMenuCS()
            case "m":
                ShowMonitoringCommandsMenuCS()
            case "f":
                ShowFolderCommandsMenuCS()
            case "w":
                ShowWindowsCommandsMenuCS()
            case "o":
                ShowPowerOptionsCommandsMenuCS()
            case "a":
                ShowADBCommandsMenuCS()
            case "v":
                ShowVaultFlowCommandsMenuCS()
            case "h":
                ShowHybridManagementMenuCS()
            default:
                OutputDebug("[TOOLTIP] Unknown key in COMMAND PALETTE: " key "`n")
        }
        return
    }

    ; Other menus can be handled here similarly, based on tooltipCurrentTitle
}

; Ensure ShowCSharpOptionsMenu marks menu as active and remembers title
; (we hook by wrapping ShowCSharpOptionsMenu via a helper)
Original_ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    if (timeout = 0) {
        timeout := tooltipConfig.optionsTimeout
    }
    global tooltipConfig
    ShowCSharpTooltip(title, items, navigation, timeout)
}

; Override previous function name to set state then call original
ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    global tooltipMenuActive, tooltipCurrentTitle
    tooltipMenuActive := true
    tooltipCurrentTitle := title
    Original_ShowCSharpOptionsMenu(title, items, navigation, timeout)
}

; Context helpers for scoping hotkeys
TooltipInLeaderMenu() {
    global tooltipMenuActive, tooltipCurrentTitle, tooltipConfig
    return tooltipMenuActive && tooltipConfig.handleInput && (tooltipCurrentTitle = "LEADER MODE")
}
TooltipInCommandsMenu() {
    global tooltipMenuActive, tooltipCurrentTitle, tooltipConfig
    return tooltipMenuActive && tooltipConfig.handleInput && (tooltipCurrentTitle = "COMMAND PALETTE")
}

; Leader menu hotkeys (only on LEADER MODE)
#HotIf TooltipInLeaderMenu()
p::HandleTooltipSelection("p")
t::HandleTooltipSelection("t")
c::HandleTooltipSelection("c")
i::HandleTooltipSelection("i")
w::HandleTooltipSelection("w")
n::HandleTooltipSelection("n")
\::HandleTooltipSelection("\\")
Esc::HandleTooltipSelection("ESC")
#HotIf

; Commands palette hotkeys (only on COMMAND PALETTE)
#HotIf TooltipInCommandsMenu()
s::HandleTooltipSelection("s")
n::HandleTooltipSelection("n")
g::HandleTooltipSelection("g")
m::HandleTooltipSelection("m")
f::HandleTooltipSelection("f")
w::HandleTooltipSelection("w")
o::HandleTooltipSelection("o")
a::HandleTooltipSelection("a")
v::HandleTooltipSelection("v")
h::HandleTooltipSelection("h")
\::HandleTooltipSelection("\\")
Esc::HandleTooltipSelection("ESC")
#HotIf

; ===================================================================
; REEMPLAZOS DE FUNCIONES EXISTENTES
; ===================================================================

; Reemplazar ShowLeaderModeMenu() original
ShowLeaderModeMenuCS() {
    TooltipNavReset()
    TooltipNavPush("LEADER")
    items := "p:Programs|t:Timestamps|c:Commands|i:Information|w:Windows|n:Excel/Numbers"
    ShowCSharpOptionsMenu("LEADER MODE", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowProgramMenu() original  
ShowProgramMenuCS() {
    TooltipNavPush("PROGRAMS")
    items := GenerateProgramItemsForCS()
    ShowCSharpOptionsMenu("PROGRAM LAUNCHER", items, "\\: Back|ESC: Exit")
}

; Generate program items for C# tooltips from ProgramMapping order
GenerateProgramItemsForCS() {
    global ProgramsIni
    items := ""
    
    ; Read order from ProgramMapping
    orderStr := IniRead(ProgramsIni, "ProgramMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR") {
        ; Fallback order
        orderStr := "e i t v n o b z m w l r q p k f"
    }
    
    ; Split order into individual keys
    keys := StrSplit(orderStr, " ")
    
    ; Process keys and build items string
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
            
        ; Get program name for this key
        programName := IniRead(ProgramsIni, "ProgramMapping", key, "")
        if (programName = "" || programName = "ERROR")
            continue
            
        ; Add to items string
        if (items != "")
            items .= "|"
        items .= key . ":" . programName
    }
    
    ; Fallback if no configuration found
    if (items == "") {
        items := "e:Explorer|i:Settings|t:Terminal|v:VisualStudio|n:Notepad|b:Vivaldi|z:Zen"
    }
    
    return items
}

; Reemplazar ShowWindowMenu() original
ShowWindowMenuCS() {
    TooltipNavPush("WINDOWS")
    items := "2:Split 50/50|3:Split 33/67|4:Quarter Split|x:Close|m:Maximize|-:Minimize|d:Draw|z:Zoom|c:Zoom with cursor|j:Next Window|k:Previous Window"
    ShowCSharpOptionsMenu("WINDOW MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowTimeMenu() original
ShowTimeMenuCS() {
    TooltipNavPush("TIMESTAMPS")
    items := "d:Date Formats|t:Time Formats|h:Date+Time Formats"
    ShowCSharpOptionsMenu("TIMESTAMP MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowInformationMenu() original
ShowInformationMenuCS() {
    TooltipNavPush("INFORMATION")
    items := GenerateInformationItemsForCS()
    ShowCSharpOptionsMenu("INFORMATION MANAGER", items, "\\: Back|ESC: Exit")
}

; Generate information items for C# tooltips from InfoMapping order
GenerateInformationItemsForCS() {
    global InfoIni
    items := ""
    
    ; Read order from InfoMapping
    orderStr := IniRead(InfoIni, "InfoMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR") {
        ; Fallback order
        orderStr := "e n p a c w g l r"
    }
    
    ; Split order into individual keys
    keys := StrSplit(orderStr, " ")
    
    ; Process keys and build items string
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
            
        ; Get information name for this key
        infoName := IniRead(InfoIni, "InfoMapping", key, "")
        if (infoName = "" || infoName = "ERROR")
            continue
            
        ; Add to items string
        if (items != "")
            items .= "|"
        items .= key . ":" . infoName
    }
    
    ; Fallback if no configuration found
    if (items == "") {
        items := "e:Email|n:Name|p:Phone|a:Address|c:Company|w:Website|g:GitHub|l:LinkedIn"
    }
    
    return items
}

; Reemplazar ShowCommandsMenu() original
ShowCommandsMenuCS() {
    TooltipNavPush("COMMANDS")
    items := BuildCommandsMainItemsFromCategories()
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
    
    ; Escribir archivo JSON específico para cada tipo de estado (atómico)
    statusFile := A_ScriptDir . "\\status_" . statusType . "_commands.json"
    try {
        FileDelete(statusFile . ".tmp")
    }
    FileAppend(jsonData, statusFile . ".tmp")
    FileMove(statusFile . ".tmp", statusFile, 1)
}

; Función para ocultar estado persistente específico
HidePersistentStatus(statusType) {
    jsonData := '{"show": false}'
    statusFile := A_ScriptDir . "\\status_" . statusType . "_commands.json"
    try {
        FileDelete(statusFile . ".tmp")
    }
    FileAppend(jsonData, statusFile . ".tmp")
    FileMove(statusFile . ".tmp", statusFile, 1)
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
    TooltipNavPush("CMD_s")
    items := BuildCommandItemsFromCategoryKey("s")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("s")
        if (items = "")
            items := "s:System Info|t:Task Manager|v:Services|e:Event Viewer|d:Device Manager|c:Disk Cleanup"
    }
    ShowCSharpOptionsMenu("SYSTEM COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Network Commands (leader → c → n)
ShowNetworkCommandsMenuCS() {
    TooltipNavPush("CMD_n")
    items := BuildCommandItemsFromCategoryKey("n")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("n")
        if (items = "")
            items := "i:IP Config|p:Ping Google|n:Netstat"
    }
    ShowCSharpOptionsMenu("NETWORK COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Git Commands (leader → c → g)
ShowGitCommandsMenuCS() {
    TooltipNavPush("CMD_g")
    items := BuildCommandItemsFromCategoryKey("g")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("g")
        if (items = "")
            items := "s:Status|l:Log|b:Branches|d:Diff|a:Add All|p:Pull"
    }
    ShowCSharpOptionsMenu("GIT COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Monitoring Commands (leader → c → m)
ShowMonitoringCommandsMenuCS() {
    TooltipNavPush("CMD_m")
    items := BuildCommandItemsFromCategoryKey("m")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("m")
        if (items = "")
            items := "p:Processes|s:Services|d:Disk Usage|m:Memory|c:CPU Usage"
    }
    ShowCSharpOptionsMenu("MONITORING COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Folder Commands (leader → c → f)
ShowFolderCommandsMenuCS() {
    TooltipNavPush("CMD_f")
    items := BuildCommandItemsFromCategoryKey("f")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("f")
        if (items = "")
            items := "t:Temp|a:AppData|p:Program Files|u:User Profile|d:Desktop|s:System32"
    }
    ShowCSharpOptionsMenu("FOLDER ACCESS", items, "\\: Back|ESC: Exit")
}

; Submenú Windows Commands (leader → c → w)
ShowWindowsCommandsMenuCS() {
    TooltipNavPush("CMD_w")
    items := BuildCommandItemsFromCategoryKey("w")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("w")
        if (items = "")
            items := "h:Toggle Hidden Files|r:Registry Editor|e:Environment Variables"
    }
    ShowCSharpOptionsMenu("WINDOWS COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Power Options (leader → c → o)
ShowPowerOptionsCommandsMenuCS() {
    TooltipNavPush("CMD_o")
    items := BuildCommandItemsFromCategoryKey("o")
    if (items = "") {
        items := "s:Sleep|h:Hibernate|r:Restart|S:Shutdown|l:Lock Screen|o:Sign Out"
    }
    ShowCSharpOptionsMenu("POWER OPTIONS", items, "\\: Back|ESC: Exit")
}

; Submenú ADB Tools (leader → c → a)
ShowADBCommandsMenuCS() {
    TooltipNavPush("CMD_a")
    items := BuildCommandItemsFromCategoryKey("a")
    if (items = "") {
        items := "d:List Devices|i:Install APK|u:Uninstall Package|l:Logcat|s:Shell|r:Reboot Device|c:Clear App Data"
    }
    ShowCSharpOptionsMenu("ADB TOOLS", items, "\\: Back|ESC: Exit")
}

; Submenú Hybrid Management (leader → c → h)
ShowHybridManagementMenuCS() {
    TooltipNavPush("CMD_h")
    items := BuildCommandItemsFromCategoryKey("h")
    if (items = "") {
        items := "R:Reload Script|e:Exit Script|c:Open Config Folder|l:View Log File|v:Show Version Info|r:Reload Config"
    }
    ShowCSharpOptionsMenu("HYBRID MANAGEMENT", items, "\\: Back|ESC: Exit")
}

; Submenú VaultFlow Commands (leader → c → v)
ShowVaultFlowCommandsMenuCS() {
    TooltipNavPush("CMD_v")
    items := BuildCommandItemsFromCategoryKey("v")
    if (items = "") {
        BuildCommandItemsFromCategoryKey("v")
        if (items = "")
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
        FileDelete(GetTooltipJsonPath())
        FileDelete(A_ScriptDir . "\\status_nvim_commands.json")
        FileDelete(A_ScriptDir . "\\status_visual_commands.json")
        FileDelete(A_ScriptDir . "\\status_yank_commands.json")
        FileDelete(A_ScriptDir . "\\status_excel_commands.json")
    }
}

; ===================================================================
; INICIALIZACIÓN AUTOMÁTICA
; ===================================================================

; Iniciar automáticamente la aplicación tooltip al cargar este archivo
; (Comentar la siguiente línea si prefieres iniciar manualmente)
; StartTooltipApp()