#!/bin/bash

# ===== CONFIG =====
KEY_PATH=~/buildserver.pem
EC2_USER=ec2-user
EC2_HOST=3.237.71.74

IMAGE_NAME="$1"
CONTAINER_NAME=react-app
PORT=80
CONTAINER_PORT=80
# ==================

if [ -z "$IMAGE_NAME" ]; then
  echo "Usage: ./deploy.sh <docker-image>"
  exit 1
fi

# Validate creds
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
  echo "❌ DOCKER_USERNAME or DOCKER_PASSWORD not set"
  exit 1
fi

echo "🚀 Deploying $IMAGE_NAME"

ssh -i "$KEY_PATH" ${EC2_USER}@${EC2_HOST} << EOF
  set -e

  echo "🔐 Docker login"
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

  echo "📥 Pulling image"
  docker pull $IMAGE_NAME

  echo "🛑 Stopping old container"
  docker stop $CONTAINER_NAME || true
  docker rm $CONTAINER_NAME || true

  echo "▶️ Running new container"
  docker run -d \
    --name $CONTAINER_NAME \
    -p ${PORT}:${CONTAINER_PORT} \
    --restart unless-stopped \
    $IMAGE_NAME

  echo "🧹 Logout from Docker"
  docker logout

  echo "✅ Deployment successful"
EOF

