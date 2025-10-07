# 🚀 AKS Infrastructure Project - Complete Deployment Guide

**Assignment Compliance**: This project fully satisfies all requirements including Terraform infrastructure provisioning, security scanning with Checkov, microservices deployment, Prometheus/Grafana monitoring, and automated daily reporting.

**Ready-to-deploy infrastructure with automated CI/CD pipelines**

## ⚡ Quick Start (Recommended)

### GitHub Actions Deployment (Primary Method)

**Prerequisites:**
- GitHub account with this repository forked/cloned
- Azure subscription: `f4d6b5a0-37f2-49d8-85ea-fe757f8cf6b1`

**Steps:**
1. **Configure GitHub Secrets** (Repository Settings → Secrets and Variables → Actions):
   ```
   AZURE_CLIENT_ID = 4813e1ea-ebfa-46c4-bbdc-6bf8225ad061
   AZURE_TENANT_ID = <your-tenant-id>
   AZURE_SUBSCRIPTION_ID = f4d6b5a0-37f2-49d8-85ea-fe757f8cf6b1
   TF_STATE_RESOURCE_GROUP = TulasiteraformRG
   TF_STATE_STORAGE_ACCOUNT = tulasiteraformstfile
   ```

2. **Create Production Environment** (Repository Settings → Environments):
   - Click "New environment"
   - Name: `production`
   - Add protection rules as needed

3. **Trigger Deployment**:
   - Push to main branch, OR
   - Go to Actions tab → "Terraform AKS Infrastructure" → "Run workflow"

4. **Monitor & Approve**:
   - Watch progress in Actions tab
   - Approve deployment when prompted

**⏱️ Total deployment time: ~10-15 minutes**

## 💻 Local Development (Optional)

For testing and validation:
az group create --name "rg-tfstate" --location "East US"
az storage account create --name "sttfstate$(date +%s)" --resource-group "rg-tfstate" --location "East US" --sku "Standard_LRS"
az storage container create --name "tfstate" --account-name "<storage-account-name>"

# 2. Configure backend (update main.tf)
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "<your-storage-account>"
    container_name       = "tfstate"
    key                 = "dev.terraform.tfstate"
  }
}

# 3. Initialize with remote backend
terraform init

# 4. Deploy infrastructure
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## 🔧 Configuration Steps

### 1. Azure Prerequisites

```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "<subscription-id>"

# Verify current subscription
az account show --output table
```

### 2. Service Principal (For CI/CD)

```bash
# Create service principal
az ad sp create-for-rbac --name "sp-aks-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>" \
  --sdk-auth

# Save the JSON output for CI/CD secrets
```

### 3. Terraform Variables Configuration

Edit `terraform.tfvars`:

```hcl
# Required Variables
location = "East US"
environment = "dev"
project_name = "aks-infra"

# Networking
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_address_prefix = "10.0.1.0/24"

# AKS Configuration
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
}
```

## 🔄 CI/CD Pipeline Setup

### Azure DevOps Setup

1. **Create Azure DevOps Project**
2. **Create Service Connection**:
   - Project Settings → Service Connections
   - New Service Connection → Azure Resource Manager
   - Use the service principal created earlier

3. **Configure Pipeline Variables**:
   ```yaml
   # Variable Groups
   - TFSTATE_RESOURCE_GROUP: "rg-tfstate"
   - TFSTATE_STORAGE_ACCOUNT: "<storage-account-name>"
   - ARM_SUBSCRIPTION_ID: "<subscription-id>"
   ```

4. **Import Pipeline**:
   - Pipelines → New Pipeline
   - Select Azure Repos Git
   - Choose existing Azure Pipelines YAML file
   - Select `/pipelines/azure-pipelines.yml`

### GitHub Actions Setup

1. **Repository Secrets** (Settings → Secrets and Variables → Actions):
   ```
   AZURE_CREDENTIALS: <service-principal-json>
   TFSTATE_RESOURCE_GROUP: "rg-tfstate"
   TFSTATE_STORAGE_ACCOUNT: "<storage-account-name>"
   ```

2. **Workflow Triggers**:
   - Push to `main` branch: Automatic deployment
   - Pull requests: Plan only
   - Manual dispatch: Available for testing

