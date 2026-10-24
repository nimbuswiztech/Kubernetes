# Quiz and Answers

1. **What happens to `emptyDir` when a container in the same Pod restarts?**  
   A. Always deleted B. Usually remains C. Converted to PV D. Copied to another node  
   **Answer: B.** The Pod remains and its `emptyDir` remains available; Pod removal ends its lifetime.

2. **What is `hostPath`?**  
   A. A cloud disk abstraction B. A node filesystem path C. A PVC D. A StorageClass  
   **Answer: B.** It exposes a path from the node hosting the Pod.

3. **Which object is cluster-scoped?**  
   A. PVC B. Pod C. PV D. Deployment  
   **Answer: C.** PVs are cluster-scoped; PVCs are namespaced.

4. **What does a PVC express?**  
   A. A storage request B. The backend filesystem itself C. A node D. A CSI driver  
   **Answer: A.** Capacity, access mode, volume mode and class are request characteristics.

5. **Static provisioning begins with:**  
   A. A pre-created PV B. A Pod restart C. A namespace deletion D. A default class only  
   **Answer: A.** The PV represents existing storage.

6. **Dynamic provisioning uses:**  
   A. A StorageClass/provisioner B. Only `emptyDir` C. Only host paths D. A Deployment selector  
   **Answer: A.** The provisioner creates backend storage when the claim needs it.

7. **What does `WaitForFirstConsumer` do?**  
   A. Waits forever B. Delays binding/provisioning to consider Pod scheduling/topology C. Deletes PVCs D. Enables RWX  
   **Answer: B.** It helps topology-aware provisioning choose a compatible location.

8. **Does `ReadWriteOnce` always mean exactly one Pod?**  
   A. Yes B. No; it generally means read-write from one node C. It means read-only D. It means any node  
   **Answer: B.** Multiple Pods on one node may use the volume, subject to driver/backend behavior.

9. **What can `Delete` reclaim policy do?**  
   A. Guarantee a backup B. Delete the underlying storage through the provisioner C. Convert to Retain D. Keep all data forever  
   **Answer: B.** Inspect the actual PV policy before deleting a claim.

10. **A PVC is Bound, but the Pod has `FailedMount`. What next?**  
    A. Force-delete finalizers B. Inspect Pod events, CSI node health, topology and mount errors C. Delete all PVs D. Install a random driver  
    **Answer: B.** Binding is not proof of successful scheduling, attachment, mounting or application I/O.

## Five interview questions
1. **PV vs PVC?** PV is a cluster-scoped representation of storage; PVC is a namespaced request that binds to a compatible PV.
2. **Static vs dynamic provisioning?** Static begins with an administrator-created PV for existing storage; dynamic uses a StorageClass provisioner to create storage on demand.
3. **Why can a claim stay Pending?** No compatible PV/class, provisioner failure, unsupported parameters, quota/capacity, access mode mismatch, selector constraints, or topology/binding-mode behavior.
4. **Why is hostPath risky?** It couples workload to node layout, can expose host data, and can enable privilege escalation or node compromise if misused.
5. **What does Retain guarantee?** It leaves storage for deliberate administrator handling; it does not guarantee backups, encryption, or protection from manual deletion.
