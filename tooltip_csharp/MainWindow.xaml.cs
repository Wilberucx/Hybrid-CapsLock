using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;
using System.Text.Json;
using TooltipApp.Models;

namespace TooltipApp
{
    public partial class MainWindow : Window
    {
        private FileSystemWatcher? _fileWatcher;
        private DispatcherTimer? _hideTimer;
        private const string CommandFile = "tooltip_commands.json";

        // Colores especificados
        public static class Colors
        {
            public const string AccentOptions = "#dbd6b9";    // Dorado
            public const string AccentNavigation = "#6c958e"; // Verde
            public const string Background = "#1e1e1e";       // Oscuro
            public const string Text = "#ffffff";             // Blanco
            public const string Border = "#404040";           // Gris
        }

        public MainWindow()
        {
            InitializeComponent();
            InitializeWindow();
            StartFileWatcher();
            
            // Fase 1: Mostrar tooltip básico estático
            ShowBasicTooltip();
        }

        private void InitializeWindow()
        {
            // Configurar ventana para click-through
            this.IsHitTestVisible = false;
            
            // Posicionar ventana
            this.Loaded += (s, e) => PositionWindow();
            
            // Configurar timer para auto-hide
            _hideTimer = new DispatcherTimer();
            _hideTimer.Tick += (s, e) => HideTooltip();
        }

        private void PositionWindow()
        {
            var screenWidth = SystemParameters.PrimaryScreenWidth;
            var screenHeight = SystemParameters.PrimaryScreenHeight;
            
            // Check if this is a persistent status tooltip
            if (currentTooltip?.tooltip_type == "status_persistent")
            {
                // Position in bottom-left corner
                this.Left = 20; // 20px from left edge
                this.Top = screenHeight - this.ActualHeight - 20; // 20px from bottom
            }
            else
            {
                // Centro horizontal, 50px desde abajo para tooltips regulares
                this.Left = (screenWidth - this.ActualWidth) / 2;
                this.Top = screenHeight - this.ActualHeight - 50;
            }
        }

        private void ShowBasicTooltip()
        {
            // Mostrar mensaje de carga exitosa
            TitleText.Text = "HYBRIDCAPSLOCK LOADED";
            
            // Limpiar grid existente
            ItemsGrid.Children.Clear();
            ItemsGrid.RowDefinitions.Clear();
            
            // Mostrar información de carga
            var loadItems = new[]
            {
                new TooltipItem { Key = "✓", Description = "System initialized successfully" },
                new TooltipItem { Key = "✓", Description = "Configuration loaded" },
                new TooltipItem { Key = "✓", Description = "Tooltips enabled" },
                new TooltipItem { Key = "✓", Description = "Ready for use" }
            };
            
            CreateItemsLayout(loadItems);
            
            this.Visibility = Visibility.Visible;
            PositionWindow();
            
            // Auto-hide después de 2 segundos
            _hideTimer.Interval = TimeSpan.FromMilliseconds(2000);
            _hideTimer.Stop();
            _hideTimer.Start();
        }

        private void ApplyPersistentStatusStyle()
        {
            // Estilo para tooltips de estado persistentes
            TooltipBorder.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#1e1e1e"));
            TooltipBorder.BorderBrush = SystemParameters.WindowGlassBrush; // Color de acento del sistema
            TooltipBorder.BorderThickness = new Thickness(2);
            TooltipBorder.Padding = new Thickness(12, 8);
            TooltipBorder.CornerRadius = new CornerRadius(3);
            
            // Título en mayúsculas y bold
            TitleText.FontWeight = FontWeights.Bold;
            TitleText.FontSize = 12;
            TitleText.Text = TitleText.Text.ToUpper();
            
            // Ocultar items grid y navigation para estados
            ItemsGrid.Visibility = Visibility.Collapsed;
            NavigationPanel.Visibility = Visibility.Collapsed;
        }

        private void ApplyRegularTooltipStyle()
        {
            // Estilo para tooltips regulares
            TooltipBorder.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#1e1e1e"));
            TooltipBorder.BorderBrush = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#404040"));
            TooltipBorder.BorderThickness = new Thickness(1);
            TooltipBorder.Padding = new Thickness(16, 12);
            TooltipBorder.CornerRadius = new CornerRadius(4);
            
            // Título normal
            TitleText.FontWeight = FontWeights.Bold;
            TitleText.FontSize = 14;
            
            // Mostrar items grid y navigation
            ItemsGrid.Visibility = Visibility.Visible;
            NavigationPanel.Visibility = Visibility.Visible;
        }

