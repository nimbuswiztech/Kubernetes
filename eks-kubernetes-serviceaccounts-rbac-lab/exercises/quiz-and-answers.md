# Quiz and Answer Key

## Ten multiple-choice questions

1. What does authentication establish?  
A. Whether a request is admitted B. Caller identity C. Pod scheduling D. Storage class  
**Answer: B.** Authentication establishes the identity and groups for the request.

2. What does a Role do?  
A. Grants itself to everyone B. Defines namespaced permissions C. Creates an IAM role D. Denies other roles  
**Answer: B.** A Role is a namespaced rule definition; a binding grants it.

3. A RoleBinding references a ClusterRole. What is the scope for namespaced resources?  
A. All namespaces B. Only the RoleBinding namespace C. Nodes too D. No access  
**Answer: B.** The binding is namespaced.

4. Which object grants a ClusterRole across namespaces?  
A. ServiceAccount B. Role C. ClusterRoleBinding D. Pod  
**Answer: C.** ClusterRoleBinding is cluster-scoped.

5. Does creating a ServiceAccount automatically grant broad API access?  
A. Yes B. No C. Only on EKS D. Only if two nodes  
**Answer: B.** Identity and permission grants are separate.

6. What does ordinary Kubernetes RBAC use for conflicting grants?  
A. Explicit deny always wins B. Additive grants C. Latest rule wins D. Random choice  
**Answer: B.** Grants are additive; RBAC does not provide a general deny rule.

7. What does `kubectl auth can-i` test?  
A. Network reachability B. Application correctness C. Authorization decision D. Pod health  
**Answer: C.** It does not prove application connectivity or admission success.

8. Which is most sensitive?  
A. List public ConfigMaps B. Read Secrets C. Get namespace names D. Read Pod labels  
**Answer: B.** Secret values commonly contain credentials and should be tightly controlled.

9. Does an AWS IAM policy granting S3 access automatically grant Kubernetes Pod read access?  
A. Yes B. No C. Only with two nodes D. Only through Role  
**Answer: B.** AWS IAM and Kubernetes authorization are separate.

10. What is the safest response to `Forbidden`?  
A. Grant cluster-admin B. Edit aws-auth C. Inspect identity, rule, binding and scope D. Print token  
**Answer: C.** Diagnose the smallest relevant authorization path.

## Five interview questions with detailed answers

1. **Role vs ClusterRole?** A Role is namespaced and defines permissions within its namespace. A ClusterRole is a cluster-scoped object that can define permissions for namespaced resources or cluster-scoped resources. Scope of the grant depends on the binding.
2. **RoleBinding vs ClusterRoleBinding?** RoleBinding grants in one namespace and can reference a Role or ClusterRole. ClusterRoleBinding grants the referenced ClusterRole across the cluster, including cluster-scoped resources covered by its rules.
3. **Why are grants additive?** Kubernetes RBAC authorizes when applicable rules grant the requested action. Removing one binding cannot negate a grant from another binding or configured authorizer.
4. **Why is Pod creation sensitive?** A created Pod may be able to select a powerful ServiceAccount, mount allowed Secrets, or run code in a trusted namespace, depending on other controls. Permissions should be designed with the workload's effective capabilities in mind.
5. **How do EKS IAM, RBAC, IRSA and Pod Identity differ?** EKS maps an AWS principal to cluster access through the configured mechanism, and EKS access policies and/or Kubernetes authorization affect API permissions. IRSA and EKS Pod Identity provide AWS credentials to workloads. Kubernetes ServiceAccount identity and RBAC govern Kubernetes API access; AWS IAM governs AWS API access.

## Final practical assignment
Create a least-privilege namespaced Role for reading Pods and Pod logs in `rbac-demo`, bind it to `demo-reader`, and demonstrate:
- `get/list/watch pods`: allowed from this grant.
- `get pods/log`: allowed from this grant.
- `create/delete pods`: not granted by this Role.
- `list secrets`: not granted by this Role.
- Scope outside `rbac-demo`: not granted by the RoleBinding.
- Explain that other bindings or EKS authorization can still alter effective results.

### Acceptance criteria
- YAML uses `rbac.authorization.k8s.io/v1`, no wildcards.
- Core API group is `""`.
- RoleBinding subject includes the correct ServiceAccount namespace.
- Both allowed and denied checks are shown.
- Student distinguishes expected lab-only policy from actual cluster-wide effective authorization.
- No tokens/Secret data exposed; cleanup is reviewed.

## Revision summary
Identity is not permission. Rules define permissions; bindings grant them. Scope follows the binding. RBAC is additive. Verify context first, test allowed and denied operations, and diagnose authentication, authorization, admission, connectivity, and AWS identity separately.
