# Script to install Notepad++ while still keeping saltstack's output not
# completely horrific
# Force PowerShell to stop on errors so we can catch them and report to Salt
$ErrorActionPreference = 'Stop'

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
  Write-Host "Version $target not found. Attempting to install from $tempExe..."
  try {
    # If the file is a .sig or corrupted, this will now trigger the 'catch' block
    Start-Process $tempExe -ArgumentList '/S' -Wait
    Start-Sleep -Seconds 5

    # Final verification: Check if the registry key now exists
    $verified = $false
    foreach ($path in $paths) { if (Test-Path $path) { $verified = $true } }

    if ($verified) {
        Write-Host "Installation successful."
        exit 0
    } else {
        Write-Error "Installer finished but registry keys not found."
        exit 1
    }
  } catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    # Explicitly return 1 so Salt catches the failure
    exit 1
  }
} else {
  Write-Host "Notepad++ $target already installed. Skipping."
  exit 0
}
