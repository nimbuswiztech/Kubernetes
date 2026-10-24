# ServiceAccount & RBAC Cheat Sheet

## The five objects
- **ServiceAccount** — namespaced workload identity.
- **Role** — namespaced permission rules.
- **ClusterRole** — cluster-scoped rule object; may describe namespaced or cluster-scoped resources.
- **RoleBinding** — namespaced grant of a Role or ClusterRole in one namespace.
- **ClusterRoleBinding** — cluster-wide grant of a ClusterRole.

## Rule shape
```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```
Core API group is `""`. Subresources are explicit, e.g. `pods/log`, `pods/exec`.

## Useful safe checks
```bash
aws sts get-caller-identity
kubectl config current-context
kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}'
kubectl auth can-i get pods -n rbac-demo
kubectl auth can-i list secrets -n rbac-demo
kubectl auth can-i get nodes
kubectl get serviceaccounts -n rbac-demo
kubectl get roles -n rbac-demo
kubectl get rolebindings -n rbac-demo
kubectl describe role pod-reader -n rbac-demo
kubectl describe rolebinding pod-reader-binding -n rbac-demo
kubectl get events -n rbac-demo --sort-by=.lastTimestamp
```
Impersonation example, only if authorized:
```bash
kubectl auth can-i list pods -n rbac-demo --as=system:serviceaccount:rbac-demo:demo-reader
```
Never print token files or Secret data.

## Troubleshooting
1. Verify AWS profile, identity and region.
2. Verify kubectl context and endpoint.
3. `Unauthorized`: authentication/credential/EKS mapping.
4. `Forbidden`: authorization, subject, verb, resource, namespace, bindings.
5. Admission rejection: inspect event/message and admission policy.
6. `can-i yes` but app fails: token mount/rotation, network, TLS, API discovery, app code.
7. AWS API failure: IRSA/Pod Identity and IAM policy/trust/association, separate from Kubernetes RBAC.

## PowerShell equivalents
```powershell
aws sts get-caller-identity
aws eks list-clusters --region <region>
kubectl config current-context
kubectl version
kubectl get serviceaccounts -n rbac-demo
kubectl get roles -n rbac-demo
kubectl get rolebindings -n rbac-demo
kubectl auth can-i get pods -n rbac-demo
kubectl auth can-i list secrets -n rbac-demo
kubectl get events -n rbac-demo --sort-by=.lastTimestamp
# Filter object names/subjects without displaying credential data:
kubectl get clusterrolebindings -o custom-columns='NAME:.metadata.name,ROLE:.roleRef.name'
```
