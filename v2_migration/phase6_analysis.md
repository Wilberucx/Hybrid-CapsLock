# Fase 6: Análisis de Capas Especializadas

## 🎯 4 Capas a Implementar

### 1. Capa Windows (w) - División de Pantalla
**Acceso:** CapsLock + Space → w
**Funcionalidades:**
- División de pantalla (splits)
- Herramientas de zoom
- Cambio de ventanas persistente
- Modo blind switch vs visual switch

### 2. Capa Excel/Accounting (n) - Numpad Virtual
**Acceso:** CapsLock + Space → n
**Funcionalidades:**
- Numpad virtual en teclado principal
- Navegación específica de Excel
- Funciones contables
- Atajos especializados

### 3. Capa Timestamp (t) - Formatos de Fecha/Hora
**Acceso:** CapsLock + Space → t
**Funcionalidades:**
- Sistema de 3 niveles (fecha, hora, datetime)
- Formatos configurables
- Persistencia de configuración
- Menús de selección de formato

### 4. Capa Information (i) - Información Personal
**Acceso:** CapsLock + Space → i
**Funcionalidades:**
- Inserción de información personal
- Datos configurables desde information.ini
- Plantillas de texto
- Información empresarial

## 🔧 Cambios v1 → v2 Necesarios:

### FormatTime Function:
```autohotkey
; v1
FormatTime, OutputVar, YYYYMMDDHHMISS, yyyy-MM-dd HH:mm:ss

; v2
OutputVar := FormatTime(, "yyyy-MM-dd HH:mm:ss")
```

### Clipboard Operations:
```autohotkey
; v1
Clipboard := text
ClipWait

; v2
A_Clipboard := text
ClipWait()
```

### WinGet Functions:
```autohotkey
; v1
WinGet, OutputVar, ProcessName, A

; v2
OutputVar := WinGetProcessName("A")
```