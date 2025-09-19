# Auditoría de Configuración (.ini) de HybridCapsLock

Este documento resume el estado actual de uso de los archivos de configuración `.ini`, los hallazgos de entradas que hoy no tienen efecto, y un borrador de plan para alinear la intención documentada con lo implementado en el código.

Nota de terminología: En esta documentación usamos el término "leader" para referirnos a la combinación `CapsLock + Space`.

---

## Alcance y Metodología

- Archivos revisados:
  - `config/configuration.ini`
  - `config/programs.ini`
  - `config/information.ini`
  - `config/timestamps.ini`
  - `config/commands.ini`
  - `config/obsidian.ini`
- Código revisado (AutoHotkey v2):
  - `HybridCapsLock.ahk`
  - `tooltip_csharp_integration.ahk`
- Criterio: detectar qué claves se leen y aplican realmente (p. ej., `IniRead(...)`) y qué claves permanecen sin uso efectivo.

---

## Estado actual por archivo

### 1) `config/configuration.ini`

- En uso real (a través de `tooltip_csharp_integration.ahk` → sección `[Tooltips]`):
  - `enable_csharp_tooltips`
  - `options_menu_timeout`
  - `status_notification_timeout`
  - `auto_hide_on_action`
  - `persistent_menus`
  - `tooltip_fade_animation`
  - `tooltip_click_through`

- En uso real (a través de `HybridCapsLock.ahk` → sección `[Layers]`):
  - `nvim_layer_enabled`, `excel_layer_enabled`, `modifier_layer_enabled`, `leader_layer_enabled`
  - `enable_layer_persistence` (nuevo: activa/desactiva persistencia de estado entre sesiones)

- En uso real (a través de `HybridCapsLock.ahk` → sección `[Behavior]`):
  - `global_timeout_seconds`, `leader_timeout_seconds`

- No usados actualmente (documentados pero sin efecto en el código):
  - `[General]`, `[UI]`, `[Performance]`, `[Security]`, `[Advanced]`, `[CustomHotkeys]`, `[ApplicationProfiles]`, `[Troubleshooting]`.
  - Ejemplos concretos (mantienen el diagnóstico original):
    - `[Advanced]`: `nvim_shift_touchpad_scroll` aparece en `ReadConfigValue`, pero no define comportamiento hoy.

### 2) `config/programs.ini`

- En uso:
  - `[Programs]`: rutas/URIs de apps.
  - `[ProgramMapping]`: `key_<letra>=ProgramName`.
  - `[MenuDisplay]`: `line1..lineN` para construir el menú.

- Iteración 3 (acotado):
  - `[Settings]` efectivo: `auto_launch` (por defecto `true`), `show_confirmation` (por defecto `false`).
  - Descartados: `timeout_seconds`, `search_in_path`, `show_launch_feedback`, `feedback_duration`.

### 3) `config/information.ini`

- En uso:
  - `[PersonalInfo]`: contenidos a insertar.
  - `[InfoMapping]`: `key_<letra>=InfoName`.
  - `[MenuDisplay]`: `info_line1..N`.

- Iteración 3 (acotado):
  - `[Settings]` efectivo: `show_confirmation` (por defecto `false`).
  - Descartados: `timeout_seconds`, `auto_paste`, `feedback_duration`.

### 4) `config/timestamps.ini`

- En uso:
  - `[DateFormats]`, `[TimeFormats]`, `[DateTimeFormats]`: `default` y `format_X`.
  - `[MenuDisplay]`: `date_lineX`, `time_lineX`, `datetime_lineX`.

- Iteración 3 (acotado):
  - `[Settings]` efectivo: `show_confirmation` (por defecto `false`).
  - Descartados: `timeout_seconds`, `auto_insert`, `preview_format`, `remember_last_format`, `feedback_duration`.

### 5) `config/commands.ini`

- En uso:
  - `[MenuDisplay]`: `main_lineX`, `system_lineX`, `network_lineX`, `git_lineX`, `monitoring_lineX`, `folder_lineX`, `windows_lineX`, `vaultflow_lineX` (para mostrar texto de menú cuando están presentes).

- Pendiente (Iteración 4):
  - `[CustomCommands]`, `[CustomCategories]`: aún no hay ejecución dinámica.
  - `[Settings]`: `show_output`, `close_on_success`, `timeout_seconds`, `enable_custom_commands`.
  - `[CategorySettings]`: `*_timeout`, `show_execution_feedback`, `feedback_duration`, `auto_close_terminals`.
  - `power_lineX` (en `[MenuDisplay]`): el submenú de Power Options sigue hardcodeado.

### 6) `config/obsidian.ini`

- Estado: marcado como "EN DESARROLLO - NO FUNCIONAL".

---

## Hallazgos transversales

