output "name" {
  value = azurerm_linux_web_app.this.name
}

output "id" {
  value = azurerm_linux_web_app.this.id
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "principal_id" {
  description = "System-assigned principal ID. Empty unless system identity is enabled (we use user-assigned)."
  value       = try(azurerm_linux_web_app.this.identity[0].principal_id, null)
}

output "staging_slot_name" {
  value = try(azurerm_linux_web_app_slot.staging[0].name, null)
}

output "staging_slot_url" {
  value = try("https://${azurerm_linux_web_app_slot.staging[0].default_hostname}", null)
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}
