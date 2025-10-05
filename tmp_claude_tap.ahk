#Requires AutoHotkey v2.0
#SingleInstance Force

; Variables globales
capsPressed := false
capsPressTime := 0
otherKeyPressed := false
layerActive := false

; Tiempo de timeout (ajustable)
TIMEOUT := 250

; ============================================
; FUNCIÓN DE LOGGING
; ============================================
Log(message)
{
    timestamp := FormatTime(A_Now, "HH:mm:ss.") . A_MSec
    OutputDebug("[" . timestamp . "] " . message)
}

; ============================================
; CAPTURA DE CAPSLOCK
; ============================================
*CapsLock::
{
    global capsPressed, capsPressTime, otherKeyPressed
    
    capsPressed := true
    capsPressTime := A_TickCount
    otherKeyPressed := false
    
    Log(">>> CapsLock PRESIONADO - Esperando release...")
    
    ; Mientras CapsLock esté presionado, actúa como modificador
    KeyWait("CapsLock")
    
    ; Calcular duración
    duration := A_TickCount - capsPressTime
    
    Log("<<< CapsLock SOLTADO - Duración: " . duration . "ms | Otra tecla usada: " . (otherKeyPressed ? "SÍ" : "NO"))
    
    ; LÓGICA DE DECISIÓN:
    ; Si se presionó otra tecla → fue usado como modificador (no hacer nada)
    ; Si NO se presionó otra tecla → evaluar si es tap o hold no usado
    if (!otherKeyPressed) {
        if (duration < TIMEOUT) {
            ; TAP CORTO → Activar/desactivar capa
            Log("→ DECISIÓN: TAP CORTO detectado (" . duration . "ms < " . TIMEOUT . "ms) - Toggling layer")
            ToggleLayer()
        } else {
            ; HOLD SIN USO → No hacer nada (evita activación accidental)
            Log("→ DECISIÓN: HOLD SIN USO detectado (" . duration . "ms >= " . TIMEOUT . "ms) - No action")
            ; Opcionalmente podrías poner un beep o tooltip de feedback
            ; ToolTip("Hold sin uso detectado")
            ; SetTimer(() => ToolTip(), -1000)
        }
    } else {
        Log("→ DECISIÓN: Fue usado como MODIFICADOR - No action (otra tecla presionada)")
    }
    
    capsPressed := false
}

; ============================================
; DETECCIÓN DE OTRAS TECLAS
; ============================================
; Hook para detectar cuando se presiona cualquier otra tecla
; mientras CapsLock está abajo
#HotIf capsPressed

; Teclas comunes (expande según necesites)
a::
{
    CapsModifier("a")
}

b::
{
    CapsModifier("b")
}

c::
{
    CapsModifier("c")
}

d::
{
    CapsModifier("d")
}

e::
{
    CapsModifier("e")
}

f::
{
    CapsModifier("f")
}

g::
{
    CapsModifier("g")
}

h::
{
    CapsModifier("h")
}

i::
{
    CapsModifier("i")
}

j::
{
    CapsModifier("j")
}

k::
{
    CapsModifier("k")
}

l::
{
    CapsModifier("l")
}

m::
{
    CapsModifier("m")
}

n::
{
    CapsModifier("n")
}

o::
{
    CapsModifier("o")
}

p::
{
    CapsModifier("p")
}

q::
{
    CapsModifier("q")
}

r::
{
    CapsModifier("r")
}

s::
{
    CapsModifier("s")
}

t::
{
    CapsModifier("t")
}

u::
{
    CapsModifier("u")
}

v::
{
    CapsModifier("v")
}

w::
{
    CapsModifier("w")
}

x::
{
    CapsModifier("x")
}

y::
{
    CapsModifier("y")
}

z::
{
    CapsModifier("z")
}

; Números
1::
{
    CapsModifier("1")
}

2::
{
    CapsModifier("2")
}

3::
{
    CapsModifier("3")
}

4::
{
    CapsModifier("4")
}

5::
{
    CapsModifier("5")
}

6::
{
    CapsModifier("6")
}

7::
{
    CapsModifier("7")
}

8::
{
    CapsModifier("8")
}

9::
{
    CapsModifier("9")
}

0::
{
    CapsModifier("0")
}

; Flechas
Left::
{
    CapsModifier("Left")
}

Right::
{
    CapsModifier("Right")
}

Up::
{
    CapsModifier("Up")
}

Down::
{
    CapsModifier("Down")
}

; Símbolos comunes
Space::
{
    CapsModifier("Space")
}

