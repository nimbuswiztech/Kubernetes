#!/usr/bin/env bash
set -euo pipefail
NS="daemonset-statefulset-demo"
echo "This deletes the dedicated lab namespace and its namespaced resources."
echo "It does NOT explicitly delete PersistentVolumes or StorageClasses."
if ! kubectl get namespace "$NS" >/dev/null 2>&1; then echo "Namespace $NS does not exist; nothing to do."; exit 0; fi
echo "Current lab resources:"
kubectl get all,pvc -n "$NS" -o wide || true
echo "Bound PVs and reclaim policies for lab claims (inspect before proceeding):"
for pvc in $(kubectl get pvc -n "$NS" -o name 2>/dev/null || true); do
  kubectl get "$pvc" -n "$NS" -o jsonpath='{.metadata.name}{" -> "}{.spec.volumeName}{"\n"}' || true
done
echo "Deleting the namespace removes namespaced objects. PVC/PV outcomes depend on retention and reclaim policy."
read -r -p "Type DELETE-LAB to delete namespace $NS: " answer
[[ "$answer" == "DELETE-LAB" ]] || { echo "Cancelled."; exit 0; }
kubectl delete namespace "$NS"
echo "Namespace deletion requested. Watch termination with: kubectl get namespace $NS"
echo "Do not delete PVs manually without confirming ownership, reclaim policy, and data-retention requirements."
