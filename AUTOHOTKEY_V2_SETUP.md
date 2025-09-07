# 🔧 Configuración de AutoHotkey v2

## ❗ Problema Identificado

**Causa raíz de los errores:** Probablemente estamos ejecutando el script con AutoHotkey v1 en lugar de v2, por eso la sintaxis v2 no funciona.

## 🔍 Verificar Versión Actual

### Método 1: Desde Windows
1. Hacer clic derecho en `HybridCapsLock_v2.ahk`
2. Seleccionar "Compile Script" o "Run Script"
3. Ver qué versión se ejecuta

### Método 2: Script de Verificación
Crear un archivo `version_check.ahk`:
```autohotkey
MsgBox("AutoHotkey Version: " . A_AhkVersion, "Version Check")
ExitApp()
```

## 📥 Instalar AutoHotkey v2

### Opción 1: Descarga Oficial
1. Ir a: https://www.autohotkey.com/
2. Descargar **AutoHotkey v2** (NO v1.1)
3. Instalar normalmente

### Opción 2: Winget (Recomendado)
```cmd
winget install AutoHotkey.AutoHotkey
```

### Opción 3: Chocolatey
```cmd
choco install autohotkey
```

## ⚙️ Configurar v2 como Predeterminado

### Si tienes ambas versiones instaladas:
1. Hacer clic derecho en archivo `.ahk`
2. "Abrir con" → "Elegir otra aplicación"
3. Buscar `AutoHotkey64.exe` (v2) en:
   - `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
   - O la ubicación donde instalaste v2

## 🧪 Probar Instalación

### Script de Prueba v2:
```autohotkey
#SingleInstance Force
#Warn All

; Verificar que estamos en v2
if (SubStr(A_AhkVersion, 1, 1) != "2") {
    MsgBox("ERROR: Ejecutándose en v" . A_AhkVersion . " - Necesita v2", "Error", "IconX")
    ExitApp()
}

; Test sintaxis v2
MsgBox("✅ AutoHotkey v2 funcionando correctamente!`nVersión: " . A_AhkVersion, "Éxito", "IconI")
ExitApp()
```

## 🔄 Solución Temporal: Versión v1

Si no puedes instalar v2 ahora, podemos crear una versión v1 del script:

### Opción A: Mantener v2 (Recomendado)
- Instalar AutoHotkey v2
- Usar nuestro script actual

### Opción B: Retroceder a v1
- Convertir el script de vuelta a sintaxis v1
- Menos eficiente pero funcional

## 📋 Próximos Pasos

1. **Verificar versión actual** de AutoHotkey
2. **Instalar v2** si es necesario
3. **Probar script de verificación**
4. **Continuar con Fase 3** una vez confirmado v2

## ❓ ¿Qué prefieres hacer?

- 🚀 **Instalar AutoHotkey v2** y continuar con migración
- 🔄 **Crear versión v1** como respaldo
- 🔍 **Verificar instalación actual** primero