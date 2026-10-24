# Student Lab: Your First Helm Chart

## Goal
Create, render, install, change, inspect, and remove a simple NGINX app using the chart in `charts/my-first-chart`.

## Safety checks
1. Run `./scripts/00-check-environment.sh`.
2. Confirm the current Kubernetes context and EKS cluster with your trainer.
3. Do not continue with cluster commands until the context is confirmed.

## Tasks
1. Run `helm version`.
2. Run `helm lint ./charts/my-first-chart`.
3. Render defaults: `helm template demo ./charts/my-first-chart -n helm-demo`.
4. Render two replicas: `helm template demo ./charts/my-first-chart -n helm-demo --set replicaCount=2`.
5. Install: `helm install demo ./charts/my-first-chart -n helm-demo --create-namespace`.
6. Verify: `helm list -n helm-demo` and `kubectl get deployments,pods,services -n helm-demo`.
7. Upgrade: `helm upgrade demo ./charts/my-first-chart -n helm-demo --set replicaCount=2`.
8. Inspect: `helm status demo -n helm-demo`, `helm get values demo -n helm-demo`, and `helm get manifest demo -n helm-demo`.
9. With trainer approval, run `./scripts/05-cleanup.sh`.

## Reflection
- What is the difference between a chart and a release?
- Which file defines defaults?
- What did `helm template` do without contacting the cluster?
