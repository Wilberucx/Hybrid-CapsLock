# Capa de Comandos (Líder: CapsLock + Space, luego `c`)

Esta capa proporciona un **command palette jerárquico** que permite ejecutar scripts, comandos de terminal, comandos de PowerShell y aplicaciones directamente desde el teclado, organizados en categorías para una navegación más intuitiva.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Mantén `CapsLock` + `Space`
2. **Entra en Capa Comandos:** Presiona `c`
3. **Selecciona una categoría:** Presiona una tecla de categoría (`s`, `n`, `g`, `m`, `f`)
4. **Ejecuta un comando:** Presiona la tecla del comando específico

## 🎮 Navegación en el Menú

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú líder principal
- **Timeout:** 7 segundos de inactividad cierra automáticamente

## ⚡ Categorías y Comandos Disponibles

### 🖥️ Sistema (`s`) - System Commands
| Tecla | Comando | Descripción |
|-------|---------|-------------|
| `s` | **System Info** | Información detallada del sistema |
| `t` | **Task Manager** | Administrador de tareas |
| `v` | **Services** | Administrador de servicios |
| `e` | **Event Viewer** | Visor de eventos |
| `d` | **Device Manager** | Administrador de dispositivos |
| `c` | **Disk Cleanup** | Limpieza de disco |

**Navegación:** `CapsLock + Space → c → s → [comando]`

### 🌐 Red (`n`) - Network Commands
| Tecla | Comando | Descripción |
|-------|---------|-------------|
| `i` | **IP Config** | Configuración de red completa |
| `p` | **Ping Test** | Test de conectividad a Google |
| `n` | **Network Info** | Información de conexiones de red |

**Navegación:** `CapsLock + Space → c → n → [comando]`

### 📂 Git (`g`) - Git Commands
| Tecla | Comando | Descripción |
|-------|---------|-------------|
| `s` | **Git Status** | Estado del repositorio actual |
| `l` | **Git Log** | Últimos 10 commits |
| `b` | **Git Branches** | Lista de ramas |
| `d` | **Git Diff** | Diferencias en archivos |
| `a` | **Git Add All** | Añadir todos los cambios |
| `p` | **Git Pull** | Actualizar desde remoto |

**Navegación:** `CapsLock + Space → c → g → [comando]`

### 📊 Monitoreo (`m`) - Monitoring Commands
| Tecla | Comando | Descripción |
|-------|---------|-------------|
| `p` | **Process List** | Top 10 procesos por CPU |
| `s` | **Service List** | Servicios en ejecución |
| `d` | **Disk Space** | Espacio en disco por unidad |
| `m` | **Memory Usage** | Uso de memoria del sistema |
| `c` | **CPU Usage** | Uso del procesador |

**Navegación:** `CapsLock + Space → c → m → [comando]`

### 📁 Carpetas (`f`) - Folder Access
| Tecla | Comando | Descripción |
|-------|---------|-------------|
| `t` | **Temp Folder** | Abre carpeta temporal |
| `a` | **AppData** | Abre carpeta AppData |
| `p` | **Program Files** | Abre Program Files |
| `u` | **User Profile** | Abre perfil de usuario |
| `d` | **Desktop** | Abre escritorio |
| `s` | **System32** | Abre System32 |

**Navegación:** `CapsLock + Space → c → f → [comando]`

## 🔧 Tipos de Comandos Soportados

### 💻 Comandos CMD (`cmd:`)
Ejecuta comandos en la línea de comandos de Windows:
```ini
GitStatus=cmd:git status
IPConfig=cmd:ipconfig /all
```

### 🔵 Comandos PowerShell (`ps:`)
Ejecuta comandos de PowerShell con salida interactiva:
```ini
ProcessList=ps:Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
DiskSpace=ps:Get-WmiObject -Class Win32_LogicalDisk
```

