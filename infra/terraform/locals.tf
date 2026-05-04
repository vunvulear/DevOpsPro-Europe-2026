# Common tags applied to every resource. Required by constitution & tagging-policy.
# Task: T4.4.

locals {
  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    repo        = var.repo
  }
}
