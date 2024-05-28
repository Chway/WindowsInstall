$output_dir = "$env:USERPROFILE\Downloads\"

$tools = @(
  @{
    Url       = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" 
    Output    = "OOSU10.exe"
    GithubApi = $false
    Regex     = ""
    Disabled  = $false
  },
  @{
    Url       = "https://github.com/brave/brave-browser/releases/latest/download/BraveBrowserSetup.exe"
    Output    = "BraveSetup.exe"
    GithubApi = $false
    Regex     = ""
    Disabled  = $false
  }
  @{
    Url       = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    Output    = "GitSetup.exe"
    GithubApi = $true
    Regex     = "Git-.*-64-bit\.exe"
    Disabled  = $true
  }
  @{
    Url       = "https://api.github.com/repos/ip7z/7zip/releases/latest"
    Output    = "7zipSetup.exe"
    GithubApi = $true
    Regex     = "7z.*-x64\.exe"
    Disabled  = $false
  }
  @{
    Url       = "https://api.github.com/repos/rizonesoft/Notepad3/releases/latest"
    Output    = "Notepad3Setup.exe"
    GithubApi = $true
    Regex     = "Notepad3_.*_x64_Setup\.exe"
    Disabled  = $true
  }
)

$current_dir = (Get-Location).path
foreach ($tool in $tools) {
  Set-Location -Path $output_dir

  if ($tool.Disabled) {
    Continue
  }

  if (!($tool.GithubApi)) {
    Write-Output "Downloading $($tool.Url)"
    Invoke-WebRequest -Uri $tool.Url -OutFile $tool.Output
    Continue
  }

  $data = Invoke-RestMethod -Uri $tool.Url
  foreach ($asset in $data.assets) {
    $asset.name -match $tool.Regex | Out-Null
    if ($matches) {
      $matches = $null
      Write-Output "Downloading $($asset.browser_download_url)"
      Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tool.Output
      break
    }
  }
}

Set-Location -Path $current_dir
Pause