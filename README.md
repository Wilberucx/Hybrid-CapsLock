# Hybrid CapsLock - Script de Productividad para AutoHotkey

Este script transforma la tecla `CapsLock` en una potente herramienta de productividad con un comportamiento híbrido, inspirado en la eficiencia de editores como Vim.

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

### Navegación Rápida
| Atajo | Acción |
|-------|--------|
| `CapsLock + h/j/k/l` | Flechas direccionales |

### Edición de Texto
| Atajo | Acción |
|-------|--------|
| `CapsLock + s` | Guardar (`Ctrl+S`) |
| `CapsLock + c/v/x` | Copiar/Pegar/Cortar |
| `CapsLock + z` | Deshacer |

### Funciones de Mouse
| Atajo | Acción |
|-------|--------|
| `CapsLock + ;` | Click izquierdo sostenido |
| `CapsLock + '` | Click derecho simple |
| `CapsLock + Shift` | Scroll con touchpad (mantener `Shift` presionado) |

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
- **[Instalación como Servicio](doc/SERVICE_INSTALLATION.md)** - Servicio de Windows para compatibilidad completa

## ⚙️ Instalación y Uso

### Opción A: Ejecución Normal
1. **Requisito:** [AutoHotkey v1.1+](https://www.autohotkey.com/)
2. **Ejecutar:** Doble click en `HybridCapsLock.ahk`
3. **Inicio automático:** Crear acceso directo en `shell:startup`

### Opción B: Servicio de Windows (Recomendado)
1. **Requisito:** [AutoHotkey v1.1+](https://www.autohotkey.com/)
2. **Instalación:** Clic derecho en `install_elevated_service.bat` → "Ejecutar como administrador"
3. **Ventajas:** 
   - Funciona con aplicaciones elevadas
   - Lanza aplicaciones con privilegios normales
   - Inicio automático con Windows

## 🔧 Configuración

### 📁 Sistema de Configuración Modular
- **`configuration.ini`** - Configuración global y comportamiento general
- **`programs.ini`** - Lanzador de programas con configuración específica
- **`timestamps.ini`** - Formatos de fecha/hora y configuración temporal
- **`commands.ini`** - Paleta de comandos del sistema con timeouts personalizables
- **`information.ini`** - Información personal y snippets con configuración de inserción

### ⚙️ Configuración Avanzada
Cada archivo `.ini` incluye una sección `[Settings]` para personalizar:
- **Timeouts específicos** por capa
- **Feedback visual** personalizable
- **Comportamientos automáticos** configurables
- **Integración con aplicaciones** específicas

### 🔧 Personalización
- **Por capa:** Ver documentación específica de cada capa
- **Global:** Editar `configuration.ini` para ajustes generales
- **Servicio:** Ver [Instalación como Servicio](doc/SERVICE_INSTALLATION.md) para gestión del servicio

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

## 📋 Versión Actual: 6.2

### Novedades v6.2:
- **🆕 Funciones de Mouse Reubicadas**: Click izquierdo sostenido (`;`) y click derecho (`'`) movidos de B/N
- **🆕 Scroll con Touchpad**: Funcionalidad trackball con `CapsLock + /` y `/` en capa Nvim
- **🆕 Ejes Invertidos**: Scroll más natural e intuitivo
- **🔧 Supresión de Caracteres**: Evita escritura no deseada durante scroll
- **🔧 Teclas Liberadas**: B y N ahora disponibles para nuevas funciones

### Novedades v6.1:
- **🆕 Capa Excel/Accounting**: Numpad completo + navegación WASD + atajos específicos de Excel
- **🆕 Integración con Zebar**: Indicadores visuales en tiempo real del estado de las capas
- **🆕 Modo Visual**: Indicador visual para el modo de selección en capa Nvim
- **🔧 Mejoras en feedback visual**: Notificaciones más consistentes y limpias

### Características v6.0:
- Búsqueda automática de ejecutables via Windows Registry
- Mejoras en el lanzador de programas
- Soporte robusto para ejecución como administrador

---

**¿Necesitas ayuda?** Consulta la documentación detallada en la carpeta `doc/` o revisa los comentarios en el código fuente.