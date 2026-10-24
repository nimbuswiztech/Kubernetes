#!/usr/bin/env bash
set -uo pipefail
NS=autoscaling-demo
echo "Context: $(kubectl config current-context)"
kubectl get hpa -n "$NS" -o wide
kubectl describe hpa frontend-hpa -n "$NS"
kubectl get deploy,pods -n "$NS" -o wide
kubectl top pods -n "$NS" 2>&1 || true
kubectl get events -n "$NS" --sort-by=.lastTimestamp | tail -n 30
