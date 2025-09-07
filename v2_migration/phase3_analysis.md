# Fase 3: Análisis de la Lógica Híbrida Central

## 🎯 Funcionalidad Core a Migrar

### Lógica Híbrida Principal (líneas 720-757):

La lógica híbrida permite que CapsLock funcione de dos maneras:
1. **TAP** (presionar y soltar rápido) = Escape
2. **HOLD** (mantener presionado) = Activar modo modificador

### Componentes Identificados:

#### 1. CapsLock Down Handler
```autohotkey
CapsLock::
    ; Detectar inicio de presión
    ; Establecer timeouts
    ; Preparar para tap vs hold detection
return
```

#### 2. CapsLock Up Handler  
```autohotkey
CapsLock Up::
    ; Detectar si fue tap o hold
    ; Ejecutar acción correspondiente
    ; Limpiar estados
return
```

#### 3. Sistema de Timeouts
- Timeout para detectar hold vs tap
- Configuración de tiempos desde .ini
- Manejo de estados temporales

#### 4. Leader Mode (CapsLock + Space)
- Activación de menús jerárquicos
- Navegación entre capas
- Sistema de submenús

## 🔧 Cambios v1 → v2 Necesarios

### Sintaxis de Hotkeys:
```autohotkey
; v1
CapsLock::
    ; código
return

CapsLock Up::
    ; código  
return

; v2
CapsLock:: {
    ; código
}

CapsLock Up:: {
    ; código
}
```

### Timers:
```autohotkey
; v1
SetTimer, label, time

; v2
SetTimer(function, time)
```

### KeyWait:
```autohotkey
; v1
KeyWait, CapsLock

; v2
KeyWait("CapsLock")
```

## 📋 Plan de Implementación Fase 3

### Paso 1: Estructura Básica
- Implementar CapsLock:: y CapsLock Up::
- Sistema básico de detección tap vs hold

### Paso 2: Sistema de Timeouts
- Configurar timeouts desde .ini
- Implementar timers para detección

### Paso 3: Leader Mode
- CapsLock + Space detection
- Sistema de menús básico

### Paso 4: Activación de Capas
- Sistema para activar/desactivar capas
- Estado persistente de capas

### Paso 5: Integración
- Conectar con hotkeys existentes
- Testing completo