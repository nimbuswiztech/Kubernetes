#!/usr/bin/env bash
set -euo pipefail
NS=autoscaling-demo
echo "Context: $(kubectl config current-context)"
if kubectl get ns "$NS" >/dev/null 2>&1; then echo "Refusing: namespace already exists; inspect ownership."; exit 1; fi
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes >/dev/null 2>&1 || { echo "Metrics API unavailable; no resources created."; exit 1; }
read -r -p "Type CREATE-autoscaling-demo to continue: " OK
[[ "$OK" == "CREATE-autoscaling-demo" ]] || { echo Cancelled; exit 1; }
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-frontend-deployment.yaml
kubectl apply -f manifests/02-backend-deployment.yaml
kubectl apply -f manifests/03-hpa-cpu.yaml
kubectl rollout status deploy/frontend -n "$NS" --timeout=120s || true
kubectl rollout status deploy/backend -n "$NS" --timeout=120s || true
kubectl get deploy,pods,hpa -n "$NS" -o wide
echo "Load generator has not been started."
