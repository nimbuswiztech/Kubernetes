#!/usr/bin/env bash
set -euo pipefail
NS="headless-demo"
echo "Current context: $(kubectl config current-context)"
echo "--- Request through normal ClusterIP Service ---"
kubectl exec -n "$NS" deploy/headless-diagnostic -- wget -qO- --timeout=5 http://backend-normal:8080/
echo
echo "--- Request using Headless Service DNS name ---"
kubectl exec -n "$NS" deploy/headless-diagnostic -- wget -qO- --timeout=5 http://backend-headless:8080/
echo
echo "--- Pod IPs for direct endpoint testing ---"
kubectl get pods -n "$NS" -l app=backend -o wide
echo "Copy one actual Pod IP from the output and run:"
echo "kubectl exec -n $NS deploy/headless-diagnostic -- wget -qO- --timeout=5 http://POD_IP:8080/"
echo "Replace POD_IP; do not type the literal placeholder."
