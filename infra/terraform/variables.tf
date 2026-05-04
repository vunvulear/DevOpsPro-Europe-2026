# Input variables. Values come from environments/<env>.tfvars; no defaults that hide intent.
# Task: T4.3. Constitution: P-IV.

variable "project" {
  description = "Short project slug used in tags and resource names."
  type        = string
}

variable "environment" {
  description = "Environment name. Allowed: dev, test, prod."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "owner" {
  description = "Owning team or individual; lands in tags."
  type        = string
}

variable "sku_name" {
  description = "App Service Plan SKU (e.g. B1, B2, P1v3)."
  type        = string
  default     = "B1"
}

variable "app_name" {
  description = "Globally unique App Service name. Use a placeholder in committed tfvars."
  type        = string
}

variable "repo" {
  description = "Owning repository in the form <org>/<repo>; lands in tags."
  type        = string
}
