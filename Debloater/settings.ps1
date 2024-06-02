#Requires -RunAsAdministrator

$PSVersion = $PSVersionTable.PSVersion
$PSVersionStr = "$($PSVersion.Major).$($PSVersion.Minor)"
if ($PSVersionStr -ne "5.1") {
    Write-Output "PowerShell 5.1 is needed to run this script."
}

Set-Location $PSScriptRoot

# IMPORT REGISTRY KEYS
$regs = Get-ChildItem "settings\regs\"
$regsCount = ($regs | Measure-Object).Count
$i = 0
foreach ($reg in $regs) {
    regedit.exe /s $reg.FullName | Out-Null
    $i++
    Write-Progress -Activity "Importing Registry Keys" -Status "Status: $i of $($regsCount)" -PercentComplete (($i / $regsCount) * 100)
}

# RUN PS SCRIPTS
$pss = Get-ChildItem "settings\ps\"
$pssCount = ($pss | Measure-Object).Count
$i = 0
foreach ($ps in $pss) {
    powershell.exe -ExecutionPolicy Bypass -File $ps.FullName | Out-Null
    $i++
    Write-Progress -Activity "Running Scripts" -Status "Status: $i of $($pssCount)" -PercentComplete (($i / $pssCount) * 100)
}

Write-Progress -Activity "Running OOSU10"
& OOSU10 "..\OOSU10\ooshutup10.cfg" "/quiet" "/nosrp"
