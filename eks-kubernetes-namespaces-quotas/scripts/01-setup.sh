#!/usr/bin/env bash
set -euo pipefail
LAB_NS="namespace-quota-demo"
if [[ "${1:-}" == "--help" ]]; then echo 'Usage: bash scripts/01-setup.sh'; exit 0; fi
command -v kubectl >/dev/null || { echo 'kubectl is required'; exit 2; }
CTX="$(kubectl config current-context)"
echo "Active kubectl context: $CTX"
echo "Target namespace: $LAB_NS"
read -r -p 'Type the target namespace exactly to continue: ' confirm
[[ "$confirm" == "$LAB_NS" ]] || { echo 'Confirmation mismatch; stopping.'; exit 3; }
if kubectl get ns "$LAB_NS" >/dev/null 2>&1; then
  echo "Namespace already exists. Refusing to assume ownership or overwrite unknown resources. Inspect it and use a reviewed reset if it is yours."; exit 4
fi
echo 'Previewing namespace manifest (client-side dry run):'
kubectl apply --dry-run=client -f manifests/00-namespaces.yaml
read -r -p 'Have you verified the context, account, region and capacity? Type APPLY to create lab resources: ' go
[[ "$go" == APPLY ]] || { echo 'Stopped without changes.'; exit 5; }
kubectl apply -f manifests/00-namespaces.yaml
kubectl apply -f manifests/01-frontend.yaml
kubectl apply -f manifests/02-backend.yaml
kubectl apply -f manifests/03-resource-quota.yaml
kubectl apply -f manifests/04-object-count-quota.yaml
kubectl apply -f manifests/05-limit-range.yaml
kubectl apply -f manifests/06-combined-scenario.yaml
printf '\nWaiting for Deployments (timeout is not a guarantee of successful scheduling):\n'
kubectl rollout status deployment/frontend -n "$LAB_NS" --timeout=120s || true
kubectl rollout status deployment/backend -n "$LAB_NS" --timeout=120s || true
kubectl get all,resourcequota,limitrange -n "$LAB_NS"
echo 'Setup commands completed. Review Pod events and quota status; do not assume all Pods are Running.'
