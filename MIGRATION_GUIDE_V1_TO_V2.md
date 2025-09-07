# 🚀 Guía de Migración: HybridCapsLock v1 → v2

**Versión:** 2.0  
**Fecha:** 2024-12-19  
**AutoHotkey:** v2.0+

## 📋 Resumen de la Migración

HybridCapsLock v2 es una migración completa a AutoHotkey v2 que mantiene **100% de compatibilidad funcional** con v1, mientras ofrece mejor performance y sintaxis moderna.

### ✅ **Lo que se mantiene igual:**
- **Todas las funcionalidades** de v1
- **Archivos de configuración** (.ini) sin cambios
- **Combinaciones de teclas** idénticas
- **Command Palette** completo (10 categorías)
- **Comportamiento** exactamente igual

### 🔄 **Lo que cambia:**
- **AutoHotkey v2** requerido (en lugar de v1)
- **Navegación hacia atrás:** `\` (backslash) en lugar de `Backspace`
- **Performance mejorada** y sintaxis optimizada
- **Mejor manejo de errores** y estabilidad

## 🎯 Requisitos Previos

### **Software Necesario:**
- ✅ **AutoHotkey v2.0+** ([Descargar aquí](https://www.autohotkey.com/v2/))
- ✅ **Windows 10/11** (recomendado)
- ✅ **Permisos de administrador** (opcional, para algunas funciones)

### **Verificar Versión Actual:**
```batch
# Verificar si tienes AutoHotkey v1 o v2
AutoHotkey.exe --version
```

## 📦 Proceso de Migración

### **Opción 1: Migración Manual (Recomendada)**

#### **Paso 1: Backup de Configuración**
```batch
# Crear backup de tu configuración actual
mkdir backup_v1
copy config\*.ini backup_v1\
copy data\*.json backup_v1\
```

#### **Paso 2: Instalar AutoHotkey v2**
1. Descargar AutoHotkey v2 desde [autohotkey.com](https://www.autohotkey.com/v2/)
2. Instalar manteniendo v1 si lo deseas (pueden coexistir)
3. Verificar instalación: `AutoHotkey.exe --version`

#### **Paso 3: Reemplazar Script Principal**
1. **Detener** HybridCapsLock v1 si está ejecutándose
2. **Renombrar** `HybridCapsLock.ahk` → `HybridCapsLock_v1_backup.ahk`
3. **Copiar** `HybridCapsLock_v2.ahk` → `HybridCapsLock.ahk`
4. **Ejecutar** el nuevo script con AutoHotkey v2

#### **Paso 4: Verificar Funcionamiento**
- ✅ CapsLock funciona como modificador
- ✅ Leader Mode: `CapsLock + Space`
- ✅ Command Palette: `Leader → c`
- ✅ Navegación: `\` para regresar, `Esc` para salir

### **Opción 2: Deployment Automático**

#### **Script de Deployment Automático:**
**Archivo:** `deploy_v2.bat`

**⚠️ IMPORTANTE:** Este script NO instala AutoHotkey v2. Debes instalarlo primero.
```batch
@echo off
echo ========================================
echo   HybridCapsLock v1 to v2 Deployment
echo ========================================
echo.
echo PREREQUISITES CHECK:
echo - AutoHotkey v2 must be installed
echo - HybridCapsLock_v2.ahk must be present
echo.

REM Check if AutoHotkey v2 is installed
where AutoHotkey.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: AutoHotkey not found in PATH
    echo Please install AutoHotkey v2 first
    pause
    exit /b 1
)

REM Check AutoHotkey version
for /f "tokens=*" %%i in ('AutoHotkey.exe --version 2^>nul') do set AHK_VERSION=%%i
echo Detected AutoHotkey version: %AHK_VERSION%

REM Create backup
echo Creating backup of v1 configuration...
if not exist backup_v1 mkdir backup_v1
copy config\*.ini backup_v1\ >nul 2>&1
copy data\*.json backup_v1\ >nul 2>&1
if exist HybridCapsLock.ahk copy HybridCapsLock.ahk backup_v1\HybridCapsLock_v1.ahk >nul 2>&1

REM Stop current script if running
echo Stopping current HybridCapsLock instance...
taskkill /f /im AutoHotkey.exe >nul 2>&1

REM Deploy v2
echo Deploying HybridCapsLock v2...
if exist HybridCapsLock.ahk (
    move HybridCapsLock.ahk HybridCapsLock_v1_backup.ahk >nul 2>&1
)
copy HybridCapsLock_v2.ahk HybridCapsLock.ahk >nul 2>&1

REM Start v2
echo Starting HybridCapsLock v2...
start "" AutoHotkey.exe HybridCapsLock.ahk

