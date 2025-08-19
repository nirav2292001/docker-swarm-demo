# Translation Service

A scalable translation service built with FastAPI backend and React frontend, designed to run on Docker Swarm for high availability and horizontal scaling.

## 🏗️ Architecture

This project consists of:
- **Backend**: FastAPI service with Hugging Face transformers for English-to-German translation
- **Frontend**: React web application for user interface
- **Docker Swarm**: Container orchestration for scalability

## 📋 Prerequisites

- Docker Engine 20.10+ with Swarm mode enabled
- Docker Compose v3.8+
- At least 2GB RAM (for ML model loading)

## 🚀 Quick Start

**Just clone and run!** Here's the simple setup:

```bash
# 1. Clone the repository
git clone https://github.com/nirav2292001/docker-swarm-demo
cd docker-swarm-demo

# 2. Initialize Docker Swarm (if not already done)
docker swarm init

# 3. Build images
cd backend
docker build -t backend:latest .
cd ../frontend
docker build -t frontend:latest --build-arg REACT_APP_API_URL=http://localhost:8000 .
cd ..

# 4. Deploy the stack
export REACT_APP_API_URL=http://localhost:8000
docker stack deploy -c docker-compose.yml translation-app
```

**That's it!** Your scalable translation service is now running.

### 🔍 Verify Deployment

```bash
# Check services
docker service ls

# Check service status
docker stack ps translation-app

# View service logs
docker service logs translation-app_backend
docker service logs translation-app_frontend
```

### 🌐 Access Your Application

- **Frontend**: http://localhost (port 80)
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

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

**Yes, you can just clone and run!** Here's the minimal setup:

```bash
# Clone repo
git clone https://github.com/nirav2292001/docker-swarm-demo
cd docker-swarm-demo

# One-time setup
docker swarm init

# Build and deploy
cd backend && docker build -t backend:latest . && cd ..
cd frontend && docker build -t frontend:latest --build-arg REACT_APP_API_URL=http://localhost:8000 . && cd ..
export REACT_APP_API_URL=http://localhost:8000
docker stack deploy -c docker-compose.yml translation-app

# Access your app
open http://localhost      # Translation service
```

That's it! You now have a fully scalable translation service running on Docker Swarm.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally and with Docker Swarm
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.