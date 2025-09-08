# StatusWindow_Simple.ps1 - Versión muy básica para identificar errores
Write-Host "=== INICIANDO StatusWindow Simple ==="

# Test 1: Verificar PowerShell básico
Write-Host "Test 1: PowerShell funcionando"

# Test 2: Verificar assemblies WPF
Write-Host "Test 2: Cargando assemblies WPF..."
try {
    Add-Type -AssemblyName PresentationFramework
    Write-Host "✅ PresentationFramework cargado"
    
    Add-Type -AssemblyName PresentationCore  
    Write-Host "✅ PresentationCore cargado"
    
    Add-Type -AssemblyName WindowsBase
    Write-Host "✅ WindowsBase cargado"
} catch {
    Write-Host "❌ ERROR cargando assemblies: $($_.Exception.Message)"
    Read-Host "Presiona Enter para continuar..."
    exit 1
}

# Test 3: Crear ventana básica
Write-Host "Test 3: Creando ventana básica..."
try {
    $window = New-Object System.Windows.Window
    $window.Title = "Test Simple"
    $window.Width = 200
    $window.Height = 100
    $window.Left = 100
    $window.Top = 100
    $window.Background = "Red"
    Write-Host "✅ Ventana creada"
} catch {
    Write-Host "❌ ERROR creando ventana: $($_.Exception.Message)"
    Read-Host "Presiona Enter para continuar..."
    exit 1
}

# Test 4: Mostrar ventana
Write-Host "Test 4: Mostrando ventana..."
try {
    $window.Show()
    Write-Host "✅ Ventana mostrada - deberías ver una ventana roja"
} catch {
    Write-Host "❌ ERROR mostrando ventana: $($_.Exception.Message)"
    Read-Host "Presiona Enter para continuar..."
    exit 1
}

# Test 5: Mantener ventana por 5 segundos
Write-Host "Test 5: Manteniendo ventana por 5 segundos..."
Start-Sleep -Seconds 5

# Test 6: Cerrar ventana
Write-Host "Test 6: Cerrando ventana..."
try {
    $window.Close()
    Write-Host "✅ Ventana cerrada"
} catch {
    Write-Host "❌ ERROR cerrando ventana: $($_.Exception.Message)"
}

Write-Host "=== TODOS LOS TESTS COMPLETADOS ==="
Write-Host "Si llegaste hasta aquí, PowerShell + WPF funciona correctamente"
Read-Host "Presiona Enter para salir..."