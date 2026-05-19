try {

    $Log = "$env:TEMP\WindowsAppShortcut.log"

    function Write-Log {
        param($Text)
        Add-Content -Path $Log -Value "$(Get-Date -Format s) - $Text"
    }

    Write-Log "Starting"

    # App AUMID
    $App = Get-StartApps | Where-Object {
        $_.Name -match "Windows App" -or $_.Name -match "Windows 365"
    } | Select-Object -First 1

    if (-not $App) {
        Write-Log "App not found"
        exit 0
    }

    $AUMID = $App.AppID

    Write-Log "Found AUMID: $AUMID"

    # Desktop path
    $DesktopPath = [Environment]::GetFolderPath('Desktop')

    if (-not (Test-Path $DesktopPath)) {
        Write-Log "Desktop missing"
        exit 0
    }

    $ShortcutPath = Join-Path $DesktopPath "Windows App.lnk"

    # Icon download location
    $IconFolder = "$env:LOCALAPPDATA\Company\Icons"
    $IconPath = Join-Path $IconFolder "WinApp.ico"

    if (!(Test-Path $IconFolder)) {
        New-Item -Path $IconFolder -ItemType Directory -Force | Out-Null
    }

    # Download icon
    $IconUrl = "https://raw.githubusercontent.com/TJM-davinci/WindowsAppIntuneScript/main/WinApp.ico"

    Invoke-WebRequest -Uri $IconUrl -OutFile $IconPath -UseBasicParsing

    Write-Log "Icon downloaded to $IconPath"

    # Create shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

    $Shortcut.TargetPath = "explorer.exe"
    $Shortcut.Arguments = "shell:AppsFolder\$AUMID"
    $Shortcut.Description = "Windows App"

    # Use custom icon
    if (Test-Path $IconPath) {
        $Shortcut.IconLocation = $IconPath
    }

    $Shortcut.Save()

    Write-Log "Shortcut created"

}
catch {
    Add-Content -Path "$env:TEMP\WindowsAppShortcut.log" `
        -Value "$(Get-Date -Format s) - ERROR: $_"
}

exit 0
