<#
.SYNOPSIS
  Build and run the API locally in Docker, then probe its endpoints.
#>

[CmdletBinding()]
param(
  [int]$Port = 3000
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$ctx      = Join-Path $repoRoot 'App'
$image    = 'brasov-sunset-api:local'
$name     = 'brasov-sunset-api-local'

Write-Host "==> docker build" -ForegroundColor Cyan
docker build `
  --build-arg APP_VERSION=local `
  --build-arg GIT_SHA=$(git -C $repoRoot rev-parse --short HEAD 2>$null) `
  -t $image `
  -f (Join-Path $ctx 'Dockerfile') `
  $ctx

Write-Host "==> docker run" -ForegroundColor Cyan
docker rm -f $name 2>$null | Out-Null
docker run -d --name $name -p "${Port}:3000" $image | Out-Null

Start-Sleep -Seconds 2
foreach ($p in @('/healthz', '/readyz', '/sunset')) {
  Write-Host "==> GET http://localhost:$Port$p" -ForegroundColor Cyan
  try {
    Invoke-RestMethod "http://localhost:$Port$p" | ConvertTo-Json -Depth 5
  } catch {
    Write-Warning "Failed: $($_.Exception.Message)"
  }
}

Write-Host "`nContainer '$name' is running on port $Port. Stop it with:" -ForegroundColor Yellow
Write-Host "  docker rm -f $name"
