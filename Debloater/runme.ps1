Start-Process -Verb RunAs powershell -ArgumentList "-File $PSScriptRoot\settings.ps1"
Start-Process -Verb RunAs powershell -ArgumentList "-File $PSScriptRoot\uninstaller.ps1"