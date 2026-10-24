# Student Lab — EKS Namespace Resource Controls

## Goals

Create and inspect a dedicated namespace; compare requests/limits, aggregate quotas, object-count quota and LimitRange; diagnose a rejection; clean up safely.

## Lab rules

Use only `namespace-quota-demo`. Do not modify shared namespaces, nodes, node groups, IAM or cluster-wide monitoring. Confirm AWS identity and kubectl context with the trainer before any write operation.

## Tasks

1. Run `bash scripts/00-check-eks-environment.sh`; record account, region, context, Ready node count and whether the lab namespace exists.
2. Predict what a namespace does and does not isolate. Inspect `kubectl get ns` and `kubectl api-resources --namespaced=true`.
3. Review manifests. Explain `100m`, `128Mi`, requests and limits before applying.
4. With instructor approval, run `bash scripts/01-setup.sh`.
5. Inspect `kubectl get pods -n namespace-quota-demo -o wide`, `kubectl describe resourcequota -n namespace-quota-demo`, and `kubectl describe limitrange -n namespace-quota-demo`.
6. Inspect `defaulted-demo` YAML and identify defaulted requests/limits. If the Pod was admitted before the LimitRange was installed, recreate only this lab-owned Pod after reviewing the effects.
7. Attempt the controlled negative test and capture the admission message. Remove only `quota-negative-test` if created.
8. Diagnose one simulated Pending or runtime scenario using the troubleshooting decision tree; do not intentionally exhaust shared nodes.
9. Complete the quiz and explain why free node capacity does not bypass quota.
10. Clean up only after instructor approval using `bash scripts/03-cleanup.sh`.

## Evidence to submit

- Preflight summary (no secrets or credentials).
- YAML excerpt showing resource requests/limits.
- Quota `hard` and `used` values.
- A representative admission error or explanation if policy/cluster conditions prevent the negative test.
- Short explanation of namespace limitations and the three failure classes.
