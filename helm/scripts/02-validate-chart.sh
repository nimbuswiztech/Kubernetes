#!/usr/bin/env bash
set -euo pipefail
command -v helm >/dev/null || { echo "Helm not found."; exit 1; }
echo "Linting canonical chart..."
helm lint ./charts/my-first-chart
echo "Rendering default manifests (no cluster changes)..."
helm template demo ./charts/my-first-chart -n helm-demo
echo "Rendering with two replicas (no cluster changes)..."
helm template demo ./charts/my-first-chart -n helm-demo --set replicaCount=2
