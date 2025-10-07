# AKS Infrastructure Project

A production-ready Terraform infrastructure setup for deploying Azure Kubernetes Service (AKS) clusters with automated CI/CD pipelines using GitHub Actions and Azure DevOps.

## 🏗️ Architecture Overview

This project implements a modular, scalable infrastructure-as-code solution:

- **🏢 Resource Group Module**: Manages Azure resource groups with standardized naming and tagging
- **🌐 Networking Module**: Creates VNet, subnets, and Network Security Groups with proper CIDR management
- **☸️ AKS Module**: Deploys Azure Kubernetes Service with system-assigned managed identity and optimized networking
- **🚀 CI/CD Integration**: Dual pipeline support (GitHub Actions + Azure DevOps) with workload identity federation

## ✅ Project Status

**Current State**: Production-ready infrastructure with working CI/CD pipelines

- ✅ **Authentication**: Workload Identity Federation configured for GitHub Actions
- ✅ **Networking**: CIDR conflicts resolved, proper service/pod networking
- ✅ **Compute**: VM size compatibility verified for Azure regions
- ✅ **Security**: Service principal with minimal permissions, secure state management
- ✅ **Automation**: Both GitHub Actions and Azure DevOps pipelines operational

## 📁 Project Structure

```
AKS-Infrastructure-Project/
├── terraform/
│   ├── modules/
│   │   ├── resource-group/      # Reusable resource group module
│   │   ├── networking/          # VNet and subnet configuration
│   │   └── aks/                # AKS cluster module
│   └── environments/
│       └── dev/                # Development environment
├── pipelines/
│   └── azure-pipelines.yml     # Azure DevOps pipeline
├── .github/workflows/
│   └── terraform.yml           # GitHub Actions workflow
└── docs/                       # Documentation
```

## 🚀 Getting Started

### Prerequisites

1. **Azure Subscription** with Contributor permissions
2. **Terraform** v1.6.0 (exact version used in CI/CD)
3. **Azure CLI** for local development
4. **GitHub/Azure DevOps** account for CI/CD pipeline execution

### 🚀 Quick Start (Automated Deployment)

The easiest way to deploy this infrastructure is through the CI/CD pipelines:

#### GitHub Actions (Recommended)
1. **Fork this repository**
2. **Configure GitHub Secrets**:
   - `AZURE_CLIENT_ID`: `4813e1ea-ebfa-46c4-bbdc-6bf8225ad061`
   - `AZURE_TENANT_ID`: Your Azure tenant ID
   - `AZURE_SUBSCRIPTION_ID`: Your subscription ID
   - `TF_STATE_RESOURCE_GROUP`: `TulasiteraformRG`
   - `TF_STATE_STORAGE_ACCOUNT`: Your storage account name

3. **Create Production Environment**: GitHub → Settings → Environments → New environment (`production`)
4. **Push changes** to main branch or manually trigger the workflow

#### Azure DevOps
1. **Import this repository** to Azure DevOps
2. **Create Service Connection** named `azure-service-connection1`
3. **Configure Variable Group** `terraform-backend` with storage account details
4. **Run the pipeline**

### 💻 Local Development Setup

For local testing and development:

```bash
# 1. Clone the repository
git clone https://github.com/Tulasi2710/AKS-Infrastructure-Project.git
cd AKS-Infrastructure-Project

# 2. Login to Azure
az login
az account set --subscription f4d6b5a0-37f2-49d8-85ea-fe757f8cf6b1

# 3. Navigate to dev environment
cd terraform/environments/dev

# 4. Initialize Terraform (configure backend as needed)
terraform init

# 5. Review and plan
terraform plan -var-file="terraform.tfvars"

# 6. Apply (use with caution in local development)
terraform apply -var-file="terraform.tfvars"
```

## 🔧 Configuration

### 🔧 Infrastructure Configuration

Current configuration in `terraform.tfvars`:

| Variable | Description | Current Value |
|----------|-------------|---------------|
| `location` | Azure region for resources | `"East US"` |
| `vnet_address_space` | Virtual network CIDR | `["10.0.0.0/16"]` |
| `aks_subnet_cidr` | AKS subnet CIDR | `"10.0.1.0/24"` |
| `node_count` | Initial number of worker nodes | `2` |
| `node_vm_size` | VM size for AKS nodes | `"Standard_D2s_v6"` |
| `service_cidr` | Kubernetes services CIDR | `"172.16.0.0/16"` |
| `dns_service_ip` | Kubernetes DNS service IP | `"172.16.0.10"` |
| `docker_bridge_cidr` | Docker bridge CIDR | `"172.17.0.1/16"` |

### 🗃️ State Management

**Remote State Configuration:**
- **Storage Account**: `tulasiteraformstfile`
- **Resource Group**: `TulasiteraformRG`
- **Container**: `tfstate`
- **State File**: `dev.terraform.tfstate`

The backend is automatically configured in CI/CD pipelines.

## 🔄 CI/CD Pipelines

### GitHub Actions Workflow ⭐ (Primary)

**Location**: `.github/workflows/terraform.yml`

**Features:**
- ✅ **Workload Identity Federation** for secure authentication
- ✅ **Three-stage pipeline**: Validate → Plan → Apply
- ✅ **Automatic triggers** on Terraform changes
- ✅ **Production environment** approval gates
- ✅ **Environment variables** for proper authentication

**Workflow Jobs:**
1. **terraform-validate**: Format check, init, validate
2. **terraform-plan**: Infrastructure planning with change preview  
3. **terraform-apply**: Automated deployment to Azure (main branch only)

### Azure DevOps Pipeline 🔄 (Alternative)

**Location**: `pipelines/azure-pipelines.yml`

