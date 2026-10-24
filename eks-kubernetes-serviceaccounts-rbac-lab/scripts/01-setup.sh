#!/usr/bin/env bash
set -euo pipefail
LAB_NAMESPACE="${LAB_NAMESPACE:-rbac-demo}"
[[ "$LAB_NAMESPACE" == "rbac-demo" ]] || { echo "Refusing: LAB_NAMESPACE must be exactly rbac-demo."; exit 2; }
echo "Context: $(kubectl config current-context)"
kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}'; echo
if kubectl get namespace rbac-demo >/dev/null 2>&1; then
  echo "Namespace rbac-demo already exists. Do not assume it is lab-owned. Review it manually; setup stops to avoid touching unrelated resources."
  exit 3
fi
echo "This creates only namespace rbac-demo and lab-owned namespaced resources; no cluster-wide RBAC changes."
read -r -p "Type CREATE-RBAC-DEMO to continue: " confirm
[[ "$confirm" == "CREATE-RBAC-DEMO" ]] || { echo "Cancelled."; exit 1; }
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-serviceaccount.yaml
kubectl apply -f manifests/02-demo-pod.yaml
kubectl get namespace rbac-demo
kubectl get serviceaccount demo-reader -n rbac-demo
kubectl get pod demo-sleeper -n rbac-demo
echo "Next: run scripts/02-demo-serviceaccount.sh"
