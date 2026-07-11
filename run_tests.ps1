# Runs the GUT unit + integration test suite headless.
#
# Usage:
#   .\run_tests.ps1                       # auto-detects the Godot executable
#   .\run_tests.ps1 -GodotPath "C:\...\Godot.exe"
#   $env:GODOT = "C:\...\Godot.exe"; .\run_tests.ps1
#
# Exit code mirrors GUT: 0 when all tests pass, non-zero on failure.

param(
    [string]$GodotPath = $env:GODOT
)

# Note: no global "Stop" — Godot prints warnings to stderr, which PowerShell would
# otherwise treat as terminating errors and abort before reporting the real exit code.
$gameDir = Join-Path $PSScriptRoot "game"

# Resolve the Godot executable: explicit arg / $env:GODOT, then PATH, then a WinGet install.
if (-not $GodotPath) {
    $onPath = (Get-Command godot -ErrorAction SilentlyContinue).Source
    if ($onPath) {
        $GodotPath = $onPath
    } else {
        $wingetDir = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
        $found = Get-ChildItem -Path $wingetDir -Recurse -Filter "Godot_v*_win64_console.exe" -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
        if ($found) { $GodotPath = $found }
    }
}

if (-not $GodotPath -or -not (Test-Path $GodotPath)) {
    Write-Error "Godot executable not found. Pass -GodotPath or set `$env:GODOT."
    exit 1
}

Write-Host "Using Godot: $GodotPath"
& $GodotPath --headless --path $gameDir -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit
exit $LASTEXITCODE
