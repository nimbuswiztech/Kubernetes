# Quiz and answers

## 10 multiple-choice questions

1. Which controller is usually appropriate for a stateless API with interchangeable replicas?
   - A. DaemonSet
   - B. Deployment
   - C. StatefulSet
   - D. PersistentVolume
   **Answer: B.** Deployments manage ReplicaSets and replaceable Pod replicas.

2. What does a DaemonSet aim to do?
   - A. Run one Pod on every eligible node
   - B. Run exactly one Pod in the cluster
   - C. Provision a volume
   - D. Expose a Service
   **Answer: A.** Node eligibility depends on scheduling rules and node state.

3. Which is a StatefulSet Pod name pattern?
   - A. `ledger-randomhash`
   - B. `ledger-2`
   - C. `ledger.service`
   - D. `pvc-ledger`
   **Answer: B.** StatefulSet Pods use stable ordinal names.

4. What does `clusterIP: None` mean for a Service?
   - A. The Service is deleted
   - B. It is headless and has no virtual ClusterIP
   - C. It is external-only
   - D. It disables DNS
   **Answer: B.** DNS can publish endpoint addresses for selected Pods.

5. What typically happens to a StatefulSet Pod's PVC when the Pod is deleted?
   - A. It is always deleted
   - B. It is retained by default
   - C. It is converted to a Secret
   - D. The node is drained
   **Answer: B.** PVC retention behavior and storage reclaim policy must be checked.

6. A Pod is Pending. What is a good first diagnostic?
   - A. Delete every PV
   - B. `kubectl describe pod`
   - C. Reboot a node
   - D. Change all node labels
   **Answer: B.** Events and scheduling conditions usually explain the blocker.

7. Does a toleration force a Pod onto a tainted node?
   - A. Yes
   - B. No; it permits the taint but does not select the node
   - C. Only for StatefulSets
   - D. It creates a node
   **Answer: B.** Node selectors, affinity, resources, and other constraints still apply.

8. What creates one claim per StatefulSet ordinal?
   - A. A headless Service
   - B. `volumeClaimTemplates`
   - C. A Deployment
   - D. A node label
   **Answer: B.** The controller creates a PVC for each Pod identity.

9. What does StatefulSet rollback not guarantee?
   - A. Reverting the Pod template revision
   - B. Reversing application-level data writes
   - C. A new revision
   - D. A controller reconciliation
   **Answer: B.** Application data recovery requires application-specific procedures.

10. Why can a DaemonSet have fewer Ready Pods than nodes?
    - A. Taints or selectors exclude nodes
    - B. Resource constraints or image failures
    - C. Node conditions / scheduling constraints
    - D. All of the above
    **Answer: D.** Desired placement and readiness are separate concerns.

## 5 interview questions with model answers

1. **Deployment vs DaemonSet?** A Deployment manages a desired replica count across the cluster, while a DaemonSet targets one Pod on each eligible node. Use a Deployment for interchangeable service replicas and a DaemonSet for node-local agents.
2. **Why use a headless Service with a StatefulSet?** It enables DNS records for individual Pods, supporting stable network identity. It does not provide a virtual ClusterIP load balancer.
3. **What does StatefulSet persistence mean?** Pod identity and claim association are stable. Durability and correctness still depend on storage, application writes, replication, and backup.
4. **Why might a DaemonSet skip a node?** Node selector/affinity, taints, OS/architecture, unschedulable state, or other scheduling constraints may make it ineligible; Pod readiness can also fail from resources or image/runtime errors.
5. **How do you troubleshoot a Pending StatefulSet Pod?** Describe the Pod, inspect events and PVCs, verify StorageClass/CSI provisioner and topology, check quotas and node resources, then make the smallest safe correction.

## Recap
- DaemonSet = node coverage.
- StatefulSet = stable ordinal identity, ordered lifecycle, and per-replica claim association.
- Deployment = stateless/interchangeable replicas.
- Services provide stable access patterns; a headless Service is not a ClusterIP load balancer.
- PVC retention is not a backup plan.
