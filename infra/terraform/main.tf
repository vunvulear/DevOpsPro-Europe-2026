locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_service_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = var.node_version
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }
}
