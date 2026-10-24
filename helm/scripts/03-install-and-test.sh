#!/usr/bin/env bash
set -euo pipefail
NS="helm-demo"
REL="demo"
CHART="./charts/my-first-chart"
echo "Current context:"
kubectl config current-context
echo "Nodes:"
kubectl get nodes
echo "Existing release check:"
helm list -n "$NS"
if helm status "$REL" -n "$NS" >/dev/null 2>&1; then
  echo "Release $REL already exists in $NS. Inspect it or use the upgrade script; refusing to install over it."
  exit 1
fi
helm lint "$CHART"
helm template "$REL" "$CHART" -n "$NS" >/tmp/helm-basics-rendered.yaml
echo "Rendered manifests saved to /tmp/helm-basics-rendered.yaml"
read -r -p "Install release '$REL' into namespace '$NS' on the current context? Type YES to continue: " confirm
[ "$confirm" = "YES" ] || { echo "Cancelled."; exit 0; }
helm install "$REL" "$CHART" -n "$NS" --create-namespace
helm status "$REL" -n "$NS"
kubectl get deployments,pods,services -n "$NS"
