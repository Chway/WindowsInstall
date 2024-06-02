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

$HideNonRemovable = $true
$HideFramework = $false
$KeepFramework = $true

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
$json = Get-Content -Raw "$PSScriptRoot\apps.json" | ConvertFrom-Json 
$json.apps | ForEach-Object { $remTable[$_.name] = $_.remove }

Function Remove-Appx {
  Write-Output "[AppxPackage]" | Write-ColorOutput Blue
  $AllApps = Get-AppxPackage -AllUsers | Sort-Object
  foreach ($App in $AllApps) {
    if ($App.NonRemovable) {
      if (!($HideNonRemovable)) {
        Write-Output "[AP][SKIP] $($App.Name) ($($App.Architecture))" | Write-ColorOutput DarkGray
      }
      Continue
    }

    if ($App.IsFramework -And $KeepFramework) {
      if (!($HideFramework)) {
        Write-Output "[AP][SKIP] $($App.Name) ($($App.Architecture))" | Write-ColorOutput DarkGray
      }
      Continue
    }

  }
  
  if ($remTable.ContainsKey($App.Name)) {
    if ($remTable.($App.Name)) {
      Write-Output "[AP][REMO] $($App.Name) ($($App.Architecture))"
      Remove-AppxPackage -Package $App.PackageFullName | Out-Null
    } else {
      Write-Output "[AP][KEEP] $($App.Name) ($($App.Architecture))"
    }
  } else {
    Write-Output "[AP][MISS] $($App.Name) ($($App.Architecture))" | Write-ColorOutput Red
  }
}

Function Remove-AppxProv {
  Write-Output "`n[AppxProvisionedPackage]" | Write-ColorOutput Blue
  $AllProvApps = Get-AppxProvisionedPackage -Online | Sort-Object
  foreach ($App in $AllProvApps) {
    if ($remTable.ContainsKey($App.DisplayName)) {
      if ($remTable.($App.DisplayName)) {
        Write-Output "[APP][REMO] $($App.DisplayName) ($($archs.($App.Architecture)))"
        Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
      } else {
        Write-Output "[APP][KEEP] $($App.DisplayName) ($($archs.($App.Architecture)))"
      }
    } else {
      Write-Output "[APP][MISS] $($App.DisplayName) ($($archs.($App.Architecture)))" | Write-ColorOutput Red
    }
  }
}

$timeRemoveAppx = Measure-Command { Remove-Appx | Out-Default }
Write-Output "Elapsed: $($timeRemoveAppx.TotalSeconds) second(s)"
$timeRemoveAppxProv = Measure-Command { Remove-AppxProv | Out-Default }
Write-Output "Elapsed: $($timeRemoveAppxProv.TotalSeconds) second(s)"

$ProgressPreference = "Continue"
Pause
