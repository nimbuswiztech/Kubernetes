# Student Lab — Headless Service

## Goal
Observe how a normal ClusterIP Service differs from a Headless Service while both select the same two application Pods.

## Before starting
1. Run `bash scripts/00-check-environment.sh`.
2. Confirm with the trainer that `headless-demo` does not exist and the selected context is correct.
3. Run `bash scripts/01-setup.sh` only after approval.

## Tasks
1. List the Pods and note their IP addresses and labels.
2. List the Services. Record the ClusterIP for `backend-normal` and the value for `backend-headless`.
3. Describe `backend-headless` and identify its selector.
4. List EndpointSlices and compare endpoint addresses with Pod IPs.
5. Resolve `backend-headless` from the diagnostic Deployment.
6. Resolve the fully qualified name `backend-headless.headless-demo.svc.cluster.local`.
7. Send an HTTP request to `backend-normal:8080`.
8. Send an HTTP request to `backend-headless:8080`.
9. Copy one Pod IP and send an HTTP request directly to it.
10. Explain why a successful DNS lookup is not proof of application connectivity.

## Questions
- Why does the Headless Service show `None` for ClusterIP?
- Why do the Services use the same selector?
- What happens to endpoint membership when a Pod is not Ready?
- Does DNS answer order guarantee round-robin?
- What should you inspect when DNS returns no endpoint addresses?

## Expected conclusions
- The normal Service has a virtual ClusterIP.
- The Headless Service does not have a virtual ClusterIP.
- Selector and readiness affect endpoint membership.
- Headless DNS can return individual endpoint IPs.
- The client/application chooses how to use returned endpoints.
- DNS and connectivity must be tested separately.

## Cleanup
Ask the trainer before cleanup. Review `scripts/05-cleanup.sh` and run it only if you own the lab resources.
