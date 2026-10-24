# Trainer Guide — Kubernetes Ingress Basics on EKS

## 60–90 minute plan
- 0–10 min: Explain Service vs Ingress; open `html/index.html`.
- 10–20 min: Run read-only environment validation.
- 20–35 min: Deploy two demo apps and inspect Services/EndpointSlices.
- 35–50 min: Test Services from a temporary curl Pod.
- 50–65 min: Inspect controller and IngressClass. If a compatible controller exists and the class is confirmed, demonstrate host routing.
- 65–75 min: Demonstrate path routing if the controller supports it.
- 75–90 min: Troubleshooting, quiz, and cleanup.

## Safe preparation checklist
- [ ] Confirm the AWS account/role and region.
- [ ] Confirm `kubectl config current-context` is the intended existing EKS cluster.
- [ ] Confirm namespace `ingress-demo` is dedicated to this lab and does not contain unrelated resources.
- [ ] Run `bash scripts/00-check-environment.sh`; review controller, IngressClass, nodes, and existing Ingresses.
- [ ] Ask cluster owner whether an approved compatible controller is installed.
- [ ] If an AWS-backed controller may provision a load balancer, obtain explicit approval for possible AWS charges.
- [ ] Do not install a controller or alter shared resources during the beginner session.
- [ ] Keep the example hostname private to the lab; DNS is not required for Host-header testing.

## Environment decision
1. **Compatible controller and class available:** use the actual class name in `manifests/03-host-ingress.yaml` and `manifests/04-path-ingress.yaml`, then follow the live demo. Confirm whether the controller provisions an AWS endpoint and whether costs are approved.
2. **No controller/class:** teach the complete Ingress YAML without applying it, or apply only in a separate approved sandbox where it is known that no billable resources will be created. An Ingress object alone does not implement routing.
3. **Controller exists but its class/behavior is unclear:** stop before applying. Ask the cluster administrator. Do not guess controller names or class names.

## Demo app design
Two NGINX Deployments mount an HTML page from a ConfigMap and return distinct text. Both use ClusterIP Services. This keeps the first practical internal-only and avoids creating external AWS resources.

## Trainer speaking script
### Practical A — Preflight (read-only)
**Before:** “We are going to inspect the existing cluster first. These commands do not create or modify resources. We must know which cluster and account we are connected to before changing anything.”
**Execute:** `bash scripts/00-check-environment.sh`
**Expected:** AWS identity/region (AWS CLI may be unconfigured), current context, cluster connectivity, node readiness, namespace status, Ingresses, IngressClasses, Services, and likely controller Pods.
**After:** “A controller is not guaranteed just because Kubernetes supports the Ingress API. We will use the discovered class only if it is confirmed compatible.”
**Question:** “Does this script create a load balancer?” **Answer:** No; it is read-only.

### Practical B — Deploy apps and inspect Services
**Before:** “A Service gives stable discovery and load balancing to matching Pods. We'll create two small apps in our dedicated namespace.”
**Execute one at a time:**
```bash
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-demo-apps.yaml
kubectl apply -f manifests/02-services.yaml
kubectl rollout status deployment/frontend -n ingress-demo --timeout=120s
kubectl rollout status deployment/catalog -n ingress-demo --timeout=120s
kubectl get pods -n ingress-demo -o wide
kubectl get svc -n ingress-demo
kubectl get endpointslice -n ingress-demo
kubectl describe svc frontend -n ingress-demo
```
`apply` changes namespaced resources. `get`, `rollout status`, and `describe` are observational.
**Expected:** Two Ready Pods, Services `frontend` and `catalog` with type `ClusterIP`, and EndpointSlices with Pod IPs.
**After:** “The Service selector matches the Pod labels. The Service is internal; it does not by itself create a public endpoint.”
**Question:** “What happens if the selector does not match any Pod?” **Answer:** The Service has no endpoints.

### Practical C — Test Services inside the cluster
**Before:** “ClusterIP is reachable from inside the cluster. We'll use a temporary curl Pod, then remove it.”
**Execute:**
```bash
kubectl run curl-check -n ingress-demo --image=curlimages/curl:8.10.1 --restart=Never --rm -it -- sh
```
At its shell:
```sh
curl -sS http://frontend/
curl -sS http://catalog/
exit
```
This creates a temporary Pod and `--rm` removes it when the session exits. If interactive TTY is unavailable, use:
```bash
kubectl run curl-check -n ingress-demo --image=curlimages/curl:8.10.1 --restart=Never --command -- sh -c 'curl -sS http://frontend/; echo; curl -sS http://catalog/; echo'
kubectl logs curl-check -n ingress-demo
kubectl delete pod curl-check -n ingress-demo --ignore-not-found
```
**Expected:** `Hello from Frontend` and `Hello from Catalog` (may be surrounded by HTML).
**After:** “Service DNS names resolve inside the namespace. This is an internal test; no external load balancer is required.”
**Question:** “Can a laptop directly reach a ClusterIP by default?” **Answer:** No, not without a network path into the cluster.

