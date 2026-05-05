provider "azurerm" {
  features {}

  # Authentication is expected to come from the environment:
  # - GitHub Actions OIDC (preferred), or
  # - `az login` for local development.
  #
  # Do NOT hardcode subscription_id, tenant_id, or client_id here.
}
