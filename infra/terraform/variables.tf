variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the App Service."
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the Linux App Service Plan."
  type        = string
}

variable "app_service_name" {
  description = "Globally-unique name of the Linux Web App (becomes <name>.azurewebsites.net)."
  type        = string
}

variable "environment" {
  description = "Environment tag (e.g. dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Team or person responsible for the resources (used as tag, not a credential)."
  type        = string
  default     = "platform-team"
}

variable "project" {
  description = "Project name (used as tag)."
  type        = string
  default     = "brasov-sunset-api"
}

variable "node_version" {
  description = "Linux App Service Node.js runtime version (matches azurerm_linux_web_app application_stack.node_version)."
  type        = string
  default     = "20-lts"
}

variable "sku_name" {
  description = "App Service Plan SKU (e.g. B1, S1, P1v3). B1 is the cheapest reasonable Linux tier for the demo."
  type        = string
  default     = "B1"
}
