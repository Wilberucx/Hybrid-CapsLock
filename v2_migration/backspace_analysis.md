# 🔍 Análisis: Funcionalidad Backspace en Menús

## 🎯 Problema Identificado

**Issue:** Backspace no retrocede a las opciones anteriores en todos los tooltips/menús jerárquicos.

## 📋 Menús que Deben Soportar Backspace

### Leader Mode Hierarchy:
1. **Nivel 1:** Leader menu principal
2. **Nivel 2:** Submenús (Programs, Windows, Timestamps, Information, Commands)
3. **Nivel 3:** Submenús específicos (ej: Commands → System Commands)

### Navegación Esperada:
- **Nivel 3 → Backspace → Nivel 2**
- **Nivel 2 → Backspace → Nivel 1**
- **Nivel 1 → Backspace/Esc → Salir**

## 🔍 Ubicaciones a Revisar

### 1. Programs Layer (Leader → p)
- ✅ Implementado correctamente

### 2. Windows Layer (Leader → w)
- ❓ Revisar implementación

### 3. Timestamps Layer (Leader → t)
- ❓ Revisar submenús (d/t/h)

### 4. Information Layer (Leader → i)
- ❓ Revisar implementación

### 5. Commands Layer (Leader → c)
- ❓ Revisar submenús de categorías

### 6. Excel Layer (Leader → n)
- ✅ Toggle directo, no aplica