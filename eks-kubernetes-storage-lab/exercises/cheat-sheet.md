# Kubernetes Storage — One-page Cheat Sheet

| Object/type | Scope / meaning | Typical persistence |
|---|---|---|
| Container writable layer | One container's writable filesystem | Not a durable data store; container replacement loses it |
| `emptyDir` | Pod volume created on its node | Survives container restart; lost when Pod is removed |
| `hostPath` | Path on the selected worker node | Node-local; not portable; security-sensitive |
| PV | Cluster-scoped resource representing storage | Depends on backend and reclaim/lifecycle |
| PVC | Namespaced request for capacity/access | Claim object is separate from backend data |
| StorageClass | Provisioner + parameters + policy | Enables dynamic provisioning |
| CSI driver | Implements storage operations for Kubernetes | Exact behavior depends on driver/backend |

## Fast commands
```bash
kubectl get pvc -n storage-demo
kubectl describe pvc <claim> -n storage-demo
kubectl get pv -o wide
kubectl describe pv <pv>
kubectl get storageclass -o yaml
kubectl get pods -n storage-demo -o wide
kubectl describe pod <pod> -n storage-demo
kubectl get events -n storage-demo --sort-by=.lastTimestamp
kubectl get csidrivers
kubectl get csinodes
```

## Lifecycle
PVC created → PV matched or dynamically provisioned → Bound → Pod scheduled → attach (if required) → mount → application I/O → Pod may be replaced while PVC remains → claim deletion invokes reclaim behavior.

## Common checks
- `Pending`: class, provisioner, events, capacity, access mode, selector, binding mode, topology, quota.
- `Bound` but Pod pending: scheduler events, AZ/node affinity, taints, CPU/memory and attachment limits.
- `ContainerCreating`: `FailedAttachVolume` / `FailedMount`, CSI node plugin, filesystem, permissions.
- `Permission denied`: UID/GID, directory ownership, read-only mount, security context, filesystem semantics.
- Before deleting PVC: identify bound PV, inspect reclaim policy and backend consequences.
