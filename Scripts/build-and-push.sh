#!/usr/bin/env bash
set -euo pipefail

PROJECT_NS="microk8s-term-project"
IMAGE_NAME="photo-gallery-api"
IMAGE_TAG="v1"
REGISTRY="localhost:32000"
FULL_IMAGE="$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

echo "==> Waiting for MicroK8s to be ready..."
microk8s status --wait-ready

echo "==> Enabling required MicroK8s addons..."
microk8s enable dns registry ingress metrics-server

echo "==> Creating namespace (if not exists)..."
microk8s kubectl create namespace "$PROJECT_NS" --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "==> Building Docker image..."
cd "$(dirname "$0")/.."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

echo "==> Tagging image for local registry..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$FULL_IMAGE"

echo "==> Pushing image to local registry..."
docker push "$FULL_IMAGE"

echo "==> Applying Kubernetes manifests..."
microk8s kubectl apply -f k8s/namespace.yaml
microk8s kubectl apply -f k8s/deployment.yaml
microk8s kubectl apply -f k8s/service.yaml
microk8s kubectl apply -f k8s/ingress.yaml
microk8s kubectl apply -f k8s/hpa.yaml

echo "==> Current Pods:"
microk8s kubectl get pods -n "$PROJECT_NS" -o wide

echo "==> Services:"
microk8s kubectl get svc -n "$PROJECT_NS"

echo "==> Ingress:"
microk8s kubectl get ingress -n "$PROJECT_NS"

echo "==> HPA:"
microk8s kubectl get hpa -n "$PROJECT_NS"