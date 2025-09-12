# Test simple para verificar que PowerShell + WPF funciona
Add-Type -AssemblyName PresentationFramework

# Crear ventana de prueba
$window = New-Object System.Windows.Window
$window.Title = "Test Status"
$window.Width = 100
$window.Height = 50
$window.Left = 20
$window.Top = 500
$window.WindowStyle = "None"
$window.Topmost = $true
$window.Background = "Red"

# Mostrar por 3 segundos
$window.Show()
Start-Sleep -Seconds 3
$window.Close()

Write-Host "Test completado - si viste una ventana roja, PowerShell + WPF funciona"