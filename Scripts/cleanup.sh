#!/usr/bin/env bash
set -euo pipefail

NS="microk8s-term-project"

echo "==> Deleting Kubernetes resources in namespace $NS..."
cd "$(dirname "$0")/.."

microk8s kubectl delete -f k8s/hpa.yaml --ignore-not-found
microk8s kubectl delete -f k8s/ingress.yaml --ignore-not-found
microk8s kubectl delete -f k8s/service.yaml --ignore-not-found
microk8s kubectl delete -f k8s/deployment.yaml --ignore-not-found
microk8s kubectl delete -f k8s/namespace.yaml --ignore-not-found

echo "==> Cleanup complete."