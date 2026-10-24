#!/usr/bin/env bash
set -euo pipefail
TARGET_NS="ingress-demo"
echo "Current context: $(kubectl config current-context)"
echo "This creates namespaced lab resources in ${TARGET_NS}; it does not install an Ingress Controller."
if kubectl get namespace "$TARGET_NS" >/dev/null 2>&1; then
  echo "Namespace already exists. Listing resources; inspect ownership before continuing:"
  kubectl get all,configmap,ingress -n "$TARGET_NS" || true
  echo "If this namespace contains anything not owned by this lab, stop now."
  read -r -p "Type ingress-demo to confirm this namespace is dedicated to this lab: " answer
  [[ "$answer" == "$TARGET_NS" ]] || { echo "Cancelled."; exit 1; }
else
  read -r -p "Type ingress-demo to create the dedicated namespace and demo apps: " answer
  [[ "$answer" == "$TARGET_NS" ]] || { echo "Cancelled."; exit 1; }
  kubectl apply -f manifests/00-namespace.yaml
fi
kubectl apply -f manifests/01-demo-apps.yaml
kubectl apply -f manifests/02-services.yaml
kubectl rollout status deployment/frontend -n "$TARGET_NS" --timeout=120s
kubectl rollout status deployment/catalog -n "$TARGET_NS" --timeout=120s
kubectl get pods,svc -n "$TARGET_NS" -o wide
echo "Demo apps are ready. No Ingress or AWS load balancer was created."
