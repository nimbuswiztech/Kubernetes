#!/usr/bin/env bash
set -Eeuo pipefail
NAMESPACE="monitoring"
command -v kubectl >/dev/null || { echo "ERROR: kubectl is required." >&2; exit 1; }
echo "Services in namespace '$NAMESPACE':"
kubectl get svc -n "$NAMESPACE"
echo
echo "Use the actual service names shown above. Common commands (verify names first):"
echo "  Prometheus: kubectl -n monitoring port-forward svc/prometheus-operated 9090:9090"
echo "  Grafana:    kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80"
echo
echo "Then open http://localhost:9090 and http://localhost:3000 respectively."
echo "Run each port-forward command in its own terminal and stop it with Ctrl+C."
echo "If the common service name is absent, select the matching service from 'kubectl get svc -n monitoring'."
echo
echo "Grafana password: inspect the Secret list and retrieve the correct admin-password key without sharing it:"
echo "  kubectl get secrets -n monitoring"
echo "  kubectl get secret -n monitoring <grafana-secret-name> -o jsonpath='{.data.admin-password}' | base64 --decode; echo"
