# 🚀 HybridCapsLock v2 - Quick Start Guide

**Versión:** 2.0  
**AutoHotkey:** v2.0+ requerido

## 📋 Lo que necesitas ANTES de empezar

### **Requisitos Obligatorios:**
1. **✅ AutoHotkey v2** instalado ([Descargar aquí](https://www.autohotkey.com/v2/))
2. **✅ HybridCapsLock_v2.ahk** (archivo principal)
3. **✅ Carpeta config/** con archivos .ini
4. **✅ Carpeta data/** (se crea automáticamente si no existe)

### **Verificar AutoHotkey v2:**
```cmd
# Si está en PATH:
AutoHotkey.exe --version

# O usar ruta completa:
"C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" --version

# O simplemente hacer doble clic en HybridCapsLock_v2.ahk
# (Windows usa AutoHotkey automáticamente si está instalado)
```

## 🎯 Opciones de Instalación

### **Opción 1: Automática (Recomendada)**
```cmd
# Ejecutar el script de deployment
deploy_v2.bat
```

**¿Qué hace este script?**
- ✅ Busca AutoHotkey v2 (PATH, Program Files, directorio actual)
- ✅ Detiene HybridCapsLock v1 si está ejecutándose
- ✅ Crea backup de tu configuración actual
- ✅ Despliega HybridCapsLock v2
- ✅ Inicia la nueva versión
- ✅ Opcionalmente lo agrega al inicio de Windows

### **Opción 2: Manual**
```cmd
# 1. Detener v1 si está ejecutándose
taskkill /f /im AutoHotkey.exe

# 2. Ejecutar v2 directamente (cualquiera de estas opciones):

# Opción A: Doble clic en el archivo (más fácil)
# HybridCapsLock_v2.ahk

# Opción B: Si AutoHotkey está en PATH
AutoHotkey.exe HybridCapsLock_v2.ahk

# Opción C: Ruta completa
"C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" HybridCapsLock_v2.ahk
```

## 🧪 Verificar que funciona

### **Pruebas básicas:**
1. **CapsLock (tap):** Debería activar/desactivar Nvim Layer
2. **CapsLock + Space:** Debería mostrar Leader Mode
3. **Leader → c:** Debería mostrar Command Palette
4. **Usar `\` (backslash):** Para navegar hacia atrás
5. **Usar `Esc`:** Para salir de menús

### **Nuevas funcionalidades v2:**
- **Leader → c → o:** Power Options (sleep, restart, etc.)
- **Leader → c → a:** ADB Tools (Android development)
- **Leader → c → v:** VaultFlow (vault management)
- **Leader → c → h:** Hybrid Management (script control)

## 🔧 Estructura de Archivos Necesaria

```
📁 HybridCapsLock/
├── 📄 HybridCapsLock_v2.ahk     # Script principal
├── 📄 deploy_v2.bat             # Script de deployment
├── 📁 config/                   # Configuraciones
│   ├── 📄 commands.ini
│   ├── 📄 configuration.ini
│   ├── 📄 information.ini
│   ├── 📄 obsidian.ini
│   ├── 📄 programs.ini
│   └── 📄 timestamps.ini
└── 📁 data/                     # Datos de estado
    ├── 📄 layer_status.json
    └── 📄 menu_status.json
```

## ❓ ¿Qué NO incluye este proyecto?

### **NO incluido (debes instalarlo por separado):**
- ❌ **AutoHotkey v2** (descargar de autohotkey.com)
- ❌ **Aplicaciones externas** (Visual Studio Code, Git, ADB, etc.)
- ❌ **VaultFlow** (si planeas usar esa funcionalidad)

### **SÍ incluido:**
- ✅ **Script principal** HybridCapsLock v2
- ✅ **Archivos de configuración** (.ini)
- ✅ **Script de deployment**
- ✅ **Documentación completa**

## 🐛 Troubleshooting Rápido

### **Error: "AutoHotkey not found"**
- **Solución:** Instalar AutoHotkey v2 desde [autohotkey.com](https://www.autohotkey.com/v2/)

### **Error: "Script no inicia"**
- **Verificar:** AutoHotkey v2 instalado (no v1)
- **Ejecutar:** Como administrador si es necesario
- **Comprobar:** Que no hay otra instancia ejecutándose

### **Error: "Backspace no funciona"**
- **Solución:** Usar `\` (backslash) en lugar de Backspace
- **Nota:** Esta es una limitación conocida de AutoHotkey v2

### **Error: "Aplicaciones no se lanzan"**
- **Verificar:** Paths en `config/programs.ini`
- **Ejecutar:** Script como administrador
- **Actualizar:** Rutas si han cambiado

## 📞 Más Ayuda

### **Documentación completa:**
- 📖 `MIGRATION_GUIDE_V1_TO_V2.md` - Guía detallada de migración
- 📖 `doc/README.md` - Documentación completa
- 📖 `doc/CONFIGURATION.md` - Guía de configuración

### **Archivos de migración:**
- 📄 `v2_migration/phase9_testing_report.md` - Reporte de testing
- 📄 `v2_migration/phase9_complete.md` - Documentación técnica

---

## 🎯 Resumen: 3 Pasos para Usar HybridCapsLock v2

1. **📥 Instalar AutoHotkey v2** (prerequisito)
2. **🚀 Ejecutar `deploy_v2.bat`** (deployment automático)
3. **🧪 Probar funcionalidades** (CapsLock + Space)

**¡Listo! HybridCapsLock v2 debería estar funcionando.** 🎉