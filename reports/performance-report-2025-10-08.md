# Daily Performance Report - 2025-10-08

Generated: 2025-10-08 08:34:57 UTC  
Report Period: Last 24 hours

## 🏗️ Infrastructure Status

### AKS Cluster Health
```
NAME                              STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-default-38792525-vmss000000   Ready    <none>   21h   v1.32.7   10.0.1.4      <none>        Ubuntu 22.04.5 LTS   5.15.0-1092-azure   containerd://1.7.28-1
aks-default-38792525-vmss000001   Ready    <none>   21h   v1.32.7   10.0.1.33     <none>        Ubuntu 22.04.5 LTS   5.15.0-1092-azure   containerd://1.7.28-1
```

### Resource Utilization
```
NAME                              CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
aks-default-38792525-vmss000000   96m          5%     2129Mi          29%       
aks-default-38792525-vmss000001   98m          5%     1471Mi          20%       
```

## 📊 Application Performance

### E-commerce Microservices Status
```

```

### Pod Resource Usage
```

```

## 🔍 Monitoring Stack Status

### Prometheus & Grafana
```
NAME                                                 READY   STATUS    RESTARTS   AGE     IP          NODE                              NOMINATED NODE   READINESS GATES
grafana-5978f65865-rlnth                             1/1     Running   0          4h33m   10.0.1.9    aks-default-38792525-vmss000000   <none>           <none>
prometheus-alertmanager-0                            1/1     Running   0          4h33m   10.0.1.57   aks-default-38792525-vmss000001   <none>           <none>
prometheus-d4469c947-8xscg                           1/1     Running   0          4h19m   10.0.1.41   aks-default-38792525-vmss000001   <none>           <none>
prometheus-kube-state-metrics-d4fd85895-k7ftp        1/1     Running   0          4h33m   10.0.1.61   aks-default-38792525-vmss000001   <none>           <none>
prometheus-prometheus-node-exporter-9kx7p            1/1     Running   0          4h33m   10.0.1.33   aks-default-38792525-vmss000001   <none>           <none>
prometheus-prometheus-node-exporter-jff5m            1/1     Running   0          4h33m   10.0.1.4    aks-default-38792525-vmss000000   <none>           <none>
prometheus-prometheus-pushgateway-65ddfcc6c4-6rvm7   1/1     Running   0          4h33m   10.0.1.52   aks-default-38792525-vmss000001   <none>           <none>
prometheus-server-86b5b6bfb7-jhkxh                   2/2     Running   0          4h33m   10.0.1.22   aks-default-38792525-vmss000000   <none>           <none>
```

### Services Status
```

```

```
NAME                                  TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)          AGE
grafana                               NodePort       172.16.237.33    <none>            80:30476/TCP     4h33m
grafana-service                       LoadBalancer   172.16.12.80     135.222.241.112   3000:31858/TCP   4h19m
prometheus-alertmanager               ClusterIP      172.16.246.124   <none>            9093/TCP         4h33m
prometheus-alertmanager-headless      ClusterIP      None             <none>            9093/TCP         4h33m
prometheus-kube-state-metrics         ClusterIP      172.16.64.244    <none>            8080/TCP         11h
prometheus-prometheus-node-exporter   ClusterIP      172.16.141.212   <none>            9100/TCP         11h
prometheus-prometheus-pushgateway     ClusterIP      172.16.99.67     <none>            9091/TCP         4h33m
prometheus-server                     NodePort       172.16.177.77    <none>            80:30170/TCP     4h33m
prometheus-service                    ClusterIP      172.16.132.174   <none>            9090/TCP         4h19m
```

## 🚨 Recent Events & Alerts

### Cluster Events (Last 1 hour)
```
NAMESPACE            LAST SEEN   TYPE      REASON    OBJECT                          MESSAGE
ecommerce-database   54m         Normal    Created   pod/postgres-859d65bc47-hdmq8   Created container: postgres
ecommerce-database   3m57s       Warning   BackOff   pod/postgres-859d65bc47-hdmq8   Back-off restarting failed container postgres in pod postgres-859d65bc47-hdmq8_ecommerce-database(453de584-a828-49af-a287-ba92b14ce6dd)
ecommerce-database   2m44s       Normal    Pulled    pod/postgres-859d65bc47-hdmq8   Container image "postgres:15-alpine" already present on machine
```

### Pod Restarts
```
ecommerce-database	postgres-859d65bc47-hdmq8	55
```

## 📈 Performance Metrics

### Response Time Analysis
- **Frontend Average Response Time**: [Query Prometheus for actual metrics]
- **Backend Service Response Time**: [Query Prometheus for actual metrics]  
- **Database Connection Pool**: [Query metrics if available]

### Error Rates
- **HTTP 4xx Errors**: [Query Prometheus for actual metrics]
- **HTTP 5xx Errors**: [Query Prometheus for actual metrics]
- **Application Errors**: [Query application logs]

### Resource Consumption
- **CPU Usage Trend**: [Query Prometheus for actual metrics]
- **Memory Usage Trend**: [Query Prometheus for actual metrics]
- **Network I/O**: [Query Prometheus for actual metrics]

## 🎯 Recommendations

  kube-system                 konnectivity-agent-798b7bf87d-xthv7                  20m (1%)      1 (52%)     20Mi (0%)        1Gi (14%)      21h
  kube-system                 kube-proxy-mmcnv                                     100m (5%)     0 (0%)      0 (0%)           0 (0%)         21h
  monitoring                  grafana-5978f65865-rlnth                             100m (5%)     500m (26%)  100Mi (1%)       500Mi (6%)     4h33m
  monitoring                  prometheus-prometheus-node-exporter-jff5m            0 (0%)        0 (0%)      0 (0%)           0 (0%)         4h33m
  monitoring                  prometheus-server-86b5b6bfb7-jhkxh                   100m (5%)     500m (26%)  200Mi (2%)       1Gi (14%)      4h33m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                750m (39%)   4 (210%)
  memory             816Mi (11%)  11246Mi (156%)
--
  monitoring                  prometheus-alertmanager-0                             0 (0%)        0 (0%)      0 (0%)           0 (0%)         4h33m
  monitoring                  prometheus-d4469c947-8xscg                            200m (10%)    500m (26%)  256Mi (3%)       512Mi (7%)     4h19m
  monitoring                  prometheus-kube-state-metrics-d4fd85895-k7ftp         0 (0%)        0 (0%)      0 (0%)           0 (0%)         4h33m
  monitoring                  prometheus-prometheus-node-exporter-9kx7p             0 (0%)        0 (0%)      0 (0%)           0 (0%)         4h33m
  monitoring                  prometheus-prometheus-pushgateway-65ddfcc6c4-6rvm7    0 (0%)        0 (0%)      0 (0%)           0 (0%)         4h33m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits

---
*Report generated by AKS Infrastructure Project - Daily Performance Pipeline*

## 📊 Prometheus Metrics (Enhanced)

- **Cpu Usage**: Query failed
- **Memory Usage**: Query failed
- **Http Requests Rate**: Query failed
- **Http Error Rate**: Query failed
