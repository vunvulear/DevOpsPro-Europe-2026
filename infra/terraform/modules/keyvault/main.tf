data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = var.purge_protection
  soft_delete_retention_days    = 7
  public_network_access_enabled = true # tighten with private endpoint in production

  network_acls {
    default_action = "Allow" # tighten in production
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Reader access for the workload's managed identity.
resource "azurerm_role_assignment" "secrets_user" {
  for_each             = toset(var.secrets_user_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

# Author access for the operator running terraform locally.
resource "azurerm_role_assignment" "secrets_officer" {
  for_each             = toset(var.secrets_officer_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
}
