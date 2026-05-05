output "resource_group" { value = azurerm_resource_group.this.name }
output "app_name"       { value = module.app_service.name }
output "app_url"        { value = module.app_service.url }
output "key_vault"      { value = module.keyvault.name }

output "appinsights_connection_string" {
  value     = module.observability.appinsights_connection_string
  sensitive = true
}
