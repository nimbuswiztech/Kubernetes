#!/usr/bin/env bash
set -euo pipefail
NS=ingress-demo
echo "Context: $(kubectl config current-context)"
kubectl get pods -n "$NS" -o wide
kubectl get svc -n "$NS"
kubectl get endpointslice -n "$NS"
kubectl describe svc frontend -n "$NS"
echo
echo "Starting a temporary curl Pod. It will be removed after you exit."
kubectl run curl-check -n "$NS" --image=curlimages/curl:8.10.1 --restart=Never --rm -it -- sh
echo "Inside the shell run: curl -sS http://frontend/ and curl -sS http://catalog/"
