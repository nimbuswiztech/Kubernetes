#!/usr/bin/env bash
set -uo pipefail
LAB_NS="namespace-quota-demo"
fail=0
printf '\n=== READ-ONLY EKS LAB PREFLIGHT ===\n'
printf 'Timestamp: '; date -Is 2>/dev/null || date
for bin in aws kubectl; do
  if command -v "$bin" >/dev/null 2>&1; then printf '[OK] %s: %s\n' "$bin" "$(command -v "$bin")"; else printf '[MISSING] %s is not installed\n' "$bin"; fail=1; fi
done
if (( fail )); then echo 'Install missing tools, then rerun. No cluster changes were made.'; exit 2; fi
printf '\n--- AWS identity ---\n'
aws sts get-caller-identity || { echo '[ERROR] AWS identity lookup failed. Check profile/credentials.'; exit 3; }
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null || true)}}"
if [[ -z "$REGION" ]]; then
  echo '[WARN] No AWS region configured. Set AWS_REGION, e.g. export AWS_REGION=ap-south-1 after verifying the correct region.'
else printf 'AWS region: %s\n' "$REGION"; fi
printf '\n--- kubectl context ---\n'
CTX="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "$CTX" ]]; then echo '[ERROR] No current kubectl context.'; exit 4; fi
printf 'Current context: %s\n' "$CTX"
printf 'Server: '; kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null; echo
printf '\n--- EKS cluster discovery ---\n'
CLUSTER="${EKS_CLUSTER_NAME:-}"
if [[ -n "$CLUSTER" && -n "$REGION" ]]; then
  aws eks describe-cluster --name "$CLUSTER" --region "$REGION" --query 'cluster.{name:name,status:status,version:version,endpoint:endpoint}' --output table || echo '[WARN] Could not describe configured EKS cluster; verify cluster name, region and IAM permissions.'
else
  echo 'EKS_CLUSTER_NAME is not set or region is unknown. Accessible clusters (if any):'
  if [[ -n "$REGION" ]]; then aws eks list-clusters --region "$REGION" --output table || echo '[WARN] Could not list EKS clusters.'; else echo 'Set AWS_REGION first, then run: aws eks list-clusters --region "$AWS_REGION"'; fi
fi
printf '\n--- API access ---\n'
kubectl get --raw=/version 2>&1 || { echo '[ERROR] Kubernetes API not reachable/authorized. No changes made.'; exit 5; }
printf '\n--- Nodes (read-only) ---\n'
kubectl get nodes -o wide || { echo '[ERROR] Unable to list nodes.'; exit 6; }
printf '\nNode capacity and allocatable (actual values from API):\n'
kubectl get nodes -o custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,CPU_CAPACITY:.status.capacity.cpu,CPU_ALLOCATABLE:.status.allocatable.cpu,MEM_CAPACITY:.status.capacity.memory,MEM_ALLOCATABLE:.status.allocatable.memory'
printf '\nNode labels:\n'; kubectl get nodes --show-labels
printf '\nNode taints:\n'; kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
ready="$(kubectl get nodes -o jsonpath='{range .items[*]}{range .status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}{end}' 2>/dev/null | grep -c '^True$' || true)"
if (( ready < 2 )); then echo "[WARN] Only $ready Ready nodes found; lab assumes two existing worker nodes. Do not create/modify nodes for this lab."; else echo "[OK] $ready Ready nodes found."; fi
printf '\n--- Namespaces and existing policies ---\n'
kubectl get namespaces
kubectl get resourcequota -A 2>&1 || true
kubectl get limitrange -A 2>&1 || true
printf '\n--- Existing Pods and declared resource requests/limits ---\n'
kubectl get pods -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,PHASE:.status.phase,NODE:.spec.nodeName,CONTAINERS:.spec.containers[*].name,REQUESTS_CPU:.spec.containers[*].resources.requests.cpu,REQUESTS_MEM:.spec.containers[*].resources.requests.memory,LIMITS_CPU:.spec.containers[*].resources.limits.cpu,LIMITS_MEM:.spec.containers[*].resources.limits.memory' 2>&1 || true
printf '\n--- Lab namespace ---\n'
if kubectl get namespace "$LAB_NS" >/dev/null 2>&1; then
  echo "[WARN] $LAB_NS already exists. Inspect ownership and all contents; setup will not delete it."
  kubectl get all,resourcequota,limitrange,configmap,secret -n "$LAB_NS" 2>&1 || true
else echo "[OK] $LAB_NS does not exist."; fi
printf '\n--- Capacity estimate / caveats ---\n'
echo 'Lab baseline declared requests are approximately 200m CPU and 128Mi memory for frontend/backend Pods; optional defaulted Pod adds LimitRange defaults (typically 100m/128Mi request).'
echo 'This is only a rough declared-request estimate. Existing requests, DaemonSets, system reservations, affinity, taints, topology and transient usage affect placement.'
echo 'For a cluster-wide view, inspect: kubectl describe nodes; kubectl get pods -A -o wide; kubectl top nodes (if metrics API exists).'
echo 'The script is read-only. No resources, IAM settings, node groups or cluster configuration were changed.'
