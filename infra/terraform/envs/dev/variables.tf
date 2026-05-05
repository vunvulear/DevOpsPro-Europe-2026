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

variable "image_tag" {
  description = "Container image tag deployed by CI. Override via -var or TF_VAR_image_tag."
  type        = string
  default     = "latest"
}

variable "deployer_principal_ids" {
  description = "Object IDs of identities (e.g. GitHub OIDC SP) that need AcrPush + KV Secrets Officer."
  type        = list(string)
  default     = []
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "log_retention_days" {
  type    = number
  default = 30
}
