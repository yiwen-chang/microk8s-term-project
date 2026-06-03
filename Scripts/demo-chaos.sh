#!/usr/bin/env bash
set -euo pipefail

NS="microk8s-term-project"
SVC_HOST="photo.local"
INGRESS_URL="http://127.0.0.1/api/load?duration=1.5"

echo "==> Generating CPU load via /api/load through Ingress..."

if command -v parallel >/dev/null 2>&1; then
  seq 1 50 | parallel -j 10 curl -s -H "Host: $SVC_HOST" "$INGRESS_URL" >/dev/null &
else
  seq 1 50 | xargs -n1 -P10 -I{} curl -s -H "Host: $SVC_HOST" "$INGRESS_URL" >/dev/null &
fi

sleep 30

echo "==> HPA status:"
microk8s kubectl get hpa photo-gallery-api-hpa -n "$NS"

echo "==> Pods after HPA activity:"
microk8s kubectl get pods -n "$NS" -o wide

echo "==> Manual scaling to 5 replicas as fallback..."
microk8s kubectl scale deployment photo-gallery-api -n "$NS" --replicas=5

sleep 10

echo "==> Pods after manual scaling:"
microk8s kubectl get pods -n "$NS" -o wide