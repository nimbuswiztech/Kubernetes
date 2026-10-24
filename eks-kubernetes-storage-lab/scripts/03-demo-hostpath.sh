#!/usr/bin/env bash
set -euo pipefail
cat <<'EOF'
SAFETY GATE: hostPath exposes a path on the selected worker node. This example uses
a dedicated lab directory only, but may be denied by Pod Security Admission or cluster policy.
Do not weaken policy, use privileged containers, or write to system paths to force it.
EOF
kubectl apply -f manifests/03-hostpath-pod.yaml
kubectl get pod hostpath-demo -n storage-demo -o wide
kubectl describe pod hostpath-demo -n storage-demo
echo "If admitted and running, this Pod creates /tmp/storage-demo-lab on its selected node."
echo "The directory is node-local; scheduling the Pod to another node can show different contents."
echo "If rejected, retain the rejection as a teaching result and use the HTML conceptual diagram."
