locals {
  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    repo        = "DevOpsPro-Europe-2026"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  os_type  = "Linux"
  sku_name = var.sku_name

  tags = local.common_tags
}

resource "azurerm_linux_web_app" "main" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only          = true
  client_affinity_enabled = false

  site_config {
    always_on              = var.sku_name != "F1" && var.sku_name != "B1" ? true : false
    health_check_path      = "/healthz"
    minimum_tls_version    = "1.2"
    ftps_state             = "Disabled"
    http2_enabled          = true
    websockets_enabled     = false
    remote_debugging_enabled = false

    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = var.node_version
    "WEBSITES_PORT"                = "3000"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENVIRONMENT"                  = var.environment
  }

  tags = local.common_tags
}
