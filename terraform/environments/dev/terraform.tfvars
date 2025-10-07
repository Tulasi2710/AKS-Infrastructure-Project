# Development Environment Variables
# Configuration for AKS Infrastructure Project

# Resource Group Configuration
location = "East US"

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_cidr    = "10.0.1.0/24"

# AKS Configuration
node_count   = 2
node_vm_size = "Standard_D2s_v6"

# AKS Network Configuration (to avoid CIDR conflicts)
service_cidr       = "172.16.0.0/16"
dns_service_ip     = "172.16.0.10"
docker_bridge_cidr = "172.17.0.1/16"
