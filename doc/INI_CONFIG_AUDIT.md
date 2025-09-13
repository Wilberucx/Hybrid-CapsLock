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

- No usados actualmente (documentados pero sin efecto en el código):
  - `[General]`, `[UI]`, `[Behavior]`, `[Performance]`, `[Security]`, `[Layers]`, `[Integration]`, `[Advanced]`, `[CustomHotkeys]`, `[ApplicationProfiles]`, `[Troubleshooting]`.
  - Ejemplos concretos:
    - `[Behavior]`: `caps_lock_acts_normal`, `global_timeout_seconds`, `leader_timeout_seconds`
      - Los menús usan `InputHook("L1 T10")` (10s) hardcodeado; no leen estos timeouts. [Wilber: Debemos implementar esta funcionalidad para próximas versiones con tal de añadir granularidad y control de la herramienta.]
    - `[Layers]`: `nvim_layer_enabled`, `excel_layer_enabled`, `modifier_layer_enabled`, `leader_layer_enabled`, `enable_layer_persistence`
      - No hay lecturas de estas flags; los estados de capa se controlan en runtime. [Wilber: Vamos a implementar esta funcionalidad en próximas versiones.]
    - `[Integration]`: `zebar_status_file`, `enable_json_status`, `status_update_interval`, `external_commands_enabled`
      - El estado JSON se escribe siempre en `data/layer_status.json` fijo; no se usan estas claves. [Wilber: Vamos a eliminar esta integración ya que está obsoleta por la integración de C# con tooltips modernos]
    - `[Advanced]`: `nvim_shift_touchpad_scroll` aparece en `ReadConfigValue`, pero esa función no se utiliza para aplicar comportamiento. [Wilber: Vamos a mantener esta pero en espera para desarrollarla mejor.]

### 2) `config/programs.ini`

- En uso:
  - `[Programs]`: rutas/URIs de apps.
  - `[ProgramMapping]`: `key_<letra>=ProgramName`.
  - `[MenuDisplay]`: `line1..lineN` para construir el menú.

- No usados:
  - `[Settings]`: `timeout_seconds`, `show_confirmation`, `auto_launch`, `search_in_path`, `show_launch_feedback`, `feedback_duration`.
    - Los flujos de UI/tiempos/feedback están hardcodeados; no se consultan estas flags. [Wilber: Vamos a implementar esta funcionalidad en próximas versiones.]

### 3) `config/information.ini`

- En uso:
  - `[PersonalInfo]`: contenidos a insertar.
  - `[InfoMapping]`: `key_<letra>=InfoName`.
  - `[MenuDisplay]`: `info_line1..N`.

- No usados:
  - `[Settings]`: `timeout_seconds`, `show_confirmation`, `auto_paste`. [Wilber: Vamos a implementar esta funcionalidad en próximas versiones.]
    - El timeout de menú es fijo; la inserción es inmediata; el feedback se muestra siempre.

### 4) `config/timestamps.ini`

- En uso:
  - `[DateFormats]`, `[TimeFormats]`, `[DateTimeFormats]`: `default` y `format_X`.
  - `[MenuDisplay]`: `date_lineX`, `time_lineX`, `datetime_lineX`.

- No usados:
  - `[Settings]`: `timeout_seconds`, `show_confirmation`, `auto_insert`, `preview_format`, `remember_last_format`, `feedback_duration`. [Wilber: Vamos a implementar esta funcionalidad en próximas versiones.]
    - El timeout de menú es fijo; la inserción es inmediata; el feedback se muestra siempre; no hay preview ni persistencia de formato.
      [Wilber: He visto varias veces la variable `show_confirmation`; este es un poco complicado de implementar, pero vamos a ver cómo lo hacemos.]

### 5) `config/commands.ini`

- En uso:
  - `[MenuDisplay]`: `main_lineX`, `system_lineX`, `network_lineX`, `git_lineX`, `monitoring_lineX`, `folder_lineX`, `windows_lineX`, `vaultflow_lineX` (para mostrar texto de menú cuando están presentes).

- No usados: [Wilber: Debemos trabajar en esta funcionalidad para próximas versiones.]
  - `[CustomCommands]`, `[CustomCategories]`: no existe lógica para ejecutar comandos dinámicos definidos aquí.
  - `[Settings]`: `show_output`, `close_on_success`, `timeout_seconds`, `enable_custom_commands`.
  - `[CategorySettings]`: `*_timeout`, `show_execution_feedback`, `feedback_duration`, `auto_close_terminals`.
  - `power_lineX` (en `[MenuDisplay]`): el submenú de Power Options está hardcodeado en el código y no lee estas líneas.

- Desajuste de teclas (si se habilitara lectura configurable):
  - En el código, Shutdown usa `"S"` (Shift+s). En `commands.ini` aparece como `u - Shutdown`. Hoy no impacta porque se ignora el ini para ese submenú, pero conviene alinear si se hace dinámico.
    [Wilber: Vamos a mantener este hardcodeado por ahora, pero alineemos esto para cuando empecemos a trabajar en esta funcionalidad.]

### 6) `config/obsidian.ini`

- Estado: marcado como "EN DESARROLLO - NO FUNCIONAL" y no utilizado por el script actual. [Wilber: Vamos a mantener este archivo en espera hasta que decidamos el alcance de la integración con Obsidian.]

---

## Hallazgos transversales

- Timeouts: la documentación sugiere jerarquía (global, leader, por capa), pero:
  - Menús nativos usan `InputHook("L1 T10")` (10s) fijo.
  - Los menús C# sí respetan `Tooltips.options_menu_timeout` (global), pero no `timeout_seconds` por capa.
    [Wilber: Vamos a implementar que tanto el tooltip como los `InputHook` usen estos timeouts jerárquicos por igual para que no haya una desincronización, pero dejémoslo así para trabajar a futuro.]
- Flags por capa (`auto_paste`, `auto_launch`, `show_confirmation`, `feedback_duration`, `remember_last_format`, etc.) no están conectadas a la lógica.
- Habilitar/deshabilitar capas desde `[Layers]` no tiene efecto; los hotkeys/estados se activan siempre.
- Integración Zebar: eliminada del proyecto (código no-op y documentación actualizada).
- Menús configurables vs ejecución: los textos se pueden cargar desde `.ini`, pero la ejecución de comandos está fijada por `switch` (no usa `[CustomCommands]`).

## Comentarios

Te dejo los comentarios en línea con [Wilber: ...] para que los revises y me digas si estás de acuerdo con los planes propuestos o si quieres ajustar algo.

---

## Sección de trabajo interno (Rovo Dev ↔ Wilber)

Nota: Los comentarios `[Wilber: ...]` en este documento son anotaciones internas pensadas para nuestra coordinación. Esta sección agrupa los primeros pasos accionables basados en esos comentarios.

### Iteración 1 — Timeouts jerárquicos (Fase 1)

Correcciones recientes (aplicadas):
- StartPersistentBlindSwitch: se reemplazó el uso de `currentMenu` (no definido en ese contexto) por la capa `"windows"`.
- Se corrigió la asignación del InputHook: ahora `ih := InputHook(...)` antes de `ih.Start()`/`ih.Wait()`.
- Progreso: líder y timestamps usan timeouts jerárquicos; pendiente commands.
- Sanitización aplicada: ahora los timeouts leídos desde `.ini` toleran comentarios inline (`; ...`) y espacios, evitando errores de conversión numérica.
- Definir función `GetEffectiveTimeout(layer)` con jerarquía:
  1) `*.ini` de la capa → `[Settings] → timeout_seconds`
  2) `configuration.ini` → `[Behavior]` → `leader_timeout_seconds`/`global_timeout_seconds`
  3) Default (10s)
