#!/bin/bash

# ArgoCD Installation Script for AKS
# This script installs ArgoCD and configures it for GitOps deployment

set -e

echo "🚀 Starting ArgoCD installation on AKS cluster..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Verify cluster connectivity
echo "🔍 Verifying cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Unable to connect to Kubernetes cluster"
    echo "Please ensure you're connected to your AKS cluster:"
    echo "  az aks get-credentials --resource-group <rg-name> --name <cluster-name>"
    exit 1
fi

echo "✅ Connected to cluster: $(kubectl config current-context)"

# Create ArgoCD namespace
echo "📁 Creating ArgoCD namespace and LoadBalancer service..."
kubectl apply -f argocd/argocd-namespace.yaml

# Install ArgoCD using official manifests
echo "📦 Installing ArgoCD core components..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD components to be ready
echo "⏳ Waiting for ArgoCD components to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd

# Apply LoadBalancer service for external access
echo "🌐 Configuring external access via LoadBalancer..."
kubectl apply -f argocd/argocd-namespace.yaml

# Create ArgoCD project and applications
echo "🎯 Creating ArgoCD project and applications..."
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/applications.yaml

# Get initial admin password
echo "🔑 Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Get LoadBalancer IP
echo "📡 Waiting for LoadBalancer IP assignment..."
timeout=300
while [ $timeout -gt 0 ]; do
    ARGOCD_IP=$(kubectl get svc argocd-server-loadbalancer -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$ARGOCD_IP" ]; then
        break
    fi
    echo "  Waiting for LoadBalancer IP... ($timeout seconds remaining)"
    sleep 10
    timeout=$((timeout-10))
done

echo ""
echo "🎉 ArgoCD installation completed successfully!"
echo "=============================================="
echo ""
echo "📊 ArgoCD Status:"
kubectl get pods -n argocd
echo ""
echo "🌐 ArgoCD Access Information:"
echo "============================="

if [ ! -z "$ARGOCD_IP" ]; then
    echo "ArgoCD UI URL: https://$ARGOCD_IP"
    echo "Username: admin"
    echo "Password: $ARGOCD_PASSWORD"
else
    echo "LoadBalancer IP: Pending"
    echo "Check status with: kubectl get svc argocd-server-loadbalancer -n argocd"
    echo "Username: admin"
    echo "Password: $ARGOCD_PASSWORD"
fi

echo ""
echo "📋 ArgoCD Applications:"
kubectl get applications -n argocd
echo ""
echo "🔍 Useful Commands:"
echo "==================="
echo "# Check ArgoCD status"
echo "kubectl get pods -n argocd"
echo ""
echo "# View applications"
echo "kubectl get applications -n argocd"
echo ""
echo "# Check application sync status"
echo "kubectl get application ecommerce-microservices -n argocd -o yaml"
echo ""
echo "# Port forward for local access (alternative)"
echo "kubectl port-forward svc/argocd-server 8080:443 -n argocd"
echo ""
echo "🚀 ArgoCD is now ready for GitOps deployments!"
echo "Any changes pushed to the k8s/ directory will be automatically synchronized."