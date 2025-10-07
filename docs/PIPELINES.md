# CI/CD Pipelines Overview

This document provides a comprehensive overview of all CI/CD pipelines available for the AKS Infrastructure Project. We have created multiple pipeline options to support different deployment scenarios and platform preferences.

## 🚀 Pipeline Architecture

The project includes **4 comprehensive pipelines** across 2 platforms:

### GitHub Actions Pipelines
1. **Complete Infrastructure + Microservices Pipeline** (`.github/workflows/infrastructure.yml`)
2. **Dedicated Microservices Pipeline** (`.github/workflows/microservices.yml`)

### Azure DevOps Pipelines  
1. **Complete Infrastructure + Microservices Pipeline** (`pipelines/azure-pipelines.yml`)
2. **Dedicated Microservices Pipeline** (`pipelines/microservices-pipeline.yml`)

## 📋 Pipeline Comparison Matrix

| Feature | GitHub Infrastructure | GitHub Microservices | Azure DevOps Infrastructure | Azure DevOps Microservices |
|---------|----------------------|----------------------|----------------------------|----------------------------|
| **Terraform Deploy** | ✅ | ❌ | ✅ | ❌ |
| **Microservices Deploy** | ✅ | ✅ | ✅ | ✅ |
| **Manual Triggers** | ✅ | ✅ | ✅ | ✅ |
| **Approval Gates** | ✅ | ✅ | ✅ | ✅ |
| **Cost Estimates** | ✅ | ❌ | ✅ | ❌ |
| **Destroy Option** | ✅ | ❌ | ✅ | ❌ |
| **PR Comments** | ✅ | ❌ | ❌ | ❌ |

---

## 🔧 GitHub Actions Pipelines

### 1. Complete Infrastructure Pipeline
**File:** `.github/workflows/infrastructure.yml`

**Purpose:** Full end-to-end deployment of both Terraform infrastructure and microservices.

**Capabilities:**
- ✅ Terraform validation, planning, and deployment
- ✅ AKS cluster creation and configuration  
- ✅ Microservices deployment to AKS
- ✅ Infrastructure destruction (manual trigger)
- ✅ Manual deployment controls
- ✅ PR plan comments
- ✅ Environment-based approvals

**Triggers:**
- Push to `main` (paths: `terraform/**`, `k8s/**`)
- Pull requests to `main`
- Manual workflow dispatch

**Manual Controls:**
- `deploy_infrastructure`: Deploy Terraform (default: true)
- `deploy_microservices`: Deploy microservices (default: true)  
- `destroy_infrastructure`: Destroy all resources (default: false)

**Environments Required:**
- `production` - For infrastructure deployment approvals
- `production-destroy` - For infrastructure destruction approvals

### 2. Microservices-Only Pipeline
**File:** `.github/workflows/microservices.yml`

**Purpose:** Deploy microservices to an existing AKS cluster.

**Capabilities:**
- ✅ Kubernetes manifest validation
- ✅ Microservices deployment to existing AKS
- ✅ Health checks and status reporting
- ✅ LoadBalancer IP monitoring
- ✅ Grafana access information

**Triggers:**
- Push to `main` (paths: `k8s/**`, `scripts/deploy-microservices.sh`)
- Pull requests to `main`
- Manual workflow dispatch

**Manual Controls:**
- `aks_cluster_name`: Target cluster name (default: aks-cluster-dev)
- `resource_group_name`: Target resource group (default: rg-aks-dev)
- `force_redeploy`: Force redeploy all services (default: false)

---

## 🔷 Azure DevOps Pipelines

### 1. Complete Infrastructure Pipeline  
**File:** `pipelines/azure-pipelines.yml`

**Purpose:** Full enterprise-grade deployment with approval workflows.

**Capabilities:**
- ✅ Terraform validation, planning, and deployment
- ✅ AKS cluster creation and configuration
- ✅ Microservices deployment to AKS  
- ✅ Infrastructure destruction (manual parameter)
- ✅ Kubernetes manifest validation
- ✅ Pipeline artifact management
- ✅ Environment-based approvals

**Triggers:**
- Push to `main` or `develop` (paths: `terraform/**`, `k8s/**`)
- Pull requests to `main`

**Parameters:**
- `deployInfrastructure`: Deploy Terraform (default: true)
- `deployMicroservices`: Deploy microservices (default: true)
- `destroyInfrastructure`: Destroy all resources (default: false)

**Environments Required:**
- `dev-infrastructure` - For infrastructure deployment approvals
- `dev-infrastructure-destroy` - For destruction approvals  
- `dev-microservices` - For microservices deployment approvals

### 2. Microservices-Only Pipeline
**File:** `pipelines/microservices-pipeline.yml`

**Purpose:** Enterprise microservices deployment to existing AKS.

