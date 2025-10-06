# Troubleshooting Home Row Mods

## Problemas Comunes y Soluciones

### 1. Las teclas no funcionan como modificadores

**Síntomas:**
- Mantener 'a' + 'c' no produce Win+C
- Las teclas solo escriben letras normales

**Diagnóstico:**
```ini
[General]
debug_mode=true
```

**Soluciones:**
1. **Verificar configuración:**
   ```ini
   [General]
   enabled=true  ; Debe estar en true
   ```

2. **Verificar tiempo de hold:**
   - Mantén la tecla por al menos 250ms antes de presionar otra
   - Si es muy difícil, reduce `tap_threshold_ms=200`

3. **Verificar asignación de modificadores:**
   ```ini
   [LeftHand]
   a_modifier=Win  ; No debe ser 'none'
   ```

### 2. Falsos positivos al escribir rápido

**Síntomas:**
- Al escribir "fast" se produce F+Alt+S+T en lugar de "fast"
- Activación accidental de modificadores

**Soluciones:**
1. **Reducir sensibilidad:**
   ```ini
   [Timing]
   tap_threshold_ms=200  ; Reducir de 250 a 200
   ```

2. **Modo permisivo:**
   ```ini
   [Timing]
   permissive_hold=true  ; Permite escribir aún después de hold
   ```

3. **Excluir aplicaciones problemáticas:**
   ```ini
   [Exclusions]
   excluded_apps=editor.exe,terminal.exe
   ```

### 3. Falsos negativos (no detecta holds)

**Síntomas:**
- Mantener claramente una tecla pero no actúa como modificador
- Necesita mantener muy largo tiempo

**Soluciones:**
1. **Aumentar sensibilidad:**
   ```ini
   [Timing]
   tap_threshold_ms=300  ; Aumentar de 250 a 300
   ```

2. **Verificar que no hay conflictos:**
   - Deshabilita temporalmente otras capas
   - Verifica en aplicaciones simples (Notepad)

### 4. Interferencias con otras capas

**Síntomas:**
- Conflictos con CapsLock Layer
- Comportamiento errático cuando múltiples layers activos

**Soluciones:**
1. **Verificar orden de includes en HybridCapsLock.ahk:**
   ```autohotkey
   #Include src\layer\nvim_layer.ahk
   #Include src\layer\homerow_mods.ahk  ; Después de otras capas
   ```

2. **Excluir apps donde hay conflictos:**
   ```ini
   [Exclusions]
   excluded_apps=vim.exe,nvim.exe
   ```

### 5. No funciona en aplicaciones específicas

**Síntomas:**
- Funciona en Notepad pero no en juegos/apps específicas
- Algunas apps bloquean los hotkeys

**Soluciones:**
1. **Ejecutar como administrador:**
   - Algunas apps requieren privilegios elevados

2. **Verificar si app está excluida:**
   ```ini
   [Exclusions]
   excluded_apps=  ; Vacía para probar
   ```

3. **Apps problemáticas comunes:**
   ```ini
   [Exclusions]
   excluded_apps=steam.exe,game.exe,cmd.exe,powershell.exe
   ```

### 6. Múltiples modificadores no funcionan

**Síntomas:**
- Ctrl+Shift+algo no funciona manteniendo F+D

**Diagnóstico:**
- Habilita debug_mode y verifica que ambas teclas se detecten como held

**Soluciones:**
1. **Verificar detección simultánea:**
   - Los logs deben mostrar ambas teclas como "usedAsMod=true"

2. **Probar secuencialmente:**
   - Mantén primera tecla, luego segunda, luego target

### 7. Rendimiento/Lag

**Síntomas:**
- Retraso al escribir
- Sistema lento cuando home row mods activo

**Soluciones:**
1. **Deshabilitar debug:**
   ```ini
   [General]
   debug_mode=false
   ```

2. **Reducir scope:**
   ```ini
   [LeftHand]
   s_modifier=none  ; Deshabilitar teclas menos usadas
   d_modifier=none
   ```

## Herramientas de Diagnóstico

### 1. Debug Logs

Habilita debug mode y usa DebugView o herramienta similar:

```ini
[General]
debug_mode=true
```

