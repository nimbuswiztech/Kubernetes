#!/usr/bin/env bash
set -euo pipefail
TARGET_NS="ingress-demo"
echo "Current kubectl context:"
kubectl config current-context
echo
if [[ "$TARGET_NS" != "ingress-demo" ]]; then
  echo "Safety check failed: target namespace is not exactly ingress-demo."
  exit 2
fi
if ! kubectl get namespace "$TARGET_NS" >/dev/null 2>&1; then
  echo "Namespace ${TARGET_NS} does not exist; nothing to clean."
  exit 0
fi
echo "Resources currently in ${TARGET_NS}:"
kubectl get all,configmap,ingress,ingressclass -n "$TARGET_NS" 2>&1 || true
echo
echo "WARNING: deleting an AWS-backed Ingress may trigger AWS resource cleanup; cleanup timing and charges depend on the controller."
echo "This script will delete ONLY namespace ${TARGET_NS}, including everything in it."
echo "Do NOT continue if the namespace contains unrelated resources."
read -r -p "Type ingress-demo to confirm deletion of this dedicated lab namespace: " answer
[[ "$answer" == "$TARGET_NS" ]] || { echo "Cancelled; no resources deleted."; exit 1; }
kubectl delete namespace "$TARGET_NS" --wait=true
echo "Verifying namespace removal..."
if kubectl get namespace "$TARGET_NS" >/dev/null 2>&1; then
  echo "Namespace still exists. Do not force-delete or remove finalizers; ask the cluster administrator to investigate."
  exit 1
fi
echo "Cleanup verified. Shared controllers, IngressClasses, and resources outside ${TARGET_NS} were not targeted."
