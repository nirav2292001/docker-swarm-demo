# Translation Service

A scalable translation service built with FastAPI backend and React frontend, designed to run on Docker Swarm for high availability and horizontal scaling.

## 🏗️ Architecture

This project consists of:
- **Backend**: FastAPI service with Hugging Face transformers for English-to-German translation
- **Frontend**: React web application for user interface
- **MLflow**: Experiment tracking and model monitoring
- **Docker Swarm**: Container orchestration for scalability

## 📋 Prerequisites

- Docker Engine 20.10+ with Swarm mode enabled
- Docker Compose v3.8+
- At least 4GB RAM (for ML model loading)
- Node.js 18+ (for local development)
- Python 3.12+ (for local development)

## 🚀 Quick Start

### Option 1: Complete Setup with Monitoring (Recommended)

**Just clone and run!** This is the simplest way to get everything running:

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd <repo-name>

# 2. Initialize Docker Swarm (if not already done)
docker swarm init

# 3. Build images
./build-images.sh  # or build manually (see below)

# 4. Setup monitoring stack
chmod +x setup-monitoring.sh
./setup-monitoring.sh

# 5. Deploy translation app with integrated monitoring
export REACT_APP_API_URL=http://localhost:8000
docker stack deploy -c docker-compose.integrated.yml translation-app
```

**That's it!** Your complete stack is now running with monitoring.

### Manual Image Building (if build script doesn't exist)

```bash
# Build backend image
cd backend
docker build -t backend:latest .

# Build frontend image
cd ../frontend
docker build -t frontend:latest --build-arg REACT_APP_API_URL=http://localhost:8000 .
cd ..
```

### Option 2: Basic Setup (Without Monitoring)

```bash
# 1. Initialize Docker Swarm
docker swarm init

# 2. Build images (see manual building above)

# 3. Deploy basic stack
export REACT_APP_API_URL=http://localhost:8000
docker stack deploy -c docker-compose.yml translation-app
```

### 🔍 Verify Deployment

```bash
# Check all services
docker service ls

# Check translation app services
docker stack ps translation-app

# Check monitoring services (if deployed)
docker stack ps monitoring

# View service logs
docker service logs translation-app_backend
docker service logs translation-app_frontend
```

### 🌐 Access Your Application

**Translation Service:**
- **Frontend**: http://localhost (port 80)
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

**Monitoring Dashboard (if deployed with integrated setup):**
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Node Exporter**: http://localhost:9100
- **cAdvisor**: http://localhost:8080

## � Monitorivng & Observability

### MLflow Integration
The backend automatically logs translation metrics:

```bash
# View MLflow logs locally
cd backend
ls mlflow_logs/

# Access MLflow UI (when running locally)
mlflow ui --backend-store-uri file:./mlflow_logs
```

Tracked metrics include:
- Translation inference time
- Input text length
- Model parameters
- Input/output artifacts

### Prometheus & Grafana Stack
When deployed with the integrated setup, you get comprehensive monitoring:

**Metrics Collected:**
- Container resource usage (CPU, memory, network, disk)
- Docker Swarm cluster health
- Service availability and response times
- Custom application metrics
- System-level metrics from all nodes

**Pre-configured Dashboards:**
- Docker Swarm Overview
- Container Resource Usage
- Service Performance Metrics
- Node Health Monitoring

**Accessing Monitoring:**
```bash
# Grafana (main dashboard)
open http://localhost:3000
# Default login: admin/admin123

# Prometheus (raw metrics)
open http://localhost:9090

# Check monitoring stack status
docker service ls | grep monitoring
```

## 🔧 Local Development

### Backend Development

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server
python main.py
```

The backend will be available at http://localhost:8000

### Frontend Development

```bash
cd frontend

# Install dependencies
npm install

# Set API URL for development
export REACT_APP_API_URL=http://localhost:8000

# Start development server
npm start
```

The frontend will be available at http://localhost:3000

## 🐳 Docker Swarm Configuration

### Service Scaling

The docker-compose.yml is configured for high availability:

```yaml
deploy:
  replicas: 3  # Run 3 instances of each service
  restart_policy:
    condition: on-failure
```

### Scaling Services

```bash
# Scale backend service to 5 replicas
docker service scale translation-app_backend=5

# Scale frontend service to 2 replicas
docker service scale translation-app_frontend=2

# Check current scaling
docker service ls
```

### Load Balancing

Docker Swarm provides built-in load balancing:
- **Ingress Network**: Distributes external traffic across service replicas
- **Overlay Network**: Enables service-to-service communication
- **VIP (Virtual IP)**: Each service gets a virtual IP for internal load balancing

### High Availability Features

1. **Service Discovery**: Services communicate using service names
2. **Health Checks**: Automatic container restart on failure
3. **Rolling Updates**: Zero-downtime deployments
4. **Multi-node Support**: Distribute services across multiple Docker hosts

## 📊 Monitoring

