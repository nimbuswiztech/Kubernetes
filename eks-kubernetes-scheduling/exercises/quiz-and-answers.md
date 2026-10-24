# Quiz, answer key and interview prep

## One-page scheduling cheat sheet
| Mechanism | What it matches | Hard or soft? | Typical use |
|---|---|---|---|
| `nodeSelector` | Node labels | Hard | Target a workload pool |
| Required node affinity | Node labels / expressions | Hard | Architecture, compliance, capacity pool |
| Preferred node affinity | Node labels / weighted expressions | Soft preference | Prefer a zone or architecture |
| Pod affinity | Matching Pod labels in a topology domain | Required or preferred | Co-locate frontend/cache/backend |
| Pod anti-affinity | Matching Pod labels in a topology domain | Required or preferred | Separate replicas for resilience |
| Taint + toleration | Node taint vs Pod toleration | Taint repels; toleration permits | Dedicated/GPU/compliance nodes |

Remember: hard constraints filter eligible nodes; preferences influence scoring. Actual placement also depends on resource requests, taints, topology, volumes and other scheduler plugins. A toleration alone does not target a node.

## Ten multiple-choice questions

**1. What does the Kubernetes scheduler do?**
A. Builds container images B. Chooses a node for an unscheduled Pod C. Runs the container runtime D. Creates an EKS cluster

**Answer: B.** Scheduler filters and scores candidate nodes, then binds the Pod. Kubelet/container runtime handle execution.

**2. What happens if no node matches a Pod's `nodeSelector`?**
A. Kubernetes ignores it B. Pod remains Pending C. Pod is moved to control plane D. Label is created automatically

**Answer: B.** Inspect `kubectl describe pod` and events for `FailedScheduling`.

**3. Which is a soft preference?**
A. `nodeSelector` B. `requiredDuringSchedulingIgnoredDuringExecution` C. `preferredDuringSchedulingIgnoredDuringExecution` D. Untolerated `NoSchedule`

**Answer: C.** Preferred rules influence ranking but do not guarantee placement.

**4. What does `topologyKey: kubernetes.io/hostname` represent?**
A. AWS region B. Node/hostname topology domain C. Namespace D. Container port

**Answer: B.** Different hostnames define different node domains.

**5. What does Pod affinity select?**
A. Node labels only B. Pod labels within a topology domain C. AWS IAM roles D. Image tags

**Answer: B.** The selector matches Pods; `topologyKey` defines where the relationship is evaluated.

**6. What can happen with 3 replicas, 2 nodes, and required hostname anti-affinity for the same app label?**
A. All three always run B. One can remain Pending C. Kubernetes deletes a node D. Scheduler ignores anti-affinity

**Answer: B.** Only two distinct hostname domains are available under those constraints.

**7. Does a toleration guarantee placement on a tainted node?**
A. Yes B. No C. Only for Deployments D. Only in EKS

**Answer: B.** It removes that taint as a blocker; use nodeSelector/affinity to target the node.

**8. Which taint effect can evict existing non-tolerating Pods?**
A. NoSchedule B. PreferNoSchedule C. NoExecute D. Exists

**Answer: C.** NoExecute affects existing Pods as well as future scheduling, subject to tolerations/tolerationSeconds.

**9. What should be checked first for a Pending Pod?**
A. Delete the node B. `kubectl describe pod` and recent events C. Reboot EKS D. Remove every taint

**Answer: B.** Events usually explain scheduling failures.

**10. Does changing a node label automatically evict a running Pod when the Pod uses `IgnoredDuringExecution` affinity?**
A. Always B. No C. Only in EKS D. Only if namespace is default

**Answer: B.** The rule is evaluated during scheduling; the existing Pod is not automatically evicted.

## Five interview questions with detailed answers

**1. Explain the scheduler filter and score phases.**
The scheduler evaluates candidate nodes against hard requirements such as resources, node selection, affinity, taints/tolerations, volume constraints and topology. Nodes that fail are filtered out. Remaining feasible nodes are scored, with preferences and scheduler scoring plugins influencing ranking. The Pod is then bound to a node. A preference cannot override a hard failure.

**2. Compare nodeSelector and node affinity.**
`nodeSelector` is a simple exact key/value hard match. Node affinity supports expressions such as `In`, `NotIn`, `Exists`, and `DoesNotExist`, plus required rules and weighted preferred rules. Both operate on node labels. Neither automatically evicts a running Pod just because a label later changes when the scheduling rule is `IgnoredDuringExecution`.

**3. Compare Pod affinity and anti-affinity.**
Both use Pod label selectors and a topology key. Affinity attracts a Pod to a topology domain containing matching Pods; anti-affinity avoids a domain containing matching Pods. Required variants are hard constraints and may leave Pods Pending when eligible topology domains are exhausted. Preferred variants express a scoring preference.

**4. What is the difference between taints and tolerations?**
A taint is attached to a node and repels Pods that do not tolerate it. A toleration is attached to a Pod and permits it to pass the matching taint filter. A toleration does not attract a Pod to the node. `NoSchedule` blocks new non-tolerating Pods, `PreferNoSchedule` is soft avoidance, and `NoExecute` can evict existing non-tolerating Pods. Be careful with `NoExecute` on shared nodes.

**5. How would you debug a Pending Pod in EKS?**
Run `kubectl describe pod <pod> -n <namespace>` and inspect recent events. Compare nodeSelector and affinity selectors to actual node labels. Inspect taints and tolerations, node Ready status, allocatable resources versus Pod requests, topology/zone labels, volumes, and existing matching Pods. If AWS errors occur, separately verify credentials, region, kubeconfig context, IAM authentication, Kubernetes RBAC and API/network access. Do not treat IAM authorization failures as scheduler placement failures.
