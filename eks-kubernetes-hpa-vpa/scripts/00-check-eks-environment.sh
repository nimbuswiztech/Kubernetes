#!/usr/bin/env bash
# Read-only discovery: no resources are created or changed.
set -uo pipefail
command -v aws >/dev/null 2>&1 || { echo "ERROR: AWS CLI missing"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl missing"; exit 1; }
echo "=== AWS identity ==="; aws sts get-caller-identity || exit 1
REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
[[ -n "$REGION" ]] || { echo "Set AWS_REGION or configure a default region."; exit 1; }
echo "AWS region: $REGION"
echo "kubectl context: $(kubectl config current-context 2>/dev/null || echo unavailable)"
if [[ -z "${EKS_CLUSTER_NAME:-}" ]]; then
  echo "Accessible EKS clusters in $REGION:"
  aws eks list-clusters --region "$REGION" --output table || true
  echo 'Set EKS_CLUSTER_NAME explicitly if needed: export EKS_CLUSTER_NAME="cluster-name"'
else
  aws eks describe-cluster --name "$EKS_CLUSTER_NAME" --region "$REGION" --query 'cluster.{name:name,version:version,status:status}' --output table || true
fi
echo "=== API access ==="; kubectl cluster-info || { echo "Cannot reach API; check context/auth."; exit 1; }
echo "=== Nodes, labels, taints, capacity ==="
kubectl get nodes -o wide || true
kubectl get nodes -o custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,CPU_CAPACITY:.status.capacity.cpu,CPU_ALLOCATABLE:.status.allocatable.cpu,MEM_CAPACITY:.status.capacity.memory,MEM_ALLOCATABLE:.status.allocatable.memory,INSTANCE:.metadata.labels.node\.kubernetes\.io/instance-type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone' || true
kubectl describe nodes 2>/dev/null | grep -E '^(Name:|Taints:|Allocatable:|  cpu:|  memory:|Allocated resources:|  (cpu|memory) +requests)' || true
READY="$(kubectl get nodes -o jsonpath='{range .items[*]}{range .status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}{end}' 2>/dev/null | grep -cx True || true)"
echo "Ready nodes: ${READY:-0}"; [[ "${READY:-0}" -ge 2 ]] || echo "WARNING: fewer than two Ready nodes; stop live load test."
echo "=== Workloads and namespaces ==="; kubectl get ns; kubectl get deploy,statefulset,pods -A -o wide
echo "=== Autoscaling resources ==="; kubectl get hpa -A 2>&1 || true
kubectl get vpa -A 2>&1 || echo "VPA API unavailable or unauthorized."
kubectl api-resources 2>/dev/null | grep -i verticalpodautoscaler || echo "No VPA API resource found."
kubectl get crd 2>/dev/null | grep -i verticalpodautoscaler || echo "No VPA CRD found."
echo "=== Metrics ==="
kubectl get deployment -A 2>/dev/null | grep -i metrics-server || echo "Metrics Server Deployment not found by name."
kubectl get apiservices v1beta1.metrics.k8s.io 2>&1 || true
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes 2>&1 | head -c 1000 || true; echo
kubectl top nodes 2>&1 || echo "Metrics unavailable: diagnose before CPU HPA demo."
kubectl top pods -A 2>&1 | head -n 25 || true
echo "=== Requests and limits ==="
kubectl get pods -A -o custom-columns='NS:.metadata.namespace,POD:.metadata.name,NODE:.spec.nodeName,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory,CPU_LIMIT:.spec.containers[*].resources.limits.cpu,MEM_LIMIT:.spec.containers[*].resources.limits.memory' || true
echo "=== Lab namespace / quota ==="
if kubectl get ns autoscaling-demo >/dev/null 2>&1; then echo "WARNING: namespace exists; inspect ownership before proceeding."; kubectl get all,resourcequota,limitrange -n autoscaling-demo 2>&1 || true; else echo "autoscaling-demo does not exist."; fi
kubectl get resourcequota,limitrange -A 2>/dev/null || true
echo "Review node allocatable resources and existing requests manually. This script cannot guarantee schedulability."
echo "Read-only validation complete; no cluster state changed."
