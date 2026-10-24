#!/usr/bin/env bash
set -u
# Read-only preflight. Does not dump kubeconfig credentials, tokens, or Secret data.
LAB_NAMESPACE="${LAB_NAMESPACE:-rbac-demo}"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-}"

section(){ printf '\n==== %s ====\n' "$1"; }
have(){ command -v "$1" >/dev/null 2>&1; }
run(){ printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@" 2>&1 || { printf '[INFO] command failed or access was denied; continuing read-only checks.\n'; return 0; }; }

section "Tooling"
for tool in aws kubectl; do
  if have "$tool"; then printf '%s: %s\n' "$tool" "$(command -v "$tool")"; else printf 'MISSING: %s\n' "$tool"; fi
done
if ! have aws || ! have kubectl; then echo "Install AWS CLI v2 and kubectl, then rerun."; exit 2; fi

section "AWS identity and region"
run aws sts get-caller-identity
if [[ -z "$AWS_REGION" ]]; then AWS_REGION="$(aws configure get region 2>/dev/null || true)"; fi
if [[ -z "$AWS_REGION" ]]; then
  read -r -p "AWS region (required for EKS discovery): " AWS_REGION
fi
if [[ -z "$AWS_REGION" ]]; then echo "No region selected; cannot discover EKS cluster."; exit 2; fi
printf 'Selected region: %s\n' "$AWS_REGION"

section "EKS cluster discovery"
if [[ -z "$EKS_CLUSTER_NAME" ]]; then
  run aws eks list-clusters --region "$AWS_REGION" --output table
  read -r -p "Enter the intended EKS cluster name (must match your authorized target): " EKS_CLUSTER_NAME
fi
if [[ -z "$EKS_CLUSTER_NAME" ]]; then echo "No cluster selected; stopping."; exit 2; fi
printf 'Selected cluster name: %s\n' "$EKS_CLUSTER_NAME"
run aws eks describe-cluster --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION" --query 'cluster.{name:name,version:version,status:status,endpoint:endpoint,accessConfig:accessConfig}' --output yaml

section "kubectl context and endpoint"
run kubectl config current-context
# Print endpoint only, not the full kubeconfig.
run kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}'
printf '\n'
run kubectl version
run kubectl get --raw=/readyz

section "Namespaces and target namespace"
run kubectl get namespaces
if kubectl get namespace "$LAB_NAMESPACE" >/dev/null 2>&1; then
  echo "WARNING: namespace $LAB_NAMESPACE already exists. Confirm it is lab-owned before doing anything; default scripts will not delete it automatically."
else
  echo "Target namespace $LAB_NAMESPACE does not currently exist or is not visible."
fi

section "ServiceAccounts, Roles, and bindings"
run kubectl get serviceaccounts -A
run kubectl get roles -A
run kubectl get rolebindings -A
run kubectl get clusterroles
run kubectl get clusterrolebindings

section "High-risk binding summary (names/subjects only)"
if kubectl get clusterrolebindings -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.roleRef.name}{"\t"}{range .subjects[*]}{.kind}{":"}{.name}{"@"}{.namespace}{" "}{end}{"\n"}{end}' 2>/dev/null; then
  : # Output is metadata only; not credentials.
else echo "Could not inspect ClusterRoleBinding metadata."; fi
echo "Review bindings to system:masters, cluster-admin, broad groups, and wildcard ClusterRoles manually. This summary is not a complete privilege audit."

section "Current caller's namespaced capabilities"
for check in \
  "create namespaces" \
  "create serviceaccounts -n $LAB_NAMESPACE" \
  "create pods -n $LAB_NAMESPACE" \
  "create roles.rbac.authorization.k8s.io -n $LAB_NAMESPACE" \
  "create rolebindings.rbac.authorization.k8s.io -n $LAB_NAMESPACE" \
  "create clusterroles.rbac.authorization.k8s.io" \
  "create clusterrolebindings.rbac.authorization.k8s.io"; do
  # shellcheck disable=SC2086
  printf '%-65s : ' "$check"
  # Parse verb/resource/optional namespace; intentionally no mutation.
  set -- $check
  verb="$1"; resource="$2"; ns=""
  if [[ "${3:-}" == "-n" ]]; then ns="${4:-}"; fi
  if [[ -n "$ns" ]]; then kubectl auth can-i "$verb" "$resource" -n "$ns" 2>&1 || true
  else kubectl auth can-i "$verb" "$resource" 2>&1 || true; fi
done
echo "Note: 'no' can mean not authorized; an error may mean discovery/access is unavailable. No cluster state was changed."

section "EKS access configuration (read-only)"
run aws eks describe-cluster --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION" --query 'cluster.accessConfig' --output yaml
run aws eks list-access-entries --cluster-name "$EKS_CLUSTER_NAME" --region "$AWS_REGION" --output table
echo "If supported and authorized, inspect each relevant access entry's associated policies separately. Access policies and Kubernetes RBAC can both affect authorization."
echo "Legacy aws-auth is not edited by this lab. Inspect it only if authorized, and never print Secret data."

section "Admission / Pod Security"
run kubectl get namespace "$LAB_NAMESPACE" --show-labels
run kubectl get validatingadmissionpolicies
run kubectl get validatingwebhookconfigurations
run kubectl get mutatingwebhookconfigurations
echo "Admission policy visibility may be restricted. Namespace labels shown above can include Pod Security labels."

section "Preflight conclusion"
echo "This script is read-only. Before setup, confirm cluster/context/region, namespace ownership, permissions, and admission requirements."
echo "Lessons that can proceed without cluster-admin: conceptual slides, read-only inspection, can-i checks allowed to the caller, and namespaced exercises when the caller can create the required namespaced objects."
echo "Cluster-scoped changes, EKS access changes, and IAM changes are not required for the default lab."
