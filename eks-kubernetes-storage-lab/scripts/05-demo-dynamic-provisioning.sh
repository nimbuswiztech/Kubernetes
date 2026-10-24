#!/usr/bin/env bash
set -euo pipefail
NS=storage-demo
kubectl get namespace "$NS"
kubectl get storageclass -o custom-columns='NAME:.metadata.name,PROVISIONER:.provisioner,BINDING:.volumeBindingMode,RECLAIM:.reclaimPolicy,DEFAULT:.metadata.annotations.storageclass\.kubernetes\.io/is-default-class'
echo
echo "Review the selected class and its parameters before proceeding. A PVC may create billable backend storage."
read -r -p "Enter an existing validated StorageClass name (blank cancels): " SC
[[ -n "$SC" ]] || { echo "Cancelled."; exit 0; }
kubectl get storageclass "$SC" -o yaml
read -r -p "Have you approved possible cloud charges and confirmed this class is suitable? Type APPROVE: " approval
[[ "$approval" == "APPROVE" ]] || { echo "Cancelled."; exit 0; }
export STORAGE_CLASS_NAME="$SC"
sed "s/__STORAGE_CLASS_NAME__/${STORAGE_CLASS_NAME}/g" manifests/07-dynamic-pvc.yaml | kubectl apply -f -
kubectl get pvc -n "$NS" -w
