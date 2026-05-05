<#
.SYNOPSIS
  One-time Azure bootstrap: creates the Terraform state backend and the GitHub
  OIDC AAD application + federated credentials for this repo.

.PARAMETER GitHubRepo
  GitHub repository in 'owner/repo' form.

.PARAMETER ProjectName
  Short slug used in resource names (3-12 lowercase alphanumerics).

.PARAMETER Location
  Azure region.

.EXAMPLE
  ./scripts/bootstrap-azure.ps1 -GitHubRepo your-org/DevOps2026_BMAD
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]  [string]$GitHubRepo,
  [Parameter(Mandatory = $false)] [string]$ProjectName = 'sunsetapi',
  [Parameter(Mandatory = $false)] [string]$Location    = 'westeurope'
)

$ErrorActionPreference = 'Stop'

$repoRoot      = Resolve-Path (Join-Path $PSScriptRoot '..')
$bootstrapDir  = Join-Path $repoRoot 'infra/terraform/bootstrap'

Write-Host "==> Verifying tools" -ForegroundColor Cyan
foreach ($cmd in @('az', 'terraform')) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "$cmd is required on PATH"
  }
}

Write-Host "==> Verifying az login" -ForegroundColor Cyan
$account = az account show --only-show-errors -o json | ConvertFrom-Json
Write-Host ("Subscription: {0} ({1})" -f $account.name, $account.id)

Push-Location $bootstrapDir
try {
  $tfvars = @"
project_name        = "$ProjectName"
location            = "$Location"
github_repository   = "$GitHubRepo"
github_environments = ["dev", "prod"]
"@
  Set-Content -Path 'terraform.tfvars' -Value $tfvars -Encoding utf8

  Write-Host "==> terraform init" -ForegroundColor Cyan
  terraform init -input=false

  Write-Host "==> terraform apply" -ForegroundColor Cyan
  terraform apply -input=false -auto-approve

  Write-Host "`n==> Bootstrap outputs" -ForegroundColor Green
  terraform output

  Write-Host "`nNext steps:" -ForegroundColor Yellow
  Write-Host " 1. Set GitHub secrets:"
  Write-Host "     AZURE_CLIENT_ID       = github_oidc_client_id"
  Write-Host "     AZURE_TENANT_ID       = azure_tenant_id"
  Write-Host "     AZURE_SUBSCRIPTION_ID = azure_subscription_id"
  Write-Host "     TFSTATE_RG            = tfstate_resource_group"
  Write-Host "     TFSTATE_STORAGE       = tfstate_storage_account"
  Write-Host " 2. Create GitHub Environments 'dev' and 'prod'."
  Write-Host " 3. Push to main to trigger CD - Dev."
}
finally {
  Pop-Location
}
