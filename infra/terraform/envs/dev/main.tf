locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    project     = "brasov-sunset-api"
    environment = var.environment
    managed_by  = "terraform"
  }

  kv_name = "kv-${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags
}

module "identity" {
  source              = "../../modules/identity"
  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags
}

module "observability" {
  source              = "../../modules/observability"
  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  retention_in_days   = var.log_retention_days
  public_app_url      = null # populate after first apply if you want availability tests
  tags                = local.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = local.kv_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  purge_protection    = false

  secrets_user_principal_ids    = [module.identity.principal_id]
  secrets_officer_principal_ids = var.deployer_principal_ids

  tags = local.tags
}

module "app_service" {
  source                        = "../../modules/app_service"
  name                          = local.name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku_name                      = var.app_service_sku
  user_assigned_identity_id     = module.identity.id
  log_analytics_workspace_id    = module.observability.log_analytics_workspace_id
  appinsights_connection_string = module.observability.appinsights_connection_string
  app_version                   = var.app_version
  create_staging_slot           = false # dev does not need slot swaps

  tags = local.tags
}

# Allow the deployer (CI service principal) to publish zip packages to the web app.
resource "azurerm_role_assignment" "deployer_website_contributor" {
  for_each             = toset(var.deployer_principal_ids)
  scope                = module.app_service.id
  role_definition_name = "Website Contributor"
  principal_id         = each.value
}
