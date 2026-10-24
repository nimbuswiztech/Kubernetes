#!/usr/bin/env bash
set -euo pipefail
LAB_NS="namespace-quota-demo"
CTX="$(kubectl config current-context)"
echo "Active kubectl context: $CTX"
echo "This script may delete ONLY namespace: $LAB_NS"
echo 'Current namespace contents:'
kubectl get all,resourcequota,limitrange,configmap,secret -n "$LAB_NS" 2>&1 || true
read -r -p 'Type the namespace name to confirm target: ' target
[[ "$target" == "$LAB_NS" ]] || { echo 'Target mismatch; refusing.'; exit 3; }
read -r -p "Type DELETE $LAB_NS to remove the namespace and all namespaced objects inside it: " confirm
[[ "$confirm" == "DELETE $LAB_NS" ]] || { echo 'Confirmation mismatch; refusing.'; exit 4; }
kubectl delete namespace "$LAB_NS" --wait=true --timeout=120s
if kubectl get namespace "$LAB_NS" >/dev/null 2>&1; then echo "Namespace still exists; inspect deletion status/finalizers. Do not strip finalizers blindly."; exit 5; else echo "Verified: $LAB_NS no longer exists."; fi
echo 'No nodes, node groups, IAM configuration, shared namespaces or cluster-scoped resources were deleted.'
