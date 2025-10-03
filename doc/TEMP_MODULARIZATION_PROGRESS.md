# Estado temporal de migración a módulos (HybridCapsLock v6.x)

Este documento sirve para llevar control y orden del refactor a estructura modular (src/). Se actualizará durante la migración.

## 1) Estructura y orquestador
- Orquestador: HybridCapsLock.ahk (nuevo)
- Orden de inclusión acordado:
  1. Core & Configuración: src/core/globals.ahk, src/core/config.ahk, src/core/persistence.ahk, src/core/confirmations.ahk
  2. UI: src/ui/tooltip_csharp_integration.ahk, src/ui/tooltips_native_wrapper.ahk
  3. Lógica de arranque: LoadLayerFlags(), LoadLayerState()
  4. Layers & Leader: src/layer/(leader_router, windows, programs, timestamps, information, commands, excel, nvim, modifier_mode)
- Configuración (INI) se mantiene en config/: configuration.ini, programs.ini, information.ini, timestamps.ini, commands.ini
- tooltips C# se mantienen (tooltip_csharp/ + JSONs)

## 2) Core
- globals.ahk
  - Variables globales, flags de capas y caminos INI
  - MarkCapsLockAsModifier() (nuevo)
- config.ahk
  - CleanIniNumber, CleanIniBool, ParseKeyList, KeyInList
  - LoadLayerFlags, GetEffectiveTimeout, ReadConfigValue
- persistence.ahk
  - GetLayerStateFile, EnsureLayerStateDir, SaveLayerState, LoadLayerState
- confirmations.ahk
  - ConfirmYN
  - ShouldConfirmAction/Programs/Information/Timestamp/Command
  - Helpers categorías (GetCategoryKeySymbol / NormalizeCategoryToken / fallback dinámico desde [Categories])

## 3) UI
- tooltip_csharp_integration.ahk: movido a src/ui/, operativo
- tooltips_native_wrapper.ahk: wrapper nativo + utilidades
  - ShowCenteredToolTip, RemoveToolTip, HideMenuTooltip, HideAllTooltips
  - Notificaciones/estados con fallback nativo o C#

