# AKS Infrastructure Project

This project provides a modular Terraform infrastructure setup for deploying Azure Kubernetes Service (AKS) clusters with CI/CD automation.

## 🏗️ Architecture Overview

The infrastructure is designed with modularity and reusability in mind:

- **Resource Group Module**: Manages Azure resource groups with tagging
- **Networking Module**: Creates VNet, subnets, and network security groups
- **AKS Module**: Deploys Azure Kubernetes Service clusters with managed identity
- **Environment Configuration**: Development environment orchestration

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

1. **Azure Subscription** with appropriate permissions
2. **Terraform** v1.6.0 or later
3. **Azure CLI** installed and configured
4. **Service Principal** for automation (optional for local development)

### Local Development Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd AKS-Infrastructure-Project
   ```

2. **Login to Azure**:
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

3. **Configure Terraform variables**:
   ```bash
   cd terraform/environments/dev
   cp terraform.tfvars.template terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan deployment**:
   ```bash
   terraform plan
   ```

6. **Apply infrastructure**:
   ```bash
   terraform apply
   ```

## 🔧 Configuration

### Terraform Variables

Key configuration options in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region for resources | `"East US"` |
| `environment` | Environment name (dev, staging, prod) | `"dev"` |
| `project_name` | Project identifier for resource naming | `"aks-infra"` |
| `kubernetes_version` | AKS Kubernetes version | `"1.28.0"` |
| `node_count` | Initial number of worker nodes | `2` |
| `vm_size` | VM size for AKS nodes | `"Standard_DS2_v2"` |
| `enable_auto_scaling` | Enable cluster autoscaler | `true` |

### Backend Configuration

For production use, configure Terraform remote state:

1. Create Azure Storage Account for state files
2. Update backend configuration in CI/CD pipelines
3. Set appropriate access controls

## � CI/CD Pipelines

### Azure DevOps Pipeline

Located at `pipelines/azure-pipelines.yml`:

- **Triggers**: Changes to `terraform/**` path
- **Stages**: Validate → Plan → Apply
- **Features**: Terraform format checking, security validation
- **Environments**: Supports approval gates for production

### GitHub Actions Workflow

Located at `.github/workflows/terraform.yml`:

- **Events**: Push to main/develop, pull requests
- **Jobs**: Check → Plan (PR) → Apply (main branch)
- **Security**: Uses Azure service principal authentication

## 🔒 Security Considerations

### Authentication

- **Local Development**: Uses Azure CLI authentication
- **CI/CD Pipelines**: Service principal with minimal required permissions
- **AKS Cluster**: System-assigned managed identity

### Network Security

- Network Security Groups with HTTP/HTTPS rules
- Private subnets for AKS nodes
- Configurable network policies

### Secret Management

Required secrets for CI/CD:

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CREDENTIALS` | Service principal credentials (JSON) |
| `TFSTATE_RESOURCE_GROUP` | Resource group for Terraform state |
| `TFSTATE_STORAGE_ACCOUNT` | Storage account for Terraform state |

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

### Common Issues

1. **Permission Errors**:
   - Verify Azure subscription permissions
   - Check service principal role assignments

2. **State Lock Issues**:
   - Ensure backend storage account is accessible
   - Check for concurrent Terraform operations

3. **AKS Node Issues**:
   - Verify VM size availability in selected region
   - Check subnet address space conflicts

### Debugging Commands

```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Check Azure resources
az aks list --output table

# Get AKS credentials
az aks get-credentials --resource-group <rg-name> --name <cluster-name>
```

## 🚀 Next Steps

This infrastructure foundation supports:

1. **Application Deployment**: Deploy microservices to the AKS cluster
2. **Monitoring Setup**: Add Prometheus, Grafana, and Azure Monitor
3. **Security Scanning**: Integrate container security tools
4. **GitOps**: Implement ArgoCD or Flux for application delivery
5. **Networking**: Add ingress controllers and load balancers

## 📝 Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test in development environment first
4. Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.