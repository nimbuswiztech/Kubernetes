# Student Lab — EKS Storage (Instructor-supervised)

## Goals
- Compare container filesystem, `emptyDir`, `hostPath`, and PV/PVC.
- Observe container restart versus Pod replacement.
- Explain static versus dynamic provisioning and reclaim policy.
- Diagnose Pending, scheduling, attach, mount and permission failures safely.

## Lab 0 — Read-only discovery
```bash
./scripts/00-check-eks-environment.sh
kubectl get nodes -o wide
kubectl get pv
kubectl get pvc -A
kubectl get storageclass
kubectl get csidrivers
```
Record: cluster version, number of Ready nodes, node zones, default StorageClass, provisioner, binding mode, reclaim policy, CSI health, and any quota constraints.

## Lab 1 — emptyDir
```bash
./scripts/01-setup.sh
kubectl apply -f manifests/01-emptydir-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo emptydir-demo -- sh -c 'echo marker > /work/marker.txt; cat /work/marker.txt'
```
Predict and test: container restart vs Pod deletion/recreation. Use the script for the supervised restart/replacement experiment.

## Lab 2 — Shared Pod volume
```bash
kubectl apply -f manifests/02-emptydir-shared-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-shared-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo emptydir-shared-demo -c reader -- cat /shared/message.txt
```

## Lab 3 — hostPath (optional, policy permitting)
```bash
./scripts/03-demo-hostpath.sh
```
If denied by policy, record the event and explain why policy should not be weakened for the lesson.

## Lab 4 — Dynamic provisioning (only after explicit instructor approval)
```bash
./scripts/05-demo-dynamic-provisioning.sh
kubectl apply -f manifests/08-dynamic-consumer-deployment.yaml
kubectl exec -n storage-demo deploy/storage-consumer -- sh -c 'echo persistent-marker > /data/marker.txt; cat /data/marker.txt'
kubectl get pvc,pv,pod -n storage-demo -o wide
kubectl get events -n storage-demo --sort-by=.lastTimestamp
```
Delete/recreate only the consumer Pod, verify the marker, and retain the PVC. Before claim deletion, inspect the bound PV reclaim policy and obtain instructor confirmation.

## Reflection
1. Why did the emptyDir marker disappear after Pod replacement?
2. Why can a Bound PVC still fail to mount?
3. What does `WaitForFirstConsumer` change?
4. What does the actual PV reclaim policy imply for backend data?
5. Which observations would change if the Pod landed in another Availability Zone?
