#!/usr/bin/env bash
set -u
echo "=== Helm Basics: read-only environment check ==="
missing=0
check_cmd() { if command -v "$1" >/dev/null 2>&1; then printf '[OK] %s: ' "$1"; "$@" 2>&1 | head -n 2; else echo "[MISSING] $1 not found"; missing=1; fi; }
check_cmd helm version --short
check_cmd kubectl version --client
check_cmd aws --version
echo
if command -v kubectl >/dev/null 2>&1; then
  echo "--- Current kubectl context (read-only) ---"
  kubectl config current-context || echo "[WARN] No current kubectl context"
  echo "--- Nodes (read-only) ---"
  kubectl get nodes -o wide || echo "[WARN] Could not list nodes; check context and authentication"
  echo "--- Lab namespace (read-only) ---"
  kubectl get namespace helm-demo || echo "[INFO] Namespace helm-demo does not exist yet"
  echo "--- Existing releases in lab namespace (read-only) ---"
  helm list -n helm-demo 2>/dev/null || echo "[INFO] Could not list releases (Helm missing, namespace absent, or access issue)"
else
  echo "[INFO] Install/configure kubectl before cluster checks."
fi
if command -v aws >/dev/null 2>&1; then
  echo "--- AWS identity and region (read-only) ---"
  aws sts get-caller-identity || echo "[WARN] AWS identity check failed; configure credentials if using EKS"
  aws configure get region || echo "[INFO] No default AWS region configured"
fi
echo
if [ "$missing" -eq 0 ]; then
  echo "CLI presence check passed. Review the output above and confirm the context, EKS access, and a Ready worker node before deploying."
else
  echo "One or more required CLIs are missing. See README.md for manual installation instructions."
fi
echo "This script is read-only: it does not install tools, change context, create namespaces, or modify cluster resources."
