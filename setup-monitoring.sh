#!/bin/bash

# Setup script for monitoring stack deployment

set -e

echo "🚀 Setting up Docker Swarm Monitoring Stack"

# Check if Docker Swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not initialized. Please run 'docker swarm init' first."
    exit 1
fi

# Create external volumes
echo "📦 Creating external volumes..."
docker volume create prometheus_data || true
docker volume create grafana_data || true
docker volume create alertmanager_data || true

# Create monitoring network
echo "🌐 Creating monitoring network..."
docker network create --driver overlay --attachable monitoring_monitoring || true

# Deploy monitoring stack
echo "🔧 Deploying monitoring stack..."
docker stack deploy -c docker-compose.monitoring.yml monitoring

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "📊 Checking service status..."
docker service ls | grep monitoring

echo ""
echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "🔗 Access URLs:"
echo "   Grafana:      http://localhost:3000 (admin/admin123)"
echo "   Prometheus:   http://localhost:9090"
echo "   AlertManager: http://localhost:9093"
echo "   Node Exporter: http://localhost:9100"
echo "   cAdvisor:     http://localhost:8080"
echo ""
echo "📈 To deploy your translation app with monitoring integration:"
echo "   docker stack deploy -c docker-compose.integrated.yml translation-app"
echo ""
echo "🔍 To view logs:"
echo "   docker service logs monitoring_grafana"
echo "   docker service logs monitoring_prometheus"
echo ""
echo "📊 Default Grafana credentials: admin/admin123"
echo "   Please change the password after first login!"