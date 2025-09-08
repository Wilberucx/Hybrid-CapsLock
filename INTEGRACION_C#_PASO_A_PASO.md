# 🔷 GUÍA DE INTEGRACIÓN C# TOOLTIPS - PASO A PASO

## 📋 Estado Actual
- ✅ Aplicación C# compilada: `tooltip_csharp/bin/Debug/net6.0-windows/TooltipApp.exe`
- ✅ Archivo de integración v2 creado: `tooltip_csharp_integration.ahk`
- ✅ Demo de prueba creado: `tmp_rovodev_test_integration.ahk`

## 🚀 PASO 1: Probar la Integración

### Ejecutar Demo de Prueba:
```bash
# Ejecutar el archivo de demo
./tmp_rovodev_test_integration.ahk
```

**Hotkeys de prueba:**
- `F1` - Leader Menu
- `F2` - Program Menu  
- `F3` - Window Menu
- `F4` - Commands Menu
- `F5` - Test de notificaciones
- `F6` - Ocultar tooltip
- `F7` - Tooltip personalizado
- `F8` - Notificación simple
- `ESC` - Salir del demo

## 🔧 PASO 2: Integrar con HybridCapsLock.ahk

### 2.1 Incluir el archivo de integración
Agregar al inicio de `HybridCapsLock.ahk` (después de las variables globales):

```autohotkey
; Incluir integración C# tooltips
#Include tooltip_csharp_integration.ahk

; Iniciar aplicación tooltip al cargar el script
StartTooltipApp()
```

### 2.2 Reemplazar funciones de tooltip existentes

#### En la función `ShowLeaderModeMenu()` (línea ~1337):
```autohotkey
; ANTES:
ShowLeaderModeMenu() {
    menuText := "`n LEADER MODE `n"
    menuText .= "p - Programs`n"
    menuText .= "t - Timestamps`n" 
    menuText .= "c - Commands`n"
    menuText .= "i - Information`n"
    menuText .= "w - Windows`n"
    menuText .= "n - Excel/Numbers`n"
    menuText .= "`n\\\\ - Back | ESC - Exit`n"
    
    ToolTipX := A_ScreenWidth // 2 - 100
    ToolTipY := A_ScreenHeight // 2 - 100
    ToolTip(menuText, ToolTipX, ToolTipY)
}

