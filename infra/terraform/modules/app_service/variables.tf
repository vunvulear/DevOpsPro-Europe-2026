variable "name" {
  description = "Resource name suffix (e.g. 'sunsetapi-dev')."
  type        = string
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "sku_name" {
  description = "App Service Plan SKU. B1 for dev, P0v3 / P1v3 for prod."
  type        = string
  default     = "B1"
}

variable "node_version" {
  description = "Linux Node.js runtime version, e.g. '20-lts'."
  type        = string
  default     = "20-lts"
}

variable "user_assigned_identity_id" {
  description = "Resource ID of the user-assigned managed identity bound to the web app."
  type        = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "appinsights_connection_string" {
  type      = string
  default   = null
  sensitive = true
}

variable "app_version" {
  type    = string
  default = "dev"
}

variable "extra_app_settings" {
  description = "Additional app settings to merge into the web app."
  type        = map(string)
  default     = {}
}

variable "create_staging_slot" {
  description = "If true, also create a 'staging' deployment slot for blue/green promotion."
  type        = bool
  default     = false
}

variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "https_only" {
  type    = bool
  default = true
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
