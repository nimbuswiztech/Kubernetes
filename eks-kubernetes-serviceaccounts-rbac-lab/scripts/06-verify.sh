#!/usr/bin/env bash
set -u
echo "Context: $(kubectl config current-context)"
kubectl get namespace rbac-demo --show-labels
kubectl get serviceaccounts -n rbac-demo
kubectl get pods -n rbac-demo -o custom-columns='NAME:.metadata.name,PHASE:.status.phase,SA:.spec.serviceAccountName'
kubectl get roles -n rbac-demo
kubectl get rolebindings -n rbac-demo
kubectl describe role pod-reader -n rbac-demo
kubectl describe rolebinding pod-reader-binding -n rbac-demo
kubectl describe clusterrole rbac-demo-configmap-reader
kubectl describe rolebinding configmap-reader-binding -n rbac-demo
kubectl get events -n rbac-demo --sort-by=.lastTimestamp
echo "No token or Secret data is displayed."
