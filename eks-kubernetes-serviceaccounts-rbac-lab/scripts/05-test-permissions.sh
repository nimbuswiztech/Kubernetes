#!/usr/bin/env bash
set -u
echo "Current caller (not impersonated):"
kubectl auth can-i get pods -n rbac-demo
kubectl auth can-i list secrets -n rbac-demo
kubectl auth can-i get nodes
echo "Lab ServiceAccount (requires caller impersonation permission):"
for check in \
  "get pods -n rbac-demo" \
  "list pods -n rbac-demo" \
  "create pods -n rbac-demo" \
  "delete pods -n rbac-demo" \
  "list secrets -n rbac-demo" \
  "get pods/log -n rbac-demo" \
  "list configmaps -n rbac-demo" \
  "list configmaps -n default" \
  "get nodes"; do
  # shellcheck disable=SC2086
  printf '%-42s : ' "$check"
  # word splitting intentionally parses a fixed list of test commands
  kubectl auth can-i $check --as=system:serviceaccount:rbac-demo:demo-reader 2>&1 || true
done
echo "A 'yes' can come from any configured authorizer or another binding, not necessarily this lab's rule."
