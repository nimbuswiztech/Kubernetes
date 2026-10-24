# Namespaces & Resource Controls — Cheat Sheet

- **Namespace**: logical scope for namespaced objects. Does not create nodes or automatically isolate traffic/IAM.
- **Namespaced examples**: Pods, Deployments, Services, ConfigMaps, Secrets, ResourceQuotas, LimitRanges.
- **Cluster-scoped examples**: Nodes, PersistentVolumes, Namespaces, StorageClasses, ClusterRoles.
- **CPU**: `1` = one CPU core; `100m` = 0.1 CPU. CPU is compressible; limits can throttle.
- **Memory**: `Mi`/`Gi` are binary units. Memory is not compressible; exceeding limit may result in OOMKilled.
- **Requests**: scheduler accounting and quota input. Not a hard cap.
- **Limits**: container upper bounds; not node capacity.
- **ResourceQuota**: aggregate namespace resource/object budget. `requests.cpu`, `requests.memory`, `limits.cpu`, `limits.memory`, `pods`, `services`, `secrets`, `configmaps`.
- **LimitRange**: per-container defaults, min and max; applied during admission to new objects, not retroactive.
- **Admission rejected**: API request fails; Pod is not scheduled.
- **Pending / FailedScheduling**: object admitted, scheduler cannot find a suitable node; inspect events and node allocatable/requested resources.
- **Runtime failure**: image pull, command, probes, config, or OOM after scheduling.

```bash
kubectl get ns
kubectl get pods -A
kubectl get resourcequota,limitrange -n namespace-quota-demo
kubectl describe resourcequota -n namespace-quota-demo
kubectl describe pod <pod> -n namespace-quota-demo
kubectl get events -n namespace-quota-demo --sort-by=.lastTimestamp
kubectl top pods -n namespace-quota-demo  # optional metrics API
```
