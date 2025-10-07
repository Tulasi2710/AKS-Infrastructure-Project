# Microservices Deployment Guide

This directory contains Kubernetes manifests for deploying a complete e-commerce microservices application on AKS.

## Architecture Overview

The application consists of the following components:

### Core Services
- **Frontend**: NGINX-based web server serving the UI
- **User Service**: RESTful API for user management (using HTTPBin for demo)
- **Product Service**: RESTful API for product catalog (using HTTP Echo for demo)
- **Database**: PostgreSQL database with persistent storage

### Infrastructure Services
- **Ingress**: Route external traffic to appropriate services
- **Monitoring**: Prometheus and Grafana for observability
- **Namespaces**: Logical separation of components

## Deployment Order

1. **Deploy Namespaces**
   ```bash
   kubectl apply -f namespaces/ecommerce-namespace.yaml
   ```

2. **Deploy Database**
   ```bash
   kubectl apply -f database/postgres-deployment.yaml
   ```

3. **Deploy Backend Services**
   ```bash
   kubectl apply -f backend/backend-services.yaml
   ```

4. **Deploy Frontend**
   ```bash
   kubectl apply -f frontend/frontend-deployment.yaml
   ```

5. **Deploy Ingress**
   ```bash
   kubectl apply -f ingress/ingress-config.yaml
   ```

6. **Deploy Monitoring**
   ```bash
   kubectl apply -f monitoring/monitoring-stack.yaml
   ```

## Service Endpoints

Once deployed, the services will be available at:

- **Frontend**: `/` (root path)
- **User API**: `/api/users/*`
- **Product API**: `/api/products/*`
- **Grafana**: External LoadBalancer (for monitoring)

## Database Configuration

The PostgreSQL database includes:
- Database: `ecommerce_db`
- Username: `postgres`
- Password: Stored in Kubernetes secret
- Persistent volume for data storage

## Monitoring

The monitoring stack provides:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- Default admin credentials: admin/admin123

## Resource Allocation

All services are configured with:
- CPU and memory limits
- Health checks (readiness/liveness probes)
- Appropriate replica counts for high availability

## Security Considerations

- Services run with non-root users where possible
- Secrets management for sensitive data
- Network policies for namespace isolation
- Resource quotas to prevent resource exhaustion

## Scaling

Services can be scaled using:
```bash
kubectl scale deployment <deployment-name> --replicas=<count> -n <namespace>
```

Example:
```bash
kubectl scale deployment user-service --replicas=3 -n ecommerce
```

## Troubleshooting

Check pod status:
```bash
kubectl get pods -n ecommerce
kubectl get pods -n monitoring
```

View logs:
```bash
kubectl logs -f deployment/<deployment-name> -n <namespace>
```

Check service connectivity:
```bash
kubectl get svc -n ecommerce
kubectl describe ingress ecommerce-ingress -n ecommerce
```