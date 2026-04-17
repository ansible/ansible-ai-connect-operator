Ansible MCP Server Backup Role
================================

This role backs up an Ansible MCP Server deployment on Kubernetes/OpenShift. It is triggered by creating an `AnsibleMCPConnectBackup` custom resource, which the operator watches and reconciles using this role.

The backup captures the MCP Server's Secrets and ConfigMap data onto a PersistentVolumeClaim (PVC) so they can be restored later using the `mcprestore` role.

Requirements
------------

- Kubernetes cluster (1.19+) or OpenShift cluster
- Ansible Operator SDK
- kubernetes.core collection
- operator_sdk.util collection
- An existing `AnsibleMCPConnect` deployment to back up

Role Variables
--------------

| Name | Description | Default |
|------|-------------|---------|
| `deployment_name` | **(required)** Name of the `AnsibleMCPConnect` deployment to back up | - |
| `backup_pvc` | Name of the PVC to store the backup. If empty, defaults to `<deployment_name>-backup-claim` | `''` |
| `backup_pvc_namespace` | Namespace for the backup PVC | Current namespace |
| `backup_storage_requirements` | Storage size for the backup PVC | `'5Gi'` |
| `backup_storage_class` | Storage class for the backup PVC. If empty, uses the cluster default | `''` |
| `clean_backup_on_delete` | Delete backup data on PVC when the backup CR is deleted | `false` |
| `no_log` | Suppress Ansible logging of sensitive data | `true` |
| `set_self_labels` | Maintain recommended Kubernetes labels on resources | `true` |

Tasks Overview
--------------

1. **init** - Creates the backup PVC (if needed), spawns a temporary management pod with the PVC mounted, looks up the MCP Server deployment, and creates a timestamped backup directory
2. **secrets** - Backs up the MCP Server's Secrets to a file on the PVC
3. **configmap** - Backs up the MCP Server's ConfigMap data to a file on the PVC
4. **cleanup** - Deletes the temporary management pod
5. **update_status** - Updates the `AnsibleMCPConnectBackup` CR status with `backupDirectory` and `backupClaim`

The role is idempotent: if the CR status already contains a `backupDirectory`, the backup is skipped.

Example Usage
-------------

Create a backup by applying an `AnsibleMCPConnectBackup` CR:

```yaml
apiVersion: mcpconnect.ansible.com/v1alpha1
kind: AnsibleMCPConnectBackup
metadata:
  name: mcp-backup-2025
  namespace: aap
spec:
  deployment_name: my-mcp-server
  backup_storage_requirements: 10Gi
```

After the operator reconciles, check the backup status:

```bash
kubectl get ansiblemcpconnectbackup mcp-backup-2025 -o jsonpath='{.status}'
```

The status will contain:
- `backupDirectory`: Path to the backup directory on the PVC
- `backupClaim`: Name of the PVC holding the backup

License
-------

Apache 2.0

Author Information
------------------

Red Hat, Inc.
Ansible Team
