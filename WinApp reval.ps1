try {

    $Log = "$env:TEMP\WindowsAppShortcut.log"

    function Write-Log {
        param($Text)
        Add-Content -Path $Log -Value "$(Get-Date -Format s) - $Text"
    }

    Write-Log "Starting"

    # Find Windows App AUMID
    $App = Get-StartApps | Where-Object {
        $_.Name -match "Windows App" -or $_.Name -match "Windows 365"
    } | Select-Object -First 1

    if (-not $App) {
        Write-Log "App not found"
        exit 0
    }

    $AUMID = $App.AppID

    Write-Log "Found AUMID: $AUMID"

    if (-not $AUMID) {
        Write-Log "No AUMID"
        exit 0
    }

    # User desktop
    $DesktopPath = [Environment]::GetFolderPath('Desktop')

    Write-Log "Desktop path: $DesktopPath"

    if (-not (Test-Path $DesktopPath)) {
        Write-Log "Desktop path missing"
        exit 0
    }

    $ShortcutPath = Join-Path $DesktopPath "Windows App.lnk"

    # Create shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

    $Shortcut.TargetPath = "explorer.exe"
    $Shortcut.Arguments = "shell:AppsFolder\$AUMID"
    $Shortcut.Description = "Windows App"

    $RdpExe = "$env:SystemRoot\System32\mstsc.exe"

    if (Test-Path $RdpExe) {
        $Shortcut.IconLocation = "$RdpExe,0"
    }

    $Shortcut.Save()

    Write-Log "Shortcut created"

}
catch {
    Add-Content -Path "$env:TEMP\WindowsAppShortcut.log" `
        -Value "$(Get-Date -Format s) - ERROR: $_"
}

exit 0