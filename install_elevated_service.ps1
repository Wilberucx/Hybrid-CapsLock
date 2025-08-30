# ===============================================================================
# HYBRID CAPSLOCK - ELEVATED SERVICE INSTALLER
# ===============================================================================
# This installer creates an elevated service that works with elevated apps
# but launches applications with normal user privileges
# ===============================================================================

param(
    [switch]$Uninstall,
    [switch]$Force
)

# Disable PowerShell profile to avoid conflicts
$env:PSModulePath = ""

$ServiceName = "HybridCapsLockElevated"
$ServiceDisplayName = "Hybrid CapsLock Elevated Service"
$ServiceDescription = "Hybrid CapsLock service with elevated privileges for compatibility with elevated apps"
$ScriptPath = Join-Path $PSScriptRoot "HybridCapsLock_Elevated.ahk"
$NSSMPath = Join-Path $PSScriptRoot "nssm.exe"

Write-Host "=== HybridCapsLock Elevated Service Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Find AutoHotkey
Write-Host "Searching for AutoHotkey..." -ForegroundColor Cyan
$AutoHotkeyPath = ""

$searchPaths = @(
    "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe",
    "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64_UIA.exe",
    "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe",
    "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey.exe",
    "C:\Program Files (x86)\AutoHotkey\AutoHotkeyU64.exe",
    "C:\Program Files (x86)\AutoHotkey\AutoHotkey.exe"
)

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $AutoHotkeyPath = $path
        Write-Host "Found AutoHotkey at: $path" -ForegroundColor Green
        break
    }
}

if (-not $AutoHotkeyPath) {
    Write-Host "ERROR: AutoHotkey not found." -ForegroundColor Red
    exit 1
}

# Check script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Host "ERROR: $ScriptPath not found" -ForegroundColor Red
    exit 1
}

if ($Uninstall) {
    Write-Host "Uninstalling elevated service..." -ForegroundColor Yellow
    
    # Stop and remove old services
    $services = @("HybridCapsLockService", "HybridCapsLockElevated")
    foreach ($svc in $services) {
        $existingService = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($existingService) {
            Write-Host "Removing service: $svc" -ForegroundColor Yellow
            & $NSSMPath stop $svc
            Start-Sleep -Seconds 3
            & $NSSMPath remove $svc confirm
        }
    }
    
    Write-Host "Uninstallation complete!" -ForegroundColor Green
    exit 0
}

# Download NSSM if needed
if (-not (Test-Path $NSSMPath)) {
    Write-Host "Downloading NSSM..." -ForegroundColor Cyan
    try {
        $nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
        $tempZip = Join-Path $env:TEMP "nssm.zip"
        $tempExtract = Join-Path $env:TEMP "nssm_extract"
        
        Invoke-WebRequest -Uri $nssmUrl -OutFile $tempZip -UseBasicParsing
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        
        $arch = if ([Environment]::Is64BitOperatingSystem) { "win64" } else { "win32" }
        $nssmSource = Join-Path $tempExtract "nssm-2.24\$arch\nssm.exe"
        
        Copy-Item $nssmSource $NSSMPath
        
        Remove-Item $tempZip -Force
        Remove-Item $tempExtract -Recurse -Force
        
        Write-Host "NSSM downloaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to download NSSM: $_" -ForegroundColor Red
        exit 1
    }
}

# Remove existing services
Write-Host "Removing any existing services..." -ForegroundColor Yellow
$services = @("HybridCapsLockService", "HybridCapsLockElevated")
foreach ($svc in $services) {
    $existingService = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Host "Stopping and removing: $svc" -ForegroundColor Yellow
        & $NSSMPath stop $svc
        Start-Sleep -Seconds 3
        & $NSSMPath remove $svc confirm
    }
}

# Install new elevated service
Write-Host "Installing elevated service..." -ForegroundColor Cyan
& $NSSMPath install $ServiceName $AutoHotkeyPath $ScriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install service" -ForegroundColor Red
    exit 1
}

# Configure service with elevated privileges
Write-Host "Configuring elevated service..." -ForegroundColor Cyan
& $NSSMPath set $ServiceName DisplayName $ServiceDisplayName
& $NSSMPath set $ServiceName Description $ServiceDescription
& $NSSMPath set $ServiceName Start SERVICE_AUTO_START

# IMPORTANT: Set service to run as LocalSystem with desktop interaction
& $NSSMPath set $ServiceName ObjectName LocalSystem
& $NSSMPath set $ServiceName Type SERVICE_INTERACTIVE_PROCESS

& $NSSMPath set $ServiceName AppDirectory $PSScriptRoot
& $NSSMPath set $ServiceName AppRestartDelay 5000
& $NSSMPath set $ServiceName AppStdout (Join-Path $PSScriptRoot "service_elevated.log")
& $NSSMPath set $ServiceName AppStderr (Join-Path $PSScriptRoot "service_elevated_error.log")

# Start service
Write-Host "Starting elevated service..." -ForegroundColor Cyan
& $NSSMPath start $ServiceName

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: Elevated service installed and started!" -ForegroundColor Green
    Write-Host "Service Name: $ServiceName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This service now works with elevated applications!" -ForegroundColor Yellow
    Write-Host "Test with Windhawk or other elevated apps." -ForegroundColor White
    Write-Host ""
    Write-Host "Applications launched will have normal user privileges." -ForegroundColor Green
    Write-Host ""
    Write-Host "To check status: Get-Service $ServiceName" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Service installed but failed to start" -ForegroundColor Red
    Write-Host "Check logs: Get-Content service_elevated_error.log" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan