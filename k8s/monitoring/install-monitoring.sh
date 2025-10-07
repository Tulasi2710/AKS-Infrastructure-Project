#!/bin/bash

# Monitoring Stack Deployment Script using Helm
# This script installs Prometheus and Grafana using Helm charts

echo "🔧 Installing Monitoring Stack (Prometheus + Grafana) using Helm..."

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "📁 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Prometheus using Helm
echo "🔍 Installing Prometheus..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer \
  --set alertmanager.enabled=true \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --timeout=10m

# Wait for deployment
echo "⏳ Waiting for Prometheus stack to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --namespace monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --namespace monitoring --timeout=300s

# Get service information
echo "📊 Getting service endpoints..."
echo "Prometheus UI:"
kubectl get service prometheus-kube-prometheus-prometheus -n monitoring
echo ""
echo "Grafana UI:"
kubectl get service prometheus-grafana -n monitoring
echo ""
echo "Grafana Login: admin / admin123"

# Apply custom dashboard
echo "📈 Applying custom dashboards..."
kubectl apply -f ./prometheus-grafana-helm.yaml

# Show access information
echo "✅ Monitoring stack deployment complete!"
echo ""
echo "Access URLs (after LoadBalancer IPs are assigned):"
echo "- Prometheus: http://<PROMETHEUS_EXTERNAL_IP>:9090"
echo "- Grafana: http://<GRAFANA_EXTERNAL_IP>:80"
echo ""
echo "To get external IPs:"
echo "kubectl get svc -n monitoring"
echo ""
echo "To port-forward (alternative access):"
echo "kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
echo "kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"