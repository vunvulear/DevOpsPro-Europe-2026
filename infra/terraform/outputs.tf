output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "app_service_name" {
  description = "Name of the Linux Web App."
  value       = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  description = "Public URL of the deployed app."
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "default_hostname" {
  description = "Default hostname (without scheme)."
  value       = azurerm_linux_web_app.main.default_hostname
}
