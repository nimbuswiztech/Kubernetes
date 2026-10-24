#!/usr/bin/env bash
set -euo pipefail
echo "Before: predict whether demo-reader can list Pods. This script changes namespaced RBAC only."
kubectl apply -f manifests/03-role-pod-reader.yaml
echo "Role exists, but the lab binding has not yet been applied:"
kubectl auth can-i list pods -n rbac-demo --as=system:serviceaccount:rbac-demo:demo-reader || echo "Impersonation may be unavailable; inspect policy instead."
read -r -p "Type APPLY-NAMESPACED-BINDING to apply the lab RoleBinding: " confirm
[[ "$confirm" == "APPLY-NAMESPACED-BINDING" ]] || { echo "Role remains; binding not applied."; exit 1; }
kubectl apply -f manifests/04-rolebinding-pod-reader.yaml
kubectl describe role pod-reader -n rbac-demo
kubectl describe rolebinding pod-reader-binding -n rbac-demo
for action in "get pods" "list pods" "watch pods" "create pods" "delete pods" "list secrets" "get pods/log"; do
  set -- $action
  printf '%-22s ' "$action"
  kubectl auth can-i "$1" "$2" -n rbac-demo --as=system:serviceaccount:rbac-demo:demo-reader || true
done
echo "Expected from this RoleBinding alone: get/list/watch pods yes; create/delete pods, list secrets, and get pods/log no."
