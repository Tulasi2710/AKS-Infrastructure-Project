# Development Environment Variables
# Configuration for AKS Infrastructure Project

# Resource Group Configuration
location = "East US"
environment = "dev"
project_name = "aks-infra"

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_address_prefix = "10.0.1.0/24"

# AKS Configuration
aks_cluster_name = "" # Will be auto-generated if left empty
kubernetes_version = "1.28.0"
node_count = 2
vm_size = "Standard_DS2_v2"
enable_auto_scaling = true
min_node_count = 1
max_node_count = 5

# Tags
tags = {
  Environment = "Development"
  Project     = "AKS-Infrastructure"
  ManagedBy   = "Terraform"
}# Trigger workflow