### 📜 Scripts (`script:`)
Ejecuta archivos de script (.bat, .ps1, .py, etc.):
```ini
MyScript=script:C:\Scripts\backup.bat
CustomTool=script:%USERPROFILE%\Scripts\tool.ps1
```

### 🚀 Ejecutables Directos
Ejecuta aplicaciones o comandos directamente:
```ini
TaskManager=taskmgr.exe
Services=services.msc
Calculator=calc.exe
```

## 🛠️ Personalización

### Añadir Comando a Categoría Existente

Para añadir un comando a una categoría existente, modifica la función correspondiente en `HybridCapsLock.ahk`:

1. **Localizar la función de categoría:**
   ```autohotkey
   ExecuteSystemCommand(keyPressed) {
       Switch keyPressed {
           Case "s": ExecuteCommand("System Info", "cmd:systeminfo")
           ; ... otros comandos
       }
   }
   ```

2. **Añadir nuevo caso:**
   ```autohotkey
   Case "h": ExecuteCommand("Mi Comando", "cmd:echo Hola Mundo")
   ```

3. **Actualizar el Input de la categoría:**
   ```autohotkey
   Input, _sysKey, L1 T7, {Escape}{Backspace}, s,t,v,e,d,c,h
   ```

4. **Actualizar el menú visual:**
   ```autohotkey
   ShowSystemCommandsMenu() {
       MenuText .= "h - Mi Comando`n"
   }
   ```

### Añadir Nueva Categoría

1. **Añadir al menú principal:**
   ```autohotkey
   Input, _cmdCategory, L1 T7, {Escape}{Backspace}, s,n,g,m,f,x
   ```

2. **Crear función de menú:**
   ```autohotkey
   ShowCustomCommandsMenu() {
       MenuText := "CUSTOM COMMANDS`n"
       ; ... definir menú
   }
   ```

3. **Crear función de ejecución:**
   ```autohotkey
   ExecuteCustomCommand(keyPressed) {
       Switch keyPressed {
           Case "1": ExecuteCommand("Mi Script", "script:C:\Scripts\mi_script.bat")
       }
   }
   ```

### Ejemplos de Comandos Personalizados

```ini
[Commands]
; Comando de desarrollo
BuildProject=cmd:cd C:\MiProyecto && npm run build

; Script personalizado
BackupFiles=script:%USERPROFILE%\Scripts\backup.bat

; PowerShell avanzado
SystemReport=ps:Get-ComputerInfo | Select-Object WindowsProductName, TotalPhysicalMemory, CsProcessors

; Abrir ubicación específica
ProjectFolder=cmd:explorer "C:\Desarrollo\MiProyecto"

