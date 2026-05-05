variable "name" {
  description = "Globally unique Key Vault name (3-24 alphanumeric/dashes)."
  type        = string
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "purge_protection" {
  type    = bool
  default = false
}

variable "secrets_user_principal_ids" {
  type    = list(string)
  default = []
}

variable "secrets_officer_principal_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
