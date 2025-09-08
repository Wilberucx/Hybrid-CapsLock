# StatusWindow_Yank.ps1 - Ventana de estado YANK
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

try {
    # Crear la ventana
    $window = New-Object System.Windows.Window
    $window.Title = "Status Yank"
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

    # Aplicar color de acento del sistema
    try {
        $border.BorderBrush = [System.Windows.SystemParameters]::WindowGlassBrush
    } catch {
        $border.BorderBrush = [System.Windows.Media.Brushes]::DodgerBlue
    }

    # Crear el texto
    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Text = "YANK"
    $textBlock.FontFamily = "Consolas"
    $textBlock.FontSize = 12
    $textBlock.FontWeight = "Bold"
    $textBlock.Foreground = [System.Windows.Media.Brushes]::White
    $textBlock.HorizontalAlignment = "Center"
    $textBlock.VerticalAlignment = "Center"

    $border.Child = $textBlock
    $window.Content = $border

    # Posicionar en esquina inferior izquierda (debajo de VISUAL)
    $screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
    $window.Left = 20
    $window.Top = $screenHeight - 180  # 80px más arriba que NVIM

    # Inicialmente oculta
    $window.Visibility = "Hidden"

    # Archivo de estado
    $statusFile = Join-Path (Split-Path $PSScriptRoot -Parent) "status_yank_commands.json"

    # Función para actualizar el estado
    function Update-Status {
        param($show)
        
        if ($show) {
            $window.Visibility = "Visible"
            $window.UpdateLayout()
            $window.Top = $screenHeight - $window.ActualHeight - 100  # 100px desde abajo
        } else {
            $window.Visibility = "Hidden"
        }
    }

    # Timer para verificar cambios en el archivo
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(200)
    $global:lastWriteTime = $null

    $timer.Add_Tick({
        if (Test-Path $statusFile) {
            $currentWriteTime = (Get-Item $statusFile).LastWriteTime
            if ($global:lastWriteTime -ne $currentWriteTime) {
                $global:lastWriteTime = $currentWriteTime
                
                try {
                    Start-Sleep -Milliseconds 50
                    $jsonContent = Get-Content $statusFile -Raw -ErrorAction SilentlyContinue
                    if ($jsonContent) {
                        $command = $jsonContent | ConvertFrom-Json
                        Update-Status -show $command.show
                    }
                } catch {
                    # Ignorar errores de lectura
                }
            }
        }
    })

    $timer.Start()

    # Mantener el script ejecutándose
    [System.Windows.Threading.Dispatcher]::Run()

} catch {
    # Ignorar errores
} finally {
    if ($timer) { $timer.Stop() }
}