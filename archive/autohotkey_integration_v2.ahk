; ===================================================================
; INTEGRACIÓN C# TOOLTIP PARA HYBRIDCAPSLOCK v2
; ===================================================================
; Funciones para reemplazar los tooltips nativos de AutoHotkey v2
; con la aplicación C# + WPF

; Función para mostrar tooltip C# (AutoHotkey v2)
ShowCSharpTooltip(title, items, navigation := "", timeout := 7000) {
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
        navJson := '"ESC: Exit"'
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
    
    ; Escribir archivo JSON
    try {
        FileDelete("tooltip_commands.json")
    }
    FileAppend(jsonData, "tooltip_commands.json")
}

; Función para ocultar tooltip C#
HideCSharpTooltip() {
    jsonData := '{"show": false}'
    try {
        FileDelete("tooltip_commands.json")
    }
    FileAppend(jsonData, "tooltip_commands.json")
}

; ===================================================================
; FUNCIONES DE REEMPLAZO PARA HYBRIDCAPSLOCK v2
; ===================================================================

; Reemplazar ShowLeaderModeMenu() original
ShowCSharpLeaderMenu() {
    items := "w:Windows|p:Programs|t:Timestamps|c:Commands|i:Information|n:Excel/Numbers"
    ShowCSharpTooltip("LEADER MODE", items)
}

; Reemplazar ShowProgramMenu() original
ShowCSharpProgramMenu() {
    ; Leer desde programs.ini si está disponible
    global ProgramsIni
    items := ""
    
    ; Intentar leer configuración dinámica
    Loop 10 {
        lineContent := IniRead(ProgramsIni, "MenuDisplay", "line" . A_Index, "")
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
        items := "v:Visual Studio|c:Chrome|n:Notepad++|t:Terminal|f:Firefox|e:Explorer"
    }
    
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("PROGRAM LAUNCHER", items, navigation)
}

; Reemplazar ShowWindowMenu() original
ShowCSharpWindowMenu() {
    items := "2:Split 50/50|3:Split 33/67|4:Quarter Split|x:Close|m:Maximize|-:Minimize|d:Draw|z:Zoom|c:Zoom with cursor|j:Window Switch|k:Window Switch"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("WINDOW MANAGER", items, navigation)
}

; Reemplazar ShowTimeMenu() original
ShowCSharpTimeMenu() {
    items := "d:Date Formats|t:Time Formats|h:Date+Time Formats"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("TIMESTAMP MANAGER", items, navigation)
}

; Reemplazar ShowInformationMenu() original
ShowCSharpInformationMenu() {
    ; Leer desde information.ini si está disponible
    global InfoIni
    items := ""
    
    ; Intentar leer configuración dinámica
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
    
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("INFORMATION MANAGER", items, navigation)
}

; Reemplazar ShowCommandsMenu() original
ShowCSharpCommandsMenu() {
    items := "s:System Commands|n:Network Commands|g:Git Commands|m:Monitoring Commands|f:Folder Commands|w:Windows Commands|o:Power Options|a:ADB Tools|v:VaultFlow|h:Hybrid Management"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("COMMAND PALETTE", items, navigation)
}

; Funciones para submenús de comandos
ShowCSharpSystemCommandsMenu() {
    items := "s:System Info|t:Task Manager|v:Services|e:Event Viewer|d:Device Manager|c:Disk Cleanup"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("SYSTEM COMMANDS", items, navigation)
}

ShowCSharpNetworkCommandsMenu() {
    items := "i:IP Config|p:Ping Google|n:Netstat"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("NETWORK COMMANDS", items, navigation)
}

ShowCSharpGitCommandsMenu() {
    items := "s:Status|l:Log|b:Branches|d:Diff|a:Add All|p:Pull"
    navigation := "\\: Back|ESC: Exit"
    ShowCSharpTooltip("GIT COMMANDS", items, navigation)
}

; Función para mostrar notificaciones temporales
ShowCSharpNotification(message, duration := 2000) {
    items := "info:" . message
    ShowCSharpTooltip("NOTIFICATION", items, "", duration)
}

; Función para iniciar la aplicación C# tooltip
StartTooltipApp() {
    ; Verificar si ya está ejecutándose
    if (!ProcessExist("TooltipApp.exe")) {
        ; No está ejecutándose, iniciarla
        try {
            Run("tooltip_csharp\\bin\\Release\\net6.0-windows\\win-x64\\publish\\TooltipApp.exe", , "Hide")
            Sleep(500)  ; Dar tiempo para que inicie
        } catch Error as e {
            ; Si no existe el ejecutable compilado, intentar con dotnet
            try {
                Run("dotnet run --project tooltip_csharp", , "Hide")
                Sleep(1000)
            }
        }
    }
}

; Función para cerrar la aplicación C# tooltip
StopTooltipApp() {
    try {
        ProcessClose("TooltipApp.exe")
    }
}

; ===================================================================
; FUNCIONES DE COMPATIBILIDAD CON TOOLTIPS EXISTENTES
; ===================================================================

; Reemplazar ShowCenteredToolTip() con versión C#
ShowCenteredToolTipCS(text, duration := 2000) {
    ; Convertir texto simple a formato de items
    items := "msg:" . text
    ShowCSharpTooltip("STATUS", items, "", duration)
}

; Reemplazar funciones de estado específicas
ShowCopyNotificationCS() {
    ShowCSharpNotification("COPIED", 800)
}

ShowNvimLayerStatusCS(isActive) {
    if (isActive) {
        ShowCSharpNotification("NVIM LAYER ON", 1500)
    } else {
        ShowCSharpNotification("NVIM LAYER OFF", 1500)
    }
}

ShowExcelLayerStatusCS(isActive) {
    if (isActive) {
        ShowCSharpNotification("EXCEL LAYER ON", 2000)
    } else {
        ShowCSharpNotification("EXCEL LAYER OFF", 2000)
    }
}

; ===================================================================
; EJEMPLOS DE USO
; ===================================================================

; Ejemplo 1: Tooltip simple
; ShowCSharpTooltip("TEST", "a:Action A|b:Action B|c:Action C")

; Ejemplo 2: Tooltip con navegación personalizada
; ShowCSharpTooltip("CUSTOM MENU", "1:Option 1|2:Option 2", "ESC: Cancel|ENTER: OK")

; Ejemplo 3: Tooltip con timeout personalizado (3 segundos)
; ShowCSharpTooltip("QUICK MENU", "q:Quick|f:Fast", "", 3000)

; ===================================================================
; INTEGRACIÓN CON HYBRIDCAPSLOCK EXISTENTE
; ===================================================================

; Para integrar con HybridCapsLock.ahk:
; 1. Incluir este archivo: #Include tooltip_csharp\autohotkey_integration_v2.ahk
; 2. Llamar StartTooltipApp() al inicio del script
; 3. Reemplazar llamadas a funciones de tooltip existentes

; Ejemplo de integración en HybridCapsLock.ahk:
; 
; ; Al inicio del script (después de las variables globales)
; #Include tooltip_csharp\autohotkey_integration_v2.ahk
; StartTooltipApp()
; 
; ; En la función ShowLeaderModeMenu(), reemplazar contenido con:
; ShowCSharpLeaderMenu()
; return
; 
; ; En lugar de:
; ; ShowCenteredToolTip("COPIED")
; ; Usar:
; ShowCopyNotificationCS()