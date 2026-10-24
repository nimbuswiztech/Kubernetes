# Headless Service — One-Page Cheat Sheet

## Definition
A Headless Service is configured with `spec.clusterIP: None`. It has no virtual ClusterIP.

## Minimal YAML
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-headless
  namespace: headless-demo
spec:
  clusterIP: None
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: http
```

## Key commands
```bash
kubectl get svc -n headless-demo
kubectl get pods -n headless-demo -o wide --show-labels
kubectl describe svc backend-headless -n headless-demo
kubectl get endpointslice -n headless-demo
kubectl get endpoints backend-headless -n headless-demo
kubectl exec -n headless-demo deploy/headless-diagnostic -- nslookup backend-headless
kubectl exec -n headless-demo deploy/headless-diagnostic -- wget -qO- http://backend-headless:8080/
```

## Remember
- Service selector must match Pod labels.
- EndpointSlices track endpoint addresses and conditions.
- Selector-based Headless Service DNS typically returns eligible endpoint IPs.
- `cluster.local` is common but not guaranteed to be the cluster DNS domain.
- DNS answer order does not guarantee round-robin.
- DNS success does not guarantee application health/connectivity.
- A Headless Service alone does not provide StatefulSet identity.
