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

## 📚 Documentación Detallada

- **[Modo Modificador](doc/MODIFIER_MODE.md)** - Todos los atajos con CapsLock mantenido
- **[Capa Nvim](doc/NVIM_LAYER.md)** - Navegación y edición estilo Vim
- **[Modo Líder](doc/LEADER_MODE.md)** - Menús contextuales y sub-capas
  - **[Capa Windows](doc/WINDOWS_LAYER.md)** - Gestión de ventanas y zoom
  - **[Capa Programas](doc/PROGRAM_LAYER.md)** - Lanzador de aplicaciones
  - **[Capa Timestamp](doc/TIMESTAMP_LAYER.md)** - Herramientas de fecha/hora
  - **[Capa Excel](doc/EXCEL_LAYER.md)** - Capa especializada para Excel con numpad, navegación y atajos

## ⚙️ Instalación y Uso

1. **Requisito:** [AutoHotkey v1.1+](https://www.autohotkey.com/)
2. **Ejecutar:** Doble click en `HybridCapsLock.ahk`
3. **Inicio automático:** Crear acceso directo en `shell:startup`

## 🔧 Configuración

- **Archivo de configuración:** `HybridCapsLock.ini`
- **Personalización:** Ver documentación específica de cada capa
- **Ejecutar como administrador:** Recomendado para evitar problemas de permisos

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

## 📋 Versión Actual: 6.1

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