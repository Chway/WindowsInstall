#Requires -RunAsAdministrator
$ProgressPreference = "SilentlyContinue"

$archs = @{
  ([uint32]5)     = "Arm"
  ([uint32]12)    = "Arm64"
  ([uint32]11)    = "Neutral"
  ([uint32]65535) = "Unknown"
  ([uint32]9)     = "X64"
  ([uint32]0)     = "X86"
  ([uint32]14)    = "X86OnArm64"
}

# By default, play safe, skip frameworks ans resources
# Unknown packages are always skipped, update app.json!
$HideSkip = $true
$SkipFramework = $true
$SkipResource = $true
$AllUsers = $true
$CleanProvisioned = $false

# https://stackoverflow.com/questions/4647756/is-there-a-way-to-specify-a-font-color-when-using-write-output
function Write-ColorOutput($ForegroundColor) {
  $fc = $host.UI.RawUI.ForegroundColor
  $host.UI.RawUI.ForegroundColor = $ForegroundColor

  if ($args) {
    Write-Output $args
  } else {
    $input | Write-Output
  }

  $host.UI.RawUI.ForegroundColor = $fc
}

$remTable = @{}
if (Test-Path -Path "$PSScriptRoot\apps.json") {
  $json = Get-Content -Raw "$PSScriptRoot\apps.json" | ConvertFrom-Json 
  $json.apps | ForEach-Object { $remTable[$_.name] = $_.remove }
} else {
  Write-Output "apps.json is missing, exiting." | Write-ColorOutput Red
  Pause
  Exit
}

Function Clean-Appx {
  Write-Output "[AppxPackage]" | Write-ColorOutput Blue
  $AllApps = if ($AllUsers) { Get-AppxPackage -AllUsers | Sort-Object } else { Get-AppxPackage | Sort-Object }
  foreach ($App in $AllApps) {
    if (!($remTable.ContainsKey($App.Name))) {
      Write-Output "[AP][MISS] $($App.Name) ($($App.Architecture))" | Write-ColorOutput Red
      Continue
    }

    if ($App.NonRemovable -Or ($App.IsFramework -And $SkipFramework) -Or ($App.IsResourcePackage -And $SkipResource)) {
      if (!($HideSkip)) {
        Write-Output "[AP][SKIP] $($App.Name) ($($App.Architecture))" | Write-ColorOutput DarkGray
      }
      Continue
    }

    if ($remTable.($App.Name)) {
      Write-Output "[AP][REMO] $($App.Name) ($($App.Architecture))" | Write-ColorOutput Yellow
      Remove-AppxPackage -Package $App.PackageFullName | Out-Null
    } else {
      Write-Output "[AP][KEEP] $($App.Name) ($($App.Architecture))"
    }
  }
}

Function Clean-AppxProv {
  Write-Output "`n[AppxProvisionedPackage]" | Write-ColorOutput Blue
  $AllProvApps = Get-AppxProvisionedPackage -Online | Sort-Object
  foreach ($App in $AllProvApps) {
    if (!($remTable.ContainsKey($App.DisplayName))) {
      Write-Output "[APP][MISS] $($App.DisplayName) ($($archs.($App.Architecture)))" | Write-ColorOutput Red
      Continue
    }

    if ($remTable.($App.DisplayName)) {
      Write-Output "[APP][REMO] $($App.DisplayName) ($($archs.($App.Architecture)))" | Write-ColorOutput Yellow
      Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
    } else {
      Write-Output "[APP][KEEP] $($App.DisplayName) ($($archs.($App.Architecture)))"
    }
  }
}

$timeCleanAppx = Measure-Command { Clean-Appx | Out-Default }
Write-Output "Elapsed: $($timeCleanAppx.TotalSeconds) second(s)"

if ($CleanProvisioned) {
  $timeCleanAppxProv = Measure-Command { Clean-AppxProv | Out-Default }
  Write-Output "Elapsed: $($timeCleanAppxProv.TotalSeconds) second(s)"
}

$ProgressPreference = "Continue"
#Pause
