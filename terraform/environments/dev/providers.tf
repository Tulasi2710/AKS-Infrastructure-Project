# Terraform providers and version constraints
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration - will be configured during initialization
  backend "azurerm" {
    # These values will be provided during terraform init
    # resource_group_name  = ""
    # storage_account_name = ""
    # container_name      = ""
    # key                = ""
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # Use workload identity federation for GitHub Actions
  use_oidc = true
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}