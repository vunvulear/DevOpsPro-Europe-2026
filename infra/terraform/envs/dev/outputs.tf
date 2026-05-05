output "resource_group" { value = azurerm_resource_group.this.name }
output "acr_login_server" { value = module.registry.login_server }
output "app_url"         { value = module.container_app.url }
output "container_app"   { value = module.container_app.name }
output "key_vault"       { value = module.keyvault.name }
output "appinsights_connection_string" {
  value     = module.observability.appinsights_connection_string
  sensitive = true
}
