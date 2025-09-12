@echo off
echo Compilando StatusApp...

REM Compilar la aplicación de estado
dotnet build StatusApp.csproj -c Debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ StatusApp compilado exitosamente!
    echo Ejecutable: bin\Debug\net6.0-windows\StatusApp.exe
) else (
    echo.
    echo ❌ Error al compilar StatusApp
)

pause