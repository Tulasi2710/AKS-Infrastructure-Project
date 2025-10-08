#!/bin/bash

# Lightweight Monitoring Stack Installation
# Alternative to heavy kube-prometheus-stack for resource-constrained environments

set -e

echo "📊 Installing Lightweight Monitoring Stack..."

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Helm if not available
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus (standalone, lighter than kube-prometheus-stack)
echo "🔍 Installing Prometheus..."
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set server.resources.requests.memory=200Mi \
  --set server.resources.requests.cpu=100m \
  --set server.resources.limits.memory=1Gi \
  --set server.resources.limits.cpu=500m \
  --set server.retention=7d \
  --set server.service.type=NodePort \
  --set alertmanager.enabled=true \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --timeout=10m

# Install Grafana (standalone)
echo "📈 Installing Grafana..."
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --set adminPassword=admin123 \
  --set service.type=NodePort \
  --set resources.requests.memory=100Mi \
  --set resources.requests.cpu=100m \
  --set resources.limits.memory=500Mi \
  --set resources.limits.cpu=500m \
  --timeout=10m

# Wait for deployments
echo "⏳ Waiting for monitoring services..."
kubectl wait --for=condition=available deployment/prometheus-server --namespace monitoring --timeout=300s || echo "Prometheus server timeout"
kubectl wait --for=condition=available deployment/grafana --namespace monitoring --timeout=300s || echo "Grafana timeout"

# Configure Grafana with Prometheus data source
echo "🔧 Configuring Grafana data source..."
kubectl create configmap grafana-datasources \
  --from-literal=datasources.yaml="
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://prometheus-server:80
  isDefault: true
" \
  -n monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

# Get access information
echo ""
echo "📊 Monitoring Access Information:"
echo "================================"

GRAFANA_NODEPORT=$(kubectl get svc grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "Not available")
PROMETHEUS_NODEPORT=$(kubectl get svc prometheus-server -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "Not available")
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' || kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "🔍 Prometheus UI: http://$NODE_IP:$PROMETHEUS_NODEPORT"
echo "📈 Grafana UI: http://$NODE_IP:$GRAFANA_NODEPORT"
echo "Grafana Login: admin / admin123"
echo ""
echo "For local access via port-forwarding:"
echo "kubectl port-forward -n monitoring svc/grafana 3000:80"
echo "kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo ""
echo "Services:"
kubectl get svc -n monitoring
echo ""
echo "Pods:"
kubectl get pods -n monitoring

echo "✅ Lightweight monitoring stack installation complete!"