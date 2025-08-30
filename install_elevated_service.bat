@echo off
REM ===============================================================================
REM HYBRID CAPSLOCK - ELEVATED SERVICE INSTALLER (BATCH)
REM ===============================================================================
REM Installs the elevated service that works with elevated apps
REM ===============================================================================

echo === HybridCapsLock Elevated Service Installer ===
echo.
echo This will install HybridCapsLock as an ELEVATED service.
echo.
echo BENEFITS:
echo - Works with elevated applications (like Windhawk)
echo - Still launches apps with normal user privileges
echo - Full compatibility with all applications
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator.
    echo Right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Installing elevated service...
powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -File "%~dp0install_elevated_service.ps1"

echo.
echo Installation complete! 
echo.
echo TEST YOUR SETUP:
echo 1. Open Windhawk (elevated app)
echo 2. Try CapsLock + s (should work now!)
echo 3. Try CapsLock + Space + n (should open Notepad with normal privileges)
echo.
echo Press any key to exit...
pause >nul