#Requires -RunAsAdministrator

$PSVersion = $PSVersionTable.PSVersion
$PSVersionStr = "$($PSVersion.Major).$($PSVersion.Minor)"
if ($PSVersionStr -ne "5.1") {
  Write-Output "PowerShell 5.1 is needed to run this script."
}

Import-Module Appx

$archs = @{
  ([uint32]5)     = "Arm"
  ([uint32]12)    = "Arm64"
  ([uint32]11)    = "Neutral"
  ([uint32]65535) = "Unknown"
  ([uint32]9)     = "X64"
  ([uint32]0)     = "X86"
  ([uint32]14)    = "X86OnArm64"
}

function Print {
  param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Prefix,
    [Parameter(Mandatory, Position = 1)]
    [string]$Action,
    [Parameter(Position = 2)]
    [string]$Str
  )

  switch ($Action) {
    "REMOVE" { $ColorAction = "Green" }
    "MISS" { $ColorAction = "Red" }
    Default { $ColorAction = "White" }
  }

  Write-Host -ForegroundColor "Yellow" "$($Prefix)" -NoNewline
  Write-Host ":" -NoNewline
  Write-Host -ForegroundColor $ColorAction "$Action" -NoNewline
  Write-Host " $Str"
}

$remTable = @{}
$json = Get-Content -Raw "$PSScriptRoot\apps.json" | ConvertFrom-Json 
$json.apps | ForEach-Object { $remTable[$_.name] = $_.remove }
$AllApps = Get-AppxPackage -AllUsers
$AllProvApps = Get-AppxProvisionedPackage -Online

$ProgressPreference = "SilentlyContinue"
foreach ($App in $AllApps) {
  if ($remTable.ContainsKey($App.Name)) {
    if ($remTable.($App.Name)) {
      Print "AP" "REMOVE" "$($App.Name) ($($App.Architecture))"
      Remove-AppxPackage -Package $App.PackageFullName | Out-Null
    }
  } else {
    Print "AP" "MISS" "$($App.Name) ($($App.Architecture), Removable: $(-not $App.NonRemovable))"
  }
}

foreach ($App in $AllProvApps) {
  if ($remTable.ContainsKey($App.DisplayName)) {
    if ($remTable.($App.DisplayName)) {
      Print "APP" "REMOVE" "$($App.DisplayName) ($($archs.($App.Architecture)))"
      Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
    }
  } else {
    Print "APP" "MISS" "$($App.DisplayName) ($($archs.($App.Architecture)))"
  }
}
$ProgressPreference = "Continue"

Pause