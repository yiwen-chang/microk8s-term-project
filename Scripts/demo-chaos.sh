#!/usr/bin/env bash
set -euo pipefail

NS="microk8s-term-project"
APP_LABEL="app=photo-gallery-api"
HOST_HEADER="photo.local"
URL="http://127.0.0.1/api/info"

echo "==> Pods before chaos test:"
microk8s kubectl get pods -n "$NS" -l "$APP_LABEL" -o wide

echo
echo "==> Testing service before deleting a pod:"
curl -s -H "Host: $HOST_HEADER" "$URL"
echo

POD=$(microk8s kubectl get pods -n "$NS" -l "$APP_LABEL" -o jsonpath='{.items[0].metadata.name}')

echo
echo "==> Deleting pod: $POD"
microk8s kubectl delete pod "$POD" -n "$NS"

echo
echo "==> Service should still be reachable through Ingress:"
for i in $(seq 1 10); do
  echo "--- Request $i ---"
  curl -s -H "Host: $HOST_HEADER" "$URL" | grep -E '"hostname"|"pod_ip"|"version"'
  sleep 1
done

echo
echo "==> Pods after Kubernetes self-healing:"
microk8s kubectl get pods -n "$NS" -l "$APP_LABEL" -o wide