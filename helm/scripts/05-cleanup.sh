#!/usr/bin/env bash
set -euo pipefail
NS="helm-demo"; REL="demo"
echo "=== SAFE CLEANUP: this targets only Helm release '$REL' in namespace '$NS' ==="
echo "Current kubectl context:"
kubectl config current-context
echo "Namespace:"
kubectl get namespace "$NS" || { echo "Namespace not found; nothing to clean."; exit 0; }
echo "Helm releases:"
helm list -n "$NS"
echo "Lab resources (review carefully):"
kubectl get deployments,pods,services -n "$NS"
helm status "$REL" -n "$NS" || { echo "Release '$REL' not found in '$NS'; refusing to uninstall anything."; exit 0; }
echo
echo "This will uninstall only release '$REL' in namespace '$NS'. It will NOT delete the namespace."
read -r -p "Type exactly 'UNINSTALL demo FROM helm-demo' to continue: " confirm
[ "$confirm" = "UNINSTALL demo FROM helm-demo" ] || { echo "Cancelled; no changes made."; exit 0; }
helm uninstall "$REL" -n "$NS"
echo "Remaining releases:"
helm list -n "$NS"
echo "Remaining resources in namespace (may include resources not owned by this release):"
kubectl get deployments,pods,services -n "$NS" || true
echo "No namespace deletion was performed. Review any remaining/shared resources manually."
