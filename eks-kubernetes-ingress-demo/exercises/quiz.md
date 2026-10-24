# Quiz and Answers

## Five multiple-choice questions

**1. What does an Ingress resource primarily define?**
A. Container image builds  
B. HTTP/HTTPS routing rules  
C. Pod CPU usage  
D. Node operating system  
**Answer: B**

**2. What implements Ingress routing?**
A. Any Service automatically  
B. The Pod scheduler  
C. A compatible Ingress Controller  
D. The namespace  
**Answer: C**

**3. Which Service type is intended for internal cluster access by default?**
A. ClusterIP  
B. NodePort  
C. LoadBalancer  
D. Ingress  
**Answer: A**

**4. What is a likely reason a Service has no endpoints?**
A. Its name is short  
B. Its selector does not match Ready Pods  
C. The namespace has a label  
D. The cluster has two nodes  
**Answer: B**

**5. What does host-based routing inspect?**
A. Container hostname only  
B. HTTP Host header  
C. Node name  
D. Pod UID  
**Answer: B**

## Three beginner interview questions

**1. What is the difference between a Service and Ingress?**  
A Service gives stable access to matching Pods. Ingress defines HTTP/HTTPS routing rules to Services and needs a compatible controller.

**2. What is an Ingress Controller?**  
Software that watches Ingress resources and implements their routing behavior.

**3. How would you troubleshoot a Service with no endpoints?**  
Compare Service selectors with Pod labels, inspect Pod readiness, then review `kubectl describe svc` and EndpointSlices.

## Three troubleshooting exercises

**Exercise 1:** `kubectl get endpointslice -n ingress-demo` shows no endpoints for `frontend`. What do you check?  
**Answer:** `kubectl get pods --show-labels -n ingress-demo`, Service selector, and Pod readiness.

**Exercise 2:** An Ingress says `IngressClass not found`. What next?  
**Answer:** Run `kubectl get ingressclass`, use the exact confirmed class, and ask the cluster owner if no compatible class exists. Do not install a controller automatically.

**Exercise 3:** curl returns 404. What do you verify?  
**Answer:** Host header, URL path, rule, backend Service name/port, endpoint, and controller events/logs.

## Final hands-on assignment
Create a manifest for `shop.lab.example.com`: `/` routes to `frontend:80`; `/catalog` routes to `catalog:80`. Use `networking.k8s.io/v1`, `pathType: Prefix`, and a confirmed class placeholder. Explain why the controller is required. Apply only in an approved lab environment.
