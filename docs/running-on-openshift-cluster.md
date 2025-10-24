# Running on an OpenShift cluster

## Overview

This guide shows you how to deploy AnsibleAIConnect or AnsibleMCPServer on
an OpenShift cluster.

These instructions assume you're using 
[a Red Hat OpenShift Service on AWS (ROSA) cluster](https://docs.openshift.com/rosa/welcome/index.html)), 
but any steps not specific to ROSA should also work on other OpenShift clusters.


## Permissions

Users will require the OpenShift Dedicated Admins [role](https://docs.openshift.com/dedicated/authentication/osd-admin-roles.html#the-dedicated-admin-role) for the namespace in which they wish to install the Operator. At the time of writing this is called `dedicated-admins-project`.

## Create a namespace

Login to the cluster:
```
oc login --token=<redacted>
```
Create a `namespace`:
```
oc create namespace <target-namespace>
```

## Install the Operator

### Installing from the Operator Hub

The Operator Hub is part of the Operator Lifecycle Manager ([OLM](https://olm.operatorframework.io/)) framework.

The Operator must first be declared to the OLM using a `CatalogSource`.

The `CatalogSource` defines the location from where an OLM `Catalog` can be retrieved.
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ansible-ai-connect-operator-dev
  namespace: <target-namespace>
spec:
  displayName: 'Ansible AI Connect Operator :: Dev'
  image: "quay.io/ansible/ansible-ai-connect-catalog:0.0.5"
  publisher: 'Ansible AI Connect Dev Team'
  sourceType: grpc
```
**NOTE:** If the `Catalog` repository is private a `secrets` entry can be provided. 
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ansible-ai-connect-operator-dev
  namespace: <target-namespace>
spec:
  displayName: 'Ansible AI Connect Operator :: Dev'
  image: "quay.io/ansible/ansible-ai-connect-catalog:0.0.5"
  publisher: 'Ansible AI Connect Dev Team'
  sourceType: grpc
  secrets:
    - redhat-operators-pull-secret
```
A `Secret` will also need to be provided:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redhat-operators-pull-secret
  namespace: <target-namespace>
data:
  .dockerconfigjson: <redacted>
type: kubernetes.io/dockerconfigjson
```
See [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials) regarding how to retrieve the `.dockerconfigjson` value. 

Once the `CatalogSource` has been successfully deployed the Operator can be installed into the `namespace` using the Operator Hub within the OpenShift console.

### Installing from the CLI

Login to the repository where the Operator image is published:
```
docker login quay.io
```
Set the Operator image name used by the `makefile`:
```
# In case you're not relying on the image from the ansible organization in Quay.io, use your own image instead.
export IMG=quay.io/ansible/ansible-ai-connect-operator:latest
```
**NOTE:** If the repository is private a `Secret` will also need to be provided:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redhat-operators-pull-secret
  namespace: <target-namespace>
data:
  .dockerconfigjson: <redacted>
type: kubernetes.io/dockerconfigjson
```
See [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials) regarding how to retrieve the `.dockerconfigjson` value.

Deploy the Operator to a [default](../config/default/kustomization.yaml) (`ansible-ai-connect-operator-system`) namespace:
```
make deploy
```

## Create an `AnsibleAIConnect` instance

### Using Operator Lifecycle Management

If the Operator was installed using the Operator Lifecycle Manager's `Catalog` a `ClusterServiceVerion` (`CSV`) resource would also have been installed. 

The [`CSV`](https://olm.operatorframework.io/docs/concepts/crds/clusterserviceversion/) contains meta-data to drive the creation of various UI components within the OpenShift console.

### Using the CLI

If the Operator Lifecycle Manager is not being used, or if creation of an `AnsibleAIConnect` instance from the CLI is desirable, the following can performed.

See [here](using-external-configuration-secrets.md#authentication-secret) for more instructions regarding configuration with `Secret`s.

1. Create a file `aiconnect.yaml` with the following content.

```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: <target-namespace>
spec:
  image_pull_secrets:
    - redhat-operators-pull-secret
  auth_config_secret_name: 'auth-configuration-secret'
  model_config_secret_name: 'model-configuration-secret'
  chatbot_config_secret_name: 'chatbot-configuration-secret'
  database:
    # This has to be the name of a StorageClass in the cluster
    postgres_storage_class: gp3
```
2. Now apply the yaml.

```bash
kubectl apply -f aiconnect.yaml
```

3. Once deployed, the `AnsibleAIConnect` instance will be accessible by running:
```bash
$ oc get route -n <target-namespace> my-aiconnect
```

### A note on `PersistentVolume`'s
The Operator supports the provisioning of a _managed_ Postgres instance.

The instance requires persistent storage which should be configured to use one of the `StorageClass`'es provisioned by OpenShift `ROSA`.

OpenShift `ROSA` includes a `ClusterOperator` for `Storage`.

See https://docs.openshift.com/rosa/storage/index.html

This [provides](https://docs.openshift.com/rosa/storage/container_storage_interface/persistent-storage-csi.html#persistent-storage-csi) `ClusterStorageInterface` [implementations](https://github.com/container-storage-interface/spec/blob/master/spec.md) for:
- Amazon Elastic Block Store ([EBS](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html))
- Amazon Elastic File System ([EFS](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)).

#### `StorageClasses`

The following `StorageClass`'es are available:

```yaml
NAME                         PROVISIONER             
gp2                          kubernetes.io/aws-ebs
gp2-csi                      ebs.csi.aws.com
gp3-csi                      ebs.csi.aws.com
gp3-customer-kms (default)   ebs.csi.aws.com
```

These are [provisioned](https://docs.openshift.com/rosa/storage/persistent_storage/persistent-storage-aws.html) by OpenShift ROSA.

## Create an `AnsibleMCPServer` instance

The Ansible MCP (Model Context Protocol) Server can be deployed alongside the AnsibleAIConnect instance to provide MCP functionality.

### Using Operator Lifecycle Management

If the Operator was installed using the Operator Lifecycle Manager's `Catalog`, you can create an `AnsibleMCPServer` instance through the OpenShift console using the Operator's UI components.

### Using the CLI

To create an `AnsibleMCPServer` instance using the CLI:

1. Create a file `mcpserver.yaml` with the following content:

```yaml
apiVersion: mcpserver.ansible.com/v1alpha1
kind: AnsibleMCPServer
metadata:
  name: my-mcpserver
  namespace: <target-namespace>
spec:
  no_log: false
  service_type: ClusterIP
  ingress_type: Route
  aap_gateway_url: https://your-aap-gateway-url.example.com
  image_pull_secrets:
    - redhat-operators-pull-secret
```

2. Apply the YAML file:

```bash
kubectl apply -f mcpserver.yaml
```

3. Once deployed, the `AnsibleMCPServer` instance will be accessible by running:

```bash
oc get route -n <target-namespace> my-mcpserver
```

### Configuration Options

Key configuration options for the `AnsibleMCPServer` include:

- `aap_gateway_url`: **Required.** The URL of your Ansible Automation Platform Gateway
- `service_type`: Service type (default: `ClusterIP`). Options: `ClusterIP`, `NodePort`, `LoadBalancer`
- `ingress_type`: Ingress type (default: `Route`). Use `Route` for OpenShift or `Ingress` for standard Kubernetes
- `image_pull_secrets`: List of secrets for pulling container images from private registries
- `api.replicas`: Number of pod replicas (default: 1)
- `api.resource_requirements`: CPU and memory limits/requests

For a complete list of configuration options, see the [mcpserver role documentation](../roles/mcpserver/README.md).