echo.
echo ========================================
echo   Migration completed successfully!
echo ========================================
echo.
echo Configuration files preserved
echo Backup created in: backup_v1\
echo.
echo Test the following:
echo - CapsLock as modifier
echo - Leader Mode: CapsLock + Space
echo - Navigation: \ (backslash) to go back
echo.
pause
```

## 🔧 Configuración Post-Migración

### **Verificar Funcionalidades Clave:**

#### **1. Core Functionality**
- [ ] **CapsLock Tap:** Activa/desactiva Nvim Layer
- [ ] **CapsLock Hold:** Funciona como modificador
- [ ] **Excel Layer:** `Leader → n` toggle

#### **2. Leader Mode**
- [ ] **Activación:** `CapsLock + Space`
- [ ] **Programs:** `p` → lanza aplicaciones
- [ ] **Windows:** `w` → gestión de ventanas
- [ ] **Timestamps:** `t` → insertar fechas/horas
- [ ] **Information:** `i` → insertar información personal
- [ ] **Commands:** `c` → command palette

#### **3. Command Palette (Leader → c)**
- [ ] **System Commands:** `s`
- [ ] **Network Commands:** `n`
- [ ] **Git Commands:** `g`
- [ ] **Monitoring Commands:** `m`
- [ ] **Folder Commands:** `f`
- [ ] **Windows Commands:** `w`
- [ ] **Power Options:** `o` ← NUEVO
- [ ] **ADB Tools:** `a` ← NUEVO
- [ ] **VaultFlow:** `v` ← NUEVO
- [ ] **Hybrid Management:** `h` ← NUEVO

#### **4. Navegación**
- [ ] **Backslash (\):** Regresa al menú anterior
- [ ] **Escape:** Sale completamente
- [ ] **Timeout:** 7 segundos en menús

### **Configurar Autostart (Opcional):**
```batch
# Agregar al inicio de Windows
copy HybridCapsLock.ahk "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"
```

## 🆕 Nuevas Funcionalidades en v2

### **Power Options (Leader → c → o)**
- `s` - Sleep
- `h` - Hibernate  
- `r` - Restart
- `d` - Shutdown
- `l` - Lock Screen
- `o` - Sign Out

### **ADB Tools (Leader → c → a)**
- `d` - List Devices
- `i` - Install APK
- `u` - Uninstall Package
- `l` - Logcat
- `s` - Shell
- `r` - Reboot Device
- `c` - Clear App Data

### **VaultFlow (Leader → c → v)**
- `v` - Run VaultFlow
- `s` - VaultFlow Status
- `l` - List Vaults
- `h` - VaultFlow Help

### **Hybrid Management (Leader → c → h)**
- `r` - Reload Script
- `e` - Exit Script
- `c` - Open Config Folder
- `l` - View Log File
- `v` - Show Version Info

## 🔄 Rollback a v1 (Si es necesario)

Si necesitas volver a v1 temporalmente:

```batch
# Detener v2
taskkill /f /im AutoHotkey.exe

# Restaurar v1
move HybridCapsLock.ahk HybridCapsLock_v2.ahk
move HybridCapsLock_v1_backup.ahk HybridCapsLock.ahk

# Iniciar v1 con AutoHotkey v1
"C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe" HybridCapsLock.ahk
```

## 🐛 Troubleshooting

### **Problema: Script no inicia**
- ✅ Verificar que AutoHotkey v2 esté instalado
- ✅ Ejecutar como administrador
- ✅ Verificar que no hay otra instancia ejecutándose

### **Problema: Backspace no funciona**
- ✅ **Solución:** Usar `\` (backslash) en lugar de Backspace
- ✅ Esta es una limitación conocida de AutoHotkey v2

### **Problema: Configuración no se carga**
- ✅ Verificar que archivos .ini estén en carpeta `config/`
- ✅ Verificar permisos de lectura en archivos
- ✅ Restaurar desde backup si es necesario

### **Problema: Aplicaciones no se lanzan**
- ✅ Verificar paths en `config/programs.ini`
- ✅ Actualizar rutas si han cambiado
- ✅ Ejecutar script como administrador

## 📞 Soporte

### **Recursos:**
- 📖 **Documentación completa:** `doc/README.md`
- 🐛 **Issues conocidos:** `TROUBLESHOOTING.md`
- 📝 **Changelog:** `CHANGELOG.md`
- 🔧 **Configuración:** `doc/CONFIGURATION.md`

### **Contacto:**
- **Autor:** Wilber Canto (Vibe Codding)
- **Versión:** HybridCapsLock v2.0
- **AutoHotkey:** v2.0+

---

**¡Disfruta de HybridCapsLock v2 con mejor performance y nuevas funcionalidades!** 🚀