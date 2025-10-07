# PowerShell script for deploying microservices to AKS
# This is the Windows PowerShell equivalent of the bash deployment script

param(
    [switch]$WhatIf,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting microservices deployment to AKS cluster..." -ForegroundColor Green

# Check if kubectl is available and cluster is accessible
Write-Host "Checking cluster connectivity..." -ForegroundColor Yellow
try {
    $clusterInfo = kubectl cluster-info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl cluster-info failed"
    }
    Write-Host "✅ Cluster connectivity confirmed" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: Unable to connect to Kubernetes cluster" -ForegroundColor Red
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "1. AKS cluster is running"
    Write-Host "2. kubectl is installed and configured"
    Write-Host "3. You have access to the cluster"
    exit 1
}

# Function to wait for deployment to be ready
function Wait-ForDeployment {
    param(
        [string]$DeploymentName,
        [string]$Namespace
    )
    
    Write-Host "Waiting for deployment '$DeploymentName' in namespace '$Namespace' to be ready..." -ForegroundColor Yellow
    
    if (-not $WhatIf) {
        kubectl wait --for=condition=available --timeout=300s deployment/$DeploymentName -n $Namespace
        if ($LASTEXITCODE -ne 0) {
            throw "Deployment $DeploymentName failed to become ready"
        }
    }
}

# Function to apply Kubernetes manifest
function Apply-Manifest {
    param(
        [string]$ManifestPath,
        [string]$Description
    )
    
    Write-Host "📄 Applying $Description..." -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "WHATIF: Would apply manifest: $ManifestPath" -ForegroundColor Magenta
    } else {
        kubectl apply -f $ManifestPath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to apply manifest: $ManifestPath"
        }
    }
}

try {
    # 1. Deploy Namespaces
    Apply-Manifest -ManifestPath "namespaces/ecommerce-namespace.yaml" -Description "namespaces"
    Write-Host "✅ Namespaces created" -ForegroundColor Green

    # 2. Deploy Database
    Apply-Manifest -ManifestPath "database/postgres-deployment.yaml" -Description "PostgreSQL database"
    Wait-ForDeployment -DeploymentName "postgres" -Namespace "ecommerce-database"
    Write-Host "✅ Database deployed and ready" -ForegroundColor Green

    # 3. Deploy Backend Services
    Apply-Manifest -ManifestPath "backend/backend-services.yaml" -Description "backend services"
    Wait-ForDeployment -DeploymentName "user-service" -Namespace "ecommerce"
    Wait-ForDeployment -DeploymentName "product-service" -Namespace "ecommerce"
    Write-Host "✅ Backend services deployed and ready" -ForegroundColor Green

    # 4. Deploy Frontend
    Apply-Manifest -ManifestPath "frontend/frontend-deployment.yaml" -Description "frontend service"
    Wait-ForDeployment -DeploymentName "frontend" -Namespace "ecommerce"
    Write-Host "✅ Frontend deployed and ready" -ForegroundColor Green

    # 5. Deploy Ingress
    Apply-Manifest -ManifestPath "ingress/ingress-config.yaml" -Description "ingress controller"
    Write-Host "✅ Ingress deployed" -ForegroundColor Green

    # 6. Deploy Monitoring
    Apply-Manifest -ManifestPath "monitoring/monitoring-stack.yaml" -Description "monitoring stack"
    Wait-ForDeployment -DeploymentName "prometheus" -Namespace "monitoring"
    Wait-ForDeployment -DeploymentName "grafana" -Namespace "monitoring"
    Write-Host "✅ Monitoring stack deployed and ready" -ForegroundColor Green

    Write-Host ""
    Write-Host "🎉 Microservices deployment completed successfully!" -ForegroundColor Green -BackgroundColor DarkGreen
    Write-Host ""

    if (-not $WhatIf) {
        # Show deployment summary
        Write-Host "📋 Deployment Summary:" -ForegroundColor Cyan
        Write-Host "====================" -ForegroundColor Cyan
        
        Write-Host "E-commerce Pods:" -ForegroundColor Yellow
        kubectl get pods -n ecommerce
        
        Write-Host "`nDatabase Pods:" -ForegroundColor Yellow
        kubectl get pods -n ecommerce-database
        
        Write-Host "`nMonitoring Pods:" -ForegroundColor Yellow
        kubectl get pods -n monitoring

        Write-Host "`n🔗 Service Information:" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor Cyan
        
        Write-Host "E-commerce Services:" -ForegroundColor Yellow
        kubectl get svc -n ecommerce
        
        Write-Host "`nDatabase Services:" -ForegroundColor Yellow
        kubectl get svc -n ecommerce-database
        
        Write-Host "`nMonitoring Services:" -ForegroundColor Yellow
        kubectl get svc -n monitoring

        Write-Host "`n🌍 Ingress Information:" -ForegroundColor Cyan
        Write-Host "======================" -ForegroundColor Cyan
        kubectl get ingress -n ecommerce

        # Get Grafana IP
        Write-Host "`n📊 Grafana Access:" -ForegroundColor Cyan
        Write-Host "=================" -ForegroundColor Cyan
        
        try {
            $grafanaIP = kubectl get svc grafana-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
            if ($grafanaIP -and $grafanaIP -ne "") {
                Write-Host "Grafana URL: http://$grafanaIP:3000" -ForegroundColor Green
                Write-Host "Username: admin" -ForegroundColor Yellow
                Write-Host "Password: admin123" -ForegroundColor Yellow
            } else {
                Write-Host "Grafana LoadBalancer IP is still pending. Check status with:" -ForegroundColor Yellow
                Write-Host "kubectl get svc grafana-service -n monitoring" -ForegroundColor White
            }
        }
        catch {
            Write-Host "Unable to retrieve Grafana IP. Service may still be initializing." -ForegroundColor Yellow
        }

        Write-Host "`n🔍 To monitor deployment status:" -ForegroundColor Cyan
        Write-Host "kubectl get pods --all-namespaces" -ForegroundColor White
        Write-Host "kubectl get svc --all-namespaces" -ForegroundColor White
    }

    Write-Host "`n✅ Deployment script completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check the logs above for more details." -ForegroundColor Yellow
    exit 1
}