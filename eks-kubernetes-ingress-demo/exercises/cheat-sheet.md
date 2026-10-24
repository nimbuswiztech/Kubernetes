# Kubernetes Ingress Cheat Sheet (one page)

## Mental model
**Client → Ingress Controller → Ingress rule → Service → matching Pods**

- **Pod:** runs one or more containers.
- **Service:** stable network name/IP and traffic distribution to matching Pods.
- **ClusterIP:** internal Service access.
- **NodePort:** exposes a Service on a port on each node.
- **LoadBalancer:** requests load-balancer integration; may incur cloud costs.
- **Ingress:** HTTP/HTTPS routing rules; requires a compatible controller.
- **IngressClass:** identifies the intended controller class.
- **Host routing:** route by `Host` header, e.g. `frontend.lab.example.com`.
- **Path routing:** route by URL path, e.g. `/catalog`.
- **Prefix:** matches a path prefix according to URL path elements.

## Read-only checks
```bash
kubectl config current-context
kubectl get nodes
kubectl get ingressclass
kubectl get ingress -A
kubectl get pods -A
kubectl get svc -n ingress-demo
kubectl get endpointslice -n ingress-demo
kubectl describe ingress frontend-host -n ingress-demo
kubectl get events -n ingress-demo --sort-by=.lastTimestamp
```

## Test internal Services
```bash
kubectl run curl-check -n ingress-demo --image=curlimages/curl:8.10.1 --restart=Never --rm -it -- sh
curl -sS http://frontend/
curl -sS http://catalog/
```

## Test Ingress
```bash
curl -i -H 'Host: frontend.lab.example.com' http://<INGRESS_ENDPOINT>/
curl -i -H 'Host: frontend.lab.example.com' http://<INGRESS_ENDPOINT>/catalog
```

## Common fixes
- No endpoints: check Pod labels, Service selector, readiness.
- No class/controller: stop; ask cluster admin, do not install one automatically.
- No endpoint: inspect Ingress events and controller status.
- 404: check Host, path, backend Service/port, and controller behavior.

## Safety
Confirm context before changes. An AWS-backed Ingress can incur charges. Never delete shared controllers or IngressClasses as part of this lab.
