# Setup paths based on standard Notepad++ installation patterns
$NppPath = "${env:ProgramFiles}\Notepad++"
$NppExe  = Join-Path $NppPath "notepad++.exe"

# PRE-CONDITION (State Check)
# Check if the main executable exists. If not, we assume it's already gone.
if (Test-Path $NppExe) {
    Write-Output "Found Notepad++ binary at '$NppExe'"
}
else {
    # Salt will see this string in 'stdout'; exit 100 identifies "Already Absent"
    Write-Output "State: Already Absent"
    exit 100
}

# EXECUTION
# Notepad++ stores its uninstaller directly in the install directory
$Uninstaller = Join-Path $NppPath "uninstall.exe"

if (Test-Path $Uninstaller) {
    Write-Output "Found uninstaller at '$Uninstaller'"
    Write-Output "Executing silent uninstallation..."

    # Start the uninstaller with the /S (Silent) flag
    $Proc = Start-Process -FilePath "$Uninstaller" -ArgumentList "/S" -Wait -PassThru

    # Optional: Wait briefly for file system hooks to release
    Start-Sleep -Seconds 2

    # FINAL VERIFICATION
    if (-not (Test-Path $NppExe)) {
        Write-Output "State: Success"
        exit 0
    } else {
        Write-Error "State: Failed to remove binary"
        exit 1
    }
}
else {
    # If binary exists but uninstaller is missing, we have a "dirty" state
    Write-Error "Binary found but '$Uninstaller' is missing. Manual cleanup required."
    exit 1
}

exit 100
