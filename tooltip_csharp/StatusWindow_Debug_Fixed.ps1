# StatusWindow_Debug_Fixed.ps1 - Version corregida
Write-Host "=== INICIANDO StatusWindow Debug ==="

try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Write-Host "Assemblies WPF cargados correctamente"
} catch {
    Write-Host "Error cargando assemblies WPF: $($_.Exception.Message)"
    exit 1
}

try {
    # Crear la ventana
    $window = New-Object System.Windows.Window
    $window.Title = "Status Debug"
    $window.WindowStyle = "None"
    $window.AllowsTransparency = $true
    $window.Background = "Transparent"
    $window.Topmost = $true
    $window.ShowInTaskbar = $false
    $window.ResizeMode = "NoResize"
    $window.SizeToContent = "WidthAndHeight"
    $window.WindowStartupLocation = "Manual"
    Write-Host "Ventana creada"

    # Crear el borde
    $border = New-Object System.Windows.Controls.Border
    $border.Background = [System.Windows.Media.Brushes]::Black
    $border.BorderBrush = [System.Windows.Media.Brushes]::Red
    $border.BorderThickness = "3"
    $border.CornerRadius = "3"
    $border.Padding = "20,10"
    Write-Host "Borde creado"

    # Crear el texto
    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Text = "DEBUG STATUS"
    $textBlock.FontFamily = "Consolas"
    $textBlock.FontSize = 14
    $textBlock.FontWeight = "Bold"
    $textBlock.Foreground = [System.Windows.Media.Brushes]::White
    $textBlock.HorizontalAlignment = "Center"
    $textBlock.VerticalAlignment = "Center"
    Write-Host "Texto creado"

    $border.Child = $textBlock
    $window.Content = $border

    # Posicionar en esquina inferior izquierda
    $screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
    $window.Left = 50
    $window.Top = $screenHeight - 200
    Write-Host "Ventana posicionada en Left: 50, Top: $($window.Top)"

    # Mostrar la ventana inmediatamente para debug
    $window.Show()
    Write-Host "Ventana mostrada - deberia ser visible ahora"

    # Archivo de estado (en directorio padre, no en tooltip_csharp)
    $statusFile = Join-Path (Split-Path $PSScriptRoot -Parent) "status_commands.json"
    Write-Host "Monitoreando archivo: $statusFile"

    # Funcion para actualizar el estado
    function Update-Status {
        param($statusText, $show)
        
        Write-Host "Update-Status llamado: Status='$statusText', Show=$show"
        
        if ($show) {
            $textBlock.Text = $statusText.ToUpper()
            $window.Visibility = "Visible"
            Write-Host "Estado mostrado: $($statusText.ToUpper())"
        } else {
            $window.Visibility = "Hidden"
            Write-Host "Estado ocultado"
        }
    }

    # Timer para verificar cambios en el archivo
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $global:lastWriteTime = $null

    $timer.Add_Tick({
        if (Test-Path $statusFile) {
            $currentWriteTime = (Get-Item $statusFile).LastWriteTime
            if ($global:lastWriteTime -ne $currentWriteTime) {
                $global:lastWriteTime = $currentWriteTime
                Write-Host "Archivo modificado: $currentWriteTime"
                
                try {
                    Start-Sleep -Milliseconds 100
                    $jsonContent = Get-Content $statusFile -Raw -ErrorAction SilentlyContinue
                    if ($jsonContent) {
                        Write-Host "JSON leido: $jsonContent"
                        $command = $jsonContent | ConvertFrom-Json
                        Update-Status -statusText $command.status -show $command.show
                    } else {
                        Write-Host "Archivo JSON vacio"
                    }
                } catch {
                    Write-Host "Error leyendo JSON: $($_.Exception.Message)"
                }
            }
        }
    })

    $timer.Start()
    Write-Host "Timer iniciado"

    # Mostrar ventana de debug por 10 segundos
    Write-Host "Ventana visible por 10 segundos para debug..."
    Start-Sleep -Seconds 10

    # Mantener el script ejecutandose
    Write-Host "Entrando en loop principal..."
    [System.Windows.Threading.Dispatcher]::Run()

} catch {
    Write-Host "Error general: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
} finally {
    if ($timer) { $timer.Stop() }
    Write-Host "=== StatusWindow Debug TERMINADO ==="
}