param(
  [string]$Version,
  [Parameter(Mandatory = $true)]
  [string[]]$Notes
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$versionPath = Join-Path $projectRoot 'version.json'
$versionData = Get-Content -Raw -Encoding UTF8 $versionPath | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($Version)) {
  $parts = $versionData.version -split '\.' | ForEach-Object { [int]$_ }
  $Version = '{0}.{1}.{2}' -f $parts[0], $parts[1], ($parts[2] + 1)
}
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
  throw "Version must use semantic version format, for example 1.2.0."
}

$build = ([int]$versionData.build) + 1
$label = "$Version+$build"
$date = Get-Date -Format 'yyyy-MM-dd'
$entry = [ordered]@{
  version = $Version
  build = $build
  label = $label
  date = $date
  notes = ($Notes -join '; ')
}
$history = @($entry) + @($versionData.history)
$newData = [ordered]@{
  version = $Version
  build = $build
  label = $label
  history = $history
}
$json = $newData | ConvertTo-Json -Depth 8
Set-Content -LiteralPath $versionPath -Value $json -Encoding UTF8

$dartHistory = ($history | ForEach-Object {
  $safeNotes = $_.notes.Replace([string][char]39, ([string][char]92 + [string][char]39))
  "  {'version': '$($_.version)', 'build': '$($_.build)', 'label': '$($_.label)', 'date': '$($_.date)', 'notes': '$safeNotes'},"
}) -join "`n"
$dart = @(
  "const appVersion = '$Version';"
  "const appBuildNumber = $build;"
  "const appVersionLabel = '$label';"
  'const appVersionHistory = <Map<String, String>>['
  $dartHistory
  '];'
) -join "`n"
Set-Content -LiteralPath (Join-Path $projectRoot 'flutter_pwa/lib/app_version.dart') -Value $dart -Encoding UTF8

$pubspecPath = Join-Path $projectRoot 'flutter_pwa/pubspec.yaml'
$pubspec = Get-Content -Raw -Encoding UTF8 $pubspecPath
$pubspec = [regex]::Replace($pubspec, '(?m)^version:\s*.*$', "version: $label")
Set-Content -LiteralPath $pubspecPath -Value $pubspec -Encoding UTF8

$changelogPath = Join-Path $projectRoot 'CHANGELOG.md'
$changelogLines = @(Get-Content -Encoding UTF8 $changelogPath)
$entryLines = @("## $label - $date", '', ($Notes | ForEach-Object { "- $_" }), '')
$newChangelog = @($changelogLines[0], '') + $entryLines + @($changelogLines[1..($changelogLines.Count - 1)])
Set-Content -LiteralPath $changelogPath -Value $newChangelog -Encoding UTF8

Write-Host "Updated BetterWaifu Prompt Builder to $label and appended the release history."
