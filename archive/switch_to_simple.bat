@echo off
echo ===================================================================
echo SWITCHING TO SIMPLE VERSION (NO EXTERNAL DEPENDENCIES)
echo ===================================================================
echo.

echo Backing up original files...
if exist TooltipApp.csproj (
    move TooltipApp.csproj TooltipApp_Original.csproj
    echo - Backed up TooltipApp.csproj
)

if exist Models\TooltipCommand.cs (
    move Models\TooltipCommand.cs Models\TooltipCommand_Original.cs
    echo - Backed up TooltipCommand.cs
)

if exist MainWindow.xaml.cs (
    move MainWindow.xaml.cs MainWindow_Original.xaml.cs
    echo - Backed up MainWindow.xaml.cs
)

echo.
echo Switching to simple version...
copy TooltipApp_Simple.csproj TooltipApp.csproj
copy Models\TooltipCommand_Simple.cs Models\TooltipCommand.cs
copy MainWindow_Simple.xaml.cs MainWindow.xaml.cs

echo.
echo ===================================================================
echo SWITCHED TO SIMPLE VERSION SUCCESSFULLY
echo ===================================================================
echo.
echo Now you can compile with:
echo   dotnet restore TooltipApp.csproj
echo   dotnet publish TooltipApp.csproj -c Release --self-contained true -r win-x64 -p:PublishSingleFile=true
echo.
echo Or run the build script:
echo   build_and_test.bat
echo.
pause