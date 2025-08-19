#!/bin/bash

# Build script for translation service images

set -e

echo "🏗️  Building Translation Service Images"

# Build backend image
echo "📦 Building backend image..."
cd backend
docker build -t backend:latest .
cd ..

# Build frontend image
echo "🎨 Building frontend image..."
cd frontend
docker build -t frontend:latest --build-arg REACT_APP_API_URL=http://localhost:8000 .
cd ..

echo "✅ All images built successfully!"
echo ""
echo "📋 Built images:"
docker images | grep -E "(backend|frontend)" | grep latest

echo ""
echo "🚀 Next steps:"
echo "1. Run monitoring setup: ./setup-monitoring.sh"
echo "2. Deploy integrated stack: docker stack deploy -c docker-compose.integrated.yml translation-app"