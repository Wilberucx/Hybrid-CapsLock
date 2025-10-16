# Historial de Cambios

## v6.3 - MAJOR CONFIGURATION REFACTOR

- **🎨 Sistema de Tooltips Mejorado**: Reemplazo completo con C# + WPF estilo Nvim
  - Tooltips profesionales con colores personalizados y posicionamiento preciso
  - Aplicación independiente con comunicación JSON
  - Soporte para múltiples estados (Nvim, Visual, Yank, Excel)
- **🏗️ Sistema de Configuración Modular**: 5 archivos .ini especializados con 75+ opciones
- **🆕 configuration.ini**: Configuración principal con UI, rendimiento, seguridad y perfiles por aplicación
- **🆕 Configuración Dinámica**: Todos los menús y funciones ahora configurables sin tocar código
- **🔧 Funciones de Mouse Reubicadas**: Click izquierdo (`;`) y derecho (`'`) para mejor ergonomía
- **⚡ Sistema de Timestamps Avanzado**: 3 niveles de navegación con formatos ilimitados
- **🎯 Paleta de Comandos Completa**: Comandos PowerShell/CMD organizados por categorías
- **📝 Capa Information**: Snippets personales configurables con mapeo de teclas
- **🔧 Optimización de Rendimiento**: Gestión de memoria, caché y limpieza automática
- **🛡️ Configuración de Seguridad**: Controles de privacidad y backup automático

### Características Heredadas v6.1-6.2

- **📊 Capa Excel/Accounting**: Numpad completo + navegación WASD + atajos específicos
- **👁️ Modo Visual**: Indicador visual para el modo de selección en capa Nvim
- **🖱️ Scroll con Touchpad**: Funcionalidad trackball con `CapsLock + /`
- **🔧 Feedback Visual Mejorado**: Notificaciones consistentes y limpias

### Base Sólida v6.0

- **🔍 Búsqueda Automática**: Ejecutables via Windows Registry
- **🚀 Lanzador Robusto**: Manejo avanzado de errores y permisos
- **🛡️ Soporte Administrativo**: Ejecución como servicio de Windows
