# Fase 7: Análisis de la Capa Comandos

## 🎯 Funcionalidad a Migrar

### Acceso desde Leader Mode:
La capa de comandos se activa con `CapsLock + Space → c`

### Componentes Identificados:

#### 1. Categorías de Comandos
- **System Commands** - Task Manager, Services, etc.
- **Network Commands** - IP Config, Ping, etc.
- **Git Commands** - Status, Log, Branches, etc.
- **Monitoring Commands** - Process List, Memory, etc.
- **Folder Access** - Temp, AppData, etc.
- **Windows Commands** - Registry, Environment, etc.

#### 2. Ejecución de Comandos
- Comandos PowerShell
- Comandos CMD
- Apertura de carpetas
- Ejecución de herramientas del sistema

#### 3. Menús Jerárquicos
- Nivel 1: Categorías principales
- Nivel 2: Comandos específicos
- Nivel 3: Parámetros (si aplica)

#### 4. Configuración Dinámica
- Lectura desde commands.ini
- Comandos personalizables
- Categorías configurables

## 🔧 Cambios v1 → v2 Necesarios:

### Run Commands:
```autohotkey
; v1
Run, cmd /c %command%
Run, powershell -Command "%psCommand%"

; v2
Run("cmd /c " . command)
Run("powershell -Command `"" . psCommand . "`"")
```

### Process Execution:
```autohotkey
; v1
RunWait, %command%, , Hide

; v2
RunWait(command, , "Hide")
```