Enter::
{
    CapsModifier("Enter")
}

Backspace::
{
    CapsModifier("Backspace")
}

#HotIf

; ============================================
; FUNCIÓN MODIFICADORA
; ============================================
CapsModifier(key)
{
    global otherKeyPressed
    otherKeyPressed := true
    
    Log("  ⚡ CapsModifier activado con tecla: " . key)
    
    ; AQUÍ DEFINES QUÉ HACE CAPSLOCK + CADA TECLA
    ; Ejemplo: CapsLock + H/J/K/L como flechas (Vim-style)
    
    switch key {
        case "h": 
            Log("    → Enviando: Left")
            Send("{Left}")
        case "j": 
            Log("    → Enviando: Down")
            Send("{Down}")
        case "k": 
            Log("    → Enviando: Up")
            Send("{Up}")
        case "l": 
            Log("    → Enviando: Right")
            Send("{Right}")
        
        ; CapsLock + números = F-keys
        case "1": 
            Log("    → Enviando: F1")
            Send("{F1}")
        case "2": 
            Log("    → Enviando: F2")
            Send("{F2}")
        case "3": 
            Log("    → Enviando: F3")
            Send("{F3}")
        case "4": 
            Log("    → Enviando: F4")
            Send("{F4}")
        case "5": 
            Log("    → Enviando: F5")
            Send("{F5}")
        case "6": 
            Log("    → Enviando: F6")
            Send("{F6}")
        case "7": 
            Log("    → Enviando: F7")
            Send("{F7}")
        case "8": 
            Log("    → Enviando: F8")
            Send("{F8}")
        case "9": 
            Log("    → Enviando: F9")
            Send("{F9}")
        case "0": 
            Log("    → Enviando: F10")
            Send("{F10}")
        
        ; CapsLock + WASD = navegación alternativa
        case "w": 
            Log("    → Enviando: Up")
            Send("{Up}")
        case "a": 
            Log("    → Enviando: Left")
            Send("{Left}")
        case "s": 
            Log("    → Enviando: Down")
            Send("{Down}")
        case "d": 
            Log("    → Enviando: Right")
            Send("{Right}")
        
        ; Por defecto, enviar Ctrl + tecla
        default: 
            Log("    → Enviando: Ctrl+" . key)
            Send("^" key)
    }
}

; ============================================
; SISTEMA DE CAPA (LAYER)
; ============================================
ToggleLayer()
{
    global layerActive
    layerActive := !layerActive
    
    if (layerActive) {
        Log("🔵 CAPA ACTIVADA")
        ToolTip("🔵 Capa Activada")
        SetTimer(() => ToolTip(), -1500)
        ; Aquí puedes activar hotkeys adicionales
    } else {
        Log("⚪ CAPA DESACTIVADA")
        ToolTip("⚪ Capa Desactivada")
        SetTimer(() => ToolTip(), -1500)
        ; Desactivar hotkeys de la capa
    }
}

; ============================================
; REMAPEOS DE LA CAPA (cuando está activa)
; ============================================
#HotIf layerActive

; Ejemplo: En la capa, las teclas de inicio se convierten en símbolos
q::
{
    Send("{!}")
}

w::
{
    Send("{@}")
}

e::
{
    Send("{#}")
}

r::
{
    Send("{$}")
}

t::
{
    Send("{%}")
}

; Números en la fila superior se convierten en símbolos
1::
{
    Send("{!}")
}

2::
{
    Send("{@}")
}

3::
{
    Send("{#}")
}

4::
{
    Send("{$}")
}

5::
{
    Send("{%}")
}

6::
{
    Send("{^}")
}

7::
{
    Send("{&}")
}

8::
{
    Send("{*}")
}

9::
{
    Send("{(}")
}

0::
{
    Send("{)}")
}

; Presionar ESC o CapsLock nuevamente desactiva la capa
Esc::
{
    global layerActive
    layerActive := false
    ToolTip("⚪ Capa Desactivada (ESC)")
    SetTimer(() => ToolTip(), -1500)
}

#HotIf

; ============================================
; INFO DE DEPURACIÓN (opcional - F12 para ver estado)
; ============================================
F12::
{
    global capsPressed, layerActive, otherKeyPressed
    info := "Estado Debug:`n"
    info .= "CapsLock presionado: " (capsPressed ? "SÍ" : "NO") "`n"
    info .= "Capa activa: " (layerActive ? "SÍ" : "NO") "`n"
    info .= "Otra tecla usada: " (otherKeyPressed ? "SÍ" : "NO")
    MsgBox(info)
}
