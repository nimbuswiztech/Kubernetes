# Student lab: DaemonSets and StatefulSets on EKS

## Rules
- Work only in `daemonset-statefulset-demo`.
- Never change shared node labels/taints, drain nodes, delete PVs, or alter cluster-wide storage configuration.
- If the namespace already exists, stop and ask the instructor.
- Record actual outputs; IPs and node names vary.

## Part A — preflight (read-only)
1. Run `./scripts/00-check-eks-environment.sh`.
2. Record AWS identity, region, current context, cluster name, Ready worker count, and default StorageClass.
3. Predict whether a DaemonSet Pod should run on every node. Explain eligible nodes.

## Part B — DaemonSet
1. Run `./scripts/01-setup.sh` after the instructor approves.
2. Run `kubectl get ds,pods -n daemonset-statefulset-demo -o wide`.
3. Compare `desiredNumberScheduled`, `currentNumberScheduled`, `numberReady`, and `updatedNumberScheduled`.
4. Use `kubectl describe ds node-observer -n daemonset-statefulset-demo`.
5. Explain why a DaemonSet might not cover a node.
6. Create a harmless revision: `kubectl annotate ds/node-observer training.example.com/change="$(date +%s)" --overwrite -n daemonset-statefulset-demo`.
7. Run `kubectl rollout status ds/node-observer -n daemonset-statefulset-demo`, then inspect history.
8. Undo the last revision and verify.

## Part C — StatefulSet identity
1. Observe ordered Pods: `kubectl get pods -n daemonset-statefulset-demo -w`.
2. In another terminal, inspect `kubectl get sts,svc,pods -n daemonset-statefulset-demo -o wide`.
3. Inspect DNS configuration and the headless Service. If a DNS utility image is unavailable, explain the expected FQDN instead of adding another workload.
4. Delete only `ledger-1`: `kubectl delete pod ledger-1 -n daemonset-statefulset-demo`.
5. Observe the replacement Pod name and status.

## Part D — persistent storage
1. Run `kubectl get pvc -n daemonset-statefulset-demo`.
2. Describe `data-ledger-0`; record StorageClass, status, and bound PV.
3. Read the heartbeat file: `kubectl exec -n daemonset-statefulset-demo ledger-0 -- tail -n 5 /data/heartbeat.log`.
4. Explain why deleting a Pod does not normally delete its PVC.
5. If PVCs are Pending, stop and diagnose; do not delete claims to “fix” them.

## Part E — review and cleanup
1. Complete the quiz and troubleshooting challenges.
2. Review `kubectl get all,pvc -n daemonset-statefulset-demo`.
3. Ask the instructor before cleanup. The cleanup script deletes the dedicated namespace; PV outcomes depend on reclaim policy and provisioner.
