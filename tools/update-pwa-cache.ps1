[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$BuildDirectory
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$versionPath = Join-Path $repoRoot 'version.json'
$version = Get-Content -Raw -Encoding utf8 $versionPath | ConvertFrom-Json
$cacheVersion = [string]$version.label
if ([string]::IsNullOrWhiteSpace($cacheVersion)) {
  throw 'version.json does not contain a release label.'
}

$buildPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $BuildDirectory))
$indexPath = Join-Path $buildPath 'index.html'
$bootstrapPath = Join-Path $buildPath 'flutter_bootstrap.js'
$workerPath = Join-Path $buildPath 'pwa_cache_worker.js'
$workerSourcePath = Join-Path $repoRoot 'flutter_pwa\web\pwa_cache_worker.js'
$marker = '__PWA_CACHE_VERSION__'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

if (-not (Test-Path -LiteralPath $workerSourcePath)) {
  throw "PWA cache worker source is missing: $workerSourcePath"
}

# Recent Flutter web builds do not consistently copy arbitrary worker files
# from web/ into build/web. Always refresh this custom worker from source so a
# stale previous-release worker cannot retain an old cache version.
Copy-Item -LiteralPath $workerSourcePath -Destination $workerPath -Force

foreach ($path in @($indexPath, $bootstrapPath, $workerPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Expected PWA cache file was not built: $path"
  }
  $content = [IO.File]::ReadAllText($path)
  if ($content.Contains($marker)) {
    [IO.File]::WriteAllText($path, $content.Replace($marker, $cacheVersion), $utf8NoBom)
    continue
  }
  if (-not $content.Contains($cacheVersion)) {
    throw "PWA cache marker is missing from: $path"
  }
}

Write-Host "Prepared versioned PWA cache for $cacheVersion."