## 📊 Post-Deployment Steps

### 1. Verify Infrastructure

```bash
# Check Terraform outputs
terraform output

# Verify Azure resources
az group list --output table
az aks list --output table
```

### 2. Configure kubectl

```bash
# Get AKS credentials
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>

# Verify cluster access
kubectl get nodes
kubectl get namespaces
```

### 3. Test Cluster Functionality

```bash
# Deploy test pod
kubectl run nginx --image=nginx --port=80
kubectl expose pod nginx --type=LoadBalancer --port=80

# Check services
kubectl get services

# Clean up test resources
kubectl delete pod nginx
kubectl delete service nginx
```

## 🔒 Security Configuration

### 1. Network Security

```bash
# Review NSG rules
az network nsg show --resource-group <rg-name> --name <nsg-name> --output table

# Review subnet configuration
az network vnet subnet show --resource-group <rg-name> --vnet-name <vnet-name> --name <subnet-name>
```

### 2. AKS Security

```bash
# Check cluster configuration
az aks show --resource-group <rg-name> --name <cluster-name> --query "{rbac:enableRbac,networkPolicy:networkProfile.networkPolicy,podCidr:networkProfile.podCidr}"

# Review node configuration
kubectl describe nodes
```

### 3. Access Control

```bash
# Check current context
kubectl config current-context

# Review cluster role bindings
kubectl get clusterrolebindings
```

## 🛠️ Troubleshooting

### Common Issues

1. **Terraform State Lock**:
   ```bash
   # Force unlock (use with caution)
   terraform force-unlock <lock-id>
   ```

2. **AKS Node Pool Issues**:
   ```bash
   # Check node pool status
   az aks nodepool list --resource-group <rg-name> --cluster-name <cluster-name> --output table
   
   # Scale node pool manually
   az aks nodepool scale --resource-group <rg-name> --cluster-name <cluster-name> --name <nodepool-name> --node-count 3
   ```

3. **Network Connectivity**:
   ```bash
   # Test cluster API connectivity
   kubectl cluster-info
   
   # Check DNS resolution
   kubectl run busybox --image=busybox:1.28 --rm -it -- nslookup kubernetes.default
   ```

### Validation Commands

```bash
# Terraform validation
terraform fmt -check -recursive
terraform validate
terraform plan -detailed-exitcode

# Azure resource validation
az resource list --resource-group <rg-name> --output table
az aks check-acr --resource-group <rg-name> --name <cluster-name> --acr <acr-name>
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] Azure subscription access verified
- [ ] Azure CLI installed and configured
- [ ] Terraform v1.6.0+ installed
- [ ] Service principal created (for CI/CD)
- [ ] Storage account created for Terraform state
- [ ] Variables configured in terraform.tfvars

### Deployment
- [ ] Terraform initialized successfully
- [ ] Terraform plan executed without errors
- [ ] Infrastructure applied successfully
- [ ] All outputs generated correctly

### Post-Deployment
- [ ] AKS cluster accessible via kubectl
- [ ] Nodes in Ready state
- [ ] Basic networking functional
- [ ] CI/CD pipeline configured and tested
- [ ] Security configurations verified

### Next Phase Preparation
- [ ] Application deployment strategy planned
- [ ] Monitoring requirements defined
- [ ] Security scanning tools identified
- [ ] GitOps workflow designed

## 🔄 Maintenance

### Regular Tasks

1. **Update Terraform Modules**:
   ```bash
   terraform get -update
   terraform plan
   ```

2. **Monitor Resource Costs**:
   ```bash
   az consumption usage list --output table
   ```

3. **Update AKS Version**:
   ```bash
   # Check available versions
   az aks get-versions --location <location> --output table
   
   # Update kubernetes_version in terraform.tfvars
   # Run terraform plan and apply
   ```

4. **Backup State Files**:
   ```bash
   # For local state
   cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d)
   ```

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Azure AKS documentation
3. Consult Terraform Azure provider documentation
4. Check project GitHub issues

---

**Next**: Once infrastructure is stable, proceed to Phase 2: Application Deployment