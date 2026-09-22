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
$workerPath = Join-Path $buildPath 'pwa_cache_worker.js'
$marker = '__PWA_CACHE_VERSION__'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

foreach ($path in @($indexPath, $workerPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Expected PWA cache file was not built: $path"
  }
  $content = [IO.File]::ReadAllText($path)
  if (-not $content.Contains($marker)) {
    throw "PWA cache marker is missing from: $path"
  }
  [IO.File]::WriteAllText($path, $content.Replace($marker, $cacheVersion), $utf8NoBom)
}

Write-Host "Prepared versioned PWA cache for $cacheVersion."
