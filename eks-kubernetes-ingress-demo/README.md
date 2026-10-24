# Kubernetes Ingress Basic Training Demo (Amazon EKS)

Beginner-friendly, 60–90 minute lab using an **existing** EKS cluster. This project does not create a cluster or install a controller.

## Quick start
1. Unzip the project.
2. Read `TRAINER-GUIDE.md` and the safety checklist.
3. Run the read-only preflight: `bash scripts/00-check-environment.sh`.
4. Review its findings. If there is no suitable controller, use the learning-only fallback in the trainer guide; do not apply an Ingress expecting it to work.
5. If approved and the namespace is safe to use, run `bash scripts/01-setup.sh`.
6. Test Services with `bash scripts/02-test-services.sh`.
7. Apply one Ingress example at a time only after confirming a compatible controller and class. See `scripts/03-test-ingress.sh` and the HTML lesson pages.
8. Clean up with `bash scripts/04-cleanup.sh`.

## What is included
- Offline HTML lesson pages in `html/` with local CSS and navigation.
- Namespaced demo Deployments and ClusterIP Services.
- Read-only environment checks, basic tests, and guarded cleanup scripts.
- Student lab, cheat sheet, quiz, and trainer speaking guide.

## Important safety notes
- These commands target the current `kubectl` context. Confirm it before every change.
- The preflight is read-only. The setup script creates namespaced lab resources, after checking the namespace is empty or already clearly owned by this lab.
- An AWS-backed Ingress can create billable AWS resources when reconciled by a controller. Obtain explicit approval before creating one.
- Never install a cluster-wide controller as part of this beginner demo without cluster-admin approval and a reviewed plan.
- `frontend.lab.example.com` is an example hostname, not a real DNS record. Use `curl -H 'Host: ...'` to test routing without public DNS.

## Requirements
AWS CLI, kubectl, Bash, access to an existing EKS cluster, and permission to create resources in `ingress-demo`. The demo image is `nginx:stable-alpine`; it serves a custom HTML response through a ConfigMap-mounted page. Pulling the image requires cluster egress or a cached image.

## Official docs
- Kubernetes Services: https://kubernetes.io/docs/concepts/services-networking/service/
- Kubernetes Ingress: https://kubernetes.io/docs/concepts/services-networking/ingress/
- Kubernetes IngressClass: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class
- Amazon EKS load balancing: https://docs.aws.amazon.com/eks/latest/userguide/eks-networking.html
- AWS Load Balancer Controller: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html


## PowerShell equivalents (important commands)
```powershell
kubectl config current-context
kubectl get nodes
kubectl get ingressclass
kubectl get pods -n ingress-demo
kubectl get svc -n ingress-demo
kubectl get endpointslice -n ingress-demo
kubectl describe svc frontend -n ingress-demo
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-demo-apps.yaml
kubectl apply -f manifests/02-services.yaml
curl.exe -i -H "Host: frontend.lab.example.com" "http://<INGRESS_ENDPOINT>/"
```
The Bash scripts require Bash (for example, WSL or Git Bash on Windows). Run individual `kubectl` commands from PowerShell as needed.
