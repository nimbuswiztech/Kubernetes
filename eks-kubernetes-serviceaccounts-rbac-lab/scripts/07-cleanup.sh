#!/usr/bin/env bash
set -euo pipefail
LAB_NAMESPACE="${LAB_NAMESPACE:-rbac-demo}"
[[ "$LAB_NAMESPACE" == "rbac-demo" ]] || { echo "Refusing: configured namespace must be exactly rbac-demo."; exit 2; }
echo "Active context: $(kubectl config current-context)"
echo -n "API server: "; kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}'; echo
echo "Target namespace: $LAB_NAMESPACE"
if ! kubectl get namespace rbac-demo >/dev/null 2>&1; then echo "Namespace not found or not visible; nothing to clean."; exit 0; fi
echo "Review lab-owned namespaced resources before cleanup:"
kubectl get serviceaccounts,roles,rolebindings,pods -n rbac-demo
echo "ClusterRole rbac-demo-configmap-reader is cluster-scoped and is NOT deleted by namespace deletion."
read -r -p "Type DELETE-RBAC-DEMO-NAMESPACE to delete the entire rbac-demo namespace and its contents: " confirm
[[ "$confirm" == "DELETE-RBAC-DEMO-NAMESPACE" ]] || { echo "Cancelled."; exit 1; }
kubectl delete namespace rbac-demo
echo "Namespace deletion requested. Verify completion:"
kubectl get namespace rbac-demo || true
echo
echo "Optional cleanup of lab-owned ClusterRole requires separate review."
if kubectl get clusterrole rbac-demo-configmap-reader >/dev/null 2>&1; then
  echo "Found clusterrole rbac-demo-configmap-reader. It may be referenced elsewhere; inspect before deletion."
  kubectl describe clusterrole rbac-demo-configmap-reader
  read -r -p "If and only if this exact object is lab-owned and unused, type DELETE-LAB-CONFIGMAP-CLUSTERROLE: " crconfirm
  if [[ "$crconfirm" == "DELETE-LAB-CONFIGMAP-CLUSTERROLE" ]]; then
    kubectl delete clusterrole rbac-demo-configmap-reader
  else echo "ClusterRole retained."; fi
fi
echo "Optional ClusterRoleBinding cleanup is separate and is never done by routine namespace cleanup."
if kubectl get clusterrolebinding rbac-demo-demo-reader-node-read >/dev/null 2>&1; then
  kubectl describe clusterrolebinding rbac-demo-demo-reader-node-read
  read -r -p "If this exact binding was created by your approved optional lab, type DELETE-EXACT-LAB-NODE-BINDING: " crbconfirm
  if [[ "$crbconfirm" == "DELETE-EXACT-LAB-NODE-BINDING" ]]; then
    kubectl delete clusterrolebinding rbac-demo-demo-reader-node-read
  else echo "ClusterRoleBinding retained."; fi
fi
if kubectl get clusterrole rbac-demo-node-reader >/dev/null 2>&1; then
  kubectl describe clusterrole rbac-demo-node-reader
  read -r -p "If this exact ClusterRole was created by your approved optional lab and has no other bindings, type DELETE-EXACT-LAB-NODE-ROLE: " node_role_confirm
  if [[ "$node_role_confirm" == "DELETE-EXACT-LAB-NODE-ROLE" ]]; then
    kubectl delete clusterrole rbac-demo-node-reader
  else echo "Optional node-reader ClusterRole retained."; fi
fi
echo "Never delete built-in ClusterRoles/ClusterRoleBindings or shared IAM/EKS access configuration."
