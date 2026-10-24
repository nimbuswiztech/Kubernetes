# Kubernetes Headless Service — Basic Training Demo on Amazon EKS

A beginner-friendly, 60–90 minute hands-on lab using an **existing** EKS cluster. The project includes offline HTML teaching pages, Kubernetes manifests, safe Bash scripts, trainer notes, and student exercises.

## Learning outcomes
Students will be able to explain `clusterIP: None`, compare ClusterIP and Headless Services, inspect EndpointSlices, resolve Service DNS, compare DNS answers with Pod IPs, and test direct endpoint connectivity.

## Prerequisites
- An existing, reachable EKS cluster and permission to create namespaced resources.
- AWS CLI v2, `kubectl`, Bash, and internet access from cluster nodes to pull the demo image.
- A current Kubernetes context deliberately selected by the trainer.
- Two replicas' worth of cluster capacity (the Deployment requests small resources).

## Start safely
1. Review `TRAINER-GUIDE.md`.
2. Run the read-only check: `bash scripts/00-check-environment.sh`.
3. If the namespace already exists or contains resources, review it manually before proceeding. Do not blindly apply or clean up.
4. If the environment is safe, apply the resources:
   ```bash
   bash scripts/01-setup.sh
   ```
5. Open `html/index.html` directly in a browser. No web server or internet is required for the teaching pages.

## Main demonstration
```bash
kubectl get pods -n headless-demo -o wide
kubectl get svc -n headless-demo
kubectl get endpointslice -n headless-demo
kubectl exec -n headless-demo deploy/headless-diagnostic -- nslookup backend-headless
kubectl exec -n headless-demo deploy/headless-diagnostic -- wget -qO- http://backend-headless:8080/
```

The diagnostic Deployment is created only when the setup script is run. BusyBox commonly provides `nslookup` and `wget`; if the image or cluster environment differs, use the fallback instructions in the HTML pages and trainer guide.

## Important notes
- A Headless Service does not have a virtual ClusterIP and does not provide the usual Service-level virtual-IP routing/load-balancing behavior.
- DNS returns endpoint addresses for a selector-based Headless Service when eligible endpoints exist; answer order is not a round-robin guarantee.
- DNS success does not prove application health or connectivity.
- Example outputs are illustrative; actual IPs, DNS suffixes, image status, and timings vary by cluster.
- `cluster.local` is common but not universal. Check the cluster's DNS domain if needed.
- The cleanup script deletes only explicitly named lab resources after confirmation. It refuses broad namespace deletion.

## Project contents
See the complete project tree in `TRAINER-GUIDE.md` and the HTML index in `html/index.html`.

## Official documentation
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Kubernetes EndpointSlices](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/)
- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
