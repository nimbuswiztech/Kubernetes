#!/usr/bin/env bash
set -Eeuo pipefail
kubectl get nodes -o wide
kubectl -n scheduling-demo get deploy,rs,pods -o wide
kubectl -n scheduling-demo get events --sort-by=.lastTimestamp
