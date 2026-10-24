#!/usr/bin/env bash
set -euo pipefail
kubectl get namespace storage-demo
kubectl apply -f manifests/01-emptydir-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo emptydir-demo -- sh -c 'printf "created-at-%s\n" "$(date -u +%FT%TZ)" > /work/marker.txt; cat /work/marker.txt'
kubectl get pod emptydir-demo -n storage-demo -o wide
kubectl describe pod emptydir-demo -n storage-demo
echo "Container restart experiment: this replaces the container process in the same Pod, not the Pod object."
kubectl exec -n storage-demo emptydir-demo -- sh -c 'kill 1' || true
kubectl wait --for=jsonpath='{.status.containerStatuses[0].restartCount}'=1 pod/emptydir-demo -n storage-demo --timeout=120s || true
kubectl exec -n storage-demo emptydir-demo -- cat /work/marker.txt
echo "Pod replacement experiment: the following deletes only the lab-owned emptydir-demo Pod."
read -r -p "Delete and recreate emptydir-demo (its emptyDir data will be lost)? Type RECREATE: " answer
[[ "$answer" == "RECREATE" ]] || exit 0
kubectl delete pod emptydir-demo -n storage-demo
kubectl apply -f manifests/01-emptydir-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo emptydir-demo -- sh -c 'if test -e /work/marker.txt; then echo "Unexpected marker exists"; else echo "Expected: marker is absent in the new Pod"; fi'
