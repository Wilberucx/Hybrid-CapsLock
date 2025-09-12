# Hybrid CapsLock - Sistema de Productividad Avanzado para AutoHotkey

Este script transforma la tecla `CapsLock` en una potente herramienta de productividad con un comportamiento híbrido, inspirado en la eficiencia de editores como Vim. Con más de 2300 líneas de código y un sistema de configuración modular de 5 archivos .ini, ofrece un entorno de trabajo completamente personalizable.

## ✨ Conceptos Clave

### 🔧 Modo Modificador (Mantener Pulsado)
Si **mantienes presionada `CapsLock`** y pulsas otra tecla, `CapsLock` actúa como una tecla modificadora (similar a `Ctrl`). Ideal para atajos rápidos y ergonómicos.

### 📝 Modo "Capa Nvim" (Toque Rápido)
Si **presionas y sueltas `CapsLock` rápidamente**, activas/desactivas la **Capa Nvim**. Un aviso visual te indicará el estado actual. Cuando está activa, muchas teclas adquieren funciones de navegación y edición estilo Vim.

### 🎯 Modo Líder (CapsLock + Space)
Accede a un menú contextual con sub-capas organizadas:
- **`w`** - Gestión de ventanas y herramientas de zoom
- **`p`** - Lanzador rápido de programas
- **`t`** - Herramientas de timestamp
- **`c`** - Paleta de comandos del sistema
- **`i`** - Información personal y snippets
- **`n`** - Capa Excel/Accounting persistente

## 🚀 Atajos Principales

### Gestión de Ventanas
| Atajo | Acción |
|-------|--------|
| `CapsLock + q` | Cerrar ventana |
| `CapsLock + f` | Maximizar/Restaurar |
| `CapsLock + Tab` | Navegador de ventanas mejorado |
| `CapsLock + 6/7` | Ajustar ventana izquierda/derecha |
| `CapsLock + F12` | Forzar cierre de proceso |

### Navegación Rápida
| Atajo | Acción |
|-------|--------|
| `CapsLock + h/j/k/l` | Flechas direccionales (estilo Vim) |
| `CapsLock + e/d` | Scroll suave abajo/arriba |
| `CapsLock + /` | Scroll con touchpad (modo trackball) |

### Edición de Texto
| Atajo | Acción |
|-------|--------|
| `CapsLock + s` | Guardar (`Ctrl+S`) |
| `CapsLock + c/v/x` | Copiar/Pegar/Cortar |
| `CapsLock + z` | Deshacer |
| `CapsLock + a` | Seleccionar todo |
| `CapsLock + o/t/w` | Abrir/Nueva pestaña/Cerrar pestaña |

### Funciones de Mouse
| Atajo | Acción |
|-------|--------|
| `CapsLock + ;` | Click izquierdo sostenido |
| `CapsLock + '` | Click derecho simple |

