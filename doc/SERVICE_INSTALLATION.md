# 🔧 HybridCapsLock como Servicio de Windows

Esta implementación permite ejecutar HybridCapsLock como un servicio de Windows que funciona con aplicaciones elevadas sin heredar privilegios elevados.

## 🚀 Instalación Rápida

### Requisitos
- AutoHotkey v1.1+ instalado
- Permisos de administrador (solo para instalación)

### Instalación
1. **Clic derecho** en `install_elevated_service.bat`
2. **Seleccionar "Ejecutar como administrador"**
3. **Seguir las instrucciones** en pantalla

## ✨ Características

- ✅ **Funciona con aplicaciones elevadas** (como Windhawk)
- ✅ **Lanza aplicaciones con privilegios normales** (resuelve el problema original)
- ✅ **Inicio automático** con Windows
- ✅ **Logs detallados** para diagnóstico

## 🔧 Gestión del Servicio

```powershell
# Ver estado
Get-Service HybridCapsLockElevated

# Iniciar/Detener
sc start HybridCapsLockElevated
sc stop HybridCapsLockElevated

# Ver logs
Get-Content service_elevated.log -Wait

# Desinstalar
.\install_elevated_service.ps1 -Uninstall
```

## 🎯 Cómo Funciona

El servicio utiliza técnicas avanzadas de "privilege dropping":

1. **Se ejecuta con privilegios elevados** para interceptar teclas en todas las aplicaciones
2. **Usa APIs de Windows** (`CreateProcessAsUser`) para lanzar aplicaciones con privilegios normales
3. **Fallback a explorer.exe** si el método principal falla

## 📁 Archivos del Servicio

- `HybridCapsLock_Elevated.ahk` - Script principal del servicio
- `privilege_dropper.ahk` - Funciones de privilege dropping
- `install_elevated_service.bat` - Instalador principal
- `install_elevated_service.ps1` - Script de instalación PowerShell

## 🔍 Solución de Problemas

### El servicio no inicia
```powershell
Get-Content service_elevated_error.log
```

### No funciona en apps elevadas
Verificar que el servicio corre como SYSTEM:
```powershell
Get-WmiObject -Class Win32_Service -Filter "Name='HybridCapsLockElevated'" | Select-Object StartName
```

### Apps se abren elevadas
Verificar logs para ver qué método de lanzamiento se usa:
```powershell
Get-Content service_elevated.log | Select-String "Launch method"
```

---

**💡 Esta solución resuelve completamente el problema de privilegios elevados manteniendo la funcionalidad completa de HybridCapsLock.**