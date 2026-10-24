# Official documentation links

Verify version-specific details against your cluster's Kubernetes version and installed driver.

- Kubernetes Volumes: https://kubernetes.io/docs/concepts/storage/volumes/
- `emptyDir`: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- `hostPath` and risks: https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
- PersistentVolumes and PVCs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- StorageClasses: https://kubernetes.io/docs/concepts/storage/storage-classes/
- Dynamic provisioning: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
- Access modes and volume modes: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
- PV lifecycle and reclaim policy: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming
- StatefulSets and `volumeClaimTemplates`: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
- CSI: https://kubernetes.io/docs/concepts/storage/volumes/#csi
- EKS EBS CSI driver: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
- EKS storage best practices: https://docs.aws.amazon.com/eks/latest/best-practices/identity-and-access-management.html
- EKS `kubectl` access: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
- Pod Security Standards: https://kubernetes.io/docs/concepts/security/pod-security-standards/
- ResourceQuota: https://kubernetes.io/docs/concepts/policy/resource-quotas/
- LimitRange: https://kubernetes.io/docs/concepts/policy/limit-range/

These are official documentation entry points; confirm exact behavior against your installed Kubernetes version, CSI driver, StorageClass and backend.


EKS-specific storage notes: the standard EBS CSI provisioner (`ebs.csi.aws.com`) and EKS Auto Mode storage provisioner (`ebs.csi.eks.amazonaws.com`) are distinct. Confirm which operating mode and driver the cluster uses before applying any EBS-specific template. See https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html.