### MLflow Integration

The backend automatically logs translation metrics:

```bash
# View MLflow logs locally
cd backend
ls mlflow_logs/

# Access MLflow UI (when running locally)
mlflow ui --backend-store-uri file:./mlflow_logs
```

Tracked metrics include:
- Translation inference time
- Input text length
- Model parameters
- Input/output artifacts

### Prometheus & Grafana Monitoring Stack

Deploy a comprehensive monitoring solution with Prometheus and Grafana:

```bash
# Create required volumes and network
docker volume create prometheus_data
docker volume create grafana_data
docker volume create alertmanager_data
docker network create --driver overlay --attachable monitoring_monitoring

# Deploy monitoring stack
docker stack deploy -c docker-compose.monitoring.yml monitoring

# Deploy translation app with monitoring integration
docker stack deploy -c docker-compose.integrated.yml translation-app
```

**Access Points:**
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100
- **cAdvisor**: http://localhost:8080

**Monitored Metrics:**
- System resources (CPU, memory, disk, network)
- Container performance and health
- Application response times and error rates
- Docker Swarm service status
- Custom translation service metrics

See [MONITORING.md](MONITORING.md) for detailed setup and configuration instructions.

## 🔄 Production Deployment

### Multi-Node Swarm Setup

1. **Manager Node Setup**:
```bash
# Initialize swarm
docker swarm init --advertise-addr <manager-ip>

# Get join tokens
docker swarm join-token worker
docker swarm join-token manager
```

2. **Worker Node Setup**:
```bash
# Join as worker (run on each worker node)
docker swarm join --token <worker-token> <manager-ip>:2377
```

3. **Deploy with Constraints**:
```yaml
# Add to docker-compose.yml for production
deploy:
  replicas: 3
  placement:
    constraints:
      - node.role == worker  # Deploy only on worker nodes
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
```

### Environment Configuration

```bash
# Production environment variables
export REACT_APP_API_URL=https://api.yourdomain.com
export BACKEND_REPLICAS=5
export FRONTEND_REPLICAS=3

# Deploy with production settings
docker stack deploy -c docker-compose.yml -c docker-compose.prod.yml translation-app
```

## 🛠️ Management Commands

### Stack Management

```bash
# Deploy/update stack
docker stack deploy -c docker-compose.yml translation-app

# Remove stack
docker stack rm translation-app

# List stacks
docker stack ls

# View stack services
docker stack services translation-app
```

### Service Management

```bash
# Update service image
docker service update --image backend:v2 translation-app_backend

# View service details
docker service inspect translation-app_backend

# View service logs
docker service logs -f translation-app_backend
```

### Node Management

```bash
# List swarm nodes
docker node ls

# Drain node for maintenance
docker node update --availability drain <node-id>

# Promote worker to manager
docker node promote <node-id>
```

## 🔍 Troubleshooting

### Common Issues

1. **Service Won't Start**:
```bash
# Check service events
docker service ps translation-app_backend --no-trunc

# Check node resources
docker node ls
docker system df
```

2. **Network Issues**:
```bash
# Inspect overlay network
docker network inspect translation-app_app-network

# Test service connectivity
docker exec -it <container-id> ping backend
```

3. **Image Issues**:
```bash
# Verify images exist on all nodes
docker images | grep backend
docker images | grep frontend

# Pull images on all nodes if needed
docker service update --force translation-app_backend
```

## 📈 Scaling Best Practices

1. **Monitor Resource Usage**: Use `docker stats` to monitor CPU/memory
2. **Gradual Scaling**: Increase replicas incrementally
3. **Load Testing**: Test with realistic traffic patterns
4. **Health Checks**: Implement proper health endpoints
5. **Resource Limits**: Set appropriate CPU/memory limits

## 🔐 Security Considerations

- Use secrets for sensitive configuration
- Implement proper CORS policies
- Use HTTPS in production
- Regular security updates for base images
- Network segmentation with overlay networks

## 📝 API Usage

### Translation Endpoint

```bash
# Translate text
curl -X POST "http://localhost:8000/translate" \
     -H "Content-Type: application/json" \
     -d '{"text": "Hello, how are you?"}'

# Response
{
  "translated_text": "Hallo, wie geht es dir?"
}
```

## ⚡ TL;DR - Super Quick Setup

**Yes, you can just clone and run the integrated file!** Here's the minimal setup:

```bash
# Clone repo
git clone <your-repo-url>
cd <repo-name>

# One-time setup
docker swarm init
chmod +x *.sh
./build-images.sh
./setup-monitoring.sh

# Deploy everything
export REACT_APP_API_URL=http://localhost:8000
docker stack deploy -c docker-compose.integrated.yml translation-app

# Access your app
open http://localhost      # Translation service
open http://localhost:3000 # Monitoring dashboard (admin/admin123)
```

That's it! You now have a fully scalable translation service with monitoring running on Docker Swarm.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally and with Docker Swarm
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.