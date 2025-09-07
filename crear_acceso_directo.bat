@echo off
echo Creando acceso directo en el escritorio...
powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\HybridCapsLock v2.lnk'); $Shortcut.TargetPath = 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe'; $Shortcut.Arguments = '%CD%\HybridCapsLock_v2.ahk'; $Shortcut.WorkingDirectory = '%CD%'; $Shortcut.IconLocation = 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe'; $Shortcut.Save()"
echo ¡Acceso directo creado en el escritorio!
pause