### Practical D — Host-based Ingress
**Before:** “Ingress is a set of HTTP routing rules. A compatible controller watches the resource and implements those rules. We will only proceed if the class and controller are confirmed.”
**Execute after replacing `<DISCOVERED_CLASS>` with the confirmed class and checking cost approval:**
```bash
kubectl apply -f manifests/03-host-ingress.yaml
kubectl get ingress -n ingress-demo
kubectl describe ingress frontend-host -n ingress-demo
kubectl get events -n ingress-demo --sort-by=.lastTimestamp
```
Discover the endpoint:
```bash
kubectl get ingress frontend-host -n ingress-demo -o wide
kubectl get ingress frontend-host -n ingress-demo -o jsonpath='{.status.loadBalancer.ingress[*].hostname}{" "}{.status.loadBalancer.ingress[*].ip}{"\n"}'
```
If an endpoint is present, set `INGRESS_ENDPOINT` to its hostname/IP and test:
```bash
curl -i -H 'Host: frontend.lab.example.com' "http://${INGRESS_ENDPOINT}/"
```
For PowerShell:
```powershell
$IngressEndpoint = "<endpoint-from-status>"
curl.exe -i -H "Host: frontend.lab.example.com" "http://$IngressEndpoint/"
```
**Expected:** An HTTP response containing `Hello from Frontend`. Endpoint and response headers vary by controller.
**After:** “The Host header selects the matching rule. The rule forwards to the `frontend` Service, which selects its Pods.”
**Question:** “Does the Ingress YAML itself run a proxy?” **Answer:** No; the controller implements the rules.

### Practical E — Path-based Ingress
**Before:** “The same hostname can route different paths to different Services. Prefix means a path prefix match, not an exact-only match.”
**Execute after class confirmation and cost approval:**
```bash
kubectl apply -f manifests/04-path-ingress.yaml
kubectl describe ingress demo-paths -n ingress-demo
kubectl get ingress demo-paths -n ingress-demo
```
Test:
```bash
curl -i -H 'Host: frontend.lab.example.com' "http://${INGRESS_ENDPOINT}/"
curl -i -H 'Host: frontend.lab.example.com' "http://${INGRESS_ENDPOINT}/catalog"
```
PowerShell:
```powershell
curl.exe -i -H "Host: frontend.lab.example.com" "http://$IngressEndpoint/"
curl.exe -i -H "Host: frontend.lab.example.com" "http://$IngressEndpoint/catalog"
```
**Expected:** `/` returns Frontend; `/catalog` returns Catalog. Controller defaults may affect unmatched paths.
**After:** “Ingress routes to Services. The application receives the path as-is here; we did not configure rewrite annotations.”
**Question:** “Which Service receives `/catalog`?” **Answer:** `catalog`.

## Troubleshooting — non-destructive first
- Pod not Ready: `kubectl describe pod <pod> -n ingress-demo`; `kubectl logs <pod> -n ingress-demo`; check image pull errors and readiness.
- Service has no endpoints: compare `kubectl get pods --show-labels -n ingress-demo` with `kubectl describe svc <service> -n ingress-demo`; selectors must match Ready Pods.
- IngressClass not found: `kubectl get ingressclass`; use the exact discovered class or stop and ask the administrator.
- No controller: `kubectl get pods -A | grep -Ei 'ingress|alb|nginx|traefik'` (PowerShell: `kubectl get pods -A | Select-String -Pattern 'ingress|alb|nginx|traefik'`). Search results are clues, not proof; ask the cluster owner to confirm.
- No endpoint: check `kubectl describe ingress`; controller events/logs, permissions, and controller-specific status. Do not install or alter a controller during this lab.
- Wrong hostname/path: verify Host header, rule host, path, and service/port names.
- HTTP 404: often wrong Host/path or controller default backend; inspect rules and controller logs.
- Reconciliation failure: inspect Ingress events and controller logs with administrator approval. Avoid changing shared resources.

## Cleanup
Run `bash scripts/04-cleanup.sh`. It verifies the current context and exact namespace, lists resources, warns about possible AWS cleanup, and requires typing the namespace name. It deletes only the dedicated `ingress-demo` namespace and its namespaced lab resources. Do not use this if the namespace contains anything not owned by this lab.
