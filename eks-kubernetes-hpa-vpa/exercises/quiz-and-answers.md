# Quiz and Answers
1. HPA changes: A node type B replica count C IAM role. **B** — it adjusts the target's scale.
2. CPU target 60% means: A node CPU B requested CPU C total cluster CPU. **B** — utilization is relative to requests.
3. Resource metrics API: A `metrics.k8s.io` B CloudTrail. **A**.
4. Does Metrics Server replace historical monitoring? **No** — use Prometheus/managed observability for history and alerts.
5. Desired replicas 3, one Pending: **describe Pod and inspect events/capacity/quota/constraints**.
6. VPA `Off`: **recommend only**.
7. Who places Pods on nodes? **Scheduler**.
8. Missing CPU requests can make utilization-based scaling unavailable for relevant containers. **True**.
9. Why can CPU HPA and VPA interact? **Changing CPU requests changes HPA utilization denominator**.
10. Does VPA guarantee scheduling? **No** — capacity and constraints still apply.

## Interview questions
- **HPA loop:** observes metrics, calculates desired replicas, updates scale subresource; scheduler separately places Pods.
- **Why requests matter:** CPU utilization is usage/request; requests also influence scheduling.
- **Desired > Ready:** inspect Pod events, allocatable resources, taints, affinity, quotas, image pulls and readiness.
- **VPA architecture:** recommender, updater, admission controller and CRD in a separately installed implementation.
- **Can HPA/VPA coexist?** Sometimes; evaluate metrics, controlled resource, update mode and implementation.

## Final assignment
Create a namespaced HPA demo with requests/limits, target 60%, 1–3 replicas; run bounded load, capture observations, diagnose one failure, and explain recommendation-only VPA.
Acceptance: no unrelated changes; metrics validated; load bounded; cleanup verified; desired vs Ready explained.
