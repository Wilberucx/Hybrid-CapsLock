# Fase 5: Análisis de la Capa Programas

## 🎯 Funcionalidad a Migrar

### Acceso desde Leader Mode:
La capa de programas se activa con `CapsLock + Space → p`

### Componentes Identificados:

#### 1. Búsqueda Automática en Registry
- Búsqueda de aplicaciones instaladas
- Detección automática de rutas
- Fallback a PATH del sistema

#### 2. Lanzamiento de Aplicaciones
- Ejecución directa de programas
- Manejo de rutas con espacios
- Parámetros de línea de comandos

#### 3. Configuración desde programs.ini
- Lista personalizable de aplicaciones
- Rutas específicas definidas por usuario
- Nombres de display personalizados

#### 4. Menús Dinámicos
- Generación automática de menús
- Navegación por categorías
- Búsqueda incremental

## 🔧 Aplicaciones Soportadas (del archivo original):

### Aplicaciones Principales:
- Explorer (e)
- Terminal/PowerShell (t)
- VS Code (c)
- Notepad (n)
- Obsidian (o)
- Navegadores (b)
- Thunderbird (m)

### Aplicaciones Adicionales:
- WSL (w)
- Beeper (p)
- Bitwarden (v)
- Y más desde programs.ini

## 📋 Cambios v1 → v2 Necesarios:

### Registry Access:
```autohotkey
; v1
RegRead, OutputVar, KeyName, ValueName

; v2
OutputVar := RegRead(KeyName, ValueName)
```

### Run Commands:
```autohotkey
; v1
Run, Target, WorkingDir

; v2
Run(Target, WorkingDir)
```

### File Operations:
```autohotkey
; v1
FileExist(path)
IfExist, path

; v2
FileExist(path)  ; Sin cambios
if FileExist(path)  ; Sintaxis mejorada
```