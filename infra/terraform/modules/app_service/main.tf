locals {
  base_app_settings = {
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_NODE_DEFAULT_VERSION = "~20"
    APP_VERSION                  = var.app_version
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }

  appinsights_settings = var.appinsights_connection_string == null ? {} : {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.appinsights_connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    XDT_MicrosoftApplicationInsights_NodeJS    = "1"
  }

  app_settings = merge(local.base_app_settings, local.appinsights_settings, var.extra_app_settings)
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = var.https_only
  public_network_access_enabled = true # tighten with Private Endpoint in production

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  site_config {
    always_on                         = var.sku_name != "F1" && var.sku_name != "B1" ? true : false
    ftps_state                        = "Disabled"
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
    minimum_tls_version               = var.minimum_tls_version
    http2_enabled                     = true

    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = local.app_settings

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
    application_logs {
      file_system_level = "Information"
    }
    detailed_error_messages = false
    failed_request_tracing  = false
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # CI deploys via WEBSITE_RUN_FROM_PACKAGE; the package URL is a live setting.
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  count = var.create_staging_slot ? 1 : 0

  name           = "staging"
  app_service_id = azurerm_linux_web_app.this.id

  https_only = var.https_only

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  site_config {
    always_on           = var.sku_name != "F1" && var.sku_name != "B1" ? true : false
    ftps_state          = "Disabled"
    health_check_path   = var.health_check_path
    minimum_tls_version = var.minimum_tls_version
    http2_enabled       = true

    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = local.app_settings

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "allLogs" }
  metric { category = "AllMetrics" }
}
