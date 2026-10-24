# Five troubleshooting challenges

## 1. DaemonSet has fewer Pods than Ready nodes
**Hint:** Compare desired count to eligible nodes; inspect labels, taints, and events.
**Solution:** `kubectl describe ds node-observer -n daemonset-statefulset-demo`; `kubectl get nodes --show-labels`; `kubectl describe node <node>`. Check selectors/affinity and taints. Do not edit shared nodes.

## 2. DaemonSet Pod is ImagePullBackOff
**Hint:** Inspect the exact image reference and Pod events.
**Solution:** `kubectl describe pod <pod> -n daemonset-statefulset-demo`; verify registry reachability, tag spelling, architecture, and pull credentials. Use an approved public image/tag.

## 3. StatefulSet Pod is Pending and its PVC is Pending
**Hint:** Separate scheduler constraints from storage provisioning.
**Solution:** `kubectl describe pod ledger-0 -n daemonset-statefulset-demo`; `kubectl describe pvc data-ledger-0 -n daemonset-statefulset-demo`; `kubectl get sc`; inspect CSI controller/node Pods and events. No default StorageClass or missing CSI driver may block dynamic provisioning.

## 4. `ledger-1` cannot resolve by DNS
**Hint:** Verify Service selector and endpoints before blaming the Pod.
**Solution:** `kubectl get svc ledger-headless -o yaml -n daemonset-statefulset-demo`; `kubectl get endpointslice -n daemonset-statefulset-demo`; verify Service name, `serviceName` in StatefulSet, namespace, Pod labels, CoreDNS health, and actual cluster DNS suffix.

## 5. Rollout is stuck
**Hint:** Find the first unavailable ordinal/Pod and its event.
**Solution:** `kubectl rollout status sts/ledger -n daemonset-statefulset-demo`; `kubectl get pods -o wide -n daemonset-statefulset-demo`; `kubectl describe pod <pod> -n daemonset-statefulset-demo`; inspect readiness, resources, storage attach, image pulls, and update partition. Roll back only after diagnosing and confirming the template revision; do not delete PVCs as a rollout fix.