## 4) Leader Router (src/layer/leader_router.ahk)
- Hotkey: CapsLock + Space
- Menú líder (nativo y C#)
- Submenús integrados: w (Windows), p (Programs), t (Timestamps), i (Information), c (Commands)
- Escape/Backspace: ocultan tooltips y regresan correctamente
- Desactiva Nvim al entrar en Windows (para evitar conflictos)

## 5) Capas migradas (estado)
- Windows (windows_layer.ahk)
  - ShowWindowMenu, ExecuteWindowAction, StartPersistentBlindSwitch
- Programs (programs_layer.ahk)
  - ShowProgramMenu/GenerateProgramMenuText
  - LaunchApp + resolutores (registry/PATH)
  - QuickShare (especial), ShowProgramDetails, LaunchProgramFromKey
- Timestamps (timestamps_layer.ahk)
  - ShowTimeMenu + menús de formatos
  - HandleTimestampMode(d/t/h), WriteTimestampFromKey
- Information (information_layer.ahk)
  - ShowInformationMenu, GenerateInformationMenuText
  - InsertInformationFromKey (nuevo) + ShowInformationDetails
- Commands (commands_layer.ahk)
  - Menú principal dinámico (BuildCommandsMainMenuText)
  - Menú de categoría dinámico (ShowDynamicCommandsMenu) usando nuevo esquema: [Categories] + [<key>_category]
  - Dispatcher dinámico (HandleCommandCategory):
    - Intenta _action/@alias vía ResolveAndExecuteCustomAction (con flags y placeholders) y confirmaciones
    - Fallbacks hardcoded migrados: system, network, git, monitoring, folder, windows, power, adb, vaultflow, hybrid
  - Helpers: SymToInternal (con fallback dinámico), LoadCommandFlags, ExpandPlaceholders, ParseEnvList, ExecuteCustomCommand
- Modifier Mode (modifier_mode.ahk)
  - Núcleo migrado (ventana, navegación, scroll, atajos comunes, pestañas, mouse-like, back/copy/snip/ctrl+enter)
  - Hotkeys normalizados a bloques multilínea
  - Teclas especiales '; y ' mapeadas por scancode (sc027, sc028) para evitar parse errors

## 6) Decisiones y convenciones
- Archivo de configuración: se mantiene formato INI (no se migra a YAML/JSON para configuración principal)
- Los tooltips C# continúan usando JSON para comunicación UI
- Esquema Commands: se adopta el nuevo (Categories + <key>_category + _action/@alias + flags)
- Nombres y rutas: src/core, src/ui, src/layer (consistente)

## 7) Puntos pendientes (próximos)

- Capa Modifier (hjkl): Soportar modificadores combinados sobre flechas
  - Objetivo: que al usar las teclas de navegación `hjkl` (flechas) en la capa Modificador, puedan acompañarse de modificadores (Ctrl/Alt/Shift/Win) y se envíe la flecha con esos modificadores.
  - Ejemplos: `Alt+h` → envía `Alt+Left`, `Shift+j` → envía `Shift+Down`, `Ctrl+k` → `Ctrl+Up`, `Win+l` → `Win+Right`.
  - Comportamiento: inteligente y sin configuración adicional; detectar dinámicamente los modificadores activos al momento de presionar `CapsLock & h/j/k/l` y construir la combinación de envío adecuada.
  - Excepciones: respetar atajos reservados estándar (p. ej., `Ctrl+a`, `Ctrl+c`). Si se detecta conflicto explícito, no aplicar la regla de flecha con modificadores. El caso `Ctrl+Shift+c` se deja pendiente para definir.
  - Aceptación: combinaciones funcionan en aplicaciones comunes sin romper atajos reservados; soporte de múltiples modificadores simultáneos; opcionalmente activable por flag si se requiere.
  - Diseño sugerido: wrapper único para `hjkl` que evalúe `GetKeyState("Ctrl/Alt/Shift/Win", "P")` y construya el prefijo (`^`, `!`, `+`, `#`) concatenado con la flecha correspondiente; futura lista de excepciones configurable.
- [HECHO] Click sostenido: liberar LButton al soltar ';' (sc027 up) y CapsLock up
- [HECHO] Migrar Excel layer (excel_layer.ahk) y toggle desde Leader (n)
- Migrar Nvim layer (nvim_layer.ahk) y sus submodos (yank/delete/visual/insert/replace, timeouts y reactivación)
- Revisar/normalizar más hotkeys a multilínea en otras capas si fuera necesario
- Validaciones en Commands: feedback cuando falten secciones [<key>_category] o keys en order
- QA adicional de confirmaciones (ShouldConfirmCommand) sobre categorías personalizadas

## 8) Problemas encontrados y soluciones
- Warning por variables globales no asignadas (CommandsIni): resuelto definiendo rutas en src/core/globals.ahk y orden de includes.
- ShowCenteredToolTip/RemoveToolTip no definidos en confirmaciones: creado wrapper nativo (src/ui/tooltips_native_wrapper.ahk) e incluido antes de confirmations.
- Escape/Backspace no ocultaban tooltips: añadidas HideMenuTooltip/HideAllTooltips y llamadas en Leader/menús.
- Tooltip nativo de Commands no mostraba opciones: dependía de [MenuDisplay]. Se implementó ShowDynamicCommandsMenu() que lee la nueva estructura ([Categories] + [<key>_category]).
- "Unknown category" para categorías personalizadas (t=Tools/x=Examples):
  - Se agregó fallback dinámico en GetCategoryKeySymbol/SymToInternal y resolución directa desde [Categories] en HandleCommandCategory.
- Errores de sintaxis en try/catch: algunos intérpretes v2 rechazan catch vacío; se eliminaron try/catch innecesarios o se tiparon correctamente.
- Errores por hotkeys en una sola línea: convertidos a bloques multilínea (v2-friendly) en Modifier.
- Error "& requires a variable" con ';' y ' en Modifier: reemplazados por scancodes sc027/sc028.
- Excel no aparecía ni respondía a 'n': se añadió entrada en menú Leader y handler para alternar excelLayerActive.
- Error en runtime: `excelStaticEnabled` no inicializado en algunos escenarios. Solución: inicialización por defecto `excelStaticEnabled := true` en `src/core/globals.ahk`.
- Omisión en capa Modificador: faltaban `CapsLock+Tab` (Alt+Tab) y `CapsLock+2` (Ctrl+Alt+Shift+2). Solución: añadidos en `src/layer/modifier_mode.ahk` (Alt+Tab persistente como en versión anterior) y semillas en `config/modifier_layer.ini`.
- Líder ignoraba flag [Layers]: leader_layer_enabled; Solución: gate del hotkey con `#HotIf (leaderLayerEnabled)`. Resultado: al deshabilitar el flag, `CapsLock & Space` no responde.

## 9) Dinamización de capas (plan)
Objetivo: hacer mapeables Excel, Modifier y Nvim desde INIs dedicados en config/ sin hardcode en .ahk.

Arquitectura propuesta:
- Nuevo módulo: src/core/mappings.ahk
  - LoadLayerMappings(layerName, iniPath) → Dict { hotkey → actionSpec }
  - ParseActionSpec(spec) → { type: send|func|macro, payload }
  - ApplyLayerMappings(layerName, mappings, contextFn) → registro con Hotkey() y HotIf
  - UnregisterLayerMappings(layerName) → limpiar/reaplicar en reload
  - MacroRunner(steps): send/sleep/tooltip/notify/func/set
- INIs por capa: config/excel_layer.ini, config/modifier_layer.ini, config/nvim_layer.ini

Esquemas sugeridos:
- Excel (config/excel_layer.ini)
  [Settings]
  enable=true
  exit_key=+n
  [Map]
  7=send:{Numpad7}
  u=send:{Numpad4}
  w=send:{Up}
  [=send:+{Tab}
  Space=send:{F2}
  Enter=send:^{Enter}
  [Actions]
  FillRight=send:^r
  Find=send:^f

- Modifier (config/modifier_layer.ini)
  [Settings]
  enable=true
  [Map]
  h=send:{Left}
  e=send:{WheelDown 3}
  c=macro: send:^c; notify:copy
  semicolon=func:StartHoldLButton
  quote=func:RightClick
  [Scancodes]
  semicolon=sc027
  quote=sc028

- Nvim (config/nvim_layer.ini)
  [Settings]
  enable=true
  delete_timeout_ms=2000
  [Normal]
  h=send:{Left}
  d=showmenu:delete
  y=showmenu:yank
  [Visual]
  v=func:EnterVisual
  b=func:EnterBlock
  [Insert]
  i=func:EnterInsert
  a=func:EnterAppend
  [Menus]
  delete=d:Delete Line|w:Delete Word|a:Delete All
  yank=y:Yank Line|w:Yank Word|a:Yank All|p:Yank Paragraph

Registro dinámico (ejemplo):
- Excel: HotIf(() => excelLayerActive && !GetKeyState("CapsLock","P")); Hotkey(key, (*) => ExecuteAction("excel", key))
- Modifier: HotIf(() => modifierLayerEnabled); Hotkey("CapsLock & " . key, handler)
- Nvim: HotIf(() => isNvimLayerActive); tablas por modo (Normal/Visual/Insert)

Reload sin reiniciar:
- Añadir a Hybrid Management (c → h → r) una llamada a recargar mappings.

## 10) Validación rápida (checklist)
- Arranque: orquestador carga sin warnings (#Warn All) y muestra tooltip inicial
- Leader: CapsLock+Space → w/p/t/i/c/n, Esc sale, Backspace vuelve (si `leader_layer_enabled=false`, no responde)
- Windows: acciones (2/3/4/x/m/-/d/z/c/j/k)
- Programs: auto_launch y confirmaciones según programs.ini
- Timestamps: d/t/h insertan correctamente
- Information: auto_paste/confirmaciones según information.ini
- Commands: con commands.ini nuevo, submenús dinámicos; _action/@alias ejecutan; fallbacks OK
- Modifier: hotkeys operativos, click sostenido y release configurado
- Excel: toggle en Leader (n), mapeos y salida (+n)

## 11) Bitácora de cambios relevantes
- Scaffolding creado y orden de includes
- UI wrapper nativo + ocultado de tooltips (HideMenuTooltip/HideAllTooltips)
- Commands dinámico (nuevo esquema) + resolutor de acciones
- Modifier: multilínea + scancodes y release LButton
- Excel: implementado + toggle en Leader
- Gate del hotkey del Líder con `#HotIf (leaderLayerEnabled)` para aislamiento por capa y depuración

## 12) Próximo paso sugerido
- Implementar src/core/mappings.ahk y dinamizar Excel primero (plantilla INI + ApplyLayerMappings).
- Luego dinamizar Modifier y Nvim.
- Añadir hot reload de mappings desde Hybrid Management.
- Motor de mapeos genérico: agregado ApplyGenericMappings/LoadSimpleMappings; seed de modifier_layer.ini y nvim_layer.ini (Nvim deshabilitado por defecto).

## 13) Seguimiento y PRs
- PRs por bloque (core/ui; leader+windows+programs; timestamps+information; commands; modifier; nvim; excel)
- Referenciar este documento en el PR como guía de revisión
- Al finalizar, reemplazar este documento por una guía final en doc/

## 8) Validación rápida (checklist)
- Arranque: orquestador carga sin warnings (#Warn All) y muestra tooltip inicial
- Leader: CapsLock+Space → w/p/t/i/c, Esc sale, Backspace vuelve
- Windows: acciones (2/3/4/x/m/-/d/z/c/j/k)
- Programs: auto_launch y confirmaciones funcionan según programs.ini
- Timestamps: d/t/h insertan correctamente
- Information: auto_paste y confirmaciones según information.ini
- Commands: con commands.ini nuevo, submenús dinámicos; _action/@alias ejecutan
- Modifier: hotkeys básicos operativos (navegación/scroll/atajos)

## 9) Bitácora de cambios relevantes
- Scaffolding creado (src/, módulos core/ui/layer)
- tooltip_csharp_integration movido a src/ui/
- HybridCapsLock_OLD.ahk preservado
- Orquestador HybridCapsLock.ahk con orden de includes y startup logic
- Integración de escape/backspace para ocultar tooltips (HideMenuTooltip/HideAllTooltips)
- Commands: soporte dinámico nativo al nuevo esquema + resolutor de acciones dinámicas
- Modifier: normalización de hotkeys y scancodes para teclas especiales

## 10) Próximo paso sugerido
- Elegir siguiente capa a migrar (recomendado: Nvim o Excel). Implementar y validar hotkeys principales. Dejar click sostenido ajustado (LButton up) en Modifier.

## 11) Seguimiento y PRs
- Abrir PRs por bloque (core/ui; leader+windows+programs; timestamps+information; commands; modifier; nvim; excel)
- Referenciar este documento en el PR como guía de revisión
- Al finalizar, reemplazar este documento por una guía final en doc/ con enlaces a cada módulo
