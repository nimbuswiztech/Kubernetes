# Troubleshooting Challenges

For every challenge: state the observed symptom, inspect objects/events, name the likely layer, and propose a non-destructive remedy.

1. **PVC Pending / no StorageClass:** run `kubectl get sc`, `kubectl describe pvc <claim> -n storage-demo`. Identify class/provisioner requirements; do not create a guessed class.
2. **PVC Pending with `WaitForFirstConsumer`:** inspect the StorageClass binding mode and consumer Pod scheduling events. A consumer may be needed before provisioning proceeds.
3. **Pod ContainerCreating / FailedAttachVolume:** inspect Pod events, `kubectl get volumeattachment`, CSI controller/node components and node topology. Do not detach a volume manually as a first response.
4. **Mount succeeds but application gets Permission denied:** inspect `id`, mount read-only flag, UID/GID, filesystem ownership and security context. Do not run privileged or chmod arbitrary host paths.
5. **PVC deleted; PV Released:** inspect reclaim policy, claimRef, finalizers and backend inventory. For Retain, follow an administrator-reviewed recovery process; do not remove finalizers blindly.

## Final practical assignment
Design a data path for a small stateful service in EKS. Include: selected StorageClass (discovered, not assumed), PVC manifest, consumer Pod/Deployment, topology assumptions, backup approach, reclaim policy, failure diagnosis commands, and cleanup plan.

Acceptance criteria:
- Correct PV/PVC/StorageClass distinctions.
- No production resources modified.
- Class, driver, IAM, quota, topology and potential charges checked before apply.
- Data survives Pod replacement while claim remains.
- Student explains what claim deletion does under the actual PV reclaim policy.
- Troubleshooting plan uses events and `describe` before destructive changes.
