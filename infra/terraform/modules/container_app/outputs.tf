output "fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "url" {
  value = "https://${azurerm_container_app.this.ingress[0].fqdn}"
}

output "name" {
  value = azurerm_container_app.this.name
}

output "environment_id" {
  value = azurerm_container_app_environment.this.id
}
