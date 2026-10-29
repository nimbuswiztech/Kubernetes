#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
NAMESPACE="monitoring"
RELEASE="prometheus"
CHART="prometheus-community/kube-prometheus-stack"
CHART_VERSION="92.11.0"

command -v kubectl >/dev/null || { echo "ERROR: kubectl is required." >&2; exit 1; }
command -v helm >/dev/null || { echo "ERROR: Helm is required." >&2; exit 1; }
kubectl cluster-info >/dev/null
echo "Using Kubernetes context: $(kubectl config current-context)"
echo "Checking whether Helm release '$RELEASE' already exists in namespace '$NAMESPACE'..."
if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "ERROR: Helm release '$RELEASE' already exists in namespace '$NAMESPACE'."
  echo "Inspect it with: helm status $RELEASE -n $NAMESPACE"
  echo "This script will not replace or upgrade an existing release automatically."
  exit 2
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
if ! helm show chart "$CHART" --version "$CHART_VERSION" >/dev/null 2>&1; then
  echo "ERROR: Chart version $CHART_VERSION is not available from the configured repository." >&2
  echo "Available versions: helm search repo $CHART --versions" >&2
  echo "Review compatibility, then update CHART_VERSION in this script." >&2
  exit 1
fi

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"
echo "Installing $CHART version $CHART_VERSION..."
helm install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --values "$PROJECT_DIR/helm/prometheus-values.yaml" \
  --values "$PROJECT_DIR/helm/grafana-values.yaml" \
  --wait --timeout 10m

echo "Waiting for monitoring Pods to become ready..."
kubectl wait --for=condition=Ready pod --all -n "$NAMESPACE" --timeout=10m
echo "Installation complete."
helm status "$RELEASE" -n "$NAMESPACE"
kubectl get pods,svc -n "$NAMESPACE"
