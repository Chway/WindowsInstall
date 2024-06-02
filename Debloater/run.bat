PowerShell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0\uninstaller.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0\uninstaller_features.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0\uninstaller_capabilities.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0\settings.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0\disabler_services.ps1'"
PAUSE