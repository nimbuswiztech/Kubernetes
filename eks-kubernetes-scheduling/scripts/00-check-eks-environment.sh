#!/usr/bin/env bash
set -Eeuo pipefail
for bin in aws kubectl; do
  command -v "$bin" >/dev/null 2>&1 || { echo "ERROR: $bin is not installed or not in PATH" >&2; exit 1; }
done

echo '=== AWS identity ==='
aws sts get-caller-identity || { echo 'Check AWS credentials/profile.' >&2; exit 1; }
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null || true)}}"
echo "=== AWS region: ${REGION:-NOT CONFIGURED} ==="
echo '=== kubectl context ==='
CURRENT_CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
[[ -n "$CURRENT_CONTEXT" ]] || { echo 'No current kubectl context.' >&2; exit 1; }
echo "$CURRENT_CONTEXT"
CLUSTER="${EKS_CLUSTER_NAME:-}"
if [[ -z "$CLUSTER" ]]; then
  if [[ -n "$REGION" ]]; then
    echo '=== Accessible EKS clusters ==='
    aws eks list-clusters --region "$REGION" --output table || true
  else
    echo 'Set AWS_REGION, then run: aws eks list-clusters --region <region>'
  fi
  read -r -p 'Existing EKS cluster name (blank to stop): ' CLUSTER
fi
[[ -n "$CLUSTER" ]] || { echo 'Stopped without making changes.'; exit 2; }
if [[ -z "$REGION" ]]; then read -r -p 'AWS region: ' REGION; fi
export AWS_REGION="$REGION"
if [[ "$CURRENT_CONTEXT" != *"$CLUSTER"* ]]; then
  echo "WARNING: current kubectl context '$CURRENT_CONTEXT' does not visibly include cluster name '$CLUSTER'. Context names can be customized; verify the context target before proceeding. If needed, run: aws eks update-kubeconfig --name '$CLUSTER' --region '$REGION'"
fi
echo '=== EKS cluster details ==='
aws eks describe-cluster --name "$CLUSTER" --region "$REGION" --query 'cluster.{name:name,status:status,version:version,endpoint:endpoint,roleArn:roleArn}' --output table

echo '=== Kubernetes API access ==='
kubectl get --raw=/readyz >/dev/null && echo 'API readyz: OK' || { echo 'Cannot reach Kubernetes API. Check kubeconfig/network/access.' >&2; exit 1; }
echo '=== Nodes ==='
kubectl get nodes -o wide
NODE_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | awk '$2=="Ready" {n++} END {print n+0}')"
echo "Ready nodes: $NODE_COUNT"
echo '=== Node labels, taints, topology, capacity and allocatable ==='
kubectl get nodes -o custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,ZONE:.metadata.labels.topology\.kubernetes\.io/zone,HOSTNAME:.metadata.labels.kubernetes\.io/hostname,INSTANCE:.metadata.labels.node\.kubernetes\.io/instance-type,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,ALLOC_CPU:.status.allocatable.cpu,ALLOC_MEMORY:.status.allocatable.memory,TAINTS:.spec.taints'
for node in $(kubectl get nodes -o name); do
  echo "--- $node labels ---"; kubectl get "$node" --show-labels
  echo "--- $node taints / allocatable ---"; kubectl describe "$node" | sed -n '/Taints:/p;/Capacity:/,/Allocatable:/p;/Allocatable:/,/System Info:/p'
done
echo '=== Node group / compute hints (best effort) ==='
aws eks list-nodegroups --cluster-name "$CLUSTER" --region "$REGION" --output table || true
echo 'Note: self-managed nodes and EKS Fargate do not appear as managed node groups. Inspect node labels and AWS resources to confirm ownership.'
echo '=== Namespace ==='
kubectl get namespace scheduling-demo || echo 'scheduling-demo namespace does not exist yet.'
echo '=== Existing workloads and requested resources ==='
kubectl get pods -A -o wide
kubectl top nodes 2>/dev/null || echo 'Metrics API unavailable; use allocatable and describe output for capacity estimates.'
if (( NODE_COUNT < 2 )); then echo 'WARNING: fewer than two Ready nodes. Multi-node placement demonstrations may not work.'; fi
echo 'Capacity note: this script does not reserve capacity or change cluster state. Inspect node Allocatable, current requests, taints, and Pod events before applying lab workloads.'
echo 'Preflight complete. No cluster resources were changed.'
