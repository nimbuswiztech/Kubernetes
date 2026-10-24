#!/usr/bin/env bash
set -Eeuo pipefail
# Removes only resources in the dedicated training namespace. Review namespace contents first.
kubectl get all -n scheduling-demo
read -r -p 'Type scheduling-demo to delete this dedicated lab namespace and its namespaced resources: ' CONFIRM
[[ "$CONFIRM" == 'scheduling-demo' ]] || { echo 'Cleanup cancelled.'; exit 1; }
kubectl delete namespace scheduling-demo
# Node labels/taints are intentionally not removed here. If you added the scoped lab label/taint manually,
# remove only the exact key/value that you recorded during setup, after confirming it was lab-created.
