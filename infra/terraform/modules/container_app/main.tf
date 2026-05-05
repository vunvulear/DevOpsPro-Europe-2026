resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = "ca-${var.name}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.user_assigned_identity_id
  }

  ingress {
    external_enabled           = true
    target_port                = var.target_port
    transport                  = "auto"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "PORT"
        value = tostring(var.target_port)
      }

      env {
        name  = "APP_VERSION"
        value = var.app_version
      }

      dynamic "env" {
        for_each = var.appinsights_connection_string == null ? [] : [1]
        content {
          name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
          value = var.appinsights_connection_string
        }
      }

      liveness_probe {
        transport = "HTTP"
        port      = var.target_port
        path      = "/healthz"

        initial_delay           = 5
        interval_seconds        = 30
        timeout                 = 3
        failure_count_threshold = 3
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.target_port
        path      = "/readyz"

        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
        success_count_threshold = 1
      }

      startup_probe {
        transport = "HTTP"
        port      = var.target_port
        path      = "/healthz"

        interval_seconds        = 5
        timeout                 = 3
        failure_count_threshold = 12
      }
    }

    # Scale to/from zero based on concurrent HTTP requests.
    http_scale_rule {
      name                = "http-concurrency"
      concurrent_requests = var.concurrent_requests_per_replica
    }
  }

  lifecycle {
    # Image is updated by CI (az containerapp update). Don't fight CI on apply.
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}
