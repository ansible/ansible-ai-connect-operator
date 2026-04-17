Ansible MCP Server Restore Role
=================================

This role restores an Ansible MCP Server deployment on Kubernetes/OpenShift from a previous backup. It is triggered by creating an `AnsibleMCPConnectRestore` custom resource, which the operator watches and reconciles using this role.

The restore reads Secrets and ConfigMap data from a backup PVC (created by the `mcpbackup` role) and re-creates them in the target namespace.

Requirements
------------

- Kubernetes cluster (1.19+) or OpenShift cluster
- Ansible Operator SDK
- kubernetes.core collection
- operator_sdk.util collection
- A completed `AnsibleMCPConnectBackup` or a PVC containing a valid backup

Role Variables
--------------

| Name | Description | Default |
|------|-------------|---------|
| `deployment_name` | **(required)** Name of the `AnsibleMCPConnect` deployment to restore | - |
| `backup_name` | Name of the `AnsibleMCPConnectBackup` CR to restore from. The role reads `backupClaim` and `backupDirectory` from the backup CR's status | `''` |
| `backup_pvc` | PVC containing the backup (used when restoring without a backup CR reference) | `''` |
| `backup_dir` | Backup directory name on the PVC (used when restoring without a backup CR reference) | `''` |
| `backup_pvc_namespace` | Namespace of the backup PVC | Current namespace |
| `no_log` | Suppress Ansible logging of sensitive data | `true` |
| `set_self_labels` | Maintain recommended Kubernetes labels on resources | `true` |

You can reference the backup either by `backup_name` (preferred) or by providing `backup_pvc` and `backup_dir` directly.

Tasks Overview
--------------

1. **init** - Looks up the backup CR (if `backup_name` is set) to resolve the PVC and directory, then spawns a temporary management pod with the backup PVC mounted
2. **secrets** - Checks for backed-up Secrets on the PVC; if found, restores them into the namespace
3. **configmap** - Checks for backed-up ConfigMap data on the PVC; if found, restores the ConfigMap into the namespace
4. **cleanup** - Deletes the temporary management pod
5. **update_status** - Sets `restoreComplete: true` on the `AnsibleMCPConnectRestore` CR status

The role is idempotent: if the CR status already shows `restoreComplete: true`, the restore is skipped. Missing backup files are handled gracefully (skipped with a debug message).

Example Usage
-------------

Restore from a backup CR:

```yaml
apiVersion: mcpconnect.ansible.com/v1alpha1
kind: AnsibleMCPConnectRestore
metadata:
  name: mcp-restore-2025
  namespace: aap
spec:
  deployment_name: my-mcp-server
  backup_name: mcp-backup-2025
```

Restore from a PVC directly:

```yaml
apiVersion: mcpconnect.ansible.com/v1alpha1
kind: AnsibleMCPConnectRestore
metadata:
  name: mcp-restore-2025
  namespace: aap
spec:
  deployment_name: my-mcp-server
  backup_pvc: my-mcp-server-backup-claim
  backup_dir: /backups/mcp-openshift-backup-2025-04-15-143022
```

After the operator reconciles, verify the restore completed:

```bash
kubectl get ansiblemcpconnectrestore mcp-restore-2025 -o jsonpath='{.status.restoreComplete}'
```

License
-------

Apache 2.0

Author Information
------------------

Red Hat, Inc.
Ansible Team
