using System;
using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace StatusApp
{
    public class Program
    {
        [STAThread]
        public static void Main()
        {
            var app = new Application();
            var window = new StatusWindow();
            app.Run(window);
        }
    }

    public class StatusWindow : Window
    {
        private readonly string statusFile;
        private FileSystemWatcher? _statusWatcher;
        private Border statusBorder;
        private TextBlock statusText;

        public StatusWindow()
        {
            InitializeComponent();
            statusFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "status_commands.json");
            
            // Posicionar en esquina inferior izquierda
            PositionWindow();
            
            // Inicialmente oculta
            this.Visibility = Visibility.Hidden;
            
            // Configurar watcher
            SetupStatusWatcher();
        }

        private void InitializeComponent()
        {
            // Configuración de la ventana
            this.Title = "Status";
            this.WindowStyle = WindowStyle.None;
            this.AllowsTransparency = true;
            this.Background = Brushes.Transparent;
            this.Topmost = true;
            this.ShowInTaskbar = false;
            this.ResizeMode = ResizeMode.NoResize;
            this.SizeToContent = SizeToContent.WidthAndHeight;
            this.WindowStartupLocation = WindowStartupLocation.Manual;

            // Crear el borde con estilo
            statusBorder = new Border
            {
                Background = new SolidColorBrush(Color.FromRgb(30, 30, 30)), // #1e1e1e
                BorderThickness = new Thickness(2),
                CornerRadius = new CornerRadius(3),
                Padding = new Thickness(12, 8),
                Margin = new Thickness(0)
            };

            // Aplicar color de acento del sistema
            try
            {
                statusBorder.BorderBrush = SystemParameters.WindowGlassBrush;
            }
            catch
            {
                statusBorder.BorderBrush = new SolidColorBrush(Color.FromRgb(0, 120, 215));
            }

            // Crear el texto
            statusText = new TextBlock
            {
                Text = "STATUS",
                FontFamily = new FontFamily("Consolas"),
                FontSize = 12,
                FontWeight = FontWeights.Bold,
                Foreground = Brushes.White,
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Center
            };

            statusBorder.Child = statusText;
            this.Content = statusBorder;
        }

        private void PositionWindow()
        {
            var screenHeight = SystemParameters.PrimaryScreenHeight;
            
            this.Left = 20; // 20px desde el borde izquierdo
            this.Top = screenHeight - 100; // Temporal, se ajustará después
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
                statusText.Text = command.Status?.ToUpper() ?? "STATUS";
                
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
            this.Top = screenHeight - this.ActualHeight - 20; // 20px desde abajo
        }

        protected override void OnClosed(EventArgs e)
        {
            _statusWatcher?.Dispose();
            base.OnClosed(e);
        }
    }

    public class StatusCommand
    {
        public bool Show { get; set; }
        public string? Status { get; set; }
    }
}