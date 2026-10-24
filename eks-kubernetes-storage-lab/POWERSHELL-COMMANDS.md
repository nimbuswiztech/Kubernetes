# PowerShell quick equivalents

```powershell
aws sts get-caller-identity
aws eks list-clusters --region $env:AWS_REGION
kubectl config current-context
kubectl version
kubectl get nodes -o wide
kubectl get nodes -L topology.kubernetes.io/zone,topology.kubernetes.io/region
kubectl get pv
kubectl get pvc -A
kubectl get storageclass -o wide
kubectl get pods,deployments,statefulsets -A -o wide
kubectl get events -n storage-demo --sort-by=.lastTimestamp
kubectl describe pvc <claim-name> -n storage-demo
kubectl describe pod <pod-name> -n storage-demo
```

PowerShell does not directly run the Bash scripts. Use these commands for discovery/filtering, or run the scripts in a Bash-compatible shell such as CloudShell, Linux, or WSL.
