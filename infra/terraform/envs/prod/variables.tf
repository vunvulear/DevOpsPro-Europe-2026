variable "project_name" {
  type    = string
  default = "sunsetapi"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "app_version" {
  description = "Version label surfaced as APP_VERSION (typically the released git tag)."
  type        = string
}

variable "app_service_sku" {
  description = "App Service Plan SKU. P1v3 is the recommended floor for prod."
  type        = string
  default     = "P1v3"
}

variable "deployer_principal_ids" {
  type    = list(string)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 90
}
