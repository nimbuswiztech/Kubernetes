# Troubleshooting Challenges

For each challenge, identify the failure layer, the evidence command, and a safe fix.

1. **`exceeded quota: compute-quota`** — Admission rejection. Run `kubectl describe resourcequota -n namespace-quota-demo`; inspect hard/used and requests/limits. Remove only the lab test object or adjust the lab quota with approval.
2. **`FailedScheduling: Insufficient cpu`** — Scheduler/node allocatable issue, not quota by itself. Inspect `kubectl describe pod`, `kubectl describe nodes`, existing requests, taints and constraints. Reduce the lab workload's requests if appropriate; do not change nodes.
3. **`minimum usage per Container is ...`** — LimitRange admission. Inspect `kubectl describe limitrange`; make new Pod resource settings conform.
4. **`ImagePullBackOff`** — Runtime/image acquisition. Inspect `kubectl describe pod` events; verify image name, registry access and approved pull credentials.
5. **`OOMKilled`** — Runtime memory termination. Inspect `kubectl describe pod` and logs. Revisit memory request/limit and application behavior; don't raise limits blindly on a shared cluster.