### Utilidades Especiales
| Atajo | Acción |
|-------|--------|
| `CapsLock + 5` | Copiar ruta/URL actual |
| `CapsLock + 9` | Captura de pantalla |
| `CapsLock + \` | Insertar email configurado |
| `CapsLock + F10` | Toggle CapsLock original |

## 📚 Documentación Detallada

### Funcionalidades Principales
- **[Modo Modificador](doc/MODIFIER_MODE.md)** - Todos los atajos con CapsLock mantenido
- **[Capa Nvim](doc/NVIM_LAYER.md)** - Navegación y edición estilo Vim
- **[Modo Líder](doc/LEADER_MODE.md)** - Menús contextuales y sub-capas
  - **[Capa Windows](doc/WINDOWS_LAYER.md)** - Gestión de ventanas y zoom
  - **[Capa Programas](doc/PROGRAM_LAYER.md)** - Lanzador de aplicaciones
  - **[Capa Timestamp](doc/TIMESTAMP_LAYER.md)** - Herramientas de fecha/hora
  - **[Capa Comandos](doc/COMMAND_LAYER.md)** - Paleta de comandos y utilidades del sistema
  - **[Capa Information](doc/INFORMATION_LAYER.md)** - Inserción rápida de información personal
  - **[Capa Excel](doc/EXCEL_LAYER.md)** - Capa especializada para Excel con numpad, navegación y atajos

### Instalación y Configuración
- **[Sistema de Configuración](doc/CONFIGURATION.md)** - Guía completa del sistema de configuración modular
- **[Integración de Tooltips](tooltip_csharp/README.md)** - Sistema de tooltips C# + WPF para mejor experiencia visual

## ⚙️ Instalación y Uso

### 📋 Versiones Disponibles
- **`HybridCapsLock.ahk`** - **Versión principal (AutoHotkey v2)** - ⭐ **RECOMENDADA**
  - Versión moderna con todas las características actualizadas
  - Mejor rendimiento y compatibilidad
  - Sistema de tooltips C# integrado
- **`HybridCapsLock_v1_[DEPRECATED].ahk`** - Versión legacy (AutoHotkey v1.1) - ⚠️ **DESACTUALIZADA**
  - Mantenida solo para compatibilidad
  - No incluye las últimas características
  - No recomendada para uso nuevo

### 🚀 Instalación (Recomendada)
1. **Requisito:** [AutoHotkey v2](https://www.autohotkey.com/) (para la versión principal)
2. **Ejecutar:** Doble click en `HybridCapsLock.ahk`
3. **Inicio automático:** Crear acceso directo en `shell:startup` para que inicie con Windows
4. **Configuración:** Los archivos en `config/` se crean automáticamente en la primera ejecución

### ⚡ Ejecución Directa (Sin Servicio)
- **Funcionamiento:** El script se ejecuta directamente sin necesidad de instalación como servicio
- **Compatibilidad:** Funciona con la mayoría de aplicaciones
- **Privilegios:** Para aplicaciones elevadas, ejecutar el script como administrador si es necesario

## 🔧 Configuración

### 📁 Sistema de Configuración Modular (Carpeta `config/`)
- **`config/configuration.ini`** - Configuración principal con 75+ opciones
  - UI y temas (tooltips, animaciones, posicionamiento)
  - Rendimiento (optimización, memoria, caché)
  - Seguridad (permisos, logging, backups)
  - Capas (habilitar/deshabilitar funcionalidades)
  - Perfiles por aplicación
- **`config/programs.ini`** - Lanzador de programas completamente configurable
  - Mapeo dinámico de teclas a programas
  - Rutas de ejecutables y variables de entorno
  - Tooltips personalizables
- **`config/timestamps.ini`** - Sistema de timestamps de 3 niveles
  - Formatos de fecha, hora y datetime ilimitados
  - Selección de formato por defecto
  - Timeouts de 20 segundos para mejor usabilidad
- **`config/commands.ini`** - Paleta de comandos jerárquica
  - Comandos personalizados PowerShell/CMD
  - Organización por categorías
  - Timeouts específicos por categoría
- **`config/information.ini`** - Información personal y snippets
  - Datos personales configurables
  - Mapeo de teclas personalizable
  - Soporte para texto multilínea

### ⚙️ Configuración Avanzada
Cada archivo `.ini` incluye secciones especializadas:
- **`[Settings]`** - Configuración específica de cada capa
- **`[MenuDisplay]`** - Personalización de tooltips y menús
- **`[ApplicationProfiles]`** - Comportamiento por aplicación
- **`[Advanced]`** - Funciones experimentales y optimización

### 🔧 Personalización
- **Por capa:** Cada archivo en `config/` controla una funcionalidad específica
- **Global:** `config/configuration.ini` para ajustes del sistema
- **Aplicaciones:** Perfiles específicos para diferentes programas
- **Tooltips:** Sistema C# integrado configurable desde `configuration.ini`
- **Datos:** Archivos de estado en `data/` (JSON para Zebar)

## 📊 Integración con Zebar

HybridCapsLock incluye integración nativa con [Zebar](https://github.com/glzr-io/zebar) para mostrar indicadores visuales del estado de las capas en tiempo real.

### 🎯 Indicadores Disponibles
- **NVIM** 📝 - Capa Nvim activa
- **EXCEL** 📊 - Capa Excel/Accounting activa  
- **VIS** 👁️ - Modo Visual activo
- **LEAD** 🎯 - Modo Líder activo (temporal)
- **YANK** ✂️ - Modo Yank en espera (temporal)

### ⚙️ Configuración Automática
El script genera automáticamente `layer_status.json` que se sincroniza con el widget de Zebar para mostrar el estado actual de todas las capas sin interrumpir el flujo de trabajo.

## 📋 Versión Actual: 6.3

### Novedades v6.3 - MAJOR CONFIGURATION REFACTOR:
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

### Características Heredadas v6.1-6.2:
- **📊 Capa Excel/Accounting**: Numpad completo + navegación WASD + atajos específicos
- **📱 Integración con Zebar**: Indicadores visuales en tiempo real del estado de las capas
- **👁️ Modo Visual**: Indicador visual para el modo de selección en capa Nvim
- **🖱️ Scroll con Touchpad**: Funcionalidad trackball con `CapsLock + /`
- **🔧 Feedback Visual Mejorado**: Notificaciones consistentes y limpias

### Base Sólida v6.0:
- **🔍 Búsqueda Automática**: Ejecutables via Windows Registry
- **🚀 Lanzador Robusto**: Manejo avanzado de errores y permisos
- **🛡️ Soporte Administrativo**: Ejecución como servicio de Windows

## 🚧 Características en Desarrollo

### 🔧 Sistema de Elevación de Privilegios (En Progreso)
- **Estado**: Implementación parcial disponible
- **Archivos**: Archivos de servicios elevados (eliminados por no ser necesarios)
- **Objetivo**: Compatibilidad completa con aplicaciones que requieren permisos de administrador
- **Desafíos actuales**:
  - Estabilidad del servicio de Windows con NSSM
  - Manejo de permisos entre procesos elevados y normales
  - Sincronización de estado entre instancias
- **Funcionalidad actual**: Instalación básica como servicio, requiere refinamiento

### ⚡ Funciones Experimentales (configuration.ini)
```ini
[Advanced]
hold_capslock_slash_scroll=false    ; Scroll con CapsLock+/ en modo Hold
nvim_shift_touchpad_scroll=false    ; Scroll con Shift en capa Nvim
```
- **Estado**: Implementación básica, puede interferir con funcionalidad normal
- **Advertencia**: Pueden afectar combinaciones de teclas estándar como Shift+letras

### 🎯 Próximas Mejoras Planificadas
- **Estabilización del servicio elevado**: Resolver problemas de sincronización
- **Mejora del scroll con touchpad**: Refinamiento de la detección de gestos
- **Temas visuales**: Sistema de temas para tooltips y notificaciones
- **Integración mejorada con Zebar**: Más indicadores y personalización
- **Backup automático**: Sistema robusto de respaldo de configuraciones

---

## ⚠️ Estado de Desarrollo

### Funcionalidades en Desarrollo:

**¿Necesitas ayuda?** Consulta la documentación detallada en la carpeta `doc/` o revisa los comentarios en el código fuente.