# Dream Server Root Installer (Windows)
# Delegates to dream-server/installers/windows/install-windows.ps1

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Dream Server Installer" -ForegroundColor Cyan
Write-Host ""

# Delegate to Windows installer
$DreamServerInstaller = Join-Path (Join-Path (Join-Path $ScriptDir "dream-server") "installers") "windows" | Join-Path -ChildPath "install-windows.ps1"
if (-not (Test-Path $DreamServerInstaller)) {
    Write-Host "Error: Windows installer not found" -ForegroundColor Red
    Write-Host "Expected: $DreamServerInstaller" -ForegroundColor Red
    exit 1
}

# Execute Windows installer with all passed arguments
& $DreamServerInstaller @RemainingArgs
