# Plan de Estabilización y Enfoque por Fases

Este documento propone un plan ordenado para estabilizar Hybrid CapsLock, priorizar lo que usas a diario y reintroducir mejoras de forma controlada.

Objetivos clave:
- Recuperar y mantener un "modo estable" utilizable a diario.
- Poner en orden la configuración y el estado global (evitar desincronizaciones).
- Integrar mejoras de forma gradual, con pruebas manuales simples.


## Fase 0 — Estabilización mínima (rápida)

Mantener lo que funciona de forma confiable y desactivar temporalmente lo experimental.

Acciones:
1) Tooltip solo como visual:
   - `config/configuration.ini` → `[Tooltips] tooltip_handles_input=false`
   - El Leader Router maneja la entrada (InputHook) y el tooltip solo muestra UI.
3) Desactivar temporalmente bloques experimentales por configuración si aplica.
4) Smoke tests rápidos (ver sección al final) para validar el “modo estable”.

Resultado esperado:
- El Leader + Tooltip no se desincronizan.
- Capas principales funcionan en el 80% de los casos de uso diarios.


## Fase 1 — Limpieza y orden

Acciones:
1) Consolidar flags en `config/configuration.ini`:
   - `[Tooltips] tooltip_handles_input=false` (por defecto)
   - Revisar y documentar el resto de banderas por bloque `[Layers]`.
2) Poda y consolidación de código:
   - Mover archivos legacy/experimentales a `legacy/` (sin borrar todavía).
   - Eliminar duplicaciones (ya se corrigió el conflicto de `ShowCSharpOptionsMenu`).
3) Unificar nombres/estado compartido:
   - Alinear nombres como `leaderActive`, `tooltipMenuActive`, `tooltipCurrentTitle`.
   - Revisar puntos de entrada/salida de capas para evitar estados colgados.
4) Documentar en breve cada capa: objetivo, hotkeys, flags, troubleshooting.


## Fase 2 — Integración gradual de mejoras

Reintroducir mejoras con cobertura de teclas y navegación completa, una por una.

Acciones por submenú (repetir patrón):
- Definir hotkeys específicos del submenú (solo cuando el tooltip muestre ese título).
- Mapear teclas a funciones existentes (ej.: `ExecuteWindowAction`, `LaunchProgramFromKey`, `HandleTimestampMode`, `InsertInformationFromKey`).
- Implementar navegación sólida:
  - `\\` para volver
  - `Esc` para cerrar
  - Timeout consistente
- Probar manualmente con el checklist.

Orden sugerido:
1) Command Palette
2) Programs
3) Windows
4) Timestamps (Date/Time/Date+Time)
5) Information
6) NVIM layer (si aplica)


## Fase 3 — Pulido y publicación

Acciones:
1) Manual de pruebas mínimo (ver blueprint abajo). Actualizar `doc/MANUAL_TESTS.md` o crear `doc/SMOKE_TESTS.md`.
2) Ajustes de performance/fiabilidad:
   - Evitar estados colgados: cerrar tooltips al salir/volver; limpiar banderas.
   - Claridad en logs `OutputDebug` (debug selectivo por módulo).
3) Cerrado de temas abiertos y release.


## Perfil de configuración estable (sugerido)

`config/configuration.ini`:
- `[Tooltips]`
  - `tooltip_handles_input=false`
  - `enable_csharp_tooltips=true` (si prefieres las WPF; puedes usar nativo si lo deseas)
- `[Layers]`
  - Activar/desactivar capas según tu uso diario (Programs, Windows, Timestamps, Information, NVIM).


## Checklist de Smoke Tests (rápido)

1) Leader básico
- Abrir Leader, navegar a Command Palette y volver con `\\`.
- Ejecutar 2 comandos (por ejemplo, abrir Notepad y otro).
- `Esc` debe salir sin trabas.

2) Tooltip (solo visual)
- Ver que el título del tooltip corresponde al nivel real.
- Cambiar entre menús y que el tooltip se actualice o cierre a tiempo.

3) Programs
- Lanzar Notepad y VS Code (o tus programas comunes).

5) Windows
- Ejecutar al menos 2 acciones (focus/tile) y validar que no se queda colgado.

6) Timestamps
- Insertar fecha/hora/fecha+hora.

7) Information
- Insertar 1-2 snippets simples.


## Tareas sugeridas (Jira/To-Do)

- Fase 0: Estabilización
  - [ ] Asegurar `tooltip_handles_input=false` y recargar
    - [ ] Correr Smoke Tests (checklist arriba)

- Fase 1: Limpieza
  - [ ] Mover archivos legacy/experimentales a `legacy/`
  - [ ] Auditar duplicaciones y conflictos de funciones
  - [ ] Revisar estado compartido entre Leader/Tooltip
  - [ ] Documentar por capa (uso y flags)

- Fase 2: Integración gradual
  - [ ] COMMAND PALETTE (captura por tooltip)
  - [ ] PROGRAMS (captura por tooltip)
  - [ ] WINDOWS (captura por tooltip)
  - [ ] TIMESTAMPS (captura por tooltip)
  - [ ] INFORMATION (captura por tooltip)

- Fase 3: Pulido
  - [ ] Actualizar `doc/MANUAL_TESTS.md` o crear `doc/SMOKE_TESTS.md`
  - [ ] Revisar logs y performance
  - [ ] Preparar release


## Notas finales
- Priorizar HomeRow y Leader/Commands para uso diario.
- Reintroducir mejoras con hotkeys contextualizados al título del tooltip, manteniendo navegación consistente.
- Mantener debug selectivo durante la estabilización para identificar problemas rápido.
