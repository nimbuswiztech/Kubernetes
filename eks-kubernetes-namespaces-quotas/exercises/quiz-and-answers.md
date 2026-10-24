# Quiz, Interview Questions and Answers

## Ten multiple-choice questions

1. Does creating a namespace create a worker node? **B. No.** A namespace is an API organization/scope boundary.
   - A Yes; B No; C Only on EKS; D Only with quotas.
2. Which is cluster-scoped? **C. Node.** Pods and Services are namespaced.
   - A Pod; B Service; C Node; D ConfigMap.
3. What does a CPU request primarily influence? **A. Scheduling and resource accounting.** It is not a hard cap.
4. What can happen when a container exceeds its CPU limit? **B. CPU throttling.** CPU is compressible.
5. What can happen when memory use exceeds its limit? **C. OOM termination may occur.** Exact behavior depends on kernel/runtime and pressure.
6. What does ResourceQuota control? **A. Aggregate namespace usage/object counts.** It does not reserve a node.
7. What does LimitRange do? **B. Defaults and per-object min/max constraints.**
8. Can quota reject a Pod while a node has spare CPU? **A. Yes.** Admission policy is distinct from scheduling capacity.
9. Does a namespace by itself block cross-namespace network traffic? **C. No.** NetworkPolicy plus a supporting CNI/policy implementation may be required.
10. A Pod is admitted but Pending with `FailedScheduling: Insufficient memory`. Where is the likely issue? **B. Scheduler placement/node allocatable capacity.** Inspect events, requests, taints and constraints.

## Five interview questions

1. **Requests vs limits?** Requests are used by scheduling and quota accounting. Limits bound container resource usage; CPU limits throttle and memory limits can cause OOM termination.
2. **Why use both ResourceQuota and LimitRange?** Quota sets aggregate namespace budgets/counts; LimitRange sets per-container defaults and bounds. They address different levels of control.
3. **Why can quota reject a Pod with free nodes?** Admission evaluates namespace hard/used quota before scheduling; spare physical capacity does not override the policy.
4. **Why can an admitted Pod be Pending?** Admission only allows the API object. The scheduler may find no node satisfying requests, taints/tolerations, affinity, topology or other constraints.
5. **Is namespace a security boundary?** It is a logical scope. Use RBAC, NetworkPolicies, Pod Security Admission, secrets practices, AWS IAM/EKS access controls and admission policy as appropriate.

## Final assignment

Create a team namespace with a labeled Deployment and Service; configure a ResourceQuota for CPU/memory requests and limits plus Pod count; configure a LimitRange with defaults/min/max; prove one defaulted Pod and one controlled rejection; capture quota usage and events; explain whether any failure is admission, scheduling, or runtime; clean up only your namespace.

### Acceptance criteria

- Correct context verified before changes.
- Namespace and all lab objects carry clear ownership labels where supported.
- Valid resource requests/limits and quota/LimitRange relationship.
- Evidence from `describe`, YAML, quota usage and events.
- Correct classification of quota rejection versus Pending scheduling failure.
- Cleanup confirmed and no unrelated resources changed.
