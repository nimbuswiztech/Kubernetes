# Troubleshooting Challenges
1. **HPA `<unknown>`:** inspect APIService, `kubectl top`, HPA conditions/events, Metrics Server health, requests and permissions.
2. **Pod Pending:** `kubectl describe pod`; inspect FailedScheduling, CPU/memory allocatable, taints, affinity, quota and fragmentation.
3. **No scale-up:** verify metric actually exceeds target relative to request, metrics are current, HPA target is correct and traffic targets lab Service.
4. **VPA no recommendation:** verify CRD, recommender health, targetRef, status and usage history.
5. **Unexpected Pod replacement:** inspect VPA update mode/events; return to Off only after confirming lab object and namespace.
```bash
kubectl describe hpa frontend-hpa -n autoscaling-demo
kubectl describe pod POD_NAME -n autoscaling-demo
kubectl get events -n autoscaling-demo --sort-by=.lastTimestamp
kubectl get apiservices v1beta1.metrics.k8s.io
kubectl top nodes
```
