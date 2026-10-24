# Troubleshooting Challenges

For each challenge, state the likely layer, collect safe evidence, propose the smallest correction, and identify what not to change.

1. **Wrong AWS profile or region:** `aws sts get-caller-identity` is unexpected or cluster discovery is empty. Check `AWS_PROFILE`, `AWS_REGION`, and `aws eks list-clusters --region <region>`. Do not change IAM policy to compensate for a wrong profile.
2. **Unauthorized:** `kubectl` cannot authenticate. Check context, endpoint, AWS CLI token-generation errors, and configured EKS access entries or legacy mapping with authorized read-only inspection. Do not edit `aws-auth` without a reviewed change.
3. **Forbidden:** `list pods` is denied. Check the exact subject, verb, resource, namespace, Role/ClusterRole and bindings. Do not grant cluster-admin.
4. **Missing subresource:** Pod list works but logs do not. Check `pods/log` and its `get` verb. `pods` is not automatically `pods/log`.
5. **RoleBinding subject namespace mismatch:** Verify `subjects[].namespace` equals the ServiceAccount's namespace. Correct only the lab-owned binding after review.
6. **Permission persists after binding removal:** Another binding or EKS access policy may grant it. Inspect all applicable grants; RBAC has no general explicit deny.
7. **Pod cannot contact API although can-i says yes:** Check token automount/projected volume configuration, DNS, endpoint routing, TLS, NetworkPolicy, application behavior, and API discovery. Never print token contents.
8. **AWS SDK cannot access S3:** Inspect IRSA/Pod Identity association, trust/role configuration and least-privilege IAM policy through the approved AWS process. A Kubernetes RoleBinding does not grant S3 access.
9. **Admission rejects Pod:** Read the error/event and namespace labels or policy constraints. RBAC success does not bypass admission.
10. **Node read expected but denied:** A RoleBinding cannot grant cluster-scoped Nodes access. A ClusterRoleBinding would be cluster-wide and requires separate approval; for this lab, skip the mutation and explain it with read-only checks.
