; ===================================================================
; INTEGRACIÓN C# TOOLTIP PARA HYBRIDCAPSLOCK
; ===================================================================
; Funciones para reemplazar los tooltips nativos de AutoHotkey
; con la aplicación C# + WPF

; Función para mostrar tooltip C#
ShowCSharpTooltip(title, items, navigation := "", timeout := 7000) {
    ; Construir JSON para items
    itemsJson := ""
    Loop, Parse, items, |
    {
        if (A_Index > 1)
            itemsJson .= ","
        
        ; Separar key y description (formato: "key:description")
        StringSplit, itemParts, A_LoopField, :
        key := itemParts1
        desc := itemParts2
        
        itemsJson .= "{""key"": """ . key . """, ""description"": """ . desc . """}"
    }
    
    ; Construir JSON para navegación
    navJson := ""
    if (navigation != "") {
        Loop, Parse, navigation, |
        {
            if (A_Index > 1)
                navJson .= ","
            navJson .= """" . A_LoopField . """"
        }
    } else {
        navJson := """ESC: Exit"""
    }
    
    ; Construir JSON completo
    jsonData := "{"
    jsonData .= """tooltip_type"": ""leader"","
    jsonData .= """title"": """ . title . ""","
    jsonData .= """items"": [" . itemsJson . "],"
    jsonData .= """navigation"": [" . navJson . "],"
    jsonData .= """timeout_ms"": " . timeout . ","
    jsonData .= """show"": true"
    jsonData .= "}"
    
    ; Escribir archivo JSON
    FileDelete, tooltip_commands.json
    FileAppend, %jsonData%, tooltip_commands.json
}

; Función para ocultar tooltip C#
HideCSharpTooltip() {
    jsonData := "{""show"": false}"
    FileDelete, tooltip_commands.json
    FileAppend, %jsonData%, tooltip_commands.json
}

; ===================================================================
; FUNCIONES DE REEMPLAZO PARA HYBRIDCAPSLOCK
; ===================================================================

; Reemplazar ShowLeaderMenu() original
ShowLeaderMenu() {
    items := "w:Windows|p:Programs|t:Time|c:Commands|i:Information|o:Obsidian"
    ShowCSharpTooltip("LEADER MENU", items)
    return
}

; Reemplazar ShowProgramMenu() original
ShowProgramMenu() {
    items := "v:Visual Studio|c:Chrome|n:Notepad++|t:Terminal|f:Firefox|e:Explorer"
    navigation := "ESC: Back|ENTER: Launch"
    ShowCSharpTooltip("PROGRAMS", items, navigation)
    return
}

; Reemplazar ShowWindowMenu() original
ShowWindowMenu() {
    items := "m:Minimize|x:Maximize|c:Close|r:Restore|t:Always on Top"
    navigation := "ESC: Back|ENTER: Apply"
    ShowCSharpTooltip("WINDOWS", items, navigation)
    return
}

; Reemplazar ShowTimeMenu() original
ShowTimeMenu() {
    items := "d:Date|t:Time|s:Timestamp|f:Formatted|u:UTC"
    navigation := "ESC: Back|ENTER: Insert"
    ShowCSharpTooltip("TIMESTAMPS", items, navigation)
    return
}

; Función para iniciar la aplicación C# tooltip
StartTooltipApp() {
    ; Verificar si ya está ejecutándose
    Process, Exist, TooltipApp.exe
    if (ErrorLevel = 0) {
        ; No está ejecutándose, iniciarla
        Run, tooltip_csharp\bin\Release\net6.0-windows\win-x64\publish\TooltipApp.exe, , Hide
        Sleep, 500  ; Dar tiempo para que inicie
    }
}

; Función para cerrar la aplicación C# tooltip
StopTooltipApp() {
    Process, Close, TooltipApp.exe
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
; 1. Incluir este archivo: #Include tooltip_csharp\autohotkey_integration.ahk
; 2. Llamar StartTooltipApp() al inicio del script
; 3. Reemplazar llamadas a ToolTip con ShowCSharpTooltip()
; 4. Reemplazar llamadas a ToolTip, con HideCSharpTooltip()

; Ejemplo de integración en HybridCapsLock.ahk:
; 
; ; Al inicio del script
; StartTooltipApp()
; 
; ; En lugar de:
; ; ToolTip, Leader Menu`nw: Windows`np: Programs, , , 1
; ; Usar:
; ShowLeaderMenu()
; 
; ; En lugar de:
; ; ToolTip, , , , 1
; ; Usar:
; HideCSharpTooltip()