**Features:**
- ✅ **Modern Terraform tasks** (TerraformTaskV4@4)
- ✅ **Service connection** authentication
- ✅ **Artifact management** for plan files
- ✅ **Environment approvals** for controlled deployments
- ✅ **Parallel execution** capabilities

**Pipeline Stages:**
1. **Validate**: Format checking and configuration validation
2. **Plan**: Infrastructure change planning with artifact storage
3. **Apply**: Deployment with approval gates

## 🔒 Security Considerations

### 🔐 Authentication Methods

**GitHub Actions:**
- ✅ **Workload Identity Federation** (No secrets stored!)
- ✅ **Service Principal**: `4813e1ea-ebfa-46c4-bbdc-6bf8225ad061`
- ✅ **Federated Credentials**: Configured for main branch and production environment

**Azure DevOps:**
- ✅ **Service Connection** with service principal authentication
- ✅ **Managed authentication** through Azure DevOps integration

**Local Development:**
- ✅ **Azure CLI** authentication (`az login`)

### 🛡️ Network Security Architecture

**Optimized Network Configuration:**
- **VNet**: `10.0.0.0/16` (Main network)
- **AKS Subnet**: `10.0.1.0/24` (Node placement)  
- **Service CIDR**: `172.16.0.0/16` (K8s services - no overlap!)
- **Pod CIDR**: Managed by Azure CNI
- **Network Security Groups**: Applied to subnets with appropriate rules

### 🔑 Required Secrets (GitHub Actions)

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `AZURE_CLIENT_ID` | `4813e1ea-ebfa-46c4-bbdc-6bf8225ad061` | Service principal ID |
| `AZURE_TENANT_ID` | Your tenant ID | Azure AD tenant |
| `AZURE_SUBSCRIPTION_ID` | `f4d6b5a0-37f2-49d8-85ea-fe757f8cf6b1` | Target subscription |
| `TF_STATE_RESOURCE_GROUP` | `TulasiteraformRG` | State storage RG |
| `TF_STATE_STORAGE_ACCOUNT` | `tulasiteraformstfile` | State storage account |

## 📊 Outputs

After successful deployment, Terraform provides:

- **Resource Group Name**: For resource organization
- **AKS Cluster Name**: For kubectl configuration
- **VNet Information**: For networking integration
- **Kubeconfig Command**: For cluster access setup

## 🛠️ Module Documentation

### Resource Group Module
- Creates Azure resource group with consistent naming
- Applies standardized tagging strategy
- Supports multiple environments

### Networking Module
- Virtual Network with configurable address space
- Dedicated subnet for AKS cluster
- Network Security Group with basic rules
- Output values for integration with other modules

### AKS Module
- Azure Kubernetes Service cluster
- System-assigned managed identity
- Configurable node pools with autoscaling
- Azure CNI networking integration

## 🔍 Troubleshooting

### 🔍 Troubleshooting & Lessons Learned

**Resolved Issues:**

1. **✅ VM Size Compatibility**: Changed from `Standard_D2s_v3` to `Standard_D2s_v6` for East US region availability
2. **✅ Network CIDR Conflicts**: Separated service CIDR (`172.16.0.0/16`) from VNet CIDR (`10.0.0.0/16`)
3. **✅ Authentication**: Implemented Workload Identity Federation for secure, secret-less authentication
4. **✅ Federated Identity**: Added production environment credential for deployment approvals

**Debugging Commands:**

```bash
# Check current configuration
terraform validate
terraform plan -var-file="terraform.tfvars"

# Azure resource verification  
az aks list --output table
az aks show --resource-group <rg-name> --name <cluster-name>

# Connect to deployed cluster
az aks get-credentials --resource-group <rg-name> --name <cluster-name>
kubectl get nodes

# Check GitHub Actions secrets
gh secret list

# Verify service principal
az ad sp show --id 4813e1ea-ebfa-46c4-bbdc-6bf8225ad061
```

## 🎯 Current Deployment Status

**Ready to Deploy!** 🚀

- ✅ All authentication issues resolved
- ✅ Network configuration optimized  
- ✅ VM sizes verified for region compatibility
- ✅ CI/CD pipelines tested and working
- ✅ Documentation updated

**To deploy your AKS cluster:**
1. Create production environment in GitHub (if using GitHub Actions)
2. Trigger the workflow by pushing to main or manual trigger
3. Approve deployment in production environment
4. Monitor deployment progress in Actions/Pipelines

## 🔮 Future Enhancements

This infrastructure foundation enables:

1. **🚀 Application Deployment**: Deploy microservices with Helm charts
2. **📊 Monitoring Stack**: Prometheus, Grafana, Azure Monitor integration
3. **🔒 Security Hardening**: Pod Security Standards, Network Policies
4. **🔄 GitOps**: ArgoCD or Flux for continuous deployment
5. **🌐 Ingress & Load Balancing**: NGINX Ingress Controller, Application Gateway
6. **📈 Scaling**: Horizontal Pod Autoscaler, Cluster Autoscaler
7. **💾 Storage**: Azure Disk, Azure Files integration

## 🤝 Contributing

1. **🏗️ Infrastructure Changes**: Test locally first, update documentation
2. **📝 Documentation**: Keep README and docs up-to-date  
3. **🔒 Security**: Follow principle of least privilege
4. **✅ Testing**: Validate with `terraform plan` before applying
5. **📊 Monitoring**: Check Azure resources after deployment

## 📚 Additional Resources

- **[Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)**
- **[Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)**
- **[GitHub Actions for Azure](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-azure)**
- **[Workload Identity Federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)**

## 📄 License

MIT License - See LICENSE file for details.

---

**⭐ Star this repository if it helped you deploy AKS infrastructure successfully!**