#!/usr/bin/env bash
set -euo pipefail
NS="${LAB_NAMESPACE:-storage-demo}"
[[ "$NS" == "storage-demo" ]] || { echo "Refusing: configured namespace must be exactly storage-demo"; exit 2; }
echo "Current kubectl context: $(kubectl config current-context)"
echo "Target namespace: $NS"
kubectl get namespace "$NS"
echo "-- Namespaced lab resources --"
kubectl get pods,deployments,statefulsets,pvc -n "$NS" -o wide || true
echo "-- All PVs (cluster-scoped; inventory only) --"
kubectl get pv -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,CLAIM_NS:.spec.claimRef.namespace,CLAIM:.spec.claimRef.name,RECLAIM:.spec.persistentVolumeReclaimPolicy,SC:.spec.storageClassName' || true
echo "-- For each lab PVC, inspect its bound PV reclaim policy before deletion --"
for claim in $(kubectl get pvc -n "$NS" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null); do
  pv="$(kubectl get pvc "$claim" -n "$NS" -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)"
  echo "PVC=$claim PV=${pv:-<unbound>}"
  if [[ -n "$pv" ]]; then
    kubectl get pv "$pv" -o custom-columns='NAME:.metadata.name,RECLAIM:.spec.persistentVolumeReclaimPolicy,PHASE:.status.phase,CLAIM:.spec.claimRef.name'
    echo "WARNING: Delete reclaim policy may delete backend storage. Retain still requires manual handling."
  fi
done
read -r -p "Delete ONLY namespaced resources in storage-demo? PVC deletion can delete backend storage. Type DELETE-LAB: " answer
[[ "$answer" == "DELETE-LAB" ]] || { echo "Cancelled; no changes made."; exit 0; }
kubectl delete deployment,statefulset,pod --all -n "$NS" --wait=true || true
kubectl delete pvc --all -n "$NS" --wait=true || true
echo "Inspect PVs after PVC deletion; do not delete PVs automatically:"
kubectl get pv -o wide || true
echo "Namespace is intentionally retained. To delete it, review its contents first and separately run: kubectl delete namespace storage-demo"
echo "Any PV in Released/Retain needs an administrator-reviewed recovery or retirement plan. Do not remove finalizers blindly."
