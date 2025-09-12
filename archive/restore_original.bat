@echo off
echo ===================================================================
echo RESTORING ORIGINAL VERSION (NEWTONSOFT.JSON)
echo ===================================================================
echo.

echo Restoring original files...
if exist TooltipApp_Original.csproj (
    del TooltipApp.csproj
    move TooltipApp_Original.csproj TooltipApp.csproj
    echo - Restored TooltipApp.csproj
)

if exist Models\TooltipCommand_Original.cs (
    del Models\TooltipCommand.cs
    move Models\TooltipCommand_Original.cs Models\TooltipCommand.cs
    echo - Restored TooltipCommand.cs
)

if exist MainWindow_Original.xaml.cs (
    del MainWindow.xaml.cs
    move MainWindow_Original.xaml.cs MainWindow.xaml.cs
    echo - Restored MainWindow.xaml.cs
)

echo.
echo ===================================================================
echo RESTORED ORIGINAL VERSION SUCCESSFULLY
echo ===================================================================
echo.
echo Now you can compile with:
echo   dotnet restore TooltipApp.csproj
echo   dotnet publish TooltipApp.csproj -c Release --self-contained true -r win-x64 -p:PublishSingleFile=true
echo.
pause