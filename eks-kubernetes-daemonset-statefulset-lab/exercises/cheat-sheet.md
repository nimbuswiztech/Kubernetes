# Kubernetes controller cheat sheet

## Inspect
```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl get ds,sts,deploy -A
kubectl get pods -n daemonset-statefulset-demo -o wide
kubectl get events -n daemonset-statefulset-demo --sort-by=.lastTimestamp
```

## DaemonSet
```bash
kubectl get ds -n daemonset-statefulset-demo
kubectl describe ds node-observer -n daemonset-statefulset-demo
kubectl rollout status ds/node-observer -n daemonset-statefulset-demo
kubectl rollout history ds/node-observer -n daemonset-statefulset-demo
kubectl annotate ds/node-observer training.example.com/change="$(date +%s)" --overwrite -n daemonset-statefulset-demo
kubectl rollout undo ds/node-observer -n daemonset-statefulset-demo
```

## StatefulSet / Service / PVC
```bash
kubectl get sts,svc,pods,pvc -n daemonset-statefulset-demo -o wide
kubectl describe sts ledger -n daemonset-statefulset-demo
kubectl rollout status sts/ledger -n daemonset-statefulset-demo
kubectl rollout history sts/ledger -n daemonset-statefulset-demo
kubectl rollout undo sts/ledger -n daemonset-statefulset-demo
kubectl describe pvc data-ledger-0 -n daemonset-statefulset-demo
kubectl exec -n daemonset-statefulset-demo ledger-0 -- tail -n 5 /data/heartbeat.log
```

## Troubleshoot
```bash
kubectl describe pod <pod> -n daemonset-statefulset-demo
kubectl logs <pod> -n daemonset-statefulset-demo
kubectl logs <pod> -n daemonset-statefulset-demo --previous
kubectl get events -n daemonset-statefulset-demo --sort-by=.lastTimestamp
kubectl get pv -o wide
kubectl get storageclass -o wide
```

## Rules of thumb
- DaemonSet: one Pod per eligible node.
- StatefulSet: stable ordinal identity and ordered lifecycle.
- Headless Service: `clusterIP: None`, endpoint DNS; no single virtual ClusterIP.
- PVC is a request for storage; PV is the provisioned/bound resource.
- StatefulSet PVCs are retained by default when a Pod or StatefulSet is deleted.
- `kubectl get nodes` capacity is not spare capacity.
