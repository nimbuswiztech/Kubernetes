#!/usr/bin/env bash
set -u
NAMESPACE="headless-demo"
failures=0
echo "=== Read-only Kubernetes Headless Service lab environment check ==="
echo "Timestamp: $(date)"
echo
if ! command -v kubectl >/dev/null 2>&1; then
  echo "MISSING: kubectl is not installed or not on PATH."
  exit 1
fi
if command -v aws >/dev/null 2>&1; then
  echo "--- AWS identity (read-only) ---"
  aws sts get-caller-identity || echo "WARNING: AWS identity could not be verified (credentials/permissions/network)."
  echo "Configured default region: $(aws configure get region 2>/dev/null || true)"
else
  echo "WARNING: AWS CLI not found; Kubernetes checks will still be attempted."
fi
echo
echo "--- Current kubectl context (no context switch is performed) ---"
kubectl config current-context || { echo "ERROR: no current kubectl context."; exit 1; }
echo
echo "--- Cluster reachability ---"
if kubectl cluster-info; then
  echo "PASS: Kubernetes API is reachable."
else
  echo "FAIL: Kubernetes API is not reachable."
  failures=$((failures+1))
fi
echo
echo "--- Nodes ---"
if kubectl get nodes -o wide; then
  ready_nodes="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2=="Ready"{n++} END{print n+0}')"
  if [ "$ready_nodes" -ge 1 ]; then
    echo "PASS: $ready_nodes Ready node(s) found."
  else
    echo "FAIL: no Ready worker/control-plane nodes reported."
    failures=$((failures+1))
  fi
else
  echo "FAIL: unable to list nodes."
  failures=$((failures+1))
fi
echo
echo "--- Target namespace: $NAMESPACE (read-only inspection) ---"
if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "WARNING: namespace already exists. Review before applying anything."
  kubectl get all -n "$NAMESPACE" -o wide
  kubectl get svc,endpointslice -n "$NAMESPACE" 2>/dev/null || true
  echo "STOP: setup script intentionally refuses to reuse an existing namespace."
else
  echo "PASS: namespace does not currently exist."
  echo "Setup may be considered only after reviewing the remaining checks."
fi
echo
echo "--- Prerequisites ---"
for bin in kubectl; do command -v "$bin" >/dev/null 2>&1 || failures=$((failures+1)); done
echo "Container image access cannot be fully confirmed by this read-only check."
echo
if [ "$failures" -eq 0 ]; then
  echo "CHECK RESULT: basic read-only checks passed. This is not a guarantee that image pulls or resource creation will succeed."
else
  echo "CHECK RESULT: $failures check(s) failed. Resolve them before proceeding."
  exit 1
fi
