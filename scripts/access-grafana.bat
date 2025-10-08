@echo off
echo Starting kubectl proxy for Grafana access...
start "" "http://localhost:8080/api/v1/namespaces/monitoring/services/grafana-service:3000/proxy/"
kubectl proxy --port=8080