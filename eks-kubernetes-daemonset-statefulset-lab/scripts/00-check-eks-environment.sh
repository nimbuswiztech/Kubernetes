#!/usr/bin/env bash
set -uo pipefail

NS="${LAB_NAMESPACE:-daemonset-statefulset-demo}"
echo "=== Read-only EKS environment preflight ==="
for cmd in aws kubectl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command '$cmd' not found." >&2
    exit 2
  fi
done
aws --version
kubectl version --client

echo
echo "=== AWS identity ==="
aws sts get-caller-identity || { echo "ERROR: AWS identity unavailable; check profile/credentials."; exit 3; }

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
if [[ -z "$REGION" ]]; then
  REGION="$(aws configure get region 2>/dev/null || true)"
fi
if [[ -z "$REGION" ]]; then
  echo "No region found in AWS_REGION, AWS_DEFAULT_REGION, or AWS CLI config."
  read -r -p "Enter AWS region for this inspection (e.g. ap-south-1): " REGION
fi
if [[ -z "$REGION" ]]; then echo "ERROR: region is required."; exit 4; fi
export AWS_REGION="$REGION"
echo "AWS region: $REGION"
echo "kubectl context: $(kubectl config current-context 2>/dev/null || echo '<unavailable>')"

CLUSTER="${EKS_CLUSTER_NAME:-}"
if [[ -z "$CLUSTER" ]]; then
  echo
  echo "EKS_CLUSTER_NAME is not set. Accessible clusters in $REGION:"
  aws eks list-clusters --region "$REGION" --output table || true
  read -r -p "Enter the intended EKS cluster name (blank to stop): " CLUSTER
fi
if [[ -z "$CLUSTER" ]]; then
  echo "Stopped without changes. Set EKS_CLUSTER_NAME or rerun and enter the intended cluster."
  exit 0
fi
export EKS_CLUSTER_NAME="$CLUSTER"
echo
echo "=== EKS cluster ==="
aws eks describe-cluster --name "$CLUSTER" --region "$REGION" \
  --query 'cluster.{name:name,status:status,version:version,endpoint:endpoint,platformVersion:platformVersion}' --output table ||
  { echo "ERROR: cannot describe cluster; verify name, region, and IAM permissions."; exit 5; }

echo
echo "=== Kubernetes access ==="
kubectl cluster-info || { echo "ERROR: kubectl cannot reach the API server. Check kubeconfig/context and authorization."; exit 6; }
echo "Current context: $(kubectl config current-context)"

echo
echo "=== Nodes: readiness, labels, taints ==="
kubectl get nodes -o wide
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,CPU_CAPACITY:.status.capacity.cpu,MEM_CAPACITY:.status.capacity.memory,CPU_ALLOCATABLE:.status.allocatable.cpu,MEM_ALLOCATABLE:.status.allocatable.memory,TAINTS:.spec.taints'
READY_WORKERS="$(kubectl get nodes -o json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(sum(1 for n in d.get("items",[]) if any(c.get("type")=="Ready" and c.get("status")=="True" for c in n.get("status",{}).get("conditions",[])) and "node-role.kubernetes.io/control-plane" not in n.get("metadata",{}).get("labels",{}) and "node-role.kubernetes.io/master" not in n.get("metadata",{}).get("labels",{})))' 2>/dev/null || echo 0)"
echo "Ready non-control-plane nodes (approximate worker count): $READY_WORKERS"
if [[ "${READY_WORKERS:-0}" -lt 2 ]]; then echo "WARNING: fewer than two Ready worker nodes detected; node coverage demonstration will be limited."; fi

echo
echo "=== Namespaces and workloads ==="
kubectl get namespaces
kubectl get daemonsets -A -o wide
kubectl get statefulsets -A -o wide
kubectl get pods -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,OWNER_KIND:.metadata.ownerReferences[0].kind,OWNER_NAME:.metadata.ownerReferences[0].name,PHASE:.status.phase,READY:.status.containerStatuses[*].ready,NODE:.spec.nodeName' || true

echo
echo "=== Storage inspection ==="
kubectl get storageclass -o wide || true
DEFAULT_SC="$(kubectl get storageclass -o json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print(",".join(x["metadata"]["name"] for x in d.get("items",[]) if x.get("metadata",{}).get("annotations",{}).get("storageclass.kubernetes.io/is-default-class")=="true" or x.get("metadata",{}).get("annotations",{}).get("storageclass.beta.kubernetes.io/is-default-class")=="true"))' 2>/dev/null || true)"
if [[ -n "$DEFAULT_SC" ]]; then echo "Default StorageClass: $DEFAULT_SC"; else echo "WARNING: no default StorageClass detected. PVCs may remain Pending unless a class is explicitly selected or dynamic provisioning is configured."; fi
kubectl get pv -o wide || true
kubectl get pvc -A -o wide || true

echo
echo "=== Lab namespace and resource requests ==="
if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "WARNING: namespace $NS already exists. Setup script will refuse to reuse it."
  kubectl get all -n "$NS" -o wide
else
  echo "Namespace $NS does not exist."
fi
echo "Node requested resources (scheduler view; not a complete free-capacity estimate):"
kubectl describe nodes | grep -E '^(Name:|  cpu |  memory |Allocated resources:|  Resource|  Requests|  Limits)' || true
echo
echo "Capacity estimate:"
echo "- Planned baseline: 1 small DaemonSet Pod per eligible node + 3 small StatefulSet Pods."
echo "- Each demo container requests 10m CPU and 24Mi memory (plus Pod/system overhead)."
echo "- This is only a rough estimate. Review node Allocated resources, quotas, Pod limits, and events."
echo "- No cluster state was changed by this script."
