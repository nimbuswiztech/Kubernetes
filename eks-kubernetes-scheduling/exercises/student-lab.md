# Student lab: EKS scheduling

## Objectives
Use an existing EKS cluster to explain and verify nodeSelector, node affinity, Pod affinity, Pod anti-affinity, taints and tolerations. Do not modify shared nodes.

## Part 1 — Read-only discovery
```bash
./scripts/00-check-eks-environment.sh
kubectl get nodes --show-labels
kubectl describe nodes
kubectl get pods -A -o wide
```
Write down node names, Ready status, zone labels, hostnames, taints, allocatable CPU/memory, and whether workloads appear shared. Do not guess the AZ layout.

## Part 2 — Namespace and baseline
```bash
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/04-backend.yaml
kubectl -n scheduling-demo get pods -o wide
```
Prediction: Where can backend run? Answer: Any node satisfying resources, taints and other constraints; this manifest does not specify a node.

## Part 3 — nodeSelector (label mutation optional and isolated only)
First select an approved dedicated lab node. Do not use a shared/production worker for mutation. If safe and approved, record the node name and check the key does not already exist:
```bash
kubectl get nodes --show-labels
kubectl get node <LAB_NODE> -o jsonpath='{.metadata.labels.training\.example\.com/workload}'
```
If the output is empty and the node is approved, add the scoped label:
```bash
kubectl label node <LAB_NODE> training.example.com/workload=demo
kubectl apply -f manifests/01-node-selector.yaml
kubectl -n scheduling-demo get pod selector-demo -o wide
kubectl -n scheduling-demo describe pod selector-demo
```
Negative test: if no node matches, create a Pod with a nonexistent label or temporarily change only the lab manifest in a copy. Observe Pending and the `FailedScheduling` event. Do not alter operational labels. Cleanup only the lab Pod and, if you personally added it, the exact label:
```bash
kubectl -n scheduling-demo delete pod selector-demo --ignore-not-found
kubectl label node <LAB_NODE> training.example.com/workload-
```
Only run the final label removal if you verified the lab created that exact label and no other person now relies on it.

## Part 4 — required and preferred node affinity
```bash
kubectl apply -f manifests/02-node-affinity-required.yaml
kubectl apply -f manifests/03-node-affinity-preferred.yaml
kubectl -n scheduling-demo get pods -o wide
kubectl -n scheduling-demo describe pod required-affinity-demo
```
The required example uses `In` for the scoped workload label and `Exists` for hostname. Without the scoped label, Pending is expected. The preferred example favors amd64 and the existence of a zone label; these are preferences and actual placement depends on available labels/resources.

## Part 5 — Pod affinity
```bash
kubectl apply -f manifests/04-backend.yaml
kubectl apply -f manifests/05-pod-affinity.yaml
kubectl -n scheduling-demo get pods -o wide
kubectl -n scheduling-demo describe pod -l app=frontend-affinity
```
The frontend requires a matching `app=backend` Pod in `scheduling-demo` on the same hostname domain. If the backend does not exist or cannot schedule, the frontend can remain Pending. For zone affinity, inspect whether the nodes have different zone labels first.

## Part 6 — Pod anti-affinity
```bash
kubectl apply -f manifests/06-pod-anti-affinity.yaml
kubectl -n scheduling-demo get pods -o wide
```
Expected with two eligible hostnames and sufficient capacity: two replicas on different nodes. Then edit the Deployment to `replicas: 3` and apply it, or run:
```bash
kubectl -n scheduling-demo scale deployment spread-demo --replicas=3
kubectl -n scheduling-demo get pods -o wide
kubectl -n scheduling-demo describe pod <PENDING_POD>
kubectl -n scheduling-demo get events --sort-by=.lastTimestamp
```
With required hostname anti-affinity, the third matching replica cannot share either hostname and can remain Pending. Fix by restoring two replicas, adding an eligible node, or changing the rule to preferred anti-affinity in a lab copy.

## Part 7 — taints and tolerations
Do not taint a shared node. If no dedicated lab node is available, teach the YAML and scheduler reasoning without changing the cluster. On a dedicated node only, first record current taints and labels, then have the administrator/instructor add `training.example.com/dedicated=demo:NoSchedule` and a corresponding node label if needed. Compare a Pod without a toleration to `manifests/07-taints-tolerations.yaml`. A toleration allows scheduling but does not guarantee placement; add matching `nodeSelector` only to a copy and only if the node label was intentionally added. Remove only the exact lab-created taint, for example `kubectl taint node <LAB_NODE> training.example.com/dedicated=demo:NoSchedule-`, after confirming the key/value/effect were lab-created.

Effects: `NoSchedule` blocks new non-tolerating Pods; `PreferNoSchedule` is soft avoidance; `NoExecute` can evict existing non-tolerating Pods. Do not demonstrate NoExecute on shared nodes.

## Part 8 — combined scenario
After the scoped workload label is present on an approved lab node:
```bash
kubectl apply -f manifests/08-combined-scenario.yaml
kubectl -n scheduling-demo get pods -o wide
kubectl -n scheduling-demo describe pods
```
Backend has hard nodeSelector targeting the scoped label and preferred hostname anti-affinity. Frontend prefers same-hostname placement near backend. If only one node has the label, two backend replicas may run on the same node because anti-affinity is preferred, not required.

## Cleanup
```bash
kubectl get all -n scheduling-demo
./scripts/03-cleanup.sh
```
Remove a custom label/taint only if you recorded that exact lab-created mutation. Never remove existing system or unrelated taints.
