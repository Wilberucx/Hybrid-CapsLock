# 🚀 Plan de Migración HybridCapsLock v1 → v2

## 📊 Resumen del Proyecto

**Objetivo:** Migrar HybridCapsLock.ahk de AutoHotkey v1 a v2 de manera gradual, capa por capa
**Archivo Principal:** `HybridCapsLock.ahk` (2,497 líneas)
**Enfoque:** Migración incremental manteniendo funcionalidad completa
**Estado:** 🟡 En Planificación

---

## 🏗️ Estructura del Proyecto Analizada

### Archivo Principal: `HybridCapsLock.ahk`

**Secciones Identificadas:**
- **SECTION 1:** Configuración Inicial (líneas 20-79)
- **SECTION 2:** Modo Modificador - Atajos rápidos (líneas 80-719) 
- **SECTION 3:** Lógica Híbrida - Tap vs Hold (líneas 720-757)
- **SECTION 4:** Capa Nvim - Navegación estilo Vim (líneas 758-1088)
- **SECTION 5:** Capa Excel/Accounting (líneas 1089-1221)
- **SECTION 6:** Funciones Helper (líneas 1222-2497)

### Capas Funcionales (7 capas principales):
- 🎯 **Capa Nvim** - Navegación y edición estilo Vim
- 🪟 **Capa Windows** - Gestión de ventanas y zoom
- 🚀 **Capa Programas** - Lanzador de aplicaciones
- ⏰ **Capa Timestamp** - Herramientas de fecha/hora
- ⚡ **Capa Comandos** - Paleta de comandos del sistema
- 📊 **Capa Information** - Inserción de información personal
- 📈 **Capa Excel** - Funcionalidades específicas para Excel

### Archivos de Configuración:
- `config/configuration.ini` - Configuración principal
- `config/programs.ini` - Configuración de programas
- `config/commands.ini` - Configuración de comandos
- `config/timestamps.ini` - Configuración de timestamps
- `config/information.ini` - Información personal
- `config/obsidian.ini` - Configuración de Obsidian

---

## 🎯 Fases de Migración

### **Fase 1: Preparación y Configuración Base** ⚙️
**Estado:** 🔴 Pendiente  
**Complejidad:** Baja  
**Tiempo Estimado:** 2-3 horas  

**Objetivos:**
- Establecer infraestructura básica en v2
- Migrar configuración inicial y variables globales
- Convertir directivas básicas
- Establecer sistema de archivos de configuración

**Archivos a crear:**
- `HybridCapsLock_v2.ahk` (archivo principal v2)
- `v2_migration/` (carpeta para archivos de migración)

**Tareas específicas:**
- [ ] Convertir `#SingleInstance, Force` → `#SingleInstance Force`
- [ ] Eliminar `#NoEnv` (no necesario en v2)
- [ ] Convertir `#Warn` → `#Warn All`
- [ ] Migrar `StringCaseSense, On` → `A_StringCaseSense := true`
- [ ] Convertir `SendMode, Input` → `SendMode("Input")`
- [ ] Migrar variables globales con sintaxis v2
- [ ] Establecer sistema de archivos .ini
- [ ] Crear funciones helper básicas

**Cambios principales v1→v2:**
```autohotkey
; v1
#SingleInstance, Force
#NoEnv
StringCaseSense, On
SendMode, Input

; v2
#SingleInstance Force
; #NoEnv no necesario
A_StringCaseSense := true
SendMode("Input")
```

---

### **Fase 2: Capa Base - Modo Modificador** 🎮
**Estado:** 🔴 Pendiente  
**Complejidad:** Baja-Media  
**Tiempo Estimado:** 4-5 horas  
**Dependencias:** Fase 1 completada

**Objetivos:**
- Migrar atajos básicos de CapsLock+tecla
- Establecer navegación fundamental
- Implementar funciones de ventana básicas

**Subsecciones a migrar:**
- [ ] Funciones de ventana (minimizar, maximizar, cerrar)
- [ ] Navegación básica (hjkl)
- [ ] Atajos comunes (Ctrl+c, Ctrl+v, etc.)
- [ ] Smooth scrolling básico
- [ ] Alt+Tab mejorado

**Hotkeys principales:**
```autohotkey
; Navegación básica
CapsLock & h::Send("{Left}")
CapsLock & j::Send("{Down}")
CapsLock & k::Send("{Up}")
CapsLock & l::Send("{Right}")

; Funciones de ventana
CapsLock & q::Send("!{F4}")
CapsLock & f::WinMaximize("A")
```

---

### **Fase 3: Lógica Híbrida Central** 🧠
**Estado:** 🔴 Pendiente  
**Complejidad:** Alta  
**Tiempo Estimado:** 6-8 horas  
**Dependencias:** Fase 2 completada  
**⚠️ CRÍTICO:** Funcionalidad core del sistema

