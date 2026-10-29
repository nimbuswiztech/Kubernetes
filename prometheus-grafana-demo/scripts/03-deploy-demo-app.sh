#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
command -v kubectl >/dev/null || { echo "ERROR: kubectl is required." >&2; exit 1; }
kubectl cluster-info >/dev/null
echo "Applying demo namespace, Deployment, and Service..."
kubectl apply -f "$PROJECT_DIR/manifests/demo-app.yaml"
kubectl rollout status deployment/demo-web -n monitoring-demo --timeout=180s
kubectl get pods,svc -n monitoring-demo -o wide
echo "Note: this demo app is not automatically exposing application-specific Prometheus metrics."
