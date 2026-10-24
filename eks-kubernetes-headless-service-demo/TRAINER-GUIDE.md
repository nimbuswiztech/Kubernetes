# Trainer Guide — Kubernetes Headless Service

## Session plan (60–90 minutes)
| Time | Activity |
|---|---|
| 0–10 min | Services and stable discovery |
| 10–20 min | ClusterIP vs Headless Service |
| 20–30 min | DNS and EndpointSlices |
| 30–40 min | Read-only environment checks and safe preparation |
| 40–55 min | Deploy and inspect |
| 55–70 min | DNS lookup and direct connectivity |
| 70–85 min | Troubleshooting and student exercises |
| 85–90 min | Recap and quiz |

## Complete project structure
```text
kubernetes-headless-service-demo/
├── README.md
├── TRAINER-GUIDE.md
├── assets/styles.css
├── html/
│   ├── index.html
│   ├── 01-service-introduction.html
│   ├── 02-what-is-headless-service.html
│   ├── 03-normal-vs-headless.html
│   ├── 04-architecture-and-dns.html
│   ├── 05-stateful-applications.html
│   ├── 06-creating-headless-service.html
│   ├── 07-inspecting-endpoints.html
│   ├── 08-testing-dns.html
│   ├── 09-direct-pod-connectivity.html
│   └── 10-troubleshooting-and-revision.html
├── manifests/
│   ├── 00-namespace.yaml
│   ├── 01-demo-deployment.yaml
│   ├── 02-normal-service.yaml
│   ├── 03-headless-service.yaml
│   └── 04-diagnostic-deployment.yaml
├── scripts/
│   ├── 00-check-environment.sh
│   ├── 01-setup.sh
│   ├── 02-inspect-service.sh
│   ├── 03-test-dns.sh
│   ├── 04-test-connectivity.sh
│   └── 05-cleanup.sh
└── exercises/
    ├── student-lab.md
    ├── cheat-sheet.md
    └── quiz.md
```

## Safe preparation checklist
- [ ] Confirm the intended AWS identity and region (`aws sts get-caller-identity`, `aws configure get region`).
- [ ] Confirm the current context (`kubectl config current-context`).
- [ ] Confirm the existing cluster is reachable (`kubectl cluster-info`).
- [ ] Confirm at least one worker node is Ready.
- [ ] Check whether `headless-demo` already exists.
- [ ] If it exists, inspect all resources and confirm it is safe to use. Do not overwrite or remove resources automatically.
- [ ] Ensure students understand that `kubectl apply` changes cluster state.
- [ ] Review cleanup targets before running cleanup.

## Trainer speaking script

### Module 1 — Service introduction
**Say:** “Pods can be replaced, and replacement Pods can receive different IP addresses. Applications need a dependable way to discover where to connect. A Kubernetes Service provides a stable discovery name and, for a normal ClusterIP Service, a virtual IP.”
**Read-only:** `kubectl get pods -n headless-demo -o wide` (after deployment).
**Expected:** Two Pods with their own IPs. IPs shown here are examples only.
**Ask:** “Should an application hard-code a Pod IP?” **Answer:** No; Pod IPs can change.

### Module 2 — Headless Service
**Say:** “A Headless Service is still a Service, but `clusterIP: None` means Kubernetes does not allocate a virtual ClusterIP for it. For a selector-based Service, DNS can return the IP addresses of eligible endpoints.”
**Read-only:** `kubectl get svc -n headless-demo`.
**Expected:** `frontend` has a ClusterIP; `backend-headless` shows `None`.
**Ask:** “Does the Headless Service automatically load-balance traffic?” **Answer:** No. Clients discover endpoints and choose how to connect.

### Module 3 — Compare Services
**Say:** “Both Services select the same Pods. The difference is how clients discover and reach them.”
**Read-only:** `kubectl get svc -n headless-demo -o wide`.
**Expected:** The normal Service has a virtual IP; the Headless Service does not.
**Ask:** “Who chooses an endpoint after a Headless DNS lookup?” **Answer:** Typically the client/application.

