#!/usr/bin/env bash
set -euo pipefail
echo "Static provisioning requires an existing, explicitly selected backend. No backend is created here."
echo "The template manifests/04-static-pv.yaml intentionally contains PLACEHOLDER values and must not be applied unchanged."
echo "For a safe shared EKS classroom, teach the lifecycle using the HTML diagram and inspect existing resources read-only."
echo "Only run a real static PV exercise in an isolated lab with an approved disposable backend and a reviewed manifest."
kubectl get pv -o wide
kubectl get pvc -A -o wide
