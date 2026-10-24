#!/usr/bin/env bash
set -euo pipefail
NS="helm-demo"; REL="demo"; CHART="./charts/my-first-chart"
kubectl config current-context
helm status "$REL" -n "$NS"
echo "Preview change to 2 replicas before applying:"
helm template "$REL" "$CHART" -n "$NS" --set replicaCount=2
read -r -p "Upgrade release '$REL' in namespace '$NS' to 2 replicas on the current context? Type YES: " confirm
[ "$confirm" = "YES" ] || { echo "Cancelled."; exit 0; }
helm upgrade "$REL" "$CHART" -n "$NS" --set replicaCount=2
helm status "$REL" -n "$NS"
kubectl get deployments,pods -n "$NS"
helm get values "$REL" -n "$NS"
