using System;
using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Media;

namespace TooltipApp
{
    public partial class StatusWindow : Window
    {
        private readonly string statusFile;
        private FileSystemWatcher? _statusWatcher;

        public StatusWindow()
        {
            InitializeComponent();
            statusFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "status_commands.json");
            
            // Aplicar color de acento del sistema al borde
            ApplySystemAccentColor();
            
            // Posicionar en esquina inferior izquierda
            PositionWindow();
            
            // Inicialmente oculta
            this.Visibility = Visibility.Hidden;
            
            // Configurar watcher para archivo de comandos de estado
            SetupStatusWatcher();
        }

        private void ApplySystemAccentColor()
        {
            try
            {
                // Obtener color de acento del sistema
                var accentColor = SystemParameters.WindowGlassBrush;
                StatusBorder.BorderBrush = accentColor;
            }
            catch
            {
                // Fallback a un color por defecto si no se puede obtener el acento
                StatusBorder.BorderBrush = new SolidColorBrush(Color.FromRgb(0, 120, 215));
            }
        }

        private void PositionWindow()
        {
            var screenWidth = SystemParameters.PrimaryScreenWidth;
            var screenHeight = SystemParameters.PrimaryScreenHeight;
            
            // Posición fija en esquina inferior izquierda
            this.Left = 20; // 20px desde el borde izquierdo
            this.Top = screenHeight - 100; // 100px desde abajo (se ajustará cuando se calcule el tamaño real)
        }

        private void SetupStatusWatcher()
        {
            try
            {
                var directory = Path.GetDirectoryName(statusFile) ?? AppDomain.CurrentDomain.BaseDirectory;
                _statusWatcher = new FileSystemWatcher(directory)
                {
                    Filter = "status_commands.json",
                    NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.CreationTime
                };

                _statusWatcher.Changed += OnStatusFileChanged;
                _statusWatcher.Created += OnStatusFileChanged;
                _statusWatcher.EnableRaisingEvents = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error starting status watcher: {ex.Message}");
            }
        }

        private void OnStatusFileChanged(object sender, FileSystemEventArgs e)
        {
            System.Threading.Thread.Sleep(50);
            
            try
            {
                var command = ReadStatusCommand();
                if (command != null)
                {
                    Dispatcher.Invoke(() => UpdateStatus(command));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error processing status file: {ex.Message}");
            }
        }

        private StatusCommand? ReadStatusCommand()
        {
            try
            {
                if (!File.Exists(statusFile))
                    return null;

                var jsonContent = File.ReadAllText(statusFile);
                if (string.IsNullOrWhiteSpace(jsonContent))
                    return null;

                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                };
                
                return JsonSerializer.Deserialize<StatusCommand>(jsonContent, options);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading status file: {ex.Message}");
                return null;
            }
        }

        private void UpdateStatus(StatusCommand command)
        {
            try
            {
                if (!command.Show)
                {
                    this.Visibility = Visibility.Hidden;
                    return;
                }

                // Actualizar texto del estado
                StatusText.Text = command.Status?.ToUpper() ?? "STATUS";
                
                // Mostrar la ventana
                this.Visibility = Visibility.Visible;
                
                // Reposicionar después de que se calcule el tamaño
                this.UpdateLayout();
                PositionWindowAfterSizing();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating status: {ex.Message}");
            }
        }

        private void PositionWindowAfterSizing()
        {
            var screenHeight = SystemParameters.PrimaryScreenHeight;
            
            // Ajustar posición Y basada en el tamaño real de la ventana
            this.Top = screenHeight - this.ActualHeight - 20; // 20px desde abajo
        }

        protected override void OnClosed(EventArgs e)
        {
            _statusWatcher?.Dispose();
            base.OnClosed(e);
        }
    }

    // Clase para deserializar comandos de estado
    public class StatusCommand
    {
        public bool Show { get; set; }
        public string? Status { get; set; }
    }
}