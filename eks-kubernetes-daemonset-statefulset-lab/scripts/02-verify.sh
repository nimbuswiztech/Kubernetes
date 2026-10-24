#!/usr/bin/env bash
set -euo pipefail
NS="daemonset-statefulset-demo"
echo "=== Controllers ==="
kubectl get ds,sts,svc -n "$NS" -o wide
echo
echo "=== Pods and placement ==="
kubectl get pods -n "$NS" -o wide
echo
echo "=== PVCs ==="
kubectl get pvc -n "$NS" -o wide
echo
echo "=== DaemonSet node coverage ==="
kubectl get ds node-observer -n "$NS" -o jsonpath='desired={.status.desiredNumberScheduled} current={.status.currentNumberScheduled} ready={.status.numberReady} updated={.status.updatedNumberScheduled}{"\n"}'
echo
echo "=== StatefulSet status ==="
kubectl get sts ledger -n "$NS" -o jsonpath='replicas={.status.replicas} ready={.status.readyReplicas} currentRevision={.status.currentRevision} updateRevision={.status.updateRevision}{"\n"}' || true
echo
echo "=== Events (recent first) ==="
kubectl get events -n "$NS" --sort-by=.lastTimestamp | tail -n 20
