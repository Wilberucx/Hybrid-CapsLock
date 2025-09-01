# Sistema de Configuración de HybridCapsLock

HybridCapsLock utiliza un sistema de configuración modular basado en archivos `.ini` que permite personalizar cada aspecto del comportamiento del script.

## 📁 Estructura de Configuración

### 🎛️ Archivo Principal: `configuration.ini`
Contiene la configuración global y comportamientos generales del script.

#### Secciones Principales:

**`[General]` - Configuración Básica**
```ini
script_version=6.3
auto_start_with_windows=true
run_as_service=false
enable_zebar_integration=true
debug_mode=false
```

**`[UI]` - Interfaz y Feedback Visual**
```ini
tooltip_font_size=12
tooltip_duration_default=1500
tooltip_position=center
show_layer_indicators=true
use_animations=true
theme=default
```

**`[Behavior]` - Comportamiento Global**
```ini
caps_lock_acts_normal=false
global_timeout_seconds=7
leader_timeout_seconds=7
enable_smooth_scrolling=true
scroll_sensitivity=3
mouse_click_duration=50
```

**`[Layers]` - Control de Capas**
```ini
nvim_layer_enabled=true
excel_layer_enabled=true
modifier_layer_enabled=true
leader_layer_enabled=true
enable_layer_persistence=true
```

### 📋 Archivos de Capa Específicos

#### `programs.ini` - Configuración del Lanzador
```ini
[Settings]
timeout_seconds=7
show_confirmation=true
auto_launch=true
search_in_path=true
show_launch_feedback=true
feedback_duration=2000
```

#### `timestamps.ini` - Configuración Temporal
```ini
[Settings]
timeout_seconds=20
show_confirmation=true
auto_insert=true
preview_format=true
remember_last_format=true
feedback_duration=1500
```

#### `commands.ini` - Configuración de Comandos
```ini
[Settings]
show_output=true
close_on_success=false
timeout_seconds=30
enable_custom_commands=true

[CategorySettings]
system_timeout=10
network_timeout=10
git_timeout=10
show_execution_feedback=true
feedback_duration=1500
auto_close_terminals=false
```

#### `information.ini` - Configuración de Información
```ini
[Settings]
timeout_seconds=10
show_confirmation=true
auto_paste=true
```

## 🔧 Personalización Avanzada

### ⏱️ Timeouts Personalizables
Cada capa puede tener su propio timeout:
- **Global:** `configuration.ini` → `[Behavior]` → `global_timeout_seconds`
- **Líder:** `configuration.ini` → `[Behavior]` → `leader_timeout_seconds`
- **Por capa:** Cada archivo `.ini` → `[Settings]` → `timeout_seconds`

### 🎨 Feedback Visual Configurable
- **Duración:** `feedback_duration` en milisegundos
- **Confirmación:** `show_confirmation` para mostrar/ocultar tooltips
- **Posición:** `tooltip_position` en `configuration.ini`

### 🚀 Optimización de Rendimiento
```ini
[Performance]
enable_hotkey_optimization=true
memory_cleanup_interval=300000
max_tooltip_instances=3
enable_fast_startup=true
cache_program_paths=true
```

### 🔒 Configuración de Seguridad
```ini
[Security]
allow_elevated_apps=true
log_keystrokes=false
encrypt_personal_info=false
auto_backup_config=true
backup_retention_days=30
```

## 🎯 Casos de Uso Comunes

### 🏢 Configuración Empresarial
```ini
; configuration.ini
[Security]
log_keystrokes=false
encrypt_personal_info=true
allow_elevated_apps=false

[Behavior]
global_timeout_seconds=5
leader_timeout_seconds=5

; programs.ini
[Settings]
timeout_seconds=5
show_launch_feedback=false
auto_launch=false
```

### 🏠 Configuración Personal
```ini
; configuration.ini
[UI]
tooltip_duration_default=2000
show_layer_indicators=true
use_animations=true

[Behavior]
global_timeout_seconds=10
enable_smooth_scrolling=true

; information.ini
[Settings]
timeout_seconds=15
show_confirmation=true
auto_paste=true
```

### 👨‍💻 Configuración de Desarrollador
```ini
; configuration.ini
[Advanced]
verbose_logging=true
experimental_features=true
debug_mode=true

; commands.ini
[CategorySettings]
git_timeout=15
show_execution_feedback=true
auto_close_terminals=false
```

## 🔄 Jerarquía de Configuración

El sistema sigue esta jerarquía (de mayor a menor prioridad):

1. **Configuración específica de capa** (`[Settings]` en archivos de capa)
2. **Configuración global** (`configuration.ini`)
3. **Valores por defecto** (hardcodeados en el script)

### Ejemplo de Jerarquía:
```
Timeout para Programs Layer:
1. programs.ini → [Settings] → timeout_seconds=7
2. configuration.ini → [Behavior] → global_timeout_seconds=5
3. Valor por defecto → 7 segundos

Resultado: 7 segundos (usa el valor específico de la capa)
```

## 🛠️ Funciones de Configuración en el Script

El script incluye funciones helper para leer configuraciones:

```autohotkey
; Leer valor de configuration.ini
timeout := ReadConfigValue("Behavior", "global_timeout_seconds", 7)

; Leer configuración específica de capa
duration := ReadLayerSettings(ProgramsIni, "feedback_duration", 1500)

; Obtener timeout con jerarquía automática
layerTimeout := GetLayerTimeout("programs")

; Verificar si una capa está habilitada
if (IsLayerEnabled("nvim")) {
    ; Activar funcionalidad Nvim
}
```

## 🔧 Solución de Problemas

### ❌ Configuración no se aplica
1. Verifica la sintaxis del archivo `.ini`
2. Asegúrate de que la sección existe: `[Settings]`
3. Reinicia el script para aplicar cambios globales

### ❌ Valores no válidos
1. Usa solo números para timeouts y duraciones
2. Usa `true`/`false` para valores booleanos
3. No uses comillas en los valores

### ❌ Archivo de configuración faltante
1. El script creará archivos por defecto si no existen
2. Copia los ejemplos de la documentación
3. Verifica permisos de escritura en el directorio

## 📋 Lista de Verificación de Configuración

- [ ] `configuration.ini` existe y tiene configuración básica
- [ ] Cada archivo de capa tiene sección `[Settings]`
- [ ] Timeouts están en segundos (números enteros)
- [ ] Duraciones están en milisegundos
- [ ] Valores booleanos usan `true`/`false`
- [ ] No hay caracteres especiales en nombres de sección
- [ ] Backup de configuración realizado antes de cambios

---

**¿Necesitas ayuda con la configuración?** Consulta los archivos de ejemplo o revisa la documentación específica de cada capa.