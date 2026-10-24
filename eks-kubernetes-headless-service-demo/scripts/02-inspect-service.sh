#!/usr/bin/env bash
set -euo pipefail
NS="headless-demo"
echo "Current context: $(kubectl config current-context)"
kubectl get pods -n "$NS" -o wide --show-labels
kubectl get svc -n "$NS" -o wide
kubectl describe svc backend-headless -n "$NS"
kubectl get endpointslice -n "$NS" -o wide
echo "--- Legacy Endpoints view (introductory inspection only; EndpointSlices are the modern API) ---"
kubectl get endpoints backend-headless -n "$NS"
