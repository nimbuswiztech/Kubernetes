#!/usr/bin/env bash
set -Eeuo pipefail
NAMESPACE="monitoring"
RELEASE="prometheus"
DEMO_NAMESPACE="monitoring-demo"

echo "This removes Helm release '$RELEASE' from namespace '$NAMESPACE' (if present)"
echo "and deletes namespace '$DEMO_NAMESPACE' (if present)."
echo "It does NOT delete cluster-scoped CRDs."
read -r -p "Type DELETE-DEMO to continue: " CONFIRM
if [[ "$CONFIRM" != "DELETE-DEMO" ]]; then
  echo "Cancelled; no resources were removed."
  exit 0
fi

if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  helm uninstall "$RELEASE" -n "$NAMESPACE"
else
  echo "Helm release '$RELEASE' not found; skipping uninstall."
fi

if kubectl get namespace "$DEMO_NAMESPACE" >/dev/null 2>&1; then
  kubectl delete namespace "$DEMO_NAMESPACE" --wait=true
else
  echo "Namespace '$DEMO_NAMESPACE' not found; skipping."
fi

echo
echo "Monitoring namespace '$NAMESPACE' is intentionally not deleted automatically."
echo "Review its remaining resources before deleting it. Do not delete it if other workloads use it."
echo "CRDs are retained intentionally because other releases may use them."