        private void CreateItemsLayout(TooltipItem[] items)
        {
            int itemsPerColumn = Math.Max(1, (int)Math.Ceiling(items.Length / 4.0));
            int currentRow = 0;
            int currentColumn = 0;

            // Crear filas necesarias
            for (int i = 0; i < itemsPerColumn; i++)
            {
                ItemsGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            }

            foreach (var item in items)
            {
                var itemPanel = new StackPanel
                {
                    Orientation = Orientation.Horizontal,
                    Margin = new Thickness(8, 2, 8, 2)
                };

                // Key con color dorado
                var keyText = new TextBlock
                {
                    Text = $"[{item.Key}]",
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = 12,
                    FontWeight = FontWeights.Bold,
                    Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString(Colors.AccentOptions)),
                    Margin = new Thickness(0, 0, 8, 0)
                };

                // Description con color blanco
                var descText = new TextBlock
                {
                    Text = item.Description,
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = 12,
                    Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString(Colors.Text))
                };

                itemPanel.Children.Add(keyText);
                itemPanel.Children.Add(descText);

                Grid.SetRow(itemPanel, currentRow);
                Grid.SetColumn(itemPanel, currentColumn);
                ItemsGrid.Children.Add(itemPanel);

                currentRow++;
                if (currentRow >= itemsPerColumn)
                {
                    currentRow = 0;
                    currentColumn++;
                }
            }
        }

        private void StartFileWatcher()
        {
            try
            {
                _fileWatcher = new FileSystemWatcher(".")
                {
                    Filter = CommandFile,
                    NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.CreationTime
                };

                _fileWatcher.Changed += OnCommandFileChanged;
                _fileWatcher.Created += OnCommandFileChanged;
                _fileWatcher.EnableRaisingEvents = true;
            }
            catch (Exception ex)
            {
                // Log error but don't crash
                Console.WriteLine($"Error starting file watcher: {ex.Message}");
            }
        }

        private void OnCommandFileChanged(object sender, FileSystemEventArgs e)
        {
            // Pequeño delay para evitar múltiples eventos
            System.Threading.Thread.Sleep(50);
            
            try
            {
                var command = ReadTooltipCommand();
                if (command != null)
                {
                    Dispatcher.Invoke(() => UpdateTooltip(command));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error processing command file: {ex.Message}");
            }
        }

        private TooltipCommand? ReadTooltipCommand()
        {
            try
            {
                if (!File.Exists(CommandFile))
                    return null;

                var jsonContent = File.ReadAllText(CommandFile);
                if (string.IsNullOrWhiteSpace(jsonContent))
                    return null;

                // Usar System.Text.Json en lugar de Newtonsoft.Json
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                };
                
                return JsonSerializer.Deserialize<TooltipCommand>(jsonContent, options);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading command file: {ex.Message}");
                return null;
            }
        }

        private void UpdateTooltip(TooltipCommand command)
        {
            try
            {
                if (!command.Show)
                {
                    HideTooltip();
                    return;
                }

                // Guardar referencia al comando actual
                currentTooltip = command;

                // Actualizar título
                if (!string.IsNullOrEmpty(command.Title))
                {
                    TitleText.Text = command.Title;
                }

                // Aplicar estilo según el tipo de tooltip
                if (command.TooltipType == "status_persistent")
                {
                    ApplyPersistentStatusStyle();
                }
                else
                {
                    ApplyRegularTooltipStyle();
                    
                    // Actualizar items si están presentes (solo para tooltips regulares)
                    if (command.Items?.Count > 0)
                    {
                        ItemsGrid.Children.Clear();
                        ItemsGrid.RowDefinitions.Clear();
                        CreateItemsLayout(command.Items.ToArray());
                    }
                }

                // Actualizar navegación si está presente
                if (command.Navigation?.Count > 0)
                {
                    UpdateNavigation(command.Navigation);
                }

                // Mostrar tooltip
                this.Visibility = Visibility.Visible;
                PositionWindow();

                // Configurar auto-hide timer
                if (command.TimeoutMs > 0)
                {
                    _hideTimer.Interval = TimeSpan.FromMilliseconds(command.TimeoutMs);
                    _hideTimer.Stop();
                    _hideTimer.Start();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating tooltip: {ex.Message}");
            }
        }

        private void UpdateNavigation(System.Collections.Generic.List<string> navigation)
        {
            NavigationPanel.Children.Clear();

            foreach (var navItem in navigation)
            {
                var border = new Border
                {
                    Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString(Colors.AccentNavigation)),
                    CornerRadius = new CornerRadius(2),
                    Padding = new Thickness(4, 2, 4, 2),
                    Margin = new Thickness(2, 0, 2, 0)
                };

                var text = new TextBlock
                {
                    Text = navItem,
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = 10,
                    Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString(Colors.Text))
                };

                border.Child = text;
                NavigationPanel.Children.Add(border);
            }
        }

        private void HideTooltip()
        {
            this.Visibility = Visibility.Hidden;
            _hideTimer?.Stop();
        }

        protected override void OnClosed(EventArgs e)
        {
            // Cleanup recursos
            _fileWatcher?.Dispose();
            _hideTimer?.Stop();
            base.OnClosed(e);
        }

        // Permitir que la ventana sea movida (para testing)
        protected override void OnMouseLeftButtonDown(MouseButtonEventArgs e)
        {
            if (e.ButtonState == MouseButtonState.Pressed)
                this.DragMove();
        }
    }
}