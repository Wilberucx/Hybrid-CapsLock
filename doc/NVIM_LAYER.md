# Capa Nvim (Activada con Toque a CapsLock)

La Capa Nvim transforma tu teclado en un entorno de navegación y edición inspirado en Vim, proporcionando control preciso sin necesidad de mantener teclas modificadoras.

## 🎯 Activación

**Método:** Presiona y suelta `CapsLock` rápidamente (tap)

Un aviso visual aparecerá indicando el estado:
- `NVIM LAYER ON` - Capa activada
- `NVIM LAYER OFF` - Capa desactivada

> **Nota:** La capa se desactiva automáticamente al activar el Modo Líder (`CapsLock + Space`)

## 🎮 Modo Visual

La Capa Nvim incluye un **Modo Visual** para seleccionar texto mientras navegas:

| Tecla | Acción | Estado Visual |
|-------|--------|---------------|
| `m` | **Toggle Modo Visual** | `VISUAL MODE ON/OFF` |

Cuando el Modo Visual está activo, todas las teclas de navegación extienden la selección.

## 🧭 Navegación Básica (hjkl)

| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `h` | `←` | `Shift+←` | Mover/seleccionar izquierda |
| `j` | `↓` | `Shift+↓` | Mover/seleccionar abajo |
| `k` | `↑` | `Shift+↑` | Mover/seleccionar arriba |
| `l` | `→` | `Shift+→` | Mover/seleccionar derecha |

## 🚀 Navegación Extendida

### Movimiento por Palabras
| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `w` | `Ctrl+→` | `Ctrl+Shift+→` | Siguiente palabra |
| `b` | `Ctrl+←` | `Ctrl+Shift+←` | Palabra anterior |

### Movimiento por Líneas
| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `0` | `Home` | `Shift+Home` | Inicio de línea |
| `4` | `End` | `Shift+End` | Fin de línea |

### Movimiento por Páginas
| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `u` | `PageUp` | `Shift+PageUp` | Página arriba |
| `d` | `PageDown` | `Shift+PageDown` | Página abajo |

## ✏️ Edición de Texto

### Operaciones Básicas
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `x` | `Delete` | Eliminar carácter bajo cursor |
| `8` | `End + Enter` | Nueva línea al final |

### Inserción de Líneas (Estilo Vim)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `o` | `End + Enter` | Nueva línea debajo del cursor |
| `O` (Shift+o) | `Home + Enter + ↑` | Nueva línea arriba del cursor |

### Duplicación
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `'` | **Duplicar línea** | Selecciona línea actual, copia y pega debajo |

## 📋 Sistema Yank/Paste (Copiar/Pegar)

### Operador Yank (Copiar)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `y` | **Activar Yank** | Espera segunda tecla para definir qué copiar |

**Después de presionar `y`:**
| Segunda Tecla | Acción | Descripción |
|---------------|--------|-------------|
| `y` | **Copiar línea** | Copia la línea actual completa |
| `p` | **Copiar párrafo** | Copia el párrafo actual |
| `a` | **Copiar todo** | Copia todo el contenido (`Ctrl+A + Ctrl+C`) |

> **Timeout:** Si no presionas una segunda tecla en 600ms, el modo yank se cancela

### Yank en Modo Visual
Si hay texto seleccionado (Modo Visual activo), presionar `y` copia inmediatamente la selección.

### Paste (Pegar)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `p` | **Pegar normal** | `Ctrl+V` - Pegar con formato |
| `P` (Shift+p) | **Pegar plano** | Pegar solo texto sin formato |

> **Nota:** Si estás en modo yank y presionas `p`, copiará el párrafo actual en lugar de pegar

## 📜 Desplazamiento Suave

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `e` | **Scroll abajo** | 3 pasos de rueda hacia abajo |
| `E` (Shift+e) | **Scroll abajo** | 3 pasos de rueda hacia abajo |
| `y` | **Scroll arriba** | 3 pasos de rueda hacia arriba |
| `Y` (Shift+y) | **Scroll arriba** | 3 pasos de rueda hacia arriba |
| `/` | **Scroll con touchpad** | Mantén `/` y mueve el touchpad para scroll trackball |

