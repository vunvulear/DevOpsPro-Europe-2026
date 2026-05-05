data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
  numeric = true
}

locals {
  suffix = random_string.suffix.result
}

# ---------------------------------------------------------------------------
# Remote state backend
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.project_name}-tfstate"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "st${var.project_name}tf${local.suffix}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # required by azurerm backend
  public_network_access_enabled   = true # tighten with private endpoint in production

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC federated identity (no client secrets)
# ---------------------------------------------------------------------------

resource "azuread_application" "github" {
  display_name = "gh-oidc-${var.project_name}"
}

resource "azuread_service_principal" "github" {
  client_id = azuread_application.github.client_id
}

# Branch-scoped credential (push to main → deploys to dev)
resource "azuread_application_federated_identity_credential" "main_branch" {
  application_id = azuread_application.github.id
  display_name   = "github-main-branch"
  description    = "Federated credential for pushes to main"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository}:ref:refs/heads/main"
}

# Pull request credential (CI plan only, no apply)
resource "azuread_application_federated_identity_credential" "pull_request" {
  application_id = azuread_application.github.id
  display_name   = "github-pull-request"
  description    = "Federated credential for pull requests (read-only plans)"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository}:pull_request"
}

# Environment-scoped credentials (dev, prod, ...)
resource "azuread_application_federated_identity_credential" "environment" {
  for_each = toset(var.github_environments)

  application_id = azuread_application.github.id
  display_name   = "github-env-${each.value}"
  description    = "Federated credential for GitHub environment ${each.value}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository}:environment:${each.value}"
}

# Subscription-level role assignments. Tighten scope (per-RG) once envs exist.
resource "azurerm_role_assignment" "contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github.object_id
}

resource "azurerm_role_assignment" "rbac_admin" {
  # Required so Terraform can create role assignments inside envs.
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.github.object_id
}

resource "azurerm_role_assignment" "tfstate_blob" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github.object_id
}
