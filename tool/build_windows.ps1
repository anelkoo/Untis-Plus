# Builds the Windows app and the installer locally: dist\UntisPlus-Setup.exe
# Needs Windows Developer Mode (Flutter plugins use symlinks) and Inno Setup 6.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
flutter build windows --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([^+\s]+)').Matches[0].Groups[1].Value
$iscc = @(
  (Get-Command iscc -ErrorAction SilentlyContinue).Source,
  "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $iscc) { throw 'Inno Setup 6 not found: winget install JRSoftware.InnoSetup' }
& $iscc /Q "/DAppVersion=$version" windows\installer.iss
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Installer: $((Resolve-Path dist\UntisPlus-Setup.exe).Path)"
