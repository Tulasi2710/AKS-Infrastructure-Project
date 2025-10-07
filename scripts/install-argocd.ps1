# PowerShell script for installing ArgoCD on AKS
# This script installs ArgoCD and configures it for GitOps deployment

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting ArgoCD installation on AKS cluster..." -ForegroundColor Green

# Check if kubectl is available
try {
    $null = kubectl version --client --output=json 2>$null
    Write-Host "✅ kubectl is available" -ForegroundColor Green
}
catch {
    Write-Host "❌ kubectl is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install kubectl and ensure it's in your PATH" -ForegroundColor Yellow
    exit 1
}

# Verify cluster connectivity
Write-Host "🔍 Verifying cluster connectivity..." -ForegroundColor Yellow
try {
    $clusterInfo = kubectl cluster-info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl cluster-info failed"
    }
    $context = kubectl config current-context 2>$null
    Write-Host "✅ Connected to cluster: $context" -ForegroundColor Green
}
catch {
    Write-Host "❌ Unable to connect to Kubernetes cluster" -ForegroundColor Red
    Write-Host "Please ensure you're connected to your AKS cluster:" -ForegroundColor Yellow
    Write-Host "  az aks get-credentials --resource-group <rg-name> --name <cluster-name>" -ForegroundColor White
    exit 1
}

# Create ArgoCD namespace and LoadBalancer service
Write-Host "📁 Creating ArgoCD namespace and LoadBalancer service..." -ForegroundColor Cyan
kubectl apply -f argocd/argocd-namespace.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create ArgoCD namespace" -ForegroundColor Red
    exit 1
}

# Install ArgoCD using official manifests
Write-Host "📦 Installing ArgoCD core components..." -ForegroundColor Cyan
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install ArgoCD components" -ForegroundColor Red
    exit 1
}

# Wait for ArgoCD components to be ready
Write-Host "⏳ Waiting for ArgoCD deployments to be ready..." -ForegroundColor Yellow

$deployments = @("argocd-server", "argocd-repo-server", "argocd-dex-server", "argocd-redis", "argocd-notifications-controller", "argocd-applicationset-controller")
foreach ($deployment in $deployments) {
    Write-Host "  Waiting for deployment/$deployment..." -ForegroundColor Gray
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n argocd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to wait for $deployment to be ready" -ForegroundColor Red
        exit 1
    }
}

# Wait for StatefulSet (argocd-application-controller is a StatefulSet, not a Deployment)
Write-Host "⏳ Waiting for ArgoCD StatefulSet to be ready..." -ForegroundColor Yellow
Write-Host "  Waiting for statefulset/argocd-application-controller..." -ForegroundColor Gray
kubectl wait --for=condition=Ready --timeout=300s statefulset/argocd-application-controller -n argocd
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to wait for argocd-application-controller StatefulSet to be ready" -ForegroundColor Red
    exit 1
}

Write-Host "✅ All ArgoCD components are ready" -ForegroundColor Green

# Create ArgoCD project and applications
Write-Host "🎯 Creating ArgoCD project and applications..." -ForegroundColor Cyan
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/applications.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create ArgoCD project/applications" -ForegroundColor Red
    exit 1
}

# Get initial admin password
Write-Host "🔑 Retrieving ArgoCD admin password..." -ForegroundColor Cyan
try {
    $passwordBase64 = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>$null
    $password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($passwordBase64))
    Write-Host "✅ Admin password retrieved" -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Unable to retrieve admin password automatically" -ForegroundColor Yellow
    $password = "Check manually with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

# Get LoadBalancer IP
Write-Host "📡 Waiting for LoadBalancer IP assignment..." -ForegroundColor Yellow
$timeout = 300
$argoCdIP = ""

while ($timeout -gt 0) {
    try {
        $argoCdIP = kubectl get svc argocd-server-loadbalancer -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
        if ($argoCdIP -and $argoCdIP.Trim() -ne "") {
            break
        }
    }
    catch {
        # Continue waiting
    }
    
    Write-Host "  Waiting for LoadBalancer IP... ($timeout seconds remaining)" -ForegroundColor Gray
    Start-Sleep -Seconds 10
    $timeout -= 10
}

Write-Host ""
Write-Host "🎉 ArgoCD installation completed successfully!" -ForegroundColor Green -BackgroundColor DarkGreen
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 ArgoCD Status:" -ForegroundColor Cyan
kubectl get pods -n argocd

Write-Host "`n🌐 ArgoCD Access Information:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

if ($argoCdIP -and $argoCdIP.Trim() -ne "") {
    Write-Host "ArgoCD UI URL: https://$argoCdIP" -ForegroundColor White
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: $password" -ForegroundColor White
} else {
    Write-Host "LoadBalancer IP: Pending" -ForegroundColor Yellow
    Write-Host "Check status with: kubectl get svc argocd-server-loadbalancer -n argocd" -ForegroundColor Gray
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: $password" -ForegroundColor White
}

Write-Host "`n📋 ArgoCD Applications:" -ForegroundColor Cyan
kubectl get applications -n argocd

Write-Host "`n🔍 Useful Commands:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "# Check ArgoCD status" -ForegroundColor Gray
Write-Host "kubectl get pods -n argocd" -ForegroundColor White
Write-Host ""
Write-Host "# View applications" -ForegroundColor Gray
Write-Host "kubectl get applications -n argocd" -ForegroundColor White
Write-Host ""
Write-Host "# Check application sync status" -ForegroundColor Gray
Write-Host "kubectl get application ecommerce-microservices -n argocd -o yaml" -ForegroundColor White
Write-Host ""
Write-Host "# Port forward for local access (alternative)" -ForegroundColor Gray
Write-Host "kubectl port-forward svc/argocd-server 8080:443 -n argocd" -ForegroundColor White
Write-Host ""
Write-Host "🚀 ArgoCD is now ready for GitOps deployments!" -ForegroundColor Green
Write-Host "Any changes pushed to the k8s/ directory will be automatically synchronized." -ForegroundColor Yellow