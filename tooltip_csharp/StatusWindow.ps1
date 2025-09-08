# StatusWindow.ps1 - Ventana de estado persistente en PowerShell
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Crear la ventana
$window = New-Object System.Windows.Window
$window.Title = "Status"
$window.WindowStyle = "None"
$window.AllowsTransparency = $true
$window.Background = "Transparent"
$window.Topmost = $true
$window.ShowInTaskbar = $false
$window.ResizeMode = "NoResize"
$window.SizeToContent = "WidthAndHeight"
$window.WindowStartupLocation = "Manual"

# Crear el borde
$border = New-Object System.Windows.Controls.Border
$border.Background = [System.Windows.Media.Brushes]::Black
$border.BorderThickness = "2"
$border.CornerRadius = "3"
$border.Padding = "12,8"

# Intentar obtener color de acento del sistema
try {
    $accentColor = [System.Windows.SystemParameters]::WindowGlassBrush
    $border.BorderBrush = $accentColor
} catch {
    # Fallback a azul
    $border.BorderBrush = [System.Windows.Media.Brushes]::DodgerBlue
}

# Crear el texto
$textBlock = New-Object System.Windows.Controls.TextBlock
$textBlock.Text = "STATUS"
$textBlock.FontFamily = "Consolas"
$textBlock.FontSize = 12
$textBlock.FontWeight = "Bold"
$textBlock.Foreground = [System.Windows.Media.Brushes]::White
$textBlock.HorizontalAlignment = "Center"
$textBlock.VerticalAlignment = "Center"

$border.Child = $textBlock
$window.Content = $border

# Posicionar en esquina inferior izquierda
$screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
$window.Left = 20
$window.Top = $screenHeight - 100

# Inicialmente oculta
$window.Visibility = "Hidden"

# Función para actualizar el estado
function Update-Status {
    param($statusText, $show)
    
    if ($show) {
        $textBlock.Text = $statusText.ToUpper()
        $window.Visibility = "Visible"
        
        # Reposicionar después del cambio de tamaño
        $window.UpdateLayout()
        $window.Top = $screenHeight - $window.ActualHeight - 20
    } else {
        $window.Visibility = "Hidden"
    }
}

# Monitorear archivo de comandos (en directorio padre)
$statusFile = Join-Path (Split-Path $PSScriptRoot -Parent) "status_commands.json"
$global:lastWriteTime = $null

# Timer para verificar cambios en el archivo
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(100)
$timer.Add_Tick({
    if (Test-Path $statusFile) {
        $currentWriteTime = (Get-Item $statusFile).LastWriteTime
        if ($global:lastWriteTime -ne $currentWriteTime) {
            $global:lastWriteTime = $currentWriteTime
            
            try {
                Start-Sleep -Milliseconds 50  # Pequeño delay
                $jsonContent = Get-Content $statusFile -Raw -ErrorAction SilentlyContinue
                if ($jsonContent) {
                    $command = $jsonContent | ConvertFrom-Json
                    Update-Status -statusText $command.status -show $command.show
                }
            } catch {
                # Ignorar errores de lectura
            }
        }
    }
})

$timer.Start()

# Mostrar la ventana y mantener el script ejecutándose
$window.Show()

# Mantener el script ejecutándose
try {
    [System.Windows.Threading.Dispatcher]::Run()
} finally {
    $timer.Stop()
}