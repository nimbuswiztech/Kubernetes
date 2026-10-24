# HPA / VPA Cheat Sheet
- Horizontal: change replica count. Vertical: change/recommend container requests/limits. Cluster scaling: add/remove worker capacity.
- HPA CPU utilization is usage relative to requested CPU, not node CPU. Requests matter for scheduling and utilization calculations.
- Metrics Server supplies recent metrics for `kubectl top` and autoscaling; it is not historical monitoring or alerting.
- HPA maxReplicas limits desired replicas; it does not guarantee scheduling or readiness and does not add nodes.
- VPA `Off`: recommendation only. `Initial`: new Pods. `Recreate`: may evict/recreate Pods. Verify semantics for installed release.
- VPA is separate from EKS and requires CRD plus healthy components. A recommendation is not a capacity reservation.
- HPA and VPA may interact when VPA changes a resource used by HPA utilization. Recommendation-only is a safer first step.
```bash
kubectl get hpa -n autoscaling-demo
kubectl describe hpa frontend-hpa -n autoscaling-demo
kubectl top nodes
kubectl top pods -n autoscaling-demo
kubectl get pods -n autoscaling-demo -o wide
kubectl describe pod POD_NAME -n autoscaling-demo
kubectl get events -n autoscaling-demo --sort-by=.lastTimestamp
kubectl api-resources | grep -i verticalpodautoscaler
```
