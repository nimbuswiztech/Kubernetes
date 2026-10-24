#!/usr/bin/env bash
set -u
echo "Context: $(kubectl config current-context)"
kubectl get serviceaccount demo-reader -n rbac-demo -o wide || exit 1
kubectl get pod demo-sleeper -n rbac-demo -o custom-columns='NAME:.metadata.name,PHASE:.status.phase,SA:.spec.serviceAccountName'
echo "Inspect only token mounting configuration; never print token contents."
kubectl get serviceaccount demo-reader -n rbac-demo -o jsonpath='{.automountServiceAccountToken}'; echo
kubectl get pod demo-sleeper -n rbac-demo -o jsonpath='{.spec.automountServiceAccountToken}'; echo
echo "Authorization checks use impersonation and may be denied if caller lacks impersonate permission."
kubectl auth can-i list pods -n rbac-demo --as=system:serviceaccount:rbac-demo:demo-reader
echo "A 'no' here can be expected before RoleBinding; other configured grants may change the result."
