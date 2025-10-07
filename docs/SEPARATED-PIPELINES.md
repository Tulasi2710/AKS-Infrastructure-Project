# Separated CI/CD Pipeline Architecture

This document describes the **separated pipeline approach** that isolates Terraform infrastructure deployment from Kubernetes microservices deployment.

## 🏗️ Pipeline Separation Strategy

To avoid conflicts and maintain pipeline stability, we've created **dedicated, isolated pipelines**:

### **Infrastructure Pipelines** (Terraform Only)
- **GitHub:** `.github/workflows/terraform.yml`
- **Azure DevOps:** `pipelines/azure-pipelines.yml`

### **Microservices Pipelines** (Kubernetes Only)  
- **GitHub:** `.github/workflows/deploy-k8s.yml`
- **Azure DevOps:** `pipelines/k8s-deployment.yml`

---

## 🔧 Infrastructure Pipelines

### **GitHub Actions: `terraform.yml`**
**Purpose:** Deploy AKS infrastructure only

**Triggers:**
- Push to `main` (paths: `terraform/**`)
- Pull requests to `main`
- Manual workflow dispatch

**Jobs:**
1. **terraform-validate** - Terraform init and validate
2. **terraform-plan** - Create execution plan
3. **terraform-apply** - Deploy to Azure (main branch only, with approval)

**Requirements:**
- GitHub secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
- Environment: `production` (for approval gates)

### **Azure DevOps: `azure-pipelines.yml`**
**Purpose:** Deploy AKS infrastructure only

**Triggers:**
- Push to `main`/`develop` (paths: `terraform/**`)

**Stages:**
1. **Validate** - Terraform init and validate
2. **Plan** - Create execution plan and publish artifact
3. **Apply** - Deploy to Azure (main branch only, with environment approval)

**Requirements:**
- Variable group: `terraform-backend`
- Service connection: `azure-service-connection1`
- Environment: `dev-infrastructure` (for approval gates)

---

## ☸️ Microservices Pipelines

### **GitHub Actions: `deploy-k8s.yml`**
**Purpose:** Deploy microservices to existing AKS cluster

**Triggers:**
- Push to `main` (paths: `k8s/**`, `scripts/deploy-microservices.*`)
- Pull requests to `main`
- Manual workflow dispatch

**Manual Parameters:**
- `aks_cluster_name` (default: aks-cluster-dev)
- `resource_group_name` (default: rg-aks-dev)
- `namespace_action` (apply, delete-and-recreate)

**Jobs:**
1. **validate-k8s** - Validate Kubernetes manifests
2. **deploy-to-aks** - Deploy to AKS cluster (main branch only, with approval)

**Deployment Steps:**
1. ✅ Connect to AKS cluster
2. 📁 Deploy namespaces
3. 🗄️ Deploy PostgreSQL database
4. 🔧 Deploy backend services (user-service, product-service)
5. 🌐 Deploy frontend (NGINX)
6. 🔀 Deploy ingress controller
7. 📊 Deploy monitoring (Prometheus, Grafana)
8. 🩺 Health checks and status reporting

### **Azure DevOps: `k8s-deployment.yml`**
**Purpose:** Deploy microservices to existing AKS cluster

**Triggers:**
- Push to `main`/`develop` (paths: `k8s/**`, `scripts/deploy-microservices.*`)

**Parameters:**
- `aksClusterName` (default: aks-cluster-dev)
- `resourceGroupName` (default: rg-aks-dev)
- `deploymentMode` (incremental, full-redeploy)

**Stages:**
1. **ValidateManifests** - Validate YAML syntax and resource specs
2. **DeployMicroservices** - Deploy to AKS with comprehensive monitoring

**Enhanced Features:**
- PowerShell-based status reporting
- Detailed resource analysis
- Color-coded deployment summaries
- LoadBalancer IP monitoring

---

## 🚀 Deployment Workflow

### **Step 1: Deploy Infrastructure**
Choose your platform and run the infrastructure pipeline:

**GitHub Actions:**
```bash
# Trigger via push to main (terraform changes) or manual dispatch
# Manual: Go to Actions → Terraform AKS Infrastructure → Run workflow
```

**Azure DevOps:**
```bash
# Trigger via push to main (terraform changes) or manual queue
# Manual: Pipelines → azure-pipelines.yml → Run pipeline
```

### **Step 2: Deploy Microservices**
After infrastructure is ready, deploy microservices:

**GitHub Actions:**
```bash
# Trigger via push to main (k8s changes) or manual dispatch
# Manual: Actions → Deploy Microservices to AKS → Run workflow
# Specify your AKS cluster name and resource group
```

**Azure DevOps:**
```bash
# Trigger via push to main (k8s changes) or manual queue  
# Manual: Pipelines → k8s-deployment.yml → Run pipeline
# Set parameters for your AKS cluster
```

---

## 🔒 Security & Approvals

### **GitHub Actions Security:**
- **Infrastructure:** Requires `production` environment approval
- **Microservices:** Requires `microservices-deployment` environment approval
- **Authentication:** Workload Identity Federation (no stored secrets)

### **Azure DevOps Security:**
- **Infrastructure:** Requires `dev-infrastructure` environment approval
- **Microservices:** Requires `aks-microservices-deployment` environment approval
- **Authentication:** Service connections with proper RBAC

---

## 📊 Pipeline Features

### **Infrastructure Pipelines:**
- ✅ Terraform validation and planning
- 🔒 Environment-based approval gates
- 📋 Pre-deployment cost warnings
- 🎯 AKS cluster creation with proper networking
- 📤 Terraform outputs for downstream consumption

### **Microservices Pipelines:**
- ✅ Kubernetes manifest validation
- 🔍 Resource specification analysis
- 🏥 Health checks and readiness probes
- 📊 Comprehensive deployment status
- 🌐 LoadBalancer IP monitoring
- 📈 Access information (Grafana, API endpoints)

---

## 🎯 Benefits of Separation

### **Stability:**
- **No format conflicts** - Infrastructure pipelines don't run `terraform fmt`
- **Isolated failures** - K8s issues don't affect Terraform deployments
- **Independent triggers** - Deploy infrastructure or microservices separately

### **Flexibility:**
- **Rapid iteration** - Update microservices without infrastructure changes
- **Targeted deployment** - Choose what to deploy based on changes
- **Environment specific** - Different parameters for different clusters

### **Maintainability:**
- **Clear separation of concerns** - Infrastructure vs Application deployment
- **Simplified troubleshooting** - Easier to debug specific pipeline issues
- **Independent versioning** - Infrastructure and application changes decoupled

---

## 🔧 Quick Reference Commands

### **Check Infrastructure Status:**
```bash
# View AKS cluster
az aks show --name <cluster-name> --resource-group <rg-name>

# Get cluster credentials  
az aks get-credentials --name <cluster-name> --resource-group <rg-name>
```

### **Check Microservices Status:**
```bash
# View all pods
kubectl get pods --all-namespaces

# Check services and LoadBalancer IPs
kubectl get svc --all-namespaces

# Check ingress
kubectl get ingress -n ecommerce

# View logs
kubectl logs -f deployment/<name> -n <namespace>
```

### **Access Applications:**
```bash
# Get LoadBalancer IPs
kubectl get svc ecommerce-loadbalancer -n ecommerce
kubectl get svc grafana-service -n monitoring

# Port forward for local access (alternative)
kubectl port-forward svc/frontend-service 8080:80 -n ecommerce
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
```

This separated approach ensures reliable, maintainable CI/CD while avoiding the complexity and potential conflicts of combined pipelines.