; DESPUÉS:
ShowLeaderModeMenu() {
    ShowLeaderModeMenuCS()
}
```

#### En la función `ShowProgramMenu()` (línea ~2274):
```autohotkey
; ANTES:
ShowProgramMenu() {
    ; Program launcher menu - reads from programs.ini
    global ProgramsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 150
    menuText := "PROGRAM LAUNCHER`n`n"
    
    ; Read menu lines dynamically from programs.ini
    Loop 10 {
        lineContent := IniRead(ProgramsIni, "MenuDisplay", "line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            menuText .= lineContent . "`n"
        }
    }
    
    menuText .= "`n[\\: Back] [Esc: Exit]"
    ToolTip(menuText, ToolTipX, ToolTipY, 2)
}

; DESPUÉS:
ShowProgramMenu() {
    ShowProgramMenuCS()
}
```

#### En la función `ShowWindowMenu()` (línea ~344):
```autohotkey
; ANTES:
ShowWindowMenu() {
    ToolTipX := A_ScreenWidth // 2 - 110
    ToolTipY := A_ScreenHeight // 2 - 120
    menuText := "WINDOW MANAGER`n`n"
    menuText .= "SPLITS:`n"
    menuText .= "2 - Split 50/50    3 - Split 33/67`n"
    menuText .= "4 - Quarter Split`n`n"
    menuText .= "ACTIONS:`n"
    menuText .= "x - Close          m - Maximize`n"
    menuText .= "- - Minimize`n`n"
    menuText .= "ZOOM TOOLS:`n"
    menuText .= "d - Draw           z - Zoom`n"
    menuText .= "c - Zoom with cursor`n`n"
    menuText .= "WINDOW SWITCHING:`n"
    menuText .= "j/k - Persistent Window Switch`n`n"
    menuText .= "[\\: Back] [Esc: Exit]"
    ToolTip(menuText, ToolTipX, ToolTipY, 2)
}

; DESPUÉS:
ShowWindowMenu() {
    ShowWindowMenuCS()
}
```

### 2.3 Reemplazar notificaciones básicas

#### Reemplazar `ShowCenteredToolTip()`:
```autohotkey
; ANTES:
ShowCenteredToolTip("COPIED")

; DESPUÉS:
ShowCenteredToolTipCS("COPIED")
```

#### Reemplazar notificaciones específicas:
```autohotkey
; ANTES:
ShowCopyNotification() {
    ShowCenteredToolTip("COPIED")
    SetTimer(RemoveToolTip, -800)
}

; DESPUÉS:
ShowCopyNotification() {
    ShowCopyNotificationCS()
}
```

### 2.4 Limpiar tooltips al salir
Agregar al final del script:

```autohotkey
; Limpiar al salir
OnExit(CleanupTooltips)

CleanupTooltips(*) {
    StopTooltipApp()
}
```

## 🎨 PASO 3: Personalización Avanzada

### 3.1 Colores y Estilos
Los colores están definidos en `tooltip_csharp/MainWindow.xaml`:
- Fondo: `#1e1e1e` (oscuro)
- Borde: `#404040` (gris)
- Texto: `#ffffff` (blanco)
- Opciones: `#dbd6b9` (dorado)
- Navegación: `#6c958e` (verde)

### 3.2 Timeouts Personalizados
```autohotkey
; Tooltip con timeout personalizado (10 segundos)
ShowCSharpTooltip("CUSTOM MENU", "a:Action A|b:Action B", "ESC: Exit", 10000)
```

### 3.3 Navegación Personalizada
```autohotkey
; Navegación personalizada
navigation := "ENTER: Select|TAB: Next|SHIFT+TAB: Previous|ESC: Cancel"
ShowCSharpTooltip("ADVANCED MENU", items, navigation)
```

## 🔍 PASO 4: Verificación y Testing

### 4.1 Verificar que la aplicación C# esté ejecutándose:
```autohotkey
; Verificar proceso
if (ProcessExist("TooltipApp.exe")) {
    ShowCenteredToolTipCS("Tooltip app is running!")
} else {
    MsgBox("Tooltip app not found!")
}
```

### 4.2 Debug de JSON:
El archivo `tooltip_commands.json` se crea en el directorio del script. Puedes abrirlo para verificar que el JSON se esté generando correctamente.

## 🚨 Solución de Problemas

### Problema: La aplicación C# no inicia
**Solución:** Verificar que el ejecutable existe:
```autohotkey
if (!FileExist("tooltip_csharp\\bin\\Debug\\net6.0-windows\\TooltipApp.exe")) {
    MsgBox("TooltipApp.exe not found. Please compile the C# application first.")
}
```

### Problema: Los tooltips no aparecen
**Solución:** Verificar el archivo JSON:
```autohotkey
; Verificar si el archivo JSON se está creando
if (FileExist("tooltip_commands.json")) {
    Run("notepad.exe tooltip_commands.json")
}
```

### Problema: Tooltips no se ocultan
**Solución:** Llamar explícitamente a hide:
```autohotkey
; Forzar ocultar tooltip
HideCSharpTooltip()
```

## 📈 Beneficios de la Integración

1. **Diseño Profesional:** Tooltips con colores y tipografía consistentes
2. **Mejor Legibilidad:** Layout en columnas y espaciado optimizado
3. **Animaciones Suaves:** Transiciones y efectos visuales
4. **Click-through:** Los tooltips no interfieren con el mouse
5. **Always-on-top:** Siempre visibles sobre otras ventanas
6. **Timeouts Inteligentes:** Control preciso de duración
7. **Navegación Visual:** Indicadores claros de opciones disponibles

## 🎯 Próximos Pasos

1. **Ejecutar demo** con `tmp_rovodev_test_integration.ahk`
2. **Verificar funcionamiento** de todos los tooltips
3. **Integrar gradualmente** en `HybridCapsLock.ahk`
4. **Personalizar colores** si es necesario
5. **Optimizar timeouts** según preferencias
6. **Documentar cambios** realizados