#!/usr/bin/env bash
set -Eeuo pipefail
echo "== Checking required commands =="
command -v kubectl >/dev/null || { echo "ERROR: kubectl is not installed or not on PATH." >&2; exit 1; }
command -v helm >/dev/null || { echo "ERROR: Helm is not installed or not on PATH." >&2; exit 1; }
echo
echo "== Current context =="
kubectl config current-context
echo
echo "== Cluster information =="
kubectl cluster-info
echo
echo "== Nodes =="
kubectl get nodes -o wide
echo
echo "If nodes are not Ready or the cluster is under resource pressure, investigate before installing."
