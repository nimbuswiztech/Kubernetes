# PowerShell equivalents for key checks

```powershell
helm version
kubectl version --client
kubectl config current-context
kubectl get nodes
helm lint .\charts\my-first-chart
helm template demo .\charts\my-first-chart -n helm-demo
helm install demo .\charts\my-first-chart -n helm-demo --create-namespace
helm list -n helm-demo
helm status demo -n helm-demo
kubectl get deployments,pods,services -n helm-demo
helm upgrade demo .\charts\my-first-chart -n helm-demo --set replicaCount=2
helm get values demo -n helm-demo
helm get manifest demo -n helm-demo
helm uninstall demo -n helm-demo
```

PowerShell commands are examples; confirm the current context and release before changing resources. The guarded Bash scripts require Bash/WSL/Git Bash.
