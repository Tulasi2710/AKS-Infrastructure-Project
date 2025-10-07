# Development Environment Configuration
# This file orchestrates the deployment of AKS infrastructure for development

locals {
  environment = "dev"
  project     = "aks-infra"

  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    CreatedBy   = "DevOps Team"
  }
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group
module "resource_group" {
  source = "../../modules/resource-group"

  name     = "${local.project}-${local.environment}-rg-${random_string.suffix.result}"
  location = var.location
  tags     = local.common_tags
}

# Networking
module "networking" {
  source = "../../modules/networking"

  vnet_name           = "${local.project}-${local.environment}-vnet"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# AKS Cluster
module "aks" {
  source = "../../modules/aks"

  cluster_name        = "${local.project}-${local.environment}-aks-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "${local.project}-${local.environment}-${random_string.suffix.result}"
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  subnet_id           = module.networking.aks_subnet_id

  tags = local.common_tags

  depends_on = [module.networking]
}