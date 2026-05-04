provider "azurerm" {
  features {}

  # No subscription_id / tenant_id / client_id hardcoded.
  # Authentication comes from environment (Azure CLI locally, OIDC in GitHub Actions).
}
