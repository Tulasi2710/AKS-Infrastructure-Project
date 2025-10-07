#!/bin/bash

# Microservices Deployment Script for AKS
# This script deploys all microservices components in the correct order

set -e

echo "🚀 Starting microservices deployment to AKS cluster..."

# Check if kubectl is available and cluster is accessible
echo "Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: Unable to connect to Kubernetes cluster"
    echo "Please ensure:"
    echo "1. AKS cluster is running"
    echo "2. kubectl is installed and configured"
    echo "3. You have access to the cluster"
    exit 1
fi

echo "✅ Cluster connectivity confirmed"

# Function to wait for deployment to be ready
wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    echo "Waiting for deployment '$deployment' in namespace '$namespace' to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
}

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    echo "Waiting for all pods in namespace '$namespace' to be ready..."
    kubectl wait --for=condition=ready --timeout=300s pod --all -n $namespace
}

# 1. Deploy Namespaces
echo "📁 Deploying namespaces..."
kubectl apply -f namespaces/ecommerce-namespace.yaml
echo "✅ Namespaces created"

# 2. Deploy Database (needs time to initialize)
echo "🗄️ Deploying PostgreSQL database..."
kubectl apply -f database/postgres-deployment.yaml
wait_for_deployment "postgres" "ecommerce-database"
echo "✅ Database deployed and ready"

# 3. Deploy Backend Services
echo "🔧 Deploying backend services..."
kubectl apply -f backend/backend-services.yaml
wait_for_deployment "user-service" "ecommerce"
wait_for_deployment "product-service" "ecommerce"
echo "✅ Backend services deployed and ready"

# 4. Deploy Frontend
echo "🌐 Deploying frontend service..."
kubectl apply -f frontend/frontend-deployment.yaml
wait_for_deployment "frontend" "ecommerce"
echo "✅ Frontend deployed and ready"

# 5. Deploy Ingress
echo "🔀 Deploying ingress controller..."
kubectl apply -f ingress/ingress-config.yaml
echo "✅ Ingress deployed"

# 6. Deploy Monitoring
echo "📊 Deploying monitoring stack..."
kubectl apply -f monitoring/monitoring-stack.yaml
wait_for_deployment "prometheus" "monitoring"
wait_for_deployment "grafana" "monitoring"
echo "✅ Monitoring stack deployed and ready"

echo ""
echo "🎉 Microservices deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "===================="
kubectl get pods -n ecommerce
echo ""
kubectl get pods -n ecommerce-database
echo ""
kubectl get pods -n monitoring
echo ""

echo "🔗 Service Information:"
echo "====================="
kubectl get svc -n ecommerce
echo ""
kubectl get svc -n ecommerce-database
echo ""
kubectl get svc -n monitoring
echo ""

echo "🌍 Ingress Information:"
echo "======================"
kubectl get ingress -n ecommerce

echo ""
echo "📊 Grafana Access:"
echo "=================="
GRAFANA_IP=$(kubectl get svc grafana-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending...")
if [ "$GRAFANA_IP" != "Pending..." ] && [ "$GRAFANA_IP" != "" ]; then
    echo "Grafana URL: http://$GRAFANA_IP:3000"
    echo "Username: admin"
    echo "Password: admin123"
else
    echo "Grafana LoadBalancer IP is still pending. Check status with:"
    echo "kubectl get svc grafana-service -n monitoring"
fi

echo ""
echo "🔍 To monitor deployment status:"
echo "kubectl get pods --all-namespaces"
echo "kubectl get svc --all-namespaces"
echo ""
echo "✅ Deployment script completed!"