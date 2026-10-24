#!/usr/bin/env bash
# Bounded CPU loop executed inside one lab-owned frontend container.
# It targets only autoscaling-demo/frontend and exits after 10..300 seconds.
set -euo pipefail
NS=autoscaling-demo
DURATION="${1:-120}"
[[ "$DURATION" =~ ^[0-9]+$ ]] && (( DURATION >= 10 && DURATION <= 300 )) || { echo "Usage: $0 [10..300 seconds]"; exit 2; }
POD="$(kubectl get pods -n "$NS" -l app=backend -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | awk '{print $1}')"
[[ -n "$POD" ]] || { echo "No Running backend Pod found in $NS."; exit 1; }
echo "Context: $(kubectl config current-context)"
echo "Target: pod/$POD, container web, namespace $NS, duration ${DURATION}s"
echo "This bounded CPU loop runs only inside the lab backend container."
echo "Start watching HPA/Pods in another terminal now; press Ctrl-C to stop early."
kubectl exec -n "$NS" "$POD" -c web -- /bin/sh -c "end=\$((\$(date +%s) + $DURATION)); while [ \$(date +%s) -lt \$end ]; do :; done"
