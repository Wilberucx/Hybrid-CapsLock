# Home Row Mods

## ¿Qué son los Home Row Mods?

Los Home Row Mods convierten las teclas de la fila de inicio (A, S, D, F, J, K, L, ;) en teclas de doble función:

- **Tap rápido** (< 250ms): Envía la letra normalmente (a, s, d, f, j, k, l, ;)
- **Hold** (≥ 250ms) + otra tecla: Actúa como modificador (Win, Alt, Shift, Ctrl)

## Layout por Defecto

```
Mano Izquierda:              Mano Derecha:
A = Win (cuando se mantiene)  J = Ctrl (cuando se mantiene)
S = Alt (cuando se mantiene)  K = Shift (cuando se mantiene)
D = Shift (cuando se mantiene) L = Alt (cuando se mantiene)
F = Ctrl (cuando se mantiene)  ; = Win (cuando se mantiene)
```

## Beneficios

- **Ergonomía**: Los modificadores están en la posición natural de los dedos
- **Velocidad**: No necesitas mover las manos para acceder a modificadores
- **Compatibilidad**: Funciona con el tipeo normal sin interferencias

## Cómo Habilitar

1. Edita `config/homerow_mods.ini`
2. Cambia `enabled=false` a `enabled=true` en la sección `[General]`
3. Recarga HybridCapsLock

## Ejemplos de Uso

| Acción | Resultado |
|--------|-----------|
| Tap rápido en 'a' | Escribe 'a' |
| Hold 'a' + 'c' | Win+C (copiar en muchas apps) |
| Hold 's' + 'tab' | Alt+Tab (cambiar ventanas) |
| Hold 'd' + 'a' | Shift+A (escribe 'A') |
| Hold 'f' + 'z' | Ctrl+Z (deshacer) |

## Configuración

### Archivo: `config/homerow_mods.ini`

#### Sección [General]
```ini
[General]
enabled=true                 ; Habilitar/deshabilitar home row mods
debug_mode=false            ; Logs de debug para troubleshooting
```

#### Sección [Timing]
```ini
[Timing]
tap_threshold_ms=250        ; Umbral en milisegundos para tap vs hold
permissive_hold=false       ; Si true, hold sin usar aún permite escribir después
```

#### Secciones [LeftHand] y [RightHand]
```ini
[LeftHand]
a_modifier=Win              ; Opciones: Win, Alt, Shift, Ctrl, none
s_modifier=Alt
d_modifier=Shift
f_modifier=Ctrl

[RightHand]
j_modifier=Ctrl
k_modifier=Shift
l_modifier=Alt
semicolon_modifier=Win
```

#### Sección [Exclusions]
```ini
[Exclusions]
; Apps donde home row mods deben deshabilitarse
excluded_apps=notepad.exe,cmd.exe,game.exe
```

## Personalización

### Cambiar Modificadores

Para cambiar qué modificador usa cada tecla, edita las secciones `[LeftHand]` y `[RightHand]`:

```ini
[LeftHand]
a_modifier=Ctrl    ; Cambiar 'a' de Win a Ctrl
s_modifier=none    ; Deshabilitar 's' como modificador
```

### Deshabilitar Teclas Específicas

Para que una tecla funcione solo como letra normal:

```ini
d_modifier=none    ; 'd' ya no actuará como modificador
```

### Ajustar Sensibilidad

Si tienes **falsos positivos** (modificadores cuando no quieres):
```ini
tap_threshold_ms=200    ; Reducir umbral (más sensible a taps)
```

Si tienes **falsos negativos** (no detecta holds):
```ini
tap_threshold_ms=300    ; Aumentar umbral (más tiempo para hold)
```

### Modo Permisivo vs Estricto

**Modo Estricto** (`permissive_hold=false`): Si mantienes una tecla sin usarla como modificador, no hace nada.

**Modo Permisivo** (`permissive_hold=true`): Si mantienes una tecla sin usarla, aún escribe la letra.

## Resolución de Problemas

### Problema: Las teclas no responden como modificadores
**Solución**: 
1. Verifica que `enabled=true` en la configuración
2. Asegúrate de mantener la tecla por al menos 250ms
3. Habilita `debug_mode=true` para ver logs

### Problema: Interferencias al escribir rápido
**Solución**:
1. Reduce `tap_threshold_ms` (ej: 200ms)
2. Considera cambiar a `permissive_hold=true`

### Problema: No funciona en cierta aplicación
**Solución**:
1. Agrega la aplicación a `excluded_apps` si causa problemas
2. Verifica que la app no esté bloqueando hotkeys

### Problema: Conflictos con otras teclas
**Solución**:
1. Verifica que no haya conflictos con otras capas de HybridCapsLock
2. Deshabilita teclas específicas con `modifier=none`

## Compatibilidad

### Compatible con:
- ✅ CapsLock Layer (NVIM)
- ✅ Otras capas de HybridCapsLock
- ✅ Aplicaciones normales
- ✅ Juegos (si están excluidos)

### Consideraciones:
- Algunos juegos pueden necesitar ser excluidos
- Aplicaciones que capturan input a bajo nivel pueden interferir
- Editores con atajos complejos pueden necesitar ajustes

## Debug y Troubleshooting

Para diagnosticar problemas:

1. Habilita debug mode:
   ```ini
   [General]
   debug_mode=true
   ```

2. Usa una herramienta como DebugView para ver los logs
3. Los logs mostrarán:
   - Cuando se presiona/suelta una tecla
   - Duración del press
   - Si se usó como modificador
   - Decisión tomada (tap/hold/used)

## Preguntas Frecuentes

**P: ¿Interfiere con el tipeo normal?**
R: No, está diseñado para no interferir. Los taps rápidos funcionan normalmente.

**P: ¿Puedo usar múltiples modificadores al mismo tiempo?**
R: Sí, puedes mantener múltiples teclas home row para combinar modificadores (ej: Ctrl+Shift+algo).

**P: ¿Funciona con layouts de teclado no-QWERTY?**
R: Sí, funciona con la posición física de las teclas, no con su función de layout.

**P: ¿Cómo deshabilito completamente la función?**
R: Cambia `enabled=false` en `config/homerow_mods.ini` y recarga HybridCapsLock.