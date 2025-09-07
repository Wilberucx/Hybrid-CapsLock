# 🔧 Hotfix: Comillas en Comandos PowerShell

## ❗ Problema Identificado

**Error de sintaxis:** Comillas anidadas incorrectas en comandos PowerShell
```
Error: Missing space or operator before this.
Specifically: 'Press Enter to exit''"')
Line 934: Run('powershell.exe -Command "Get-Process | ... Read-Host ''Press Enter to exit''"')
```

**Causa:** Uso incorrecto de comillas simples anidadas dentro de comillas dobles en AutoHotkey v2.

## ✅ Solución Aplicada

### Problema de Comillas:
```autohotkey
; ❌ Incorrecto (causaba error de sintaxis):
Run('powershell.exe -Command "Get-Process | ... Read-Host ''Press Enter to exit''"')

; ✅ Correcto (usando backticks para escape):
Run("powershell.exe -Command `"Get-Process | ... Read-Host 'Press Enter to exit'`"")
```

### Cambios Realizados:
1. **Comillas externas:** `'...'` → `"..."`
2. **Comillas internas:** `"..."` → `` `"..."` ``
3. **Comillas anidadas:** `''..''` → `'...'`

## 📋 Comandos Corregidos

### ExecuteMonitoringCommand - 5 comandos:

**Processes (p):**
```autohotkey
; Antes:
Run('powershell.exe -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host ''Press Enter to exit''"')

; Después:
Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
```

**Services (s):**
```autohotkey
Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
```

**Disk Usage (d):**
```autohotkey
Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
```

**Memory (m):**
```autohotkey
Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
```

**CPU (c):**
```autohotkey
Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
```

## 🎯 Regla de Comillas en AutoHotkey v2

### Patrón Correcto para PowerShell:
```autohotkey
; Estructura general:
Run("powershell.exe -Command `"[comando PowerShell con 'comillas simples' internas]`"")

; Explicación:
; - Comillas dobles externas para AutoHotkey
; - Backticks para escapar comillas dobles internas
; - Comillas simples para strings dentro de PowerShell
```

### Ejemplos de Uso:
```autohotkey
; ✅ Correcto:
Run("powershell.exe -Command `"Write-Host 'Hello World'`"")
Run("powershell.exe -Command `"Get-Process | Where-Object {$_.Name -eq 'notepad'}`"")

; ❌ Incorrecto:
Run('powershell.exe -Command "Write-Host ''Hello World''"')
Run("powershell.exe -Command "Get-Process | Where-Object {$_.Name -eq 'notepad'}"")
```

## 📊 Estado Post-Corrección

### Funcionalidad:
- ✅ Todos los comandos PowerShell funcionan correctamente
- ✅ Sin errores de sintaxis
- ✅ Comandos de monitoreo completamente operativos
- ✅ Read-Host funciona para pausar salida

### Testing Requerido:
- [x] Leader → c → m → p (Top Processes)
- [x] Leader → c → m → s (Services)
- [x] Leader → c → m → d (Disk Usage)
- [x] Leader → c → m → m (Memory)
- [x] Leader → c → m → c (CPU Info)

## ✅ Estado Final

**Problema:** Completamente resuelto  
**Comandos PowerShell:** 100% funcionales  
**Sintaxis:** Correcta y validada  
**Capa Comandos:** Totalmente operativa

## 🎯 Lección Aprendida

**Para comandos PowerShell complejos en AutoHotkey v2:**
1. Usar comillas dobles externas
2. Usar backticks para escapar comillas internas
3. Usar comillas simples dentro de PowerShell
4. Probar sintaxis antes de implementar

### Patrón de Referencia:
```autohotkey
Run("powershell.exe -Command `"[PowerShell command with 'single quotes']`"")
```