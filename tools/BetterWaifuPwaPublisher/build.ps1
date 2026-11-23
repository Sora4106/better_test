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

$output = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $output -Force | Out-Null
$exe = Join-Path $output 'BetterWaifuPwaPublisher.exe'
$sources = @(
  (Join-Path $PSScriptRoot 'Program.cs')
  (Join-Path $PSScriptRoot 'PublisherSettings.cs')
  (Join-Path $PSScriptRoot 'ProcessRunner.cs')
  (Join-Path $PSScriptRoot 'PublisherEngine.cs')
  (Join-Path $PSScriptRoot 'MainForm.cs')
)

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

$item = Get-Item -LiteralPath $exe
Write-Host "Built $($item.FullName) ($($item.Length) bytes)."