> **Nota:** `y` tiene doble función: scroll cuando se presiona solo, yank cuando se usa como operador. El scroll con touchpad (`/`) replica la funcionalidad de ratones trackball con ejes invertidos para mayor naturalidad.

## 🖱️ Funciones de Mouse

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `;` | **Click izquierdo sostenido** | Mantiene click izquierdo hasta soltar la tecla |
| `'` | **Click derecho** | Click derecho simple |

> **Nota:** Las funciones de mouse en la capa Nvim permiten control preciso sin salir del modo de navegación.

## ⏰ Timestamps en Capa Nvim

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `,` | **Escribir timestamp** | Inserta timestamp con formato actual |
| `.` | **Cambiar formato** | Cicla entre formatos predefinidos |

### Formatos Disponibles
1. `yyyy-MM-dd HH:mm:ss` → `2024-01-15 14:30:25`
2. `dd/MM/yyyy HH:mm` → `15/01/2024 14:30`
3. `yyyyMMdd_HHmmss` → `20240115_143025`
4. `HH:mm:ss` → `14:30:25`
5. `yyyy-MM-dd` → `2024-01-15`
6. `yyyy-MM-ddTHH:mm:ssZ` → `2024-01-15T14:30:25Z` (ISO 8601)

## 🔧 Función Especial

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `f` | **Desactivar capa + Ctrl+Alt+K** | Desactiva Nvim Layer y envía `Ctrl+Alt+K` |

Esta función es útil para aplicaciones que usan `Ctrl+Alt+K` como atajo, permitiendo acceso rápido sin conflictos.

## 💡 Flujos de Trabajo Comunes

### 📝 Edición Rápida
```
1. CapsLock (activar capa)
2. hjkl (navegar al texto)
3. m (activar visual)
4. w/b (seleccionar palabras)
5. y (copiar selección)
6. o (nueva línea)
7. p (pegar)
```

### 📋 Copia Masiva
```
1. CapsLock (activar capa)
2. y → a (copiar todo)
3. Cambiar aplicación
4. CapsLock (activar capa)
5. p (pegar)
```

### 🎯 Navegación Precisa
```
1. CapsLock (activar capa)
2. 0 (inicio de línea)
3. w w w (tres palabras adelante)
4. m (activar visual)
5. 4 (seleccionar hasta fin de línea)
```

## ⚙️ Configuración y Estados

### Estados Visuales
- **Capa Nvim:** `NVIM LAYER ON/OFF`
- **Modo Visual:** `VISUAL MODE ON/OFF`
- **Formato Timestamp:** `TIMESTAMP FORMAT [formato]`
- **Yank Menu:** Muestra opciones `y/p/a` durante operación yank

### Persistencia
- El estado de la capa se mantiene hasta que se desactive manualmente
- Los formatos de timestamp se recuerdan durante la sesión
- El Modo Visual se resetea al desactivar la capa

## ⚠️ Consideraciones

### 🔄 Integración con Otros Modos
- **Modo Líder:** Desactiva automáticamente la Capa Nvim
- **Modo Modificador:** No interfiere con la capa (requiere mantener CapsLock)

### 📱 Compatibilidad
- **Aplicaciones de texto:** Funciona perfectamente en editores, navegadores, etc.
- **Aplicaciones específicas:** Algunos programas pueden interceptar ciertas teclas
- **Juegos:** Recomendado desactivar la capa antes de jugar

### ⚡ Rendimiento
- **Respuesta instantánea:** Las teclas responden inmediatamente
- **Memoria mínima:** No consume recursos significativos
- **Timeout automático:** El modo yank se cancela automáticamente

## 🔧 Personalización

### Añadir Nuevas Funciones
```autohotkey
#If (isNvimLayerActive && !GetKeyState("CapsLock","P"))

nueva_tecla::
    if (VisualMode)
        Send, +{nueva_accion}  ; Con selección
    else
        Send, {nueva_accion}   ; Sin selección
return

#If ; Fin del contexto
```

### Modificar Formatos de Timestamp
```autohotkey
global TSFormats := ["formato1", "formato2", "nuevo_formato"]
```

> **Tip:** La Capa Nvim es especialmente útil para escritores, programadores y cualquiera que trabaje intensivamente con texto.