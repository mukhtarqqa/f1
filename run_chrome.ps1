param(
    [string]$SupabaseUrl = $env:SUPABASE_URL,
    [string]$SupabaseKey = $env:SUPABASE_ANON_KEY,
    [int]$Port = 5173
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

# Reuse the project's local VS Code configuration when available.
$launchPath = Join-Path $PSScriptRoot '.vscode/launch.json'
if ((-not $SupabaseUrl -or -not $SupabaseKey) -and (Test-Path -LiteralPath $launchPath)) {
    $launch = Get-Content -LiteralPath $launchPath -Raw | ConvertFrom-Json
    $chrome = $launch.configurations | Where-Object deviceId -EQ 'chrome' | Select-Object -First 1
    foreach ($argument in $chrome.args) {
        if (-not $SupabaseUrl -and $argument.StartsWith('--dart-define=SUPABASE_URL=')) {
            $SupabaseUrl = $argument.Substring('--dart-define=SUPABASE_URL='.Length)
        }
        if (-not $SupabaseKey -and $argument.StartsWith('--dart-define=SUPABASE_ANON_KEY=')) {
            $SupabaseKey = $argument.Substring('--dart-define=SUPABASE_ANON_KEY='.Length)
        }
    }
}

if (-not $SupabaseUrl -or -not $SupabaseKey) {
    throw 'Передайте -SupabaseUrl и -SupabaseKey либо задайте SUPABASE_URL и SUPABASE_ANON_KEY.'
}

& flutter run -d chrome "--web-port=$Port" "--dart-define=SUPABASE_URL=$SupabaseUrl" "--dart-define=SUPABASE_ANON_KEY=$SupabaseKey"
exit $LASTEXITCODE
