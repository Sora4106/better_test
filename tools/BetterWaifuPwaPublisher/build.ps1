[CmdletBinding()]
param(
  [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $PSScriptRoot 'release'
}
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compiler)) {
  throw "找不到 Windows .NET Framework C# 編譯器：$compiler"
}

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$versionPath = Join-Path $projectRoot 'version.json'
if (-not (Test-Path -LiteralPath $versionPath)) {
  throw "找不到專案版本檔案：$versionPath"
}
$versionData = Get-Content -Raw -Encoding UTF8 $versionPath | ConvertFrom-Json
$semanticVersion = [string]$versionData.version
$buildNumber = [int]$versionData.build
$versionLabel = [string]$versionData.label
$versionMatch = [regex]::Match($semanticVersion, '^(\d+)\.(\d+)\.(\d+)$')
if (-not $versionMatch.Success) {
  throw "version.json 的 version 格式不正確：$semanticVersion"
}
if ($versionLabel -ne "$semanticVersion+$buildNumber") {
  throw "version.json 的 label 與 version/build 不一致：$versionLabel"
}
$fileVersion = '{0}.{1}.{2}.{3}' -f $versionMatch.Groups[1].Value, $versionMatch.Groups[2].Value, $versionMatch.Groups[3].Value, $buildNumber

$output = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $output -Force | Out-Null
$exe = Join-Path $output "BetterWaifuPwaPublisher-v$versionLabel.exe"
$generatedSource = Join-Path ([IO.Path]::GetTempPath()) ("BetterWaifuPublisherVersion-{0}.cs" -f [Guid]::NewGuid().ToString('N'))
$generatedCode = @"
using System.Reflection;

[assembly: AssemblyVersion("$fileVersion")]
[assembly: AssemblyFileVersion("$fileVersion")]
[assembly: AssemblyInformationalVersion("$versionLabel")]

namespace BetterWaifuPwaPublisher
{
    internal static class PublisherBuildInfo
    {
        public const string VersionLabel = "$versionLabel";
    }
}
"@
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($generatedSource, $generatedCode, $utf8NoBom)
$sources = @(
  (Join-Path $PSScriptRoot 'Program.cs')
  (Join-Path $PSScriptRoot 'PublisherSettings.cs')
  (Join-Path $PSScriptRoot 'ProcessRunner.cs')
  (Join-Path $PSScriptRoot 'PublisherEngine.cs')
  (Join-Path $PSScriptRoot 'MainForm.cs')
  $generatedSource
)

try {
  & $compiler `
    /nologo `
    /target:winexe `
    /platform:x64 `
    /optimize+ `
    /debug- `
    "/win32manifest:$(Join-Path $PSScriptRoot 'app.manifest')" `
    "/out:$exe" `
    /reference:System.dll `
    /reference:System.Core.dll `
    /reference:System.Drawing.dll `
    /reference:System.Windows.Forms.dll `
    /reference:System.Web.Extensions.dll `
    @sources

  if ($LASTEXITCODE -ne 0) {
    throw "EXE 編譯失敗，csc exit code: $LASTEXITCODE"
  }
} finally {
  if (Test-Path -LiteralPath $generatedSource) {
    Remove-Item -LiteralPath $generatedSource -Force
  }
}

$item = Get-Item -LiteralPath $exe
Write-Host "Built BetterWaifu PWA Publisher $versionLabel at $($item.FullName) ($($item.Length) bytes)."