**Logs normales:**
```
[HOMEROW] Initialized with threshold=250ms
[HOMEROW] Registered: a -> Win
[HOMEROW] a DOWN
[HOMEROW] a UP - dur=150ms, usedAsMod=0, threshold=250ms
[HOMEROW] a TAP - sending letter
```

**Logs de modificador:**
```
[HOMEROW] a DOWN
[HOMEROW] Sending: #{c}
[HOMEROW] Marked a as used modifier
[HOMEROW] a UP - dur=300ms, usedAsMod=1, threshold=250ms
[HOMEROW] a was used as modifier
```

### 2. Herramientas de Testing

**Test básico de tecla:**
1. Abre Notepad
2. Habilita debug_mode
3. Presiona 'a' rápido → debe escribir 'a'
4. Mantén 'a' + presiona 'c' → debe activar Win+C

**Test de timing:**
1. Presiona y mantén 'a' por exactamente el threshold
2. Verifica en logs la duración reportada
3. Ajusta threshold según necesidad

### 3. Configuración de Test Mínima

Para aislar problemas, usa configuración mínima:

```ini
[General]
enabled=true
debug_mode=true

[Timing]
tap_threshold_ms=250
permissive_hold=false

[LeftHand]
a_modifier=Win
s_modifier=none
d_modifier=none
f_modifier=none

[RightHand]
j_modifier=none
k_modifier=none
l_modifier=none
semicolon_modifier=none

[Exclusions]
excluded_apps=
```

## Escenarios de Troubleshooting

### Escenario 1: Usuario nuevo - nada funciona

1. **Verificar que está habilitado:**
   ```ini
   enabled=true
   ```

2. **Usar configuración mínima** (solo tecla 'a')

3. **Test en Notepad** con debug habilitado

4. **Verificar logs** para confirmar registro de hotkeys

### Escenario 2: Funcionaba antes, ahora no

1. **Verificar cambios recientes** en configuración

2. **Recargar HybridCapsLock** completamente

3. **Verificar conflictos** con nuevos programas

4. **Revisar exclusions** - quizás se agregó app actual

### Escenario 3: Funciona parcialmente

1. **Test tecla por tecla** para identificar cuáles fallan

2. **Verificar asignaciones** de modificadores

3. **Test en diferentes apps** para aislar problemas de compatibilidad

### Escenario 4: Problemas de rendimiento

1. **Deshabilitar debug_mode** si estaba habilitado

2. **Reducir número de teclas activas**

3. **Verificar exclusions** para apps pesadas

## Casos Extremos

### Home Row + CapsLock

Si usas tanto Home Row Mods como CapsLock Layer:

1. **Evitar conflictos:**
   ```ini
   [Exclusions]
   excluded_apps=nvim.exe  ; Si NVIM layer interfiere
   ```

2. **Test combinaciones:**
   - CapsLock + Home Row debe funcionar independientemente
   - No debe haber interferencia mutua

### Layouts No-QWERTY

Para Dvorak, Colemak, etc:

1. **Las teclas se mapean por posición física**, no lógica
2. **Verificar que las teclas físicas correctas** están siendo interceptadas
3. **Ajustar configuración si es necesario**

### Gaming

Para juegos que requieren teclas home row:

1. **Usar exclusions extensivas:**
   ```ini
   excluded_apps=steam.exe,game1.exe,game2.exe
   ```

2. **O deshabilitar temporalmente:**
   ```ini
   enabled=false
   ```

## Preguntas de Diagnóstico

Al reportar problemas, incluye:

1. **¿Qué configuración estás usando?** (contenido de homerow_mods.ini)
2. **¿En qué aplicación ocurre?** (nombre del proceso)
3. **¿Qué teclas específicas fallan?** (a, s, d, f, j, k, l, ;)
4. **¿Qué dicen los debug logs?** (con debug_mode=true)
5. **¿Funciona la configuración mínima?** (solo tecla 'a')
6. **¿Hay otras capas/hotkeys activos?** (CapsLock layer, etc.)

## Contacto y Soporte

Si el problema persiste después de seguir esta guía:

1. **Habilita debug_mode** y captura logs del problema
2. **Usa configuración mínima** para confirmar si es problema general
3. **Documenta pasos exactos** para reproducir el problema
4. **Incluye configuración** y logs en el reporte