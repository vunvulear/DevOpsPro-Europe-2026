variable "project_name" {
  description = "Short project slug, used in resource names. 3-12 lowercase alphanumerics."
  type        = string
  default     = "sunsetapi"

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.project_name))
    error_message = "project_name must be 3-12 lowercase alphanumeric characters."
  }
}

variable "location" {
  description = "Azure region for the bootstrap resources."
  type        = string
  default     = "westeurope"
}

variable "github_repository" {
  description = "GitHub repository in 'owner/repo' form. Federated credentials are scoped to it."
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be in 'owner/repo' form."
  }
}

variable "github_environments" {
  description = "GitHub Actions environments that may assume the federated identity."
  type        = list(string)
  default     = ["dev", "prod"]
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    project     = "brasov-sunset-api"
    managed_by  = "terraform"
    component   = "bootstrap"
  }
}
