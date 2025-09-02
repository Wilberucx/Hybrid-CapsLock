# Integración con Obsidian - HybridCapsLock

## Descripción

Esta funcionalidad permite importar los hotkeys de Obsidian (desde el archivo `hotkeys.json`) y convertirlos automáticamente a hotkeys compatibles con el sistema HybridCapsLock de AutoHotkey.

## Características

- ✅ **Importación automática** del archivo `hotkeys.json` de Obsidian
- ✅ **Conversión inteligente** de combinaciones de teclas de Obsidian a AutoHotkey
- ✅ **Filtros configurables** para incluir/excluir comandos específicos
- ✅ **Mapeo personalizable** de teclas modificadoras
- ✅ **Acciones personalizadas** para comandos específicos
- ✅ **Generación automática** de código AutoHotkey
- ✅ **Sistema de respaldo** y logs de importación
- ✅ **Integración completa** con el menú Leader de HybridCapsLock

## Instalación y Configuración

### Paso 1: Exportar hotkeys de Obsidian

1. Abre Obsidian
2. Ve a `Settings` → `Hotkeys`
3. Exporta tu configuración de hotkeys (esto genera un archivo `hotkeys.json`)
4. Copia el archivo `hotkeys.json` a la carpeta `data/` de HybridCapsLock
5. Renómbralo a `obsidian_hotkeys.json`

### Paso 2: Configurar la integración

Edita el archivo `config/obsidian_hotkeys.ini` para personalizar:

- **Mapeo de teclas modificadoras**
- **Filtros de comandos**
- **Acciones personalizadas**
- **Configuraciones de importación**

### Paso 3: Importar hotkeys

1. Presiona `CapsLock + Space` (Leader Mode)
2. Presiona `o` (Obsidian Integration)
3. Presiona `i` (Import Hotkeys)

## Uso

### Acceso al menú de Obsidian

```
CapsLock + Space → o
```

### Opciones disponibles

- `i` - **Import Obsidian Hotkeys**: Importa hotkeys desde `obsidian_hotkeys.json`
- `s` - **Show Import Status**: Muestra el estado de la última importación
- `r` - **Reload Hotkeys**: Recarga los hotkeys importados
- `c` - **Clear Imported Hotkeys**: Limpia los hotkeys importados
- `e` - **Edit Mappings**: Abre el archivo de configuración para editar

## Configuración Avanzada

### Mapeo de Teclas Modificadoras

En `[KeyMapping]`:
```ini
Mod=CapsLock          ; Obsidian "Mod" → CapsLock en AutoHotkey
Alt=Alt               ; Alt permanece como Alt
Shift=Shift           ; Shift permanece como Shift
Ctrl=Ctrl             ; Ctrl permanece como Ctrl
```

### Filtros de Comandos

En `[FilterRules]`:
```ini
; Incluir solo estos patrones de comandos
include_commands=editor:*|workspace:*|app:*

; Excluir estos patrones de comandos
exclude_commands=developer:*|editor:toggle-spellcheck

; Excluir estas combinaciones de teclas
exclude_keys=F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12
```

### Acciones Personalizadas

En `[CustomActions]`:
```ini
editor:toggle-bold=Send, ^b
editor:toggle-italic=Send, ^i
app:go-back=Send, !{Left}
workspace:split-vertical=GoSplitScreen(50)
command-palette:open=Send, ^+p
```

### Mapeo de Comandos

En `[CommandMapping]`:
```ini
editor:toggle-bold=SendBold
workspace:split-vertical=SplitVertical
app:go-back=NavigateBack
```

## Ejemplos de Conversión

### Ejemplo 1: Toggle Bold
**Obsidian JSON:**
```json
"editor:toggle-bold": [
  {
    "modifiers": ["Mod"],
    "key": "b"
  }
]
```

**AutoHotkey generado:**
```autohotkey
; editor:toggle-bold
CapsLock & b::
    Send, ^b
return
```

