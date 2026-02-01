#!/bin/bash

set -e

# Configurações
VERSION="1.5.0"
DOCKER_USERNAME="welitonjjose"
IMAGE_NAME="alts-wpp"
FULL_IMAGE="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
LATEST_IMAGE="${DOCKER_USERNAME}/${IMAGE_NAME}:latest"

echo "========================================="
echo "Building Chatwoot Docker Image"
echo "Version: ${VERSION}"
echo "Image: ${FULL_IMAGE}"
echo "========================================="

# Volta para o diretório raiz do projeto (pai de builder)
cd "$(dirname "$0")/.."

# Build da imagem
echo ""
echo "🔨 Building Docker image..."
docker build \
  -f builder/Dockerfile \
  -t ${FULL_IMAGE} \
  -t ${LATEST_IMAGE} \
  .

echo ""
echo "✅ Build completed successfully!"

# Login no Docker Hub (se necessário)
echo ""
echo "🔐 Logging in to Docker Hub..."
echo "Please enter your Docker Hub credentials if prompted"
docker login

# Push das imagens
echo ""
echo "📤 Pushing image to Docker Hub..."
docker push ${FULL_IMAGE}
docker push ${LATEST_IMAGE}

echo ""
echo "========================================="
echo "✅ Success!"
echo "========================================="
echo "Image published:"
echo "  - ${FULL_IMAGE}"
echo "  - ${LATEST_IMAGE}"
echo ""
echo "To use this image, update your docker-compose.yml:"
echo "  image: ${FULL_IMAGE}"
echo "========================================="
