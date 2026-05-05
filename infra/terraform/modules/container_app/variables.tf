variable "name"                       { type = string }
variable "resource_group_name"        { type = string }
variable "location"                   { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "user_assigned_identity_id"  { type = string }
variable "acr_login_server"           { type = string }

variable "image" {
  description = "Full image reference, e.g. acrname.azurecr.io/brasov-sunset-api:1.0.0."
  type        = string
}

variable "app_version" {
  type    = string
  default = "dev"
}

variable "appinsights_connection_string" {
  type      = string
  default   = null
  sensitive = true
}

variable "target_port" {
  type    = number
  default = 3000
}

variable "cpu"    { type = number;  default = 0.25 }
variable "memory" { type = string;  default = "0.5Gi" }

variable "min_replicas" { type = number; default = 0 }
variable "max_replicas" { type = number; default = 3 }

variable "concurrent_requests_per_replica" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
