#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="headless-demo"
MARKER="$ROOT/.headless-demo-namespace-created-by-this-lab"
echo "Current context: $(kubectl config current-context)"
echo "This script creates namespaced lab resources and changes cluster state."
if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "REFUSING: namespace '$NAMESPACE' already exists. Inspect it and choose a safe, reviewed approach; this script will not reuse it."
  exit 2
fi
read -r -p "Type CREATE headless-demo to create the namespace and lab resources: " confirm
if [ "$confirm" != "CREATE headless-demo" ]; then echo "Cancelled."; exit 1; fi
kubectl apply -f "$ROOT/manifests/00-namespace.yaml"
touch "$MARKER"
kubectl apply -f "$ROOT/manifests/01-demo-deployment.yaml"
kubectl apply -f "$ROOT/manifests/02-normal-service.yaml"
kubectl apply -f "$ROOT/manifests/03-headless-service.yaml"
kubectl apply -f "$ROOT/manifests/04-diagnostic-deployment.yaml"
echo "Waiting for application and diagnostic rollouts..."
kubectl rollout status deployment/headless-demo -n "$NAMESPACE" --timeout=180s
kubectl rollout status deployment/headless-diagnostic -n "$NAMESPACE" --timeout=180s
kubectl get pods -n "$NAMESPACE" -o wide
kubectl get svc -n "$NAMESPACE"
echo "Setup complete. Marker written to: $MARKER"
