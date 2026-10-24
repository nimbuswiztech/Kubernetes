# Helm Basics Cheat Sheet

## Environment
```bash
helm version
kubectl version --client
kubectl config current-context
kubectl get nodes
helm list -n helm-demo
```

## Repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm search repo nginx
helm repo update
helm show chart bitnami/nginx
helm repo remove bitnami
```
Repository commands change local Helm configuration, not cluster resources.

## Local chart workflow
```bash
helm lint ./charts/my-first-chart
helm template demo ./charts/my-first-chart -n helm-demo
helm template demo ./charts/my-first-chart -n helm-demo --set replicaCount=2
```

## Release management
```bash
helm install demo ./charts/my-first-chart -n helm-demo --create-namespace
helm list -n helm-demo
helm status demo -n helm-demo
helm get values demo -n helm-demo
helm get manifest demo -n helm-demo
helm upgrade demo ./charts/my-first-chart -n helm-demo --set replicaCount=2
helm uninstall demo -n helm-demo
```
Always confirm the context, namespace, and release before making changes.
