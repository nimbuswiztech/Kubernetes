#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NS="headless-demo"
MARKER="$ROOT/.headless-demo-namespace-created-by-this-lab"
echo "Current context: $(kubectl config current-context)"
if [ "$NS" != "headless-demo" ]; then echo "Safety check failed: unexpected namespace."; exit 2; fi
if ! kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "Namespace does not exist; nothing to clean."
  rm -f "$MARKER"
  exit 0
fi
echo "Resources currently in target namespace:"
kubectl get all -n "$NS" -o wide
kubectl get svc,endpointslice -n "$NS" 2>/dev/null || true
echo
echo "This script will delete only the specifically named lab Deployments and Services."
echo "It will NOT delete the namespace, shared DNS, controllers, nodes, or EKS cluster."
read -r -p "Type DELETE LAB RESOURCES to continue: " confirm
if [ "$confirm" != "DELETE LAB RESOURCES" ]; then echo "Cancelled; no resources deleted."; exit 1; fi
kubectl delete deployment headless-diagnostic headless-demo -n "$NS" --ignore-not-found
kubectl delete service backend-normal backend-headless -n "$NS" --ignore-not-found
echo "Resource-specific cleanup completed. Remaining resources:"
kubectl get all -n "$NS" -o wide || true
if [ -f "$MARKER" ]; then
  echo
  echo "The local marker says this script created the namespace, but namespace deletion is deliberately not automatic."
  echo "After reviewing remaining resources and confirming the namespace is dedicated and empty, delete it manually if desired:"
  echo "kubectl delete namespace headless-demo"
  echo "Do not run that command if any unrelated resources or shared use exist."
  rm -f "$MARKER"
else
  echo "No local creation marker found. Namespace deletion is not offered; inspect ownership and remaining resources manually."
fi
