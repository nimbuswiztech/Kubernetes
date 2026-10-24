#!/usr/bin/env bash
set -u
echo "Context: $(kubectl config current-context 2>/dev/null || echo UNKNOWN)"
kubectl get namespace storage-demo
kubectl get pods,deployments,statefulsets,pvc -n storage-demo -o wide 2>/dev/null || true
kubectl get pv -o wide 2>/dev/null || true
kubectl get storageclass -o wide 2>/dev/null || true
kubectl get events -n storage-demo --sort-by=.lastTimestamp 2>/dev/null || true
