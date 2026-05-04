# Azure provider config. Subscription/tenant come from ARM_* env vars set by azure/login@v2 (OIDC).
# Task: T4.2. Constitution: P-II (OIDC-only).

provider "azurerm" {
  features {}
}
