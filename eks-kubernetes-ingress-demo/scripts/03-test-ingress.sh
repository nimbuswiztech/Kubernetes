#!/usr/bin/env bash
set -euo pipefail
NS=ingress-demo
echo "Context: $(kubectl config current-context)"
echo "This script does not apply an Ingress or create a load balancer."
echo "Before proceeding manually, confirm a compatible controller, the exact IngressClass, and approval for possible AWS charges."
kubectl get ingressclass -o wide
kubectl get pods -A -o wide | grep -Ei 'NAMESPACE|ingress|alb|nginx|traefik|haproxy' || true
echo
echo "Review manifests/03-host-ingress.yaml and replace <DISCOVERED_CLASS> with the confirmed class."
echo "Only then, with approval, run: kubectl apply -f manifests/03-host-ingress.yaml"
echo "Inspect with:"
echo "kubectl get ingress -n ${NS} -o wide"
echo "kubectl describe ingress frontend-host -n ${NS}"
echo "kubectl get events -n ${NS} --sort-by=.lastTimestamp"
echo
echo "If endpoint is available:"
echo "curl -i -H 'Host: frontend.lab.example.com' http://<INGRESS_ENDPOINT>/"
