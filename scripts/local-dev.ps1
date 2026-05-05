<#
.SYNOPSIS
  Run the API locally with Node.js, then probe its endpoints.
#>

[CmdletBinding()]
param(
  [int]$Port = 3000
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$appDir   = Join-Path $repoRoot 'App'

Write-Host "==> npm install" -ForegroundColor Cyan
Push-Location $appDir
try {
  npm install --no-audit --no-fund

  Write-Host "==> Starting server on port $Port" -ForegroundColor Cyan
  $env:PORT = "$Port"
  $env:APP_VERSION = 'local'
  $proc = Start-Process -FilePath 'node' -ArgumentList 'server.js' -PassThru -NoNewWindow

  try {
    Start-Sleep -Seconds 2
    foreach ($p in @('/healthz', '/readyz', '/sunset')) {
      Write-Host "==> GET http://localhost:$Port$p" -ForegroundColor Cyan
      try {
        Invoke-RestMethod "http://localhost:$Port$p" | ConvertTo-Json -Depth 5
      } catch {
        Write-Warning "Failed: $($_.Exception.Message)"
      }
    }
    Write-Host "`nServer running with PID $($proc.Id). Press Ctrl+C to stop, or:" -ForegroundColor Yellow
    Write-Host "  Stop-Process -Id $($proc.Id)"
    Wait-Process -Id $proc.Id
  }
  finally {
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }
  }
}
finally {
  Pop-Location
}
