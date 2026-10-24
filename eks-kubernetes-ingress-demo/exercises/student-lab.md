# Student Lab: Kubernetes Ingress Basics

## Goals
- Explain Ingress, Services, and Ingress Controllers.
- Deploy two apps and test their ClusterIP Services.
- Read host/path routing rules and diagnose common errors.

## Part A — Inspect
1. Run `bash scripts/00-check-environment.sh`.
2. Write down the current context and Ready node count.
3. Record any IngressClass names and whether the cluster owner confirms a compatible controller.
4. Do not install a controller or apply Ingress if the prerequisite is uncertain.

## Part B — Deploy and test Services
1. Follow `bash scripts/01-setup.sh`.
2. Run `kubectl get pods -n ingress-demo`.
3. Run `kubectl get svc -n ingress-demo`.
4. Run `kubectl get endpointslice -n ingress-demo`.
5. Use a temporary curl Pod to request `http://frontend/` and `http://catalog/`.
6. Explain how Service selectors connect a Service to Pods.

## Part C — Ingress
Only if the class/controller is confirmed and any AWS charges are approved:
1. Replace `<DISCOVERED_CLASS>` in the host manifest.
2. Apply `manifests/03-host-ingress.yaml`.
3. Inspect status, events, and endpoint.
4. Test with a Host header.
5. Apply `manifests/04-path-ingress.yaml` and test `/` and `/catalog`.

If no suitable controller exists, read the manifests and explain why they do not create a working route by themselves.

## Final assignment
Write an Ingress manifest for `shop.lab.example.com` where `/` routes to `frontend:80` and `/catalog` routes to `catalog:80`. Include a correct `ingressClassName` placeholder and explain the controller prerequisite. Do not apply it unless approved.

## Cleanup
Run `bash scripts/04-cleanup.sh` only if `ingress-demo` contains lab-owned resources only.
