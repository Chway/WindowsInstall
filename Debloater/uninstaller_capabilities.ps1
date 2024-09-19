$removable = @("App.StepsRecorder~~~~0.0.1.0",
  "App.Support.QuickAssist~~~~0.0.1.0",
  "MathRecognizer~~~~0.0.1.0",
  "Media.WindowsMediaPlayer~~~~0.0.12.0",
  "Microsoft.Windows.WordPad~~~~0.0.1.0",
  "OneCoreUAP.OneSync~~~~0.0.1.0",
  "Hello.Face.18967~~~~0.0.1.0",
  "Language.Speech~~~en-GB~0.0.1.0",
  "Language.Handwriting~~~en-GB~0.0.1.0")

$capabilities = Get-WindowsCapability -Online | Where-Object State -EQ Installed | Select-Object Name

foreach ($capability in $capabilities) {
  if ($removable -contains $capability.Name) {
    Write-Output "Removing $($capability.Name)"
    Remove-WindowsCapability -Online -Name $capability.Name 
  }
}
