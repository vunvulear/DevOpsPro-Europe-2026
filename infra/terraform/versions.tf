# Terraform + provider version pins. Local state by design (demo simplification).
# Task: T4.1. Constitution: P-IV (one screen per file).

terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
