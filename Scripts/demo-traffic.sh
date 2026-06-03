#!/usr/bin/env bash
set -euo pipefail

HOST_HEADER="photo.local"
URL="http://127.0.0.1/"

echo "==> Hitting Ingress in a loop to show different pod hostnames/IPs..."
for i in $(seq 1 20); do
  echo "--- Request $i ---"
  curl -s -H "Host: $HOST_HEADER" "$URL" | grep -E "Pod hostname|Pod IP|App version|Current timestamp" || true
  sleep 1
done