**Objetivos:**
- Migrar sistema tap vs hold de CapsLock
- Implementar detección de timeouts
- Establecer activación/desactivación de capas

**Componentes críticos:**
- [ ] Detección de tap vs hold
- [ ] Sistema de timeouts configurables
- [ ] Activación/desactivación de capas
- [ ] Estado persistente de CapsLock
- [ ] Leader mode (CapsLock + Space)

**Lógica principal:**
```autohotkey
; Sistema híbrido tap/hold
CapsLock::
{
    ; Detectar si es tap o hold
    ; Activar capa correspondiente
    ; Manejar timeouts
}
```

---

### **Fase 4: Capa Nvim** 🎯
**Estado:** 🔴 Pendiente  
**Complejidad:** Media-Alta  
**Tiempo Estimado:** 5-6 horas  
**Dependencias:** Fase 3 completada

**Objetivos:**
- Migrar navegación estilo Vim completa
- Implementar acciones de edición
- Establecer sistema de scroll avanzado

**Subsecciones:**
- [ ] Navegación extendida (hjkl + modificadores)
- [ ] Acciones de edición (yank, paste, delete)
- [ ] Funciones de click (left, right, middle)
- [ ] Scroll mode con touchpad
- [ ] Timestamps específicos de Nvim
- [ ] Visual mode

**Contexto específico:**
```autohotkey
#HotIf (isNvimLayerActive && !GetKeyState("CapsLock", "P"))
; Hotkeys específicos de Nvim
#HotIf
```

---

### **Fase 5: Capa Programas** 🚀
**Estado:** 🔴 Pendiente  
**Complejidad:** Media  
**Tiempo Estimado:** 4-5 horas  
**Dependencias:** Fase 3 completada

**Objetivos:**
- Migrar lanzador de aplicaciones
- Implementar búsqueda en Registry
- Establecer menús dinámicos

**Componentes:**
- [ ] Sistema de búsqueda automática en Registry
- [ ] Lanzamiento de aplicaciones
- [ ] Menús dinámicos desde programs.ini
- [ ] Detección de aplicaciones instaladas
- [ ] Fallback a PATH del sistema

**Aplicaciones soportadas:**
- Explorer, Terminal, VS Code, Notepad
- Obsidian, Navegadores, Thunderbird
- WSL, Beeper, Bitwarden, etc.

---

### **Fase 6: Capas Especializadas** 📊
**Estado:** 🔴 Pendiente  
**Complejidad:** Media  
**Tiempo Estimado:** 6-7 horas  
**Dependencias:** Fase 3 completada

**Objetivos:**
- Migrar capas específicas de funcionalidad
- Implementar herramientas especializadas

**Capas a migrar:**

#### 6.1 Capa Windows 🪟
- [ ] División de pantalla (splits)
- [ ] Herramientas de zoom
- [ ] Cambio de ventanas persistente
- [ ] Modo blind switch vs visual switch

#### 6.2 Capa Excel/Accounting 📈
- [ ] Numpad virtual
- [ ] Navegación específica de Excel
- [ ] Funciones contables
- [ ] Atajos especializados

#### 6.3 Capa Timestamp ⏰
- [ ] Sistema de 3 niveles (fecha, hora, datetime)
- [ ] Formatos configurables
- [ ] Persistencia de configuración
- [ ] Menús de selección de formato

#### 6.4 Capa Information 📊
- [ ] Inserción de información personal
- [ ] Datos configurables desde information.ini
- [ ] Plantillas de texto
- [ ] Información empresarial

---

### **Fase 7: Capa Comandos** ⚡
**Estado:** 🔴 Pendiente  
**Complejidad:** Alta  
**Tiempo Estimado:** 6-8 horas  
**Dependencias:** Fase 3 completada

**Objetivos:**
- Migrar paleta de comandos completa
- Implementar ejecución de comandos del sistema
- Establecer menús jerárquicos

**Componentes:**
- [ ] Sistema de comandos personalizados
- [ ] Ejecución de PowerShell/CMD
- [ ] Menús jerárquicos (3 niveles)
- [ ] Integración con commands.ini
- [ ] Categorías: System, Network, Git, Monitoring, etc.

**Categorías principales:**
- System Commands (Task Manager, Services, etc.)
- Network Commands (IP Config, Ping, etc.)
- Git Commands (Status, Log, Branches, etc.)
- Monitoring Commands (Process List, Memory, etc.)
- Folder Access (Temp, AppData, etc.)
- Windows Commands (Registry, Environment, etc.)

---

### **Fase 8: Navegación Jerárquica y Detección de Teclas** ✅
**Estado:** ✅ COMPLETADA  
**Complejidad:** Media  
**Tiempo Real:** 4 horas  
**Dependencias:** Todas las fases anteriores

