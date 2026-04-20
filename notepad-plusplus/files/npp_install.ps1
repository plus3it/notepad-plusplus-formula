# Script to install Notepad++ while still keeping saltstack's output not
# completely horrific
#
################################################################################

# Force PowerShell to stop on errors so we can catch them and report to Salt
$ErrorActionPreference = 'Stop'

$target = $args[0].Trim("'")
$tempExe = $args[1].Trim("'")

# Normalize the exe-installer's path
$tempExe = $tempExe -replace '/', '\'

# Declare registry-keys to be modified
$paths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"
)

$installed = $false

# Do pre-installation Check of registry-keys
foreach ($path in $paths) {
  if (Test-Path $path) {
    $val = (Get-ItemProperty $path).DisplayVersion
    if ($val -match $target) { $installed = $true; break }
  }
}

# Execute the EXE-based installer
if (-not $installed) {
  Write-Output "Version $target not found. Attempting to install from $tempExe..."
  try {
    # "remote" files may get marked as blocked. Bypass that nonsense
    Unblock-File -Path $tempExe -ErrorAction SilentlyContinue

    # Execute the EXE-installer
    & $tempExe /S | Out-Null

    # Capture the result of the installer
    $exitCode = $LASTEXITCODE

    # Give the Registry a few seconds to flush changes to disk
    Start-Sleep -Seconds 5

    # Make sure we did what we tried to do...
    $verified = $false
    foreach ($path in $paths) { if (Test-Path $path) { $verified = $true } }

    if ($verified) {
        Write-Output "Installation successful (Exit Code: $exitCode)."
        exit 0
    } else {
        Write-Error "Installer finished (Exit Code: $exitCode) but registry keys not found."
        exit 1
    }
  } catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
  }
} else {
  Write-Output "Notepad++ $target already installed. Skipping."
  exit 0
}
