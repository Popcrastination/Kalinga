# PowerShell equivalent of run.sh, for Windows terminals without Git Bash/WSL.
# Reads .env and runs the app with the matching --dart-define flags.
# Does NOT change how the app reads config — still --dart-define, still
# String.fromEnvironment in lib/services/supabase_config.dart. GEMINI_API_KEY
# is deliberately never read here; it never belongs on this command.
#
# Usage: .\run.ps1            (defaults to chrome)
#        .\run.ps1 web-server (or any other flutter run -d target)

param(
    [string]$Target = "chrome"
)

if (-not (Test-Path ".env")) {
    Write-Error "No .env found. Run: Copy-Item .env.example .env, then fill in your real values."
    exit 1
}

$envValues = @{}
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*([A-Z_]+)\s*=\s*(.+)\s*$') {
        $envValues[$matches[1]] = $matches[2]
    }
}

$supabaseUrl = $envValues["SUPABASE_URL"]
$supabaseKey = $envValues["SUPABASE_PUBLISHABLE_KEY"]

if ([string]::IsNullOrWhiteSpace($supabaseUrl) -or [string]::IsNullOrWhiteSpace($supabaseKey)) {
    Write-Error "SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY is empty in .env — fill both in first."
    exit 1
}

flutter run -d $Target `
    --dart-define=SUPABASE_URL=$supabaseUrl `
    --dart-define=SUPABASE_PUBLISHABLE_KEY=$supabaseKey
