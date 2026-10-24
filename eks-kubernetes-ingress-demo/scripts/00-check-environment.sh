#!/usr/bin/env bash
set -u
echo "=== Read-only EKS / Kubernetes environment check ==="
echo "No resources will be created or modified by this script."
echo
if command -v aws >/dev/null 2>&1; then
  echo "--- AWS identity ---"
  aws sts get-caller-identity 2>&1 || echo "WARNING: AWS identity check failed; verify AWS credentials/profile."
  echo "--- AWS configured region ---"
  aws configure get region 2>&1 || true
else
  echo "WARNING: AWS CLI not found; skipping AWS identity/region."
fi
if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl not found. Install/configure kubectl before proceeding."
  exit 2
fi
echo
echo "--- Current kubectl context ---"
kubectl config current-context 2>&1 || { echo "ERROR: no current context"; exit 2; }
echo "--- Cluster connectivity ---"
kubectl cluster-info 2>&1 || echo "WARNING: cluster-info failed; verify context, network, and IAM access."
echo "--- Nodes and Ready condition ---"
kubectl get nodes -o wide 2>&1 || echo "WARNING: unable to list nodes."
READY_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 ~ /Ready/ {n++} END {print n+0}')"
echo "Ready node count: ${READY_COUNT:-unknown}"
if [ "${READY_COUNT:-0}" -lt 1 ]; then echo "WARNING: no Ready worker/control-plane nodes were detected."; fi
echo
echo "--- Namespace ingress-demo ---"
if kubectl get namespace ingress-demo >/dev/null 2>&1; then
  echo "Namespace exists. Inspect its contents before using it:"
  kubectl get all,configmap,ingress -n ingress-demo 2>&1 || true
else
  echo "Namespace ingress-demo does not exist (safe to create only after approval)."
fi
echo
echo "--- Existing Ingress resources ---"
kubectl get ingress -A -o wide 2>&1 || echo "No Ingress list available."
echo "--- IngressClasses ---"
kubectl get ingressclass -o wide 2>&1 || echo "No IngressClass list available."
echo "--- Services ---"
kubectl get svc -A 2>&1 | head -n 80 || true
echo "--- Pods whose names may indicate a controller (clue only; not proof) ---"
kubectl get pods -A -o wide 2>&1 | grep -Ei 'NAMESPACE|ingress|alb|nginx|traefik|haproxy|gateway' || true
echo
echo "=== Readiness summary ==="
echo "Confirm with the cluster owner whether a compatible controller and class are installed."
echo "Do not install a controller automatically. An AWS-backed Ingress may incur charges."
echo "Preflight complete; review all warnings before any apply command."
