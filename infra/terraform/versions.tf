terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # State is intentionally local for the live demo.
  # Real projects should use a remote backend (azurerm) — see infra/terraform/README.md.
}
