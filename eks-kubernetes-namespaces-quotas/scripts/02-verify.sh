#!/usr/bin/env bash
set -u
LAB_NS="namespace-quota-demo"
echo "Context: $(kubectl config current-context 2>/dev/null || echo UNKNOWN)"
kubectl get namespace "$LAB_NS" --show-labels || exit 2
kubectl get deployments,replicasets,pods,services,resourcequota,limitrange -n "$LAB_NS" -o wide
printf '\nQuota details:\n'; kubectl describe resourcequota -n "$LAB_NS" || true
printf '\nPod resource settings:\n'; kubectl get pods -n "$LAB_NS" -o yaml | grep -E '(^  name:|requests:|limits:|cpu:|memory:)' || true
printf '\nRecent namespace events:\n'; kubectl get events -n "$LAB_NS" --sort-by=.lastTimestamp || true
printf '\nOptional metrics (requires metrics API):\n'; kubectl top pods -n "$LAB_NS" 2>&1 || echo 'Metrics unavailable; use describe/events and declared resources.'
