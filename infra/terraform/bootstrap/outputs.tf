output "tfstate_resource_group" {
  value       = azurerm_resource_group.tfstate.name
  description = "Resource group holding the Terraform state storage account."
}

output "tfstate_storage_account" {
  value       = azurerm_storage_account.tfstate.name
  description = "Storage account name. Use this in each env's backend.hcl."
}

output "tfstate_container" {
  value       = azurerm_storage_container.tfstate.name
  description = "Blob container for state files."
}

output "github_oidc_client_id" {
  value       = azuread_application.github.client_id
  description = "Set as GitHub secret AZURE_CLIENT_ID."
}

output "azure_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Set as GitHub secret AZURE_TENANT_ID."
}

output "azure_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Set as GitHub secret AZURE_SUBSCRIPTION_ID."
}
