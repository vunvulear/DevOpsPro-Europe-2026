# Three resources: RG + Linux App Service Plan + Linux Web App for Node.js.
# Demo simplifications (intentional): local state, no slots, no diagnostic settings, no APIM.
# Task: T4.5. Constitution: P-IV (hardening defaults), Additional Constraints (tags).

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = local.common_tags

  site_config {
    health_check_path        = "/healthz"
    http2_enabled            = true
    minimum_tls_version      = "1.2"
    ftps_state               = "Disabled"
    websockets_enabled       = false
    remote_debugging_enabled = false

    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "~20"
  }
}
