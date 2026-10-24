#!/usr/bin/env bash
set -Eeuo pipefail
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/04-backend.yaml
kubectl apply -f manifests/05-pod-affinity.yaml
kubectl -n scheduling-demo get pods -o wide
