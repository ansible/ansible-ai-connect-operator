Ansible MCP Server Role
========================

This role deploys and manages the Ansible MCP (Model Context Protocol) Server in a Kubernetes/OpenShift cluster. It handles the complete lifecycle of the MCP Server deployment including configuration, service setup, ingress/route configuration, and horizontal pod autoscaling.

Requirements
------------

- Kubernetes cluster (1.19+) or OpenShift cluster
- Ansible Operator SDK
- kubernetes.core collection
- operator_sdk.util collection

Role Variables
--------------

### Basic Kubernetes Configuration

- `kind`: Resource kind (default: `'AnsibleMCPConnect'`)
- `api_version`: API version (default: `'mcpconnect.ansible.com/v1alpha1'`)
- `deployment_type`: Deployment type identifier (default: `'ansible-mcp-connect'`)
- `image_pull_policy`: Image pull policy (default: `IfNotPresent`)
- `image_pull_secrets`: List of image pull secrets (default: `[]`)
- `_image`: Container image for MCP Server (default: `quay.io/ttakamiy/aap-mcp-server`) <!-- !!TODO!! -->
- `_image_version`: Image version (default: from `DEFAULT_MCP_SERVER_VERSION` env var or `'latest'`)
- `additional_labels`: Additional labels to propagate to resources (default: `[]`)
- `no_log`: Prevent Ansible logging of sensitive data (default: `false`)

### MCP Server API Configuration

- `api`: Custom API configuration (default: `{}`)
- `_api`: Default API configuration including:
  - `replicas`: Number of pod replicas (default: `1`)
  - `resource_requirements`: CPU and memory limits/requests
    - limits: cpu `200m`, memory `1000Mi`
    - requests: cpu `100m`, memory `500Mi`
  - `node_selector`: Node selector for pod scheduling (optional)

### Service Configuration

- `default_http_port`: HTTP port (default: `8085`)
- `default_https_port`: HTTPS port (default: `443`)
- `default_target_port`: Target port (default: `8085`)
- `service_type`: Kubernetes service type (default: `'ClusterIP'`)
- `loadbalancer_protocol`: Load balancer protocol (optional)
- `loadbalancer_port`: Load balancer port (optional)
- `nodeport_port`: NodePort port assignment (optional, auto-assigned by default)
- `service_annotations`: Custom service annotations (optional)
- `service_account_annotations`: Service account annotations (optional)

### Ingress/Route Configuration

- `ingress_type`: Ingress type - `'Route'` for OpenShift or `'Ingress'` for Kubernetes (default: `'Route'`)
- `ingress_class_name`: Ingress class name (optional)
- `ingress_path`: Ingress path (default: `'/'`)
- `ingress_path_type`: Path type (default: `'Prefix'`)
- `ingress_api_version`: Ingress API version (default: `'networking.k8s.io/v1'`)
- `hostname`: Hostname for ingress (optional)
- `ingress_annotations`: Ingress annotations as literal block (optional)
- `ingress_tls_secret`: TLS secret for ingress (optional)

### Route-Specific Configuration (OpenShift)

- `route_tls_termination_mechanism`: TLS termination type - `edge` or `passthrough` (default: `edge`)
- `route_tls_secret`: Secret containing TLS credentials (optional)
- `route_api_version`: Route API version (default: `'route.openshift.io/v1'`)
- `route_host`: Custom route host (optional, auto-generated if not specified)

### Custom CA Certificates

- `bundle_cacert_secret`: Secret containing custom CA trusted bundle (optional)

Dependencies
------------

This role depends on the `common` role for cluster configuration.

Required collections:
- operator_sdk.util
- kubernetes.core

Example Playbook
----------------

Basic usage with default settings:

```yaml
- hosts: localhost
  roles:
    - role: mcpserver
```

Custom configuration example:

```yaml
- hosts: localhost
  roles:
    - role: mcpserver
      vars:
        api:
          replicas: 3
          resource_requirements:
            limits:
              cpu: "500m"
              memory: "2Gi"
            requests:
              cpu: "250m"
              memory: "1Gi"
          node_selector: |
            disktype: ssd
            kubernetes.io/arch: amd64
        ingress_type: 'Ingress'
        hostname: 'mcp-server.example.com'
        ingress_tls_secret: 'mcp-server-tls'
        bundle_cacert_secret: 'custom-ca-bundle'
```

Tasks Overview
--------------

The role performs the following tasks in order:

1. Combines default and custom variables for each component
2. Configures the cluster using the common role
3. Sets MCP Server service images
4. Sets bundle certificate authority (if configured)
5. Loads Route TLS certificate (if using OpenShift routes with TLS)
6. Deploys MCP Server API service (ConfigMap, Service, Deployment, Ingress/Route)
7. Sets up HorizontalPodAutoscaler
8. Updates status variables

License
-------

Apache 2.0

Author Information
------------------

Red Hat, Inc.
Ansible Team
