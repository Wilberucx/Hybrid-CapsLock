@echo off
echo ===================================================================
echo HYBRIDCAPSLOCK C# TOOLTIP - BUILD AND TEST
echo ===================================================================
echo.

echo Checking .NET SDK installation...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: .NET SDK not found!
    echo Please install .NET 6.0 SDK from: https://dotnet.microsoft.com/download/dotnet/6.0
    echo Or run: winget install Microsoft.DotNet.SDK.6
    pause
    exit /b 1
)

echo .NET SDK found: 
dotnet --version
echo.

echo Building C# Tooltip Application (Self-Contained)...
cd tooltip_csharp
dotnet restore TooltipApp.csproj
dotnet publish TooltipApp.csproj -c Release --self-contained true -r win-x64 -p:PublishSingleFile=true
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful!
echo.

echo Testing JSON communication...
cd ..
powershell -ExecutionPolicy Bypass -File tmp_rovodev_test_tooltip.ps1

echo.
echo ===================================================================
echo BUILD AND TEST COMPLETED
echo ===================================================================
echo.
echo To run the tooltip application:
echo   cd tooltip_csharp
echo   dotnet run
echo.
echo To integrate with HybridCapsLock:
echo   1. Include autohotkey_integration.ahk in your script
echo   2. Call StartTooltipApp() at script startup
echo   3. Replace ToolTip calls with ShowCSharpTooltip()
echo.
pause