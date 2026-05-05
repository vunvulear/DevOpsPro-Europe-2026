variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group."
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the Linux App Service Plan."
  type        = string
}

variable "app_service_name" {
  description = "Name of the Linux Web App."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, test, prod)."
  type        = string
}

variable "owner" {
  description = "Owning team or person for cost allocation and contact."
  type        = string
}

variable "project" {
  description = "Logical project name used for tagging and grouping."
  type        = string
  default     = "brasov-sunset-api"
}

variable "node_version" {
  description = "Node.js runtime version for the Linux Web App."
  type        = string
  default     = "20-lts"
}

variable "sku_name" {
  description = "App Service Plan SKU. B1 is a sensible demo default."
  type        = string
  default     = "B1"
}
