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

variable "image_tag" {
  description = "Container image tag deployed by CI."
  type        = string
}

variable "deployer_principal_ids" {
  type    = list(string)
  default = []
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 10
}

variable "log_retention_days" {
  type    = number
  default = 90
}
