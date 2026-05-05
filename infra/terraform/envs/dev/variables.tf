variable "project_name" {
  type    = string
  default = "sunsetapi"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "app_version" {
  description = "Free-form version label surfaced as APP_VERSION env var (typically the commit SHA)."
  type        = string
  default     = "dev"
}

variable "app_service_sku" {
  description = "App Service Plan SKU. B1 is enough for dev."
  type        = string
  default     = "B1"
}

variable "deployer_principal_ids" {
  description = "Object IDs of CI/operator identities granted Website Contributor on the web app."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  type    = number
  default = 30
}
