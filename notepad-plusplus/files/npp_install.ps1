# Script to install Notepad++ while still keeping saltstack's output not 
# completely horrific
$target = $args[0]
$tempExe = $args[1]

$paths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"
)

$installed = $false

# Iterate our HKLM paths and determine if NPP is already installed and at 
# correct version
foreach ($path in $paths) {
  if (Test-Path $path) {
    $val = (Get-ItemProperty $path).DisplayVersion
    if ($val -match $target) { $installed = $true; break }
  }
}

# Install if necessary
if (-not $installed) {
  Write-Host "Version $target not found. Installing..."
  Start-Process $tempExe -ArgumentList '/S' -Wait
  Start-Sleep -Seconds 5
} else {
  Write-Host "Notepad++ $target already installed. Skipping."
}

