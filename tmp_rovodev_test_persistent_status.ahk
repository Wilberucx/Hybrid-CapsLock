; ===================================================================
; DEMO DE TOOLTIPS DE ESTADO PERSISTENTE
; ===================================================================
; Prueba de los nuevos tooltips de estado en esquina inferior izquierda

#SingleInstance Force
#Warn All

; Incluir la integración C# actualizada
#Include tooltip_csharp_integration.ahk

; Variables de estado (declarar antes de los hotkeys)
global nvimActive := false
global visualActive := false
global yankActive := false
global excelActive := false

; Iniciar aplicaciones por separado
StartTooltipApp()  ; Para tooltips de opciones
StartStatusApp()   ; Para ventanas de estado
Sleep(1000)        ; Dar más tiempo para que ambas inicien

; Mostrar instrucciones
MsgBox("🎯 DEMO DE ESTADOS PERSISTENTES - VENTANAS INDEPENDIENTES`n`n" .
       "Los estados aparecen como VENTANAS INDEPENDIENTES (PowerShell + WPF)`n" .
       "en la esquina inferior izquierda con borde de acento del sistema.`n`n" .
       "📋 CONTROLES:`n" .
       "F1 - Mostrar/Ocultar NVIM`n" .
       "F2 - Mostrar/Ocultar VISUAL`n" .
       "F3 - Mostrar/Ocultar YANK`n" .
       "F4 - Mostrar/Ocultar EXCEL`n`n" .
       "F5 - Test de menú normal (centro - para comparar)`n" .
       "F6 - Test notificación temporal (para comparar)`n" .
       "ESC - Salir", "Ventanas de Estado Demo")

; ===================================================================
; HOTKEYS DE PRUEBA
; ===================================================================

; F1 - Toggle NVIM status
F1:: {
    global nvimActive
    nvimActive := !nvimActive
    ShowNvimLayerStatusCS(nvimActive)
}

; F2 - Toggle VISUAL status
F2:: {
    global visualActive
    visualActive := !visualActive
    if (visualActive) {
        ShowVisualStatus()
    } else {
        HideVisualStatus()
    }
}

; F3 - Toggle YANK status
F3:: {
    global yankActive
    yankActive := !yankActive
    if (yankActive) {
        ShowYankStatus()
    } else {
        HideYankStatus()
    }
}

; F4 - Toggle EXCEL status
F4:: {
    global excelActive
    excelActive := !excelActive
    ShowExcelLayerStatusCS(excelActive)
}

; F5 - Test menú normal (para comparar)
F5:: {
    ShowLeaderModeMenuCS()
}

; F6 - Test notificación temporal (para comparar)
F6:: {
    ShowCopyNotificationCS()
}

; ESC - Salir
Esc:: {
    ; Ocultar todos los estados
    HideNvimStatus()
    HideVisualStatus()
    HideYankStatus()
    HideExcelStatus()
    
    Sleep(500)
    StopTooltipApp()
    MsgBox("Demo terminado.`n`n✅ Estados persistentes funcionando correctamente!", "Demo Completed")
    ExitApp()
}

; Mostrar mensaje inicial
ShowCenteredToolTipCS("Presiona F1-F6 para probar ventanas de estado independientes", 3000)