- Timeouts jerárquicos: implementados para menús nativos (InputHook) y sincronizados con menús C# a través de la misma jerarquía (`GetEffectiveTimeout`).
- Flags por capa: `*_layer_enabled` conectadas y activas (leader/nvim/excel/modifier). Modifier se encapsula bajo `#HotIf (modifierLayerEnabled)` y se excluyen (`Leader` y `CapsLock+F10`).
- Persistencia de capas: implementada (opt-in por `enable_layer_persistence`). Estados persistidos: `isNvimLayerActive`, `excelLayerActive`, `capsActsNormal` en `data/layer_state.ini` con "clamps" por flags de `[Layers]`.
- Recarga en caliente: disponible desde Leader → Commands → Hybrid Management (`r` = Reload Config, `R` = Reload Script).
- Integración Zebar: ya eliminada.
- Menús configurables vs ejecución: textos se cargan desde `.ini`, ejecución de comandos sigue por `switch` (dinamización en Iteración 4).
- Confirmaciones en Commands: jerarquía implementada (global > categoría > comando > default de capa; per-categoría domina). Se añadió soporte per-command sensible a mayúscula/minúscula mediante alias `key_ascii_<ord>` para evitar colisiones case-insensitive en INI (ej.: HybridManagement R vs r).

## Comentarios

Los comentarios `[Wilber: ...]` del documento original se conservan como referencia histórica; los planes actualizados se reflejan en las iteraciones siguientes.

---

## Sección de trabajo interno (Rovo Dev ↔ Wilber)

### Iteración 1 — Timeouts jerárquicos (Fase 1)

Estado: Completado (ver versión anterior del documento).

### Iteración 2 — Flags de habilitación de capas (Fase 2)

Estado: Completado (gating, tooltips C#, persistencia, recarga en caliente).

### Iteración 3 — Settings por capa (Fase 3, acotado)

Decisión de alcance (acordada):
- Implementar únicamente:
  - Programs: `auto_launch` (por defecto `true`) y `show_confirmation` (por defecto `false`).
  - Information: `show_confirmation` (por defecto `false`).
  - Timestamps: `show_confirmation` (por defecto `false`).
- El resto de claves propuestas inicialmente se descartan.

Lógica efectiva propuesta:
- Regla general de confirmación: si `show_confirmation=true` → solicitar confirmación (y/n) antes de ejecutar/pegar/insertar.
- Si `show_confirmation=false` → acción inmediata.
- Nota sobre `auto_launch` (Programs):
  - Cuando `show_confirmation=false` y `auto_launch=true` (por defecto) → lanzamiento inmediato (comportamiento actual).
  - Si `show_confirmation=true`, la confirmación prevalece (se pregunta igual).

Criterios de aceptación (CA):
- CA1: Cambios en `show_confirmation` alteran el flujo (pide confirmación vs inmediato) tras `r` (Reload Config) sin reiniciar.
- CA2: En Programs, con `show_confirmation=false`, `auto_launch=true` ejecuta inmediatamente al seleccionar un programa.
- CA3: Mensajería clara: “Confirm <acción>? (y/n)” con tooltips C# o nativo, y cancelación con n/Esc.

Plan de pruebas:
- Programs: alternar `show_confirmation` (true/false) y validar confirmación/ejecución inmediata; verificar que con `show_confirmation=true` nunca se lanza sin confirmar.
- Information: alternar `show_confirmation`; confirmar que no pega si se cancela.
- Timestamps: alternar `show_confirmation`; confirmar que no inserta si se cancela.

### Iteración 4 — Commands dinámicos (Fase 4)
Estado: En progreso → Confirmaciones jerárquicas implementadas y cableadas. Resta dinamizar ejecución de CustomCommands (ejecución por switch aún presente) y `power_lineX`.

- Jerarquía `show_confirmation` (Commands):
  1) Global: `[configuration.ini] [Behavior] show_confirmation_global`
  2) Por categoría: `[commands.ini] [CategorySettings] <Friendly>_show_confirmation` (si true, fuerza confirmación y no mira per-command)
  3) Por comando: `[commands.ini] [Confirmations.<Friendly>]` clave por tecla
  4) Default de capa: `[commands.ini] [Settings] show_confirmation`
  5) Fallback: `power=true`, otros `false`

- Compatibilidad mayúscula/minúscula en per-command:
  - Añadido soporte de alias `key_ascii_<ord>` para distinguir teclas con mayúsculas/minúsculas evitando colisiones case-insensitive en INI.
  - Orden de búsqueda per-command: `key_ascii_<ord>` → `key_<char>` → clave raw.

- Power Options:
  - Estructura de `CategorySettings` y plantilla per-command documentadas. Por defecto, el control recomendado es por categoría.
  - `power_lineX` aún hardcodeado en UI nativa; pendiente decidir si se leerá de INI o se documenta como fijo.

### Iteración 5 — Integración Zebar (Fase 5)
- Completado.

### Iteración 6 — Obsidian (Fase 6)
- Pendiente de definir.

### Checklist de acción
- [x] F1: Timeouts jerárquicos.
- [x] F2: Flags por capa + Persistencia + Recarga en caliente.
- [x] F3: Settings por capa (Programs/Information/Timestamps) — alcance acotado a `auto_launch` y `show_confirmation`.
- [x] F4: Commands dinámicos — jerarquía de confirmación implementada (global > categoría > comando > default de capa). Per-category domina sobre per-command.
- [x] F5: Zebar eliminado.
- [ ] F6: Obsidian.