; Comando con parámetros
RestartService=cmd:net stop "Mi Servicio" && net start "Mi Servicio"
```

## 💡 Consejos de Uso

### 🚀 Flujo Rápido Jerárquico
```
CapsLock + Space → c → s → t (Task Manager en 4 teclas)
CapsLock + Space → c → g → s (Git Status en 4 teclas)
CapsLock + Space → c → n → i (IP Config en 4 teclas)
CapsLock + Space → c → f → t (Temp Folder en 4 teclas)
```

### 🎯 Comandos por Categoría
- **Sistema (`s`):** `t` (Task Manager), `v` (Services), `e` (Event Viewer)
- **Git (`g`):** `s` (Status), `l` (Log), `b` (Branches), `d` (Diff)
- **Red (`n`):** `i` (IP Config), `p` (Ping), `n` (Network Info)
- **Monitoreo (`m`):** `p` (Process List), `d` (Disk Space), `m` (Memory)
- **Carpetas (`f`):** `t` (Temp), `a` (AppData), `p` (Program Files)

### ⚡ Memoria Muscular Jerárquica
**Categorías:**
- `s` = **S**ystem
- `n` = **N**etwork
- `g` = **G**it
- `m` = **M**onitoring
- `f` = **F**olders

**Comandos comunes:**
- `s` = **S**tatus/System Info
- `t` = **T**ask Manager/Temp
- `p` = **P**ing/Process List/Program Files
- `d` = **D**iff/Disk Space/Desktop

## 🔄 Variables de Entorno Soportadas

El sistema expande automáticamente estas variables:
- `%USERPROFILE%` - Carpeta del usuario
- `%TEMP%` - Carpeta temporal
- `%APPDATA%` - Carpeta AppData

## ⚠️ Solución de Problemas

### Comando No Se Ejecuta
1. **Verificar sintaxis:** Revisar prefijos `cmd:`, `ps:`, `script:`
2. **Comprobar rutas:** Usar rutas absolutas para scripts
3. **Permisos:** Algunos comandos requieren ejecutar como administrador

### Script No Encontrado
1. **Verificar ruta:** Usar rutas completas o variables de entorno
2. **Permisos de archivo:** Verificar que el script sea ejecutable
3. **Extensión correcta:** .bat, .ps1, .py, etc.

### Comando PowerShell Falla
1. **Política de ejecución:** Verificar `Get-ExecutionPolicy`
2. **Sintaxis:** Probar el comando directamente en PowerShell
3. **Módulos:** Verificar que los módulos necesarios estén instalados

## 🔧 Configuración Avanzada

### Archivo commands.ini - Sección [Settings]
```ini
[Settings]
show_output=true          ; Mostrar ventana de salida
close_on_success=false    ; No cerrar automáticamente
timeout_seconds=30        ; Timeout para comandos largos
```

## 📊 Integración con Zebar

La capa de comandos se integra con el sistema de estado de Zebar, mostrando cuando está activa en el indicador visual.

## 🆕 Novedades v6.3

- **🆕 Command Palette**: Nueva capa completa para ejecutar comandos
- **🆕 Soporte Multi-tipo**: CMD, PowerShell, Scripts y Ejecutables
- **🆕 Variables de Entorno**: Expansión automática de variables
- **🆕 Configuración Dinámica**: Todo configurable via commands.ini
- **🆕 Feedback Visual**: Notificaciones de ejecución y estado

## 💼 Casos de Uso

### Desarrollo
- Ejecutar builds, tests, deploys
- Comandos Git frecuentes
- Abrir proyectos y herramientas

### Administración de Sistema
- Monitoreo de recursos
- Gestión de servicios
- Diagnóstico de red

### Productividad
- Acceso rápido a carpetas
- Limpieza y mantenimiento
- Automatización de tareas repetitivas

---

## ✅ Estado de Implementación

**✅ COMPLETAMENTE IMPLEMENTADO** - La capa de comandos está ahora totalmente funcional en el código principal.

### 🎯 Navegación Implementada
- **Activación:** `CapsLock + Space → c`
- **Timeout:** 10 segundos de inactividad
- **Navegación:** `Esc` para salir, `Backspace` para volver
- **Estructura jerárquica:** Menú principal → Categoría → Comando específico

### 🔧 Funcionalidades Destacadas

#### 📁 Toggle de Archivos Ocultos (Comando Principal Solicitado)
- **Acceso:** `CapsLock + Space → c → w → h`
- **Función:** Alterna entre mostrar/ocultar archivos ocultos en el Explorador
- **Feedback:** Tooltip visual confirmando el estado actual
- **Actualización automática:** Refresca todas las ventanas del explorador

#### 🎨 Comandos Creativos Adicionales
- **Monitoreo del sistema:** Procesos, memoria, CPU, servicios
- **Herramientas de red:** IP config, ping, netstat
- **Git integrado:** Status, log, branches, diff, add, pull
- **Acceso rápido a carpetas:** Temp, AppData, Program Files, etc.
- **Utilidades de Windows:** Registry Editor, Variables de entorno

**¿Necesitas más comandos?** Edita las funciones `Execute[Category]Command` en `HybridCapsLock.ahk` para añadir comandos personalizados.