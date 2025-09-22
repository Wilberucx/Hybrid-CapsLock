# 📚 Documentación de HybridCapsLock

Esta carpeta contiene toda la documentación detallada de HybridCapsLock.

## 🎯 Funcionalidades Principales

### Modos de Operación

- **[Modo Modificador](MODIFIER_MODE.md)** - Todos los atajos con CapsLock mantenido
- **[Capa Nvim](NVIM_LAYER.md)** - Navegación y edición estilo Vim
- **[Modo Líder](LEADER_MODE.md)** - Menús contextuales y sub-capas

### Capas Especializadas

- **[Capa Windows](WINDOWS_LAYER.md)** - Gestión de ventanas y zoom
- **[Capa Programas](PROGRAM_LAYER.md)** - Lanzador de aplicaciones
- **[Capa Timestamp](TIMESTAMP_LAYER.md)** - Herramientas de fecha/hora
- **[Capa Excel](EXCEL_LAYER.md)** - Capa especializada para Excel con numpad, navegación y atajos

## ⚙️ Instalación y Configuración

### Instalación Avanzada

- Instalación como servicio: próximamente (documento en preparación)

## 🔗 Enlaces Rápidos

- [Pruebas Manuales](MANUAL_TESTS.md) - Checklist de pruebas manuales

- [README Principal](../README.md) - Documentación principal del proyecto
- [Changelog](../CHANGELOG.md) - Historial de cambios y versiones
- [Configuración de Programas](../config/programs.ini) - Configurar aplicaciones del lanzador
- [Configuración General](../config/configuration.ini) - Configuraciones generales
- [Configuración de Timestamps](../config/timestamps.ini) - Configurar herramientas de fecha/hora

## 🛠️ Cómo configurar

1) Configuración global
- Abre config/configuration.ini y ajusta:
  - [Behavior]: timeouts globales (global_timeout_seconds, leader_timeout_seconds), smooth scrolling, confirmación global (show_confirmation_global)
  - [Layers]: activar/desactivar capas (nvim/excel/modifier/leader) y persistencia
  - [Tooltips]: enable_csharp_tooltips, options_menu_timeout, status_notification_timeout, persistent_menus, tooltip_fade_animation, tooltip_click_through
- Guía: ver doc/CONFIGURATION.md (secciones [Behavior], [Layers], [Tooltips])

2) Configuración por capa
- Programs: doc/PROGRAM_LAYER.md → editar config/programs.ini (Settings, ProgramMapping, MenuDisplay)
  - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md
- Information: doc/INFORMATION_LAYER.md → editar config/information.ini (PersonalInfo, InfoMapping, MenuDisplay)
  - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md
- Timestamps: doc/TIMESTAMP_LAYER.md → editar config/timestamps.ini (DateFormats/TimeFormats/DateTimeFormats, MenuDisplay, Settings)
  - Confirmaciones: ver sección “Confirmaciones en Timestamps” y el modelo en CONFIGURATION.md
- Commands: doc/COMMAND_LAYER.md → editar config/commands.ini (MenuDisplay, Settings, CategorySettings, Confirmations)
  - Confirmaciones: ver “Precedencia de Confirmación (Commands)” y el modelo en CONFIGURATION.md
- Windows/Nvim/Excel: ver docs de capa; confirmaciones no aplican

3) Timeouts y Tooltips
- Timeouts jerárquicos: por capa en cada *.ini (Settings.timeout_seconds), líder y global en configuration.ini. Ver doc/CONFIGURATION.md → “Timeouts jerárquicos (InputHook)”
- Tooltips C#: ajustar [Tooltips] en configuration.ini; ver doc/CONFIGURATION.md → “Tooltips (C#) configurables”

4) Aplicar cambios
- Recarga desde el propio script (sin reiniciar Windows): leader → c → h → R (Hybrid Management → Reload Script)
- Alternativamente, recarga configuración ligera con la opción de reload correspondiente si está disponible

5) Verificar
- Abre el menú líder y recorre cada capa para validar tooltips, timeouts y confirmaciones según tu configuración

## 🚀 Inicio Rápido

1. **Instalación básica**: Ejecutar `HybridCapsLock.ahk`
2. **Instalación**: Ejecutar directamente el script principal
3. **Personalización**: Editar archivos `.ini` según necesidades
4. **Documentación específica**: Consultar archivos individuales para cada funcionalidad

