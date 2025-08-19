# Docker Swarm Monitoring Stack

A comprehensive monitoring solution for your Docker Swarm translation service using Prometheus and Grafana.

## 🏗️ Architecture

The monitoring stack includes:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Node Exporter**: System-level metrics
- **cAdvisor**: Container-level metrics

## 📋 Prerequisites

- Docker Swarm cluster initialized
- At least 2GB RAM available for monitoring services
- Ports 3000, 8080, 9090, 9091, 9093, 9100 available

## 🚀 Quick Setup

### 1. Create Required Volumes

```bash
# Create persistent volumes for data
docker volume create prometheus_data
docker volume create grafana_data
```

### 2. Create Monitoring Network

```bash
# Create overlay network for monitoring services
docker network create --driver overlay --attachable monitoring_monitoring
```

### 3. Deploy Monitoring Stack

```bash
# Deploy the monitoring stack
docker stack deploy -c docker-compose.monitoring.yml monitoring
```

### 4. Verify Deployment

```bash
# Check service status
docker service ls | grep monitoring

# Check if all services are running
docker stack ps monitoring
```

## 🔗 Access Points

Once deployed, access the monitoring services:

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | admin/admin123 |
| Prometheus | http://localhost:9090 | - |
| Node Exporter | http://localhost:9100 | - |
| cAdvisor | http://localhost:8080 | - |


## 📊 Monitoring Your Translation Service

### Integrate with Existing Services

To monitor your translation service, deploy it with the integrated compose file:

```bash
# Deploy translation app with monitoring integration
docker stack deploy -c docker-compose.integrated.yml translation-app
```

### Key Metrics Monitored

#### System Metrics (Node Exporter)
- CPU usage per node
- Memory utilization
- Disk space and I/O
- Network traffic
- System load

#### Container Metrics (cAdvisor)
- Container CPU and memory usage
- Container restart counts
- Container network I/O
- Container filesystem usage

#### Application Metrics
- HTTP request rates
- Response times
- Error rates
- Translation processing time
- MLflow experiment metrics


## 📈 Grafana Dashboards

### Pre-built Dashboards

1. **Docker Swarm Overview**: System and container metrics
2. **Translation Service**: Application-specific metrics
3. **Node Metrics**: Detailed system monitoring

### Creating Custom Dashboards

1. Access Grafana at http://localhost:3000
2. Login with admin/admin123
3. Create new dashboard
4. Add panels with Prometheus queries

### Useful Prometheus Queries

```promql
# CPU usage by container
rate(container_cpu_usage_seconds_total[5m]) * 100

# Memory usage by container
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100

# HTTP request rate
rate(http_requests_total[5m])

# Translation response time
histogram_quantile(0.95, rate(translation_duration_seconds_bucket[5m]))
```

## 🔧 Configuration

### Prometheus Configuration

Edit `monitoring/prometheus/prometheus.yml` to:
- Add new scrape targets
- Modify scrape intervals
- Configure service discovery

### Grafana Configuration

- **Data Sources**: Auto-provisioned Prometheus connection
- **Dashboards**: Auto-loaded from `monitoring/grafana/dashboards/`
- **Plugins**: Configured in docker-compose environment

### Resource Limits

Adjust resource limits in `docker-compose.monitoring.yml`:

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
    reservations:
      memory: 512M
      cpus: '0.25'
```

## 🔍 Troubleshooting

### Common Issues

#### Services Not Starting

```bash
# Check service logs
docker service logs monitoring_prometheus
docker service logs monitoring_grafana

# Check resource constraints
docker node ls
docker system df
```

#### Metrics Not Appearing

```bash
# Verify Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check network connectivity
docker exec -it $(docker ps -q -f name=monitoring_prometheus) ping node-exporter
```

#### Grafana Dashboard Issues

```bash
# Reset Grafana data
docker volume rm grafana_data
docker volume create grafana_data

# Restart Grafana service
docker service update --force monitoring_grafana
```

### Performance Tuning

#### Prometheus Retention

Adjust retention in `docker-compose.monitoring.yml`:

```yaml
command:
  - '--storage.tsdb.retention.time=30d'  # Keep data for 30 days
  - '--storage.tsdb.retention.size=10GB'  # Limit storage size
```

#### Scrape Intervals

Optimize scrape intervals based on needs:

```yaml
scrape_configs:
  - job_name: 'high-frequency'
    scrape_interval: 5s    # For critical metrics
  - job_name: 'low-frequency'
    scrape_interval: 60s   # For less critical metrics
```

## 🔐 Security Considerations

### Authentication

1. **Change Default Passwords**:
```bash
# Update Grafana admin password
docker exec -it $(docker ps -q -f name=monitoring_grafana) \
  grafana-cli admin reset-admin-password newpassword
```

2. **Enable HTTPS**:
```yaml
# Add to Grafana environment
- GF_SERVER_PROTOCOL=https
- GF_SERVER_CERT_FILE=/etc/ssl/certs/grafana.crt
- GF_SERVER_CERT_KEY=/etc/ssl/private/grafana.key
```

### Network Security

```yaml
# Restrict external access
ports:
  - "127.0.0.1:3000:3000"  # Grafana only on localhost
  - "127.0.0.1:9090:9090"  # Prometheus only on localhost
```

## 📊 Scaling Considerations

### Multi-Node Deployment

```yaml
# Deploy monitoring on manager nodes only
deploy:
  placement:
    constraints:
      - node.role == manager

# Deploy exporters on all nodes
deploy:
  mode: global
```

### High Availability

```yaml
# Multiple Prometheus replicas with shared storage
deploy:
  replicas: 2
  placement:
    max_replicas_per_node: 1
```

## 🔄 Maintenance

### Regular Tasks

1. **Monitor Disk Usage**:
```bash
# Check Prometheus data size
docker exec -it $(docker ps -q -f name=monitoring_prometheus) \
  du -sh /prometheus
```

2. **Update Images**:
```bash
# Update to latest versions
docker service update --image prom/prometheus:latest monitoring_prometheus
docker service update --image grafana/grafana:latest monitoring_grafana
```

3. **Backup Configuration**:
```bash
# Backup Grafana dashboards
docker exec -it $(docker ps -q -f name=monitoring_grafana) \
  tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana
```

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Docker Swarm Monitoring Best Practices](https://docs.docker.com/engine/swarm/)
- [AlertManager Configuration](https://prometheus.io/docs/alerting/latest/alertmanager/)

## 🤝 Contributing

To add new monitoring features:

1. Update Prometheus configuration for new metrics
2. Create Grafana dashboards for visualization
3. Add relevant alerts in AlertManager
4. Update documentation

## 📄 License

This monitoring configuration is part of the translation service project and follows the same MIT License.