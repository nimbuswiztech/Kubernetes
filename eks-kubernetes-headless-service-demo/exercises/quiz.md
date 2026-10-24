# Quiz — Headless Services

## Multiple-choice questions

**1. Which field makes a Service Headless?**  
A. `type: NodePort`  
B. `clusterIP: None`  
C. `port: None`  
D. `selector: None`  
**Answer:** B.

**2. What does a selector do in this lab?**  
A. Changes the cluster DNS domain  
B. Chooses the EKS node  
C. Matches Pods using labels  
D. Installs a DNS server  
**Answer:** C.

**3. What does a selector-based Headless Service DNS query typically return when eligible endpoints exist?**  
A. Only the node IP  
B. The Service's virtual ClusterIP  
C. Individual endpoint IP addresses  
D. An external load balancer address  
**Answer:** C.

**4. Does DNS answer order guarantee round-robin traffic distribution?**  
A. Yes, always  
B. No  
C. Only on EKS  
D. Only with two replicas  
**Answer:** B.

**5. Which resource is the modern API for tracking Service endpoint sets?**  
A. EndpointSlice  
B. IngressClass  
C. ConfigMap  
D. StorageClass  
**Answer:** A.

## Beginner interview questions

**1. What is a Headless Service?**  
A Kubernetes Service configured with `clusterIP: None`, so it does not have a virtual ClusterIP and can support endpoint discovery through DNS.

**2. Why are Headless Services used with StatefulSets?**  
They can help peers discover individual Pods, while StatefulSets provide stable ordinal Pod identity.

**3. DNS resolves but HTTP fails. What do you check?**  
Pod readiness, application listening port, Service `targetPort`, endpoint membership, Pod logs, network policies, and direct endpoint connectivity.

## Troubleshooting exercises

**Exercise 1: DNS returns no endpoint addresses.**  
**Solution:** Check Service exists in the correct namespace, compare selector with Pod labels, inspect Pod readiness, and inspect EndpointSlices.

**Exercise 2: `kubectl exec ... nslookup` says command not found.**  
**Solution:** Check available tools with `command -v nslookup` and use a suitable approved diagnostic image. Do not assume all images contain DNS tools.

**Exercise 3: DNS succeeds but the request times out.**  
**Solution:** Confirm endpoint IP and port, check readiness and application logs, test the normal Service and direct Pod IP, and inspect applicable NetworkPolicies.

## Final hands-on assignment
Create a second Headless Service named `backend-headless-lab2` in a trainer-approved test namespace, selecting a second simple workload. Verify its `CLUSTER-IP`, selector, EndpointSlices, DNS response, and direct connectivity. Do not modify the shared training resources without permission.
