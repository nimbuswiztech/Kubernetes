#!/usr/bin/env bash
set -euo pipefail
NS="${LAB_NAMESPACE:-storage-demo}"
[[ "$NS" == "storage-demo" ]] || { echo "Refusing: LAB_NAMESPACE must be exactly storage-demo"; exit 2; }
kubectl config current-context
echo "Target namespace: $NS"
if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "Namespace already exists. No changes made. Inspect it first: kubectl get all,pvc -n $NS"
  exit 1
fi
read -r -p "Create the isolated namespace storage-demo? Type CREATE: " answer
[[ "$answer" == "CREATE" ]] || { echo "Cancelled."; exit 1; }
kubectl apply -f manifests/00-namespace.yaml
kubectl get namespace "$NS"
