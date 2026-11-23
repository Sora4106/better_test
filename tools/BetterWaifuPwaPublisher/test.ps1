[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compiler)) {
  throw "找不到 Windows .NET Framework C# 編譯器：$compiler"
}

$testDirectory = Join-Path ([IO.Path]::GetTempPath()) 'BetterWaifuPwaPublisherBuildTests'
New-Item -ItemType Directory -Path $testDirectory -Force | Out-Null
$testExe = Join-Path $testDirectory 'PublisherEngineSmokeTests.exe'

try {
  & $compiler `
    /nologo `
    /target:exe `
    /platform:x64 `
    /optimize+ `
    "/out:$testExe" `
    /reference:System.dll `
    /reference:System.Core.dll `
    /reference:System.Web.Extensions.dll `
    (Join-Path $PSScriptRoot 'PublisherSettings.cs') `
    (Join-Path $PSScriptRoot 'ProcessRunner.cs') `
    (Join-Path $PSScriptRoot 'PublisherEngine.cs') `
    (Join-Path $PSScriptRoot 'PublisherEngineSmokeTests.cs')

  if ($LASTEXITCODE -ne 0) {
    throw "測試程式編譯失敗，csc exit code: $LASTEXITCODE"
  }

  & $testExe
  if ($LASTEXITCODE -ne 0) {
    throw "Publisher engine smoke tests failed with exit code $LASTEXITCODE"
  }
} finally {
  if (Test-Path -LiteralPath $testExe) {
    Remove-Item -LiteralPath $testExe -Force
  }
}
