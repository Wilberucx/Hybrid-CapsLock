# Fase 1: Análisis de Configuración Base

## Elementos a migrar de v1:

### Directivas iniciales (líneas 21-26):
```autohotkey
#SingleInstance, Force
#NoEnv
#Warn
StringCaseSense, On
SendMode, Input
```

### Variables globales identificadas (líneas 46-77):
- isNvimLayerActive
- _tempEditMode
- VisualMode
- leaderActive
- currentTempStatus
- tempStatusExpiry
- excelLayerActive
- capsLockWasHeld
- rightClickHeld
- scrollModeActive
- ConfigIni, ProgramsIni, TimestampsIni, InfoIni, CommandsIni, ObsidianIni
- LayerStatusFile
- _yankAwait
- capsActsNormal

### Funciones iniciales a migrar:
- ShowCenteredToolTip()
- RemoveToolTip timer
- SetCapsLockState configuration