#!/usr/bin/env bash
set -euo pipefail
NS="headless-demo"
echo "Current context: $(kubectl config current-context)"
echo "--- Verify diagnostic Pod ---"
kubectl get pods -n "$NS" -l app=headless-diagnostic -o wide
echo "--- Check available utilities ---"
kubectl exec -n "$NS" deploy/headless-diagnostic -- sh -c 'command -v nslookup; command -v wget'
echo "--- Short DNS name ---"
kubectl exec -n "$NS" deploy/headless-diagnostic -- nslookup backend-headless
echo "--- Fully qualified DNS name (cluster domain may differ from cluster.local) ---"
kubectl exec -n "$NS" deploy/headless-diagnostic -- nslookup backend-headless.headless-demo.svc.cluster.local
echo "--- Compare with Pod IPs ---"
kubectl get pods -n "$NS" -o wide