- Aplicar en menús nativos (InputHook) y sincronizar con menús C# (usar mismo valor efectivo).

### Iteración 2 — Flags de habilitación de capas (Fase 2)
- Leer `[Layers]` (`*_layer_enabled`) en el arranque y condicionar el registro/activación de hotkeys/menús.
- (Opcional) Persistencia con `enable_layer_persistence` si decidimos implementarla.

### Iteración 3 — Settings por capa (Fase 3)
- Programs: `auto_launch`, `show_confirmation`, `show_launch_feedback`, `feedback_duration`, `search_in_path`.
- Information: `auto_paste`, `show_confirmation`, `feedback_duration`.
- Timestamps: `auto_insert`, `preview_format`, `remember_last_format`, `feedback_duration`.

### Iteración 4 — Commands dinámicos (Fase 4)
- Soportar `[CustomCommands]` (`ps:`/`cmd:`/`ahk:`) y `[CustomCategories]` para construir menús y ejecutar.
- Definir estrategia para Power Options: o leer `power_lineX` o mantener hardcode y documentar.
- Alinear teclas (p. ej., `Shutdown` `S` vs `u`).

### Iteración 5 — Integración Zebar (Fase 5)
- Completado: Integración eliminada. `UpdateLayerStatus()` ahora es no-op, variables asociadas removidas y documentación limpiada.

### Iteración 6 — Obsidian (Fase 6)
- Definir alcance mínimo viable o mantener en espera hasta decisión.

### Checklist de acción
- [ ] F1: Reemplazar timeouts hardcodeados por jerárquicos y sincronizados con C#.
- [ ] F2: Aplicar `*_layer_enabled` y revisar persistencia.
- [ ] F3: Conectar settings por capa (Programs/Information/Timestamps).
- [ ] F4: Habilitar `CustomCommands`/`CustomCategories` y revisar `power_lineX`.
- [x] F5: Integración Zebar eliminada (no-op en código y docs actualizadas).
- [ ] F6: Decidir estrategia para `obsidian.ini`.
