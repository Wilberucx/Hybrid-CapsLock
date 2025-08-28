# Changelog - HybridCapsLock

## v7.0.0 (2024-12-XX) - MAJOR ARCHITECTURE REFACTOR

### 🏗️ **BREAKING CHANGES**
- **Configuration files restructured** - Layer-specific configurations moved to dedicated files
- **Timestamps system completely redesigned** - New 3-level navigation system
- **Programs configuration centralized** - All program settings now in single file

### ✨ **Added**
- **`programs.ini`** - Centralized configuration for Programs Layer
  - Dynamic program mapping from configuration file
  - Centralized tooltip management
  - Easy program addition without code changes
- **`timestamps.ini`** - Comprehensive timestamp configuration
  - Configurable date, time, and datetime formats
  - Default format selection per category
  - 20-second timeouts for better usability
  - 3-level navigation: Type → Format → Insert
- **`general.ini`** - General application settings (replaces HybridCapsLock.ini)
- **Enhanced mouse functionality**
  - `CapsLock + b` - Left click hold (perfect for drag & drop)
  - `CapsLock + n` - Right click (context menus)
- **Improved navigation**
  - Backspace support for going back in menus
  - Extended timeouts for complex operations
  - Better error messages with file references

### 🔄 **Changed**
- **Programs Layer workflow**
  - Old: Hardcoded program list requiring code changes
  - New: Fully configurable via `programs.ini`
- **Timestamps Layer workflow**
  - Old: `CapsLock + Space → t → d/h/s` (limited formats)
  - New: `CapsLock + Space → t → d/t/h → number/default` (unlimited formats)
- **Configuration architecture**
  - Established pattern for layer-specific configuration files
  - Clear separation of concerns
  - Better documentation and examples

### 🗑️ **Removed**
- **Hardcoded program mappings** - Now fully configurable
- **Fixed timestamp formats** - Replaced with configurable system
- **HybridCapsLock.ini** - Renamed to `general.ini` for consistency

### 🐛 **Fixed**
- **Mouse click conflicts** - Separated left/right click to different keys
- **Program launcher reliability** - Better error handling and user feedback
- **Tooltip updates** - Dynamic generation from configuration files

### 📁 **New File Structure**
```
HybridCapsLock.ahk          # Main script
general.ini                 # General settings
programs.ini                # Programs Layer configuration
timestamps.ini              # Timestamps Layer configuration
layer_status.json           # Zebar integration
menu_selection.json         # Menu state
menu_status.json           # Menu status
doc/                       # Documentation
```

### 🔧 **Migration Guide**
1. **Programs**: Edit `programs.ini` instead of modifying script code
2. **Timestamps**: Use new 3-level navigation system
3. **Configuration**: General settings moved to `general.ini`

### 🎯 **Benefits**
- **Easier maintenance** - No code changes needed for common customizations
- **Better organization** - Clear separation of layer configurations
- **Scalable architecture** - Pattern established for future layers
- **User-friendly** - Better error messages and longer timeouts
- **More powerful** - Unlimited format configurations

---

## v6.1 (2025-08-23)

### 🆕 Nuevas Características

#### Capa Excel/Accounting
- **Nueva capa persistente** especializada para trabajo con hojas de cálculo
- **Numpad completo** con distribución ergonómica (7-8-9, u-i-o, j-k-l)
- **Navegación WASD** para movimiento fluido entre celdas
- **Atajos específicos de Excel**: Ctrl+Enter, F2, Ctrl+F, Ctrl+R, etc.
- **Operaciones matemáticas**: +, -, /, coma y punto decimal del numpad

#### Integración con Zebar
- **Indicadores visuales en tiempo real** del estado de las capas
- **Estilo minimalista** que se integra perfectamente con widgets existentes
- **Actualización automática** cada 500ms sin impacto en rendimiento
- **Sincronización automática** mediante archivo JSON

#### Modo Visual Mejorado
- **Indicador visual** para el modo de selección en capa Nvim
- **Activación con `m`** en capa Nvim
- **Integración completa** con sistema de notificaciones

### 🔧 Mejoras

#### Sistema de Notificaciones
- **Feedback visual consistente** para todas las capas
- **Notificaciones limpias** sin colores distractivos
- **Integración automática** con Zebar cuando está disponible

#### Documentación
- **README actualizado** con nuevas características
- **Documentación completa** de la capa Excel
- **Guías de integración** con Zebar
- **Changelog detallado** para seguimiento de cambios

### 🐛 Correcciones
- **Sintaxis AutoHotkey v1.1**: Corregido `EnvGet()` por sintaxis correcta
- **Referencias de documentación**: Actualizadas todas las referencias obsoletas
- **Consistencia de nombres**: Unificado "Capa Excel" en toda la documentación

---

## v6.0 (Anterior)

### Características Base
- Búsqueda automática de ejecutables via Windows Registry
- Mejoras en el lanzador de programas
- Soporte robusto para ejecución como administrador
- Sistema de capas Nvim y modo líder
- Gestión avanzada de ventanas
- Herramientas de timestamp

---

**Nota**: Este changelog documenta los cambios desde la implementación de la integración con Zebar y la capa Excel.