### Ejemplo 2: Split Vertical
**Obsidian JSON:**
```json
"workspace:split-vertical": [
  {
    "modifiers": ["Mod"],
    "key": "\\"
  }
]
```

**AutoHotkey generado:**
```autohotkey
; workspace:split-vertical
CapsLock & \::
    GoSplitScreen(50)
return
```

### Ejemplo 3: Command Palette
**Obsidian JSON:**
```json
"command-palette:open": [
  {
    "modifiers": ["Mod", "Shift"],
    "key": "p"
  }
]
```

**AutoHotkey generado:**
```autohotkey
; command-palette:open
CapsLock & +p::
    Send, ^+p
return
```

## Comandos Soportados

### Comandos de Editor
- `editor:toggle-bold` → Negrita
- `editor:toggle-italic` → Cursiva
- `editor:open-search` → Buscar
- `editor:open-search-replace` → Buscar y reemplazar
- `editor:save-file` → Guardar archivo
- `editor:toggle-source` → Alternar modo fuente

### Comandos de Workspace
- `workspace:split-vertical` → División vertical
- `workspace:split-horizontal` → División horizontal
- `workspace:close-tab` → Cerrar pestaña
- `workspace:new-tab` → Nueva pestaña
- `workspace:next-tab` → Siguiente pestaña
- `workspace:previous-tab` → Pestaña anterior

### Comandos de Aplicación
- `app:go-back` → Navegar atrás
- `app:go-forward` → Navegar adelante
- `app:toggle-left-sidebar` → Alternar barra lateral izquierda
- `app:toggle-right-sidebar` → Alternar barra lateral derecha
- `app:reload` → Recargar aplicación

### Comandos de Navegación
- `command-palette:open` → Abrir paleta de comandos
- `quick-switcher:open` → Abrir intercambiador rápido
- `global-search:open` → Abrir búsqueda global
- `graph:open` → Abrir vista de grafo

## Archivos Generados

### `generated_obsidian_hotkeys.ahk`
Contiene todos los hotkeys convertidos de Obsidian a AutoHotkey.

### `data/obsidian_import.log`
Log detallado del proceso de importación con errores y estadísticas.

### Respaldos automáticos
Se crean automáticamente respaldos con timestamp de archivos anteriores.

## Solución de Problemas

### Error: "obsidian_hotkeys.json not found"
- Verifica que el archivo esté en la carpeta `data/`
- Asegúrate de que el nombre sea exactamente `obsidian_hotkeys.json`

### Error: "Invalid JSON format"
- Verifica que el archivo JSON sea válido
- Usa un validador JSON online para verificar la sintaxis

### Error: "No valid hotkeys found"
- Revisa los filtros en `[FilterRules]`
- Verifica que los comandos no estén siendo excluidos

### Los hotkeys no funcionan
- Reinicia el script HybridCapsLock
- Verifica que Obsidian esté activo
- Revisa el archivo `generated_obsidian_hotkeys.ahk`

## Personalización Avanzada

### Crear acciones personalizadas
```ini
[CustomActions]
mi-comando-personalizado=MiFuncionPersonalizada()
```

### Filtros complejos con wildcards
```ini
[FilterRules]
include_commands=editor:toggle-*|workspace:split-*
exclude_commands=*:debug-*|*:developer-*
```

### Mapeo de teclas especiales
```ini
[KeyMapping]
Mod=CapsLock
Meta=Win
Super=Win
```

## Compatibilidad

- ✅ AutoHotkey v1.1+
- ✅ Windows 10/11
- ✅ Obsidian v0.15.0+
- ✅ Todas las versiones de HybridCapsLock v6.3+

## Contribuir

Para reportar bugs o sugerir mejoras, por favor:
1. Revisa los logs en `data/obsidian_import.log`
2. Incluye tu configuración de `obsidian_hotkeys.ini`
3. Proporciona el archivo `obsidian_hotkeys.json` problemático

---

**¡Disfruta de la integración perfecta entre Obsidian y HybridCapsLock!** 🚀