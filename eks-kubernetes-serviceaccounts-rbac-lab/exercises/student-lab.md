# Student Lab: ServiceAccounts and RBAC

## Safety gate
Use only the approved cluster and `rbac-demo`. Run the read-only preflight. Stop if the namespace already exists and is not known to be lab-owned. Do not create ClusterRoleBindings, modify IAM, edit `aws-auth`, or display tokens/Secrets.

## Part A — Identity
1. Inspect current context and API endpoint.
2. Create or inspect `demo-reader`.
3. Inspect the Pod's `spec.serviceAccountName`.
4. Predict whether the ServiceAccount can list Pods before a binding exists.
5. Run the approved `kubectl auth can-i` check. If impersonation is denied, document that limitation; do not request extra production permissions.

## Part B — Namespaced Role
1. Inspect `manifests/03-role-pod-reader.yaml`.
2. Identify API group, resource and verbs.
3. Apply the Role and test `list pods`.
4. Apply the RoleBinding only after instructor confirmation.
5. Test `list pods`, `create pods`, `list secrets`, and `get pods/log`.
6. Explain any result that differs from the expected lab-only result by checking other grants and EKS authorizers.

## Part C — ClusterRole reused locally
1. Inspect the ConfigMap ClusterRole.
2. Explain why the object is cluster-scoped but its RoleBinding is namespaced.
3. Test ConfigMap access in `rbac-demo` and `default`.
4. Do not create a test namespace with unrelated data.

## Part D — Least privilege
Requirement: “A monitoring identity can list Pods and read their logs in `rbac-demo`; it cannot create/delete Pods or read Secrets.”
- Define the smallest Role.
- Bind it to `demo-reader`.
- Prove allowed and denied actions.
- Explain why a denial cannot be guaranteed if another binding grants the action.

## Deliverables
- A brief policy rationale.
- The YAML reviewed by a partner.
- Positive and negative `can-i` results.
- A cleanup confirmation and note of any retained cluster-scoped lab object.
