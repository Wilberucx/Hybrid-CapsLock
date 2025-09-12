# Changelog - HybridCapsLock

## v6.3.0 (2024-12-XX) - MAJOR CONFIGURATION REFACTOR

### 🏗️ **BREAKING CHANGES**
- **Configuration system completely restructured** - Modular .ini files replace single configuration
- **Mouse functions relocated** - Click functions moved from B/N keys to semicolon/quote
- **Timestamps system redesigned** - New 3-level navigation with unlimited formats
- **Programs layer centralized** - All program settings moved to dedicated configuration file

### ✨ **Added**
- **Sistema de Tooltips Mejorado (C# + WPF)** - Reemplazo completo de tooltips nativos de AutoHotkey
  - Tooltips estilo Nvim con diseño profesional y colores personalizados
  - Aplicación C# independiente (`TooltipApp.exe`) con comunicación JSON
  - Posicionamiento preciso (centro-inferior de pantalla)
  - Click-through habilitado y always-on-top para mejor experiencia
  - Soporte para múltiples estados: Nvim, Visual, Yank, Excel
  - Configuración completa desde `configuration.ini` (timeouts, animaciones, persistencia)
  - Scripts PowerShell especializados para cada capa de estado
  - Integración automática con inicialización del script principal
- **`configuration.ini`** - Comprehensive main configuration with 75+ settings
  - UI customization (tooltips, themes, animations)
  - Performance optimization settings
  - Security and privacy controls
  - Layer enable/disable toggles
  - Application-specific profiles
  - Advanced experimental features
- **`programs.ini`** - Complete Programs Layer configuration
  - Dynamic program mapping from configuration file
  - Centralized tooltip management
  - Easy program addition without code changes
  - Support for complex paths and environment variables
- **`timestamps.ini`** - Advanced timestamp configuration
  - Configurable date, time, and datetime formats
  - Default format selection per category
  - 20-second timeouts for better usability
  - 3-level navigation: Type → Format → Insert
- **`commands.ini`** - Commands Layer configuration
  - Custom command definitions
  - Category organization
  - Timeout settings per category
  - PowerShell and CMD command support
- **`information.ini`** - Personal Information Layer configuration
  - Personal snippets and data
  - Custom key mappings
  - Multi-line text support
- **Enhanced mouse functionality**
  - `CapsLock + ;` - Left click hold (perfect for drag & drop)
  - `CapsLock + '` - Right click (context menus)
  - Improved click duration control
- **Advanced system integration**
  - Zebar status integration with JSON export
  - Application-specific behavior profiles
  - Memory management and performance optimization
  - Automatic configuration backup system
- **Improved navigation**
  - Backspace support for going back in menus
  - Extended timeouts for complex operations
  - Better error messages with file references
  - Escape key support throughout all menus

### 🔄 **Changed**
- **Sistema de Tooltips**
  - Old: Tooltips nativos de AutoHotkey con limitaciones de diseño y posicionamiento
  - New: Sistema C# + WPF con tooltips profesionales estilo Nvim
  - Mejor control visual, colores personalizados y comunicación JSON
  - Soporte para estados múltiples y configuración avanzada
- **Configuration architecture**
  - Old: Single configuration file with limited options
  - New: Modular system with 5 specialized .ini files
  - Established pattern for layer-specific configurations
  - Clear separation of concerns
- **Programs Layer workflow**
  - Old: Hardcoded program list requiring code changes
  - New: Fully configurable via `programs.ini` with dynamic loading
- **Timestamps Layer workflow**
  - Old: `leader → t → d/h/s` (3 fixed formats)
  - New: `leader → t → d/t/h → number/default` (unlimited formats)
- **Mouse functions**
  - Old: `CapsLock + b/n` for mouse clicks
  - New: `CapsLock + ;/'` for better ergonomics
- **System performance**
  - Optimized hotkey processing
  - Memory cleanup intervals
  - Cached program paths for faster launches

### 🗑️ **Removed**
- **Hardcoded program mappings** - Now fully configurable
- **Fixed timestamp formats** - Replaced with unlimited configurable system
- **Mouse functions on B/N keys** - Relocated to semicolon/quote keys
- **Single configuration file** - Split into specialized modules

### 🐛 **Fixed**
- **Mouse click conflicts** - Separated left/right click to different keys
- **Program launcher reliability** - Better error handling and user feedback
- **Tooltip updates** - Dynamic generation from configuration files
- **Memory leaks** - Implemented automatic cleanup routines
- **Configuration validation** - Better error handling for invalid settings

### 📁 **New File Structure**
```
HybridCapsLock.ahk          # Main script (2300+ lines)
tooltip_csharp_integration.ahk # C# tooltip system integration
config/                     # Configuration files directory
  ├── configuration.ini     # Main configuration (130+ settings)
  ├── programs.ini          # Programs Layer configuration
  ├── timestamps.ini        # Timestamps Layer configuration
  ├── commands.ini          # Commands Layer configuration
  └── information.ini       # Information Layer configuration
data/                       # Runtime data files
  ├── layer_status.json     # Zebar integration status
  └── menu_status.json      # Menu state tracking
tooltip_csharp/             # C# tooltip application
  ├── TooltipApp.exe        # Compiled C# application
  ├── StatusWindow_*.ps1    # PowerShell scripts for each layer
  ├── *.xaml               # WPF interface definitions
  └── Models/               # C# data models
doc/                        # Comprehensive documentation
```

### 🔧 **Migration Guide**
1. **Configuration**: Settings now organized in `config/` directory
2. **Programs**: Edit `config/programs.ini` instead of modifying script code
3. **Timestamps**: Use new 3-level navigation system
4. **Mouse**: Update muscle memory for new `;` and `'` click functions
5. **Commands**: Customize command palette via `config/commands.ini`
6. **File Organization**: All .ini files moved to `config/`, JSON files to `data/`

### 🎯 **Benefits**
- **Easier maintenance** - No code changes needed for common customizations
- **Better organization** - Clear separation of layer configurations  
- **Scalable architecture** - Pattern established for future layers
- **User-friendly** - Better error messages and longer timeouts
- **More powerful** - Unlimited format configurations and advanced settings
- **Performance optimized** - Memory management and caching systems
- **Highly customizable** - 75+ configuration options across all layers

### 🚧 **Known Issues & In Development**
- **Elevated Service System** - Partial implementation available but requires stability improvements
  - Files: Archivos de servicios elevados (eliminados por no ser necesarios)
  - Issues: Sistema de servicios elevados removido por complejidad innecesaria
  - Status: Basic installation works, needs refinement for production use
- **Experimental Scroll Features** - Basic implementation with potential interference
  - `hold_capslock_slash_scroll` and `nvim_shift_touchpad_scroll` in configuration.ini
  - May affect normal Shift+letter combinations when enabled
  - Recommended to keep disabled until further development

### 🔮 **Future Roadmap**
- Sistema de servicios elevados removido - usar ejecución directa del script
- Improve touchpad scroll gesture detection and reliability
- Implement visual theme system for tooltips and notifications
- Enhance Zebar integration with more status indicators
- Develop robust automatic configuration backup system

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