#!/usr/bin/env bash
set -Eeuo pipefail
echo "== Helm releases =="
helm list -n monitoring || true
echo
echo "== Monitoring resources =="
kubectl get pods,svc -n monitoring
echo
echo "== Monitoring Pod readiness =="
kubectl get pods -n monitoring
echo
echo "== Demo app resources (if deployed) =="
if kubectl get namespace monitoring-demo >/dev/null 2>&1; then
  kubectl get deploy,pods,svc -n monitoring-demo
  kubectl rollout status deployment/demo-web -n monitoring-demo --timeout=60s
else
  echo "Namespace monitoring-demo does not exist yet."
fi
echo
echo "Readiness is not a guarantee that every Prometheus target or dashboard query has data. Check Prometheus Status > Targets."
