# Fase 4: Análisis de la Capa Nvim Context-Sensitive

## 🎯 Funcionalidad a Migrar

### Contexto Condicional (líneas 759-1085):
La capa Nvim utiliza hotkeys condicionales que solo funcionan cuando:
- `isNvimLayerActive` es true
- CapsLock NO está presionado

### Sintaxis v1 vs v2:
```autohotkey
; v1
#If (isNvimLayerActive && !GetKeyState("CapsLock","P"))
; hotkeys aquí
#If

; v2
#HotIf (isNvimLayerActive && !GetKeyState("CapsLock","P"))
; hotkeys aquí
#HotIf
```

## 📋 Componentes Identificados:

### 1. Navegación Extendida
- Movimiento con modificadores (Shift, Ctrl)
- Navegación por palabras
- Inicio/fin de línea

### 2. Funciones de Edición
- Visual mode (selección)
- Yank (copiar) y paste
- Delete y cut operations
- Undo/redo

### 3. Click Functions
- Left click, right click, middle click
- Click con modificadores

### 4. Touchpad Scroll Mode
- Activación con CapsLock & /
- Scroll con Shift keys
- Configuración desde .ini

### 5. Timestamps Específicos
- Inserción de fecha/hora en modo Nvim
- Formatos específicos para editores

## 🔧 Cambios v1 → v2 Necesarios:

### Directiva Condicional:
```autohotkey
; v1
#If (condition)

; v2  
#HotIf (condition)
```

### Funciones de Sistema:
```autohotkey
; v1
Click, Left
WinGetTitle, title, A

; v2
Click("Left")
title := WinGetTitle("A")
```