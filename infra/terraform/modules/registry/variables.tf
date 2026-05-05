variable "acr_name" {
  description = "Globally unique ACR name (lowercase, 5-50 chars)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "sku" {
  type    = string
  default = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "pull_principal_ids" {
  description = "Object IDs of identities that should be granted AcrPull."
  type        = list(string)
  default     = []
}

variable "push_principal_ids" {
  description = "Object IDs of identities (CI service principals) that should be granted AcrPush."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
