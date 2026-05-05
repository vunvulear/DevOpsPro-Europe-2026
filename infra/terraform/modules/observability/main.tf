resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "Node.JS"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# Availability test: fires from Azure to /healthz every 5 minutes.
resource "azurerm_application_insights_standard_web_test" "healthz" {
  count = var.public_app_url == null ? 0 : 1

  name                    = "wt-${var.name}-healthz"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.this.id
  geo_locations           = ["emea-nl-ams-azr", "emea-ru-msa-edge", "emea-gb-db3-azr"]
  frequency               = 300
  timeout                 = 30
  enabled                 = true

  request {
    url = "${var.public_app_url}/healthz"
  }

  validation_rules {
    expected_status_code        = 200
    ssl_check_enabled           = true
    ssl_cert_remaining_lifetime = 7
  }

  tags = var.tags
}