**Objetivos Completados:**
- ✅ Corregir navegación jerárquica en Leader Mode
- ✅ Solucionar detección de teclas Backspace y Esc
- ✅ Implementar stack de navegación funcional
- ✅ Establecer solución temporal robusta con backslash (\)

---

### **Fase 9: Finalización y Optimización** 🎯
**Estado:** 🔴 Pendiente  
**Complejidad:** Media  
**Tiempo Estimado:** 6-8 horas  
**Dependencias:** Todas las fases anteriores

**Objetivos:**
- Verificación completa de funcionalidades vs v1
- Testing exhaustivo de todas las capas
- Optimización de performance y limpieza de código
- Documentación final y scripts de instalación

**Componentes críticos:**
- [ ] Testing funcional completo
- [ ] Optimización de performance
- [ ] Documentación de usuario actualizada
- [ ] Scripts de migración e instalación
- [ ] Validación final de compatibilidad

**Entregables:**
- [ ] HybridCapsLock_v2.ahk optimizado y final
- [ ] Documentación completa actualizada
- [ ] Guía de migración v1→v2
- [ ] Scripts de soporte (instalación, testing)

**Tareas finales:**
- [ ] Integración con Zebar (layer_status.json)
- [ ] Sistema de tooltips unificado
- [ ] Gestión de estado JSON
- [ ] Testing completo de todas las capas
- [ ] Optimización de rendimiento
- [ ] Documentación actualizada
- [ ] Scripts de instalación actualizados

---

## 🛠️ Estrategia de Implementación

### **Enfoque Incremental:**
1. **Archivo paralelo** - `HybridCapsLock_v2.ahk` junto a `HybridCapsLock.ahk`
2. **Testing por fases** - Cada capa se prueba independientemente
3. **Configuración compartida** - Usar los mismos archivos .ini
4. **Rollback fácil** - Posibilidad de volver a v1 en cualquier momento

### **Estructura de archivos durante migración:**
```
HybridCapsLock/
├── HybridCapsLock.ahk              # Versión original v1
├── HybridCapsLock_v2.ahk           # Nueva versión v2
├── v2_migration/                   # Archivos de migración
│   ├── phase1_base.ahk            # Fase 1 aislada
│   ├── phase2_modifier.ahk        # Fase 2 aislada
│   ├── phase3_hybrid.ahk          # Fase 3 aislada
│   └── ...
├── config/                        # Configuración compartida
└── doc/                           # Documentación
```

### **Testing Strategy:**
- **Unit testing** por fase
- **Integration testing** entre fases
- **Regression testing** con v1
- **Performance testing** comparativo

---

## 📋 Principales Cambios v1→v2

### **Sintaxis de Funciones:**
```autohotkey
; v1
Function, param1, param2

; v2
Function(param1, param2)
```

### **Variables:**
```autohotkey
; v1
global myVar := "value"

; v2
myVar := "value"  ; Variables son locales por defecto
global myVar := "value"  ; Para globales explícitas
```

### **Hotkeys con contexto:**
```autohotkey
; v1
#If (condition)
hotkey::action
#If

; v2
#HotIf (condition)
hotkey::action
#HotIf
```

### **Directivas:**
```autohotkey
; v1
#SingleInstance, Force
#NoEnv
StringCaseSense, On
SendMode, Input

; v2
#SingleInstance Force
; #NoEnv no necesario
A_StringCaseSense := true
SendMode("Input")
```

---

## 🎯 Criterios de Éxito

### **Por Fase:**
- [ ] Todas las funcionalidades de la fase funcionan correctamente
- [ ] No hay regresiones en funcionalidades anteriores
- [ ] Performance igual o mejor que v1
- [ ] Configuración compatible con v1

### **General:**
- [ ] 100% de funcionalidades migradas
- [ ] Performance mejorada o igual
- [ ] Compatibilidad completa con archivos .ini existentes
- [ ] Documentación actualizada
- [ ] Scripts de instalación funcionando

---

## 📝 Notas Importantes

### **Compatibilidad:**
- Los archivos .ini existentes deben seguir funcionando
- Los usuarios deben poder cambiar entre v1 y v2 fácilmente
- La configuración debe ser compartida

### **Performance:**
- v2 generalmente es más rápido que v1
- Aprovechar mejoras de sintaxis para optimizar
- Mantener o mejorar tiempos de respuesta

### **Mantenimiento:**
- Código más limpio y mantenible en v2
- Mejor manejo de errores
- Sintaxis más moderna y legible

---

## 🔗 Referencias

- [AutoHotkey v2 Migration Guide](https://www.autohotkey.com/docs/v2/v2-changes.htm)
- [AutoHotkey v2 Documentation](https://www.autohotkey.com/docs/v2/)
- [Proyecto Original HybridCapsLock](./README.md)

---

**Última actualización:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Responsable:** RovoDev  
**Estado del proyecto:** 🟢 Fase 8B Completada - Funcionalidades Faltantes Implementadas