resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = false
  public_network_access_enabled = true # tighten with private endpoint in production
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false

  # Premium-only hardening (no-op on Basic/Standard).
  retention_policy_in_days = var.sku == "Premium" ? 30 : null
  trust_policy_enabled     = var.sku == "Premium"

  tags = var.tags
}

# Allow the runtime managed identity to pull images.
resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.pull_principal_ids)
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# Allow the deployer (CI) identity to push images.
resource "azurerm_role_assignment" "acr_push" {
  for_each             = toset(var.push_principal_ids)
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = each.value
}
