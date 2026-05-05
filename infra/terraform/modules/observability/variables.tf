variable "name" {
  type        = string
  description = "Resource name suffix (e.g. 'sunsetapi-dev')."
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "public_app_url" {
  type        = string
  default     = null
  description = "Public ingress URL of the app for the availability web test. Pass null to skip."
}

variable "tags" {
  type    = map(string)
  default = {}
}
