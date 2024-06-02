$removable = @("WCF-Services45", 
  "WCF-TCP-PortSharing45", 
  "MediaPlayback", 
  "WindowsMediaPlayer",
  "SmbDirect",
  "MSRDC-Infrastructure",
  "WorkFolders-Client")

$features = Get-WindowsOptionalFeature -Online | Where-Object State -EQ Enabled | Select-Object FeatureName

foreach ($feature in $features) {
  if ($removable -contains $feature.FeatureName) {
    Write-Output "Disabling $($feature.FeatureName)"
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $feature.FeatureName 
  }
}