### Module 4 — Architecture and DNS
**Say:** “The client asks cluster DNS for the Service name. DNS may return multiple endpoint IPs. The client then connects to an address.”
**Read-only:** `kubectl get endpointslice -n headless-demo`.
**Expected:** EndpointSlice endpoint addresses correspond to eligible Pod IPs.
**Ask:** “Does DNS answer order guarantee round-robin?” **Answer:** No.

### Module 5 — Stateful applications
**Say:** “StatefulSets provide stable Pod identities and are often paired with a governing Headless Service. A Headless Service alone does not give a regular Deployment stable per-Pod names across replacements.”
**Read-only:** `kubectl get statefulsets -n headless-demo` (likely none).
**Ask:** “Which resource provides stable ordinal Pod identity?” **Answer:** StatefulSet.

### Module 6 — Create the lab
**Say:** “First we inspect the environment. Only after confirming the namespace is safe do we apply the manifests.”
**Read-only:** `bash scripts/00-check-environment.sh`.
**Changes state:** `bash scripts/01-setup.sh`; creates namespace-scoped lab resources.
**Expected:** Two demo application Pods and one diagnostic Pod become Ready.
**Ask:** “Why check the namespace first?” **Answer:** To avoid colliding with unrelated resources.

### Module 7 — Inspect endpoints
**Say:** “The Service selector matches labels on Pods. Kubernetes tracks eligible endpoints in EndpointSlices.”
**Read-only:** `bash scripts/02-inspect-service.sh`.
**Expected:** Endpoint addresses line up with ready Pod IPs; output varies.
**Ask:** “What is the first thing to check if there are no endpoints?” **Answer:** Selector/Pod labels and Pod readiness.

### Module 8 — DNS
**Say:** “Run the query from inside the cluster so it uses the cluster's configured DNS.”
**Read-only:** `bash scripts/03-test-dns.sh`.
**Expected:** `nslookup backend-headless` returns one or more Pod IPs if eligible endpoints are published.
**Ask:** “If DNS returns no addresses, what should we inspect?” **Answer:** Service selector, labels, readiness, EndpointSlices, and DNS response.

### Module 9 — Connectivity
**Say:** “DNS discovery and application connectivity are separate checks. We'll request the normal Service and each discovered endpoint.”
**Read-only requests:** `bash scripts/04-test-connectivity.sh`.
**Expected:** Response text identifies the Pod serving the request. Connection results depend on readiness and network policy.
**Ask:** “Can DNS succeed while the request fails?” **Answer:** Yes.

### Module 10 — Troubleshooting
**Say:** “Start with read-only inspection. Avoid changing cluster-wide DNS or deleting resources to troubleshoot a simple lab.”
**Read-only:** `kubectl describe svc backend-headless -n headless-demo`; `kubectl get pods -n headless-demo --show-labels`; `kubectl get endpointslice -n headless-demo -o yaml`.
**Ask:** “Why might a temporary client not have `dig`?” **Answer:** Tools vary by container image; use tools that the selected image actually includes.

## Port explanation
The demo container listens on port `8080`. Both Services expose port `8080` and forward to `targetPort: 8080`. The diagnostic Pod uses HTTP requests to port 8080.

## Readiness and endpoint membership
The example uses an HTTP readiness probe. A Pod that is not Ready may not be published as a ready endpoint for normal client discovery. Exact EndpointSlice conditions and DNS responses depend on Kubernetes version and Service settings.

## Windows / PowerShell notes
The YAML can be applied from PowerShell using the same `kubectl apply -f` commands. Bash scripts require Bash (for example, Git Bash or WSL on Windows). Read-only equivalents:
```powershell
kubectl config current-context
kubectl cluster-info
kubectl get nodes
kubectl get pods -n headless-demo -o wide
kubectl get svc -n headless-demo
kubectl get endpointslice -n headless-demo
kubectl exec -n headless-demo deploy/headless-diagnostic -- nslookup backend-headless
kubectl exec -n headless-demo deploy/headless-diagnostic -- wget -qO- http://backend-headless:8080/
```

## Cleanup caution
The cleanup script refuses to delete the namespace. It deletes only the specifically named lab Deployments and Services after confirmation. It removes the namespace only if it was created by the setup script and a marker file exists locally; review the script and target namespace before use. The marker is local to the machine, not stored in Kubernetes.
