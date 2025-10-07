output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}