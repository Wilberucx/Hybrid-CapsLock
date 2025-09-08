; ===================================================================
; TEST SIMPLE DE DEBUG PARA VENTANA DE ESTADO
; ===================================================================

#SingleInstance Force
#Warn All

MsgBox("🔍 TEST DE DEBUG - VENTANA DE ESTADO`n`n" .
       "Este test ejecutará StatusWindow_Debug.ps1 que:`n" .
       "• Muestra logs en consola`n" .
       "• Ventana con borde ROJO para debug`n" .
       "• Texto más grande`n" .
       "• Se muestra inmediatamente por 10 segundos`n`n" .
       "Presiona OK para continuar", "Debug Test")

; Ejecutar versión de debug corregida con ventana visible para ver logs
statusScript := "tooltip_csharp\\StatusWindow_Debug_Fixed.ps1"
if (FileExist(statusScript)) {
    MsgBox("✅ Ejecutando StatusWindow_Debug.ps1`n`nDeberías ver:`n1. Ventana de PowerShell con logs`n2. Ventana con borde ROJO en esquina inferior izquierda")
    
    ; Ejecutar con ventana visible para ver logs y mantenerla abierta
    Run('powershell.exe -NoExit -ExecutionPolicy Bypass -File "' . statusScript . '"', , "Show")
    
    Sleep(3000)  ; Dar tiempo para que aparezca
    
    ; Crear archivo JSON para probar
    MsgBox("📄 Creando archivo JSON de prueba`n`nDeberías ver que el texto cambia a 'TEST NVIM'")
    
    jsonData := '{"show": true, "status": "TEST NVIM"}'
    try {
        FileDelete("status_commands.json")
    }
    FileAppend(jsonData, "status_commands.json")
    
    Sleep(3000)
    
    ; Probar ocultar
    MsgBox("👁️ Ocultando ventana de estado")
    jsonData := '{"show": false}'
    try {
        FileDelete("status_commands.json")
    }
    FileAppend(jsonData, "status_commands.json")
    
    Sleep(2000)
    
    ; Mostrar de nuevo
    MsgBox("👁️ Mostrando de nuevo con 'EXCEL'")
    jsonData := '{"show": true, "status": "EXCEL"}'
    try {
        FileDelete("status_commands.json")
    }
    FileAppend(jsonData, "status_commands.json")
    
    Sleep(3000)
    
    MsgBox("🏁 Test completado!`n`n¿Funcionó correctamente?`n`n" .
           "Si NO funcionó, revisa la ventana de PowerShell para ver los logs de error.")
    
    ; Limpiar
    try {
        FileDelete("status_commands.json")
    }
    
    ; Cerrar PowerShell
    Run("powershell.exe -Command `"Get-Process powershell | Where-Object {`$_.CommandLine -like '*StatusWindow_Debug*'} | Stop-Process -Force`"", , "Hide")
    
} else {
    MsgBox("❌ No se encontró StatusWindow_Debug.ps1 en: " . statusScript)
}

ExitApp()