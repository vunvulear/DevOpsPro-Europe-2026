# Outputs consumed by the deploy + smoke-test workflow.
# Task: T4.6.

output "default_hostname" {
  description = "Public hostname of the Linux Web App."
  value       = azurerm_linux_web_app.app.default_hostname
}

output "resource_group_name" {
  description = "Resource group containing the App Service."
  value       = azurerm_resource_group.rg.name
}

output "app_name" {
  description = "App Service name (matches var.app_name)."
  value       = azurerm_linux_web_app.app.name
}
