# Fase 2: Análisis del Modo Modificador

## Hotkeys a migrar del archivo original:

### Funciones de Ventana (líneas 83-96):
```autohotkey
CapsLock & 1::WinMinimize, A
CapsLock & `::Send, #m
CapsLock & q::Send, !{F4}
CapsLock & f:: ; Maximizar/Restaurar toggle
```

### Navegación Básica (líneas 113-116):
```autohotkey
CapsLock & h::Send, {Left}
CapsLock & j::Send, {Down}
CapsLock & k::Send, {Up}
CapsLock & l::Send, {Right}
```

### Smooth Scrolling (líneas 119-120):
```autohotkey
CapsLock & e::Send, {WheelDown}{WheelDown}{WheelDown}
CapsLock & d::Send, {WheelUp}{WheelUp}{WheelUp}
```

### Atajos Comunes (líneas 188-210):
```autohotkey
CapsLock & a::Send, ^a
CapsLock & s::Send, ^s
CapsLock & c::Send, ^c
CapsLock & v::Send, ^v
CapsLock & z::Send, ^z
CapsLock & x::Send, ^x
CapsLock & y::Send, ^y
CapsLock & r::Send, ^r
CapsLock & t::Send, ^t
CapsLock & n::Send, ^n
CapsLock & o::Send, ^o
```

### Alt+Tab Mejorado (líneas 97-110):
```autohotkey
CapsLock & Tab::
    Send, {Alt down}{Tab}
    KeyWait, Tab
    While GetKeyState("CapsLock", "P") {
        if GetKeyState("Tab", "P") {
            Send, {Tab}
            KeyWait, Tab
        }
        Sleep, 10
    }
    Send, {Alt up}
return
```

## Cambios necesarios para v2:
1. Send syntax: Send, {key} → Send("{key}")
2. WinMinimize, A → WinMinimize("A")
3. KeyWait, key → KeyWait("key")
4. GetKeyState("key", "P") → GetKeyState("key", "P") (sin cambios)
5. Sleep, ms → Sleep(ms)
6. return statements → no necesarios en funciones