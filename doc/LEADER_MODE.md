# Modo Líder (CapsLock + Space)

El Modo Líder es un sistema de menús contextuales que organiza funciones avanzadas en sub-capas especializadas. Proporciona acceso rápido a herramientas de gestión de ventanas, lanzamiento de programas y utilidades de timestamp.

## 🎯 Activación

**Combinación:** `CapsLock + Space`

Al activar el modo líder, aparece un menú visual que muestra las opciones disponibles.

## 📋 Menú Principal

```
LEADER MENU

w - Windows
p - Programs  
t - Time
n - Excel

[Esc: Exit]
```

## 🌟 Sub-Capas Disponibles

### 🪟 [Capa Windows](WINDOWS_LAYER.md) - Tecla `w`
Gestión avanzada de ventanas y herramientas de zoom.

**Funciones principales:**
- División de pantalla (splits 50/50, 33/67, cuadrantes)
- Acciones de ventana (cerrar, maximizar, minimizar)
- Herramientas de zoom (Draw, Zoom, Zoom with cursor)
- Cambio de ventanas persistente (blind/visual switch)

### 🚀 [Capa Programas](PROGRAM_LAYER.md) - Tecla `p`
Lanzador rápido de aplicaciones comunes.

**Aplicaciones disponibles:**
- Explorador, Terminal, Visual Studio/Code
- Navegadores, Obsidian, Notepad
- Bitwarden, Configuración de Windows
- Y más...

### ⏰ [Capa Timestamp](TIMESTAMP_LAYER.md) - Tecla `t`
Herramientas para insertar y formatear fechas/horas.

**Funciones principales:**
- Inserción de fecha, hora o datetime
- Cambio de formatos de fecha y hora
- Configuración de separadores
- Formatos persistentes entre sesiones

### 📊 [Capa Excel](EXCEL_LAYER.md) - Tecla `n`
Capa persistente especializada para trabajo con hojas de cálculo y aplicaciones contables.

**Funciones principales:**
- Numpad completo con distribución ergonómica (7-8-9, u-i-o, j-k-l)
- Navegación con flechas (WASD) y Tab/Shift+Tab
- Atajos específicos de Excel (Ctrl+Enter, F2, Ctrl+F, etc.)
- Operaciones matemáticas y símbolos del numpad
- Modo persistente optimizado para trabajo continuo

## 🎮 Navegación

### Controles Universales
- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú principal (desde sub-capas)
- **Timeout:** 7 segundos de inactividad cierra automáticamente

### Flujo de Navegación
```
CapsLock + Space → Menú Principal
                ↓
        Seleccionar sub-capa (w/p/t)
                ↓
        Ejecutar acción específica
                ↓
        Salir automáticamente O volver con Backspace
```

## 💡 Características Especiales

### 🔄 Integración con Capa Nvim
- Si la Capa Nvim está activa al llamar al líder, se desactiva automáticamente
- Esto evita conflictos entre modos y proporciona una transición limpia

### 📱 Feedback Visual
- Cada sub-capa muestra su propio menú contextual
- Tooltips centrados en pantalla para mejor visibilidad
- Indicadores de estado para acciones persistentes

### ⚡ Modos Persistentes
Algunas funciones (como el cambio de ventanas) mantienen el modo activo para operaciones continuas:
- **Blind Switch** - Navegación rápida sin vista previa
- **Visual Switch** - Navegación con vista previa estilo Alt+Tab

## 🔧 Personalización

### Añadir Nueva Sub-Capa

1. **Editar el Input principal:**
   ```autohotkey
   Input, _leaderKey, L1 T7, {Escape} ; Añadir nueva tecla aquí
   ```

2. **Añadir nuevo bloque condicional:**
   ```autohotkey
   if (_leaderKey = "nueva_tecla") {
       ShowNuevoMenu()
       Input, _nuevaAccion, L1 T7, {Escape}{Backspace}
       ; Lógica de la nueva sub-capa
   }
   ```

3. **Crear función de menú:**
   ```autohotkey
   ShowNuevoMenu() {
       ; Definir el menú visual
   }
   ```

4. **Actualizar menú principal:**
   ```autohotkey
   ShowLeaderMenu() {
       MenuText .= "nueva_tecla - Nueva Función`n"
   }
   ```

## 📊 Estadísticas de Uso

El modo líder está optimizado para:
- **Acceso rápido:** Máximo 2 teclas para cualquier función
- **Memoria muscular:** Teclas mnemotécnicas (w=windows, p=programs, t=time)
- **Eficiencia:** Timeout automático para evitar bloqueos
- **Flexibilidad:** Sistema modular fácil de extender

## ⚠️ Consideraciones

- **Conflictos de teclas:** El líder desactiva automáticamente la Capa Nvim
- **Aplicaciones en pantalla completa:** Algunos tooltips pueden no ser visibles
- **Rendimiento:** Los timeouts previenen el uso excesivo de memoria
- **Compatibilidad:** Funciona mejor con AutoHotkey v1.1+