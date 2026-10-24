#!/usr/bin/env bash
# Read-only discovery only. Does not create or modify cluster resources.
set -u
section(){ printf '\n===== %s =====\n' "$1"; }
command -v aws >/dev/null 2>&1 || { echo "ERROR: AWS CLI not found"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl not found"; exit 1; }

section "AWS identity and configuration"
aws sts get-caller-identity --query '{Account:Account,Arn:Arn,UserId:UserId}' --output table || echo "WARN: AWS identity lookup failed; check profile/credentials."
printf 'AWS_PROFILE=%s\n' "${AWS_PROFILE:-<default profile chain>}"
printf 'AWS_REGION=%s AWS_DEFAULT_REGION=%s\n' "${AWS_REGION:-<unset>}" "${AWS_DEFAULT_REGION:-<unset>}"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
if [[ -z "$REGION" ]]; then
  REGION="$(aws configure get region 2>/dev/null || true)"
fi
printf 'Resolved region: %s\n' "${REGION:-<not configured>}"

section "EKS clusters visible to this identity"
if [[ -n "$REGION" ]]; then aws eks list-clusters --region "$REGION" --output table || true
else echo "Set AWS_REGION or AWS_DEFAULT_REGION, then rerun to list clusters."; fi
CLUSTER="${EKS_CLUSTER_NAME:-}"
if [[ -z "$CLUSTER" ]]; then
  read -r -p "Enter the existing EKS cluster name to inspect (blank exits): " CLUSTER
fi
if [[ -z "$CLUSTER" ]]; then echo "No cluster selected; stopping after read-only AWS discovery."; exit 0; fi
if [[ -z "$REGION" ]]; then
  read -r -p "Enter the AWS region for cluster $CLUSTER: " REGION
fi
aws eks describe-cluster --name "$CLUSTER" --region "$REGION" \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,PlatformVersion:platformVersion}' --output table || {
  echo "WARN: unable to describe cluster; verify cluster name, region, and IAM permissions."; exit 0; }

section "kubectl context and API access"
kubectl config current-context 2>/dev/null || echo "WARN: no current kubectl context"
kubectl version --output=yaml 2>/dev/null | sed -n '1,24p' || echo "WARN: Kubernetes API version query failed"
kubectl cluster-info 2>/dev/null || echo "WARN: cluster-info failed; context/access may be wrong"
echo "Current context must be verified manually against the intended cluster before any write operation."

section "Nodes, readiness, topology, capacity"
kubectl get nodes -o wide 2>/dev/null || echo "WARN: cannot list nodes"
kubectl get nodes -L topology.kubernetes.io/zone,topology.kubernetes.io/region,node.kubernetes.io/instance-type 2>/dev/null || true
kubectl get nodes -o custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,TAINTS:.spec.taints,CAPACITY_CPU:.status.capacity.cpu,CAPACITY_MEM:.status.capacity.memory,ALLOC_CPU:.status.allocatable.cpu,ALLOC_MEM:.status.allocatable.memory' 2>/dev/null || true
READY="$(kubectl get nodes -o jsonpath='{range .items[*]}{range .status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}{end}' 2>/dev/null | grep -c '^True$' || true)"
echo "Ready nodes reported: ${READY:-0}"
if [[ "${READY:-0}" -lt 2 ]]; then echo "WARNING: fewer than two Ready nodes; two-node placement/topology exercises may not be possible."; fi

section "Namespaces and storage inventory (read-only)"
kubectl get namespaces
kubectl get pv -o wide 2>/dev/null || echo "WARN: cannot list PVs"
kubectl get pvc -A -o wide 2>/dev/null || echo "WARN: cannot list PVCs"
kubectl get storageclass -o wide 2>/dev/null || echo "WARN: cannot list StorageClasses"
echo "-- Default StorageClass annotation, if any --"
kubectl get storageclass -o jsonpath='{range .items[*]}{.metadata.name}{" default="}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{" provisioner="}{.provisioner}{" bindingMode="}{.volumeBindingMode}{" reclaim="}{.reclaimPolicy}{"\n"}{end}' 2>/dev/null || true
echo "-- Existing workload/storage objects in all namespaces (inventory only) --"
kubectl get pods,deployments,statefulsets -A -o wide 2>/dev/null | head -100 || true

section "CSI components and API resources"
kubectl get csidrivers 2>/dev/null || echo "INFO: CSIDriver API unavailable or access denied"
kubectl get csinodes 2>/dev/null || echo "INFO: CSINode API unavailable or access denied"
kubectl get pods,daemonsets,deployments -A -o wide 2>/dev/null | grep -Ei 'ebs-csi|efs-csi|csi-' || echo "INFO: no obviously named CSI components found (not proof that none exist)"
kubectl api-resources 2>/dev/null | grep -Ei 'persistentvolume|persistentvolumeclaim|storageclass|volumeattachment|csidriver|csinode|volumesnapshot' || true
kubectl get crd 2>/dev/null | grep -Ei 'storage|snapshot|csi' || true

section "Namespace and policy constraints"
if kubectl get namespace storage-demo >/dev/null 2>&1; then
  echo "WARNING: storage-demo already exists. Inspect ownership/resources before reuse; setup will not overwrite it automatically."
  kubectl get resourcequota,limitrange -n storage-demo 2>/dev/null || true
  kubectl get pvc,pod,deploy,statefulset -n storage-demo -o wide 2>/dev/null || true
else
  echo "storage-demo does not currently exist."
fi
kubectl get resourcequota,limitrange -A 2>/dev/null || true

section "Safety summary"
cat <<'EOF'
This script made no cluster changes and does not print credentials or secrets.
Before running write operations:
1. Confirm AWS account/role, region, cluster name, and kubectl context.
2. Confirm storage-demo is lab-owned or choose a different isolated cluster.
3. Inspect StorageClass provisioner, binding mode, reclaim policy, and parameters.
4. Obtain explicit approval before creating any PVC that may provision billable cloud storage.
5. Never use existing production PVs/PVCs as lab objects.
EOF
