locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    project     = "brasov-sunset-api"
    environment = var.environment
    managed_by  = "terraform"
  }

  acr_name = lower(replace("acr${var.project_name}${var.environment}", "-", ""))
  kv_name  = "kv-${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

module "identity" {
  source              = "../../modules/identity"
  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags
}

module "registry" {
  source              = "../../modules/registry"
  acr_name            = local.acr_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Premium" # gives geo-replication, retention, trust policy

  pull_principal_ids = [module.identity.principal_id]
  push_principal_ids = var.deployer_principal_ids

  tags = local.tags
}

module "observability" {
  source              = "../../modules/observability"
  name                = local.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  retention_in_days   = var.log_retention_days
  public_app_url      = null
  tags                = local.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = local.kv_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  purge_protection    = true

  secrets_user_principal_ids    = [module.identity.principal_id]
  secrets_officer_principal_ids = var.deployer_principal_ids

  tags = local.tags
}

module "container_app" {
  source                        = "../../modules/container_app"
  name                          = local.name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  log_analytics_workspace_id    = module.observability.log_analytics_workspace_id
  user_assigned_identity_id     = module.identity.id
  acr_login_server              = module.registry.login_server
  image                         = "${module.registry.login_server}/brasov-sunset-api:${var.image_tag}"
  app_version                   = var.image_tag
  appinsights_connection_string = module.observability.appinsights_connection_string

  min_replicas = var.min_replicas
  max_replicas = var.max_replicas
  cpu          = 0.5
  memory       = "1Gi"

  tags = local.tags
}