**Capabilities:**
- ✅ Advanced Kubernetes manifest validation
- ✅ Resource specification checks
- ✅ Microservices deployment with health monitoring
- ✅ Comprehensive status reporting
- ✅ PowerShell-based deployment summaries

**Triggers:**
- Push to `main` or `develop` (paths: `k8s/**`, `scripts/deploy-microservices.*`)
- Pull requests to `main`

**Parameters:**
- `aksClusterName`: Target cluster name (default: aks-cluster-dev)
- `resourceGroupName`: Target resource group (default: rg-aks-dev)  
- `forceRedeploy`: Force redeploy all services (default: false)

---

## 🛠️ Deployment Scenarios

### Scenario 1: First-Time Complete Setup
**Recommended Pipeline:** GitHub Infrastructure or Azure DevOps Infrastructure
- Deploys Terraform infrastructure (AKS cluster, networking, etc.)
- Automatically deploys microservices to the new cluster
- Provides complete end-to-end setup

### Scenario 2: Microservices Updates Only  
**Recommended Pipeline:** GitHub Microservices or Azure DevOps Microservices
- Updates microservices in existing AKS cluster
- Faster deployment (no infrastructure changes)
- Ideal for application development cycles

### Scenario 3: Infrastructure Changes
**Recommended Pipeline:** GitHub Infrastructure or Azure DevOps Infrastructure  
- Modify Terraform configurations
- Update AKS cluster settings
- Optionally redeploy microservices

### Scenario 4: Emergency Destruction
**Recommended Pipeline:** Any Infrastructure pipeline with destroy parameter
- **GitHub:** Set `destroy_infrastructure: true` in manual trigger
- **Azure DevOps:** Set `destroyInfrastructure: true` in parameters

---

## 🔒 Security & Approvals

### GitHub Actions Security
- **Workload Identity Federation** - No stored secrets
- **Environment Protection Rules** - Manual approvals required
- **Branch Protection** - Only main branch deployments
- **OIDC Authentication** - Secure Azure access

### Azure DevOps Security
- **Service Connections** - Managed Azure authentication
- **Environment Approvals** - Manual gates for critical operations
- **Variable Groups** - Secure configuration management
- **Branch Policies** - PR requirements and quality gates

---

## 📊 Monitoring & Observability

### Deployment Monitoring
All pipelines include:
- **Pod Health Checks** - Verify all services are running
- **Service Endpoint Validation** - Ensure connectivity
- **LoadBalancer Status** - Monitor external access
- **Resource Usage Reports** - CPU/memory utilization

### Application Access
- **Frontend Application:** `http://<loadbalancer-ip>`
- **API Endpoints:** 
  - User Service: `http://<loadbalancer-ip>/api/users`
  - Product Service: `http://<loadbalancer-ip>/api/products`
- **Grafana Dashboard:** `http://<grafana-ip>:3000` (admin/admin123)

---

## 🚦 Quick Start Guide

### For GitHub Actions:
1. **Set up environments** in GitHub repository settings
2. **Configure secrets:** `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
3. **Choose your pipeline:**
   - Complete setup: Trigger `infrastructure.yml`
   - Microservices only: Trigger `microservices.yml`

### For Azure DevOps:
1. **Create service connection** to Azure
2. **Set up environments** with approval gates
3. **Configure variable groups** for Terraform backend
4. **Choose your pipeline:**
   - Complete setup: Run `azure-pipelines.yml`
   - Microservices only: Run `microservices-pipeline.yml`

---

## 🔧 Troubleshooting

### Common Issues:
- **Authentication Failures:** Verify service connections and federated credentials
- **Terraform State Locks:** Check backend storage account accessibility
- **Pod Startup Issues:** Review resource limits and node capacity
- **LoadBalancer Pending:** Verify AKS networking and Azure subscription limits

### Diagnostic Commands:
```bash
# Check cluster connectivity
kubectl cluster-info

# Review pod status
kubectl get pods --all-namespaces

# Check service endpoints
kubectl get svc --all-namespaces

# View deployment logs
kubectl logs -f deployment/<name> -n <namespace>
```

---

## 📈 Cost Optimization

### Infrastructure Costs (Approximate):
- **AKS Cluster:** ~$150-200/month (2x Standard_D2s_v6 nodes)
- **Load Balancers:** ~$20-30/month
- **Storage:** ~$10-20/month
- **Total Estimated:** ~$180-250/month

### Cost-Saving Tips:
- Use **spot instances** for non-production workloads
- Implement **cluster autoscaling** to reduce idle costs
- Schedule **shutdown/startup** for development environments
- Monitor usage with **Azure Cost Management**

This comprehensive pipeline setup provides maximum flexibility for different deployment scenarios while maintaining security, observability, and cost control.