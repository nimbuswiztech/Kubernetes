#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NS="daemonset-statefulset-demo"
echo "This creates a namespace and low-resource demo workloads in the current context:"
kubectl config current-context
if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "ERROR: namespace $NS already exists. Inspect it and use a fresh, approved lab namespace; this script will not reuse it." >&2
  exit 10
fi
echo "Review StorageClass availability before continuing:"
kubectl get storageclass -o wide || true
read -r -p "Type CREATE-LAB to create only namespace $NS and its lab resources: " answer
[[ "$answer" == "CREATE-LAB" ]] || { echo "Cancelled."; exit 0; }
kubectl apply -f "$ROOT/manifests/00-namespaces.yaml"
kubectl apply -f "$ROOT/manifests/01-daemonset-basic.yaml"
kubectl apply -f "$ROOT/manifests/05-headless-service.yaml"
kubectl apply -f "$ROOT/manifests/07-statefulset-volume-claims.yaml"
echo "Waiting briefly for controller progress. PVC binding depends on cluster storage configuration."
kubectl rollout status daemonset/node-observer -n "$NS" --timeout=120s || true
kubectl rollout status statefulset/ledger -n "$NS" --timeout=180s || true
kubectl get ds,sts,svc,pods,pvc -n "$NS" -o wide
echo "Setup applied. If PVCs or Pods are Pending, inspect events before changing anything."
