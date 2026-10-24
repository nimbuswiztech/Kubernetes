#!/usr/bin/env bash
set -euo pipefail
echo "Standard namespaced-reuse demonstration. Creates a ClusterRole definition (cluster-scoped object) and a RoleBinding in rbac-demo."
echo "This changes a cluster-scoped object definition but does NOT grant it cluster-wide; confirm the name is unused and instructor has approval."
if kubectl get clusterrole rbac-demo-configmap-reader >/dev/null 2>&1; then
  echo "ClusterRole name already exists. Stop and inspect ownership; refusing to overwrite."; exit 3
fi
read -r -p "Type CREATE-LAB-CLUSTERROLE to create this narrowly scoped ClusterRole: " confirm
[[ "$confirm" == "CREATE-LAB-CLUSTERROLE" ]] || { echo "Cancelled."; exit 1; }
kubectl apply -f manifests/05-role-configmap-reader.yaml
kubectl apply -f manifests/06-rolebinding-configmap-reader.yaml
kubectl describe clusterrole rbac-demo-configmap-reader
kubectl describe rolebinding configmap-reader-binding -n rbac-demo
echo "Expected from this binding alone: ConfigMaps readable in rbac-demo, not in other namespaces."
kubectl auth can-i list configmaps -n rbac-demo --as=system:serviceaccount:rbac-demo:demo-reader || true
kubectl auth can-i list configmaps -n default --as=system:serviceaccount:rbac-demo:demo-reader || true
echo
echo "OPTIONAL CLUSTERROLEBINDING extension is NOT run here."
echo "If explicitly approved, review manifests/09-clusterrolebinding-read-nodes-optional.yaml and use the separate gated procedure in TRAINER-GUIDE.md."
