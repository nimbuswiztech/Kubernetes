#!/usr/bin/env bash
set -euo pipefail
echo "This demo requires a validated StorageClass and explicit approval because provisioning may incur charges."
./scripts/05-demo-dynamic-provisioning.sh
echo "When the PVC is Bound, apply the consumer manifest:"
echo "  kubectl apply -f manifests/08-dynamic-consumer-deployment.yaml"
echo "Then inspect:"
echo "  kubectl get pvc,pv,pod -n storage-demo -o wide"
echo "  kubectl describe pod -n storage-demo -l app=storage-consumer"
echo "  kubectl get events -n storage-demo --sort-by=.lastTimestamp"
