output "resource_group_name" {
  description = "Name of the created Resource Group."
  value       = azurerm_resource_group.this.name
}

output "app_service_name" {
  description = "Name of the created Linux Web App."
  value       = azurerm_linux_web_app.this.name
}

output "app_service_default_hostname" {
  description = "Default hostname of the Linux Web App, e.g. <name>.azurewebsites.net."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "app_service_url" {
  description = "Public HTTPS URL of the Linux Web App."
  value       = "https://${azurerm_linux_web_app.this.default_hostname}"
}
