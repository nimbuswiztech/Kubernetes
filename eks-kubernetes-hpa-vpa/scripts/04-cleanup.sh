#!/usr/bin/env bash
set -euo pipefail
NS=autoscaling-demo
echo "Context: $(kubectl config current-context)"
echo "Target namespace: $NS"
[[ "$NS" == autoscaling-demo ]] || { echo "Refused: only autoscaling-demo is allowed."; exit 1; }
kubectl get ns "$NS" >/dev/null 2>&1 || { echo "Nothing to clean."; exit 0; }
kubectl get all,resourcequota,limitrange -n "$NS" 2>&1 || true
echo "This deletes only the lab namespace and its namespaced resources; shared Metrics Server/VPA and nodes remain."
read -r -p "Type DELETE-autoscaling-demo to continue: " OK
[[ "$OK" == "DELETE-autoscaling-demo" ]] || { echo Cancelled; exit 1; }
kubectl delete job hpa-load -n "$NS" --ignore-not-found=true --wait=true
kubectl delete namespace "$NS" --wait=true
kubectl get ns "$NS" >/dev/null 2>&1 && { echo "Namespace still exists."; exit 1; } || true
echo "Cleanup verified."
