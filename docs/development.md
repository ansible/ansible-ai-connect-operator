# Development Guide

Makefile targets can be used to build, deploy and test changes made to the ansible-ai-connect-operator.

Run `make help` to see all available targets and options.


## Prerequisites

You will need to have the following tools installed:

* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [podman](https://podman.io/docs/installation) or [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [oc](https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/getting-started-cli.html) (if using OpenShift)

You will also need a container registry account. This guide uses [quay.io](https://quay.io), but any container registry will work.

If you don't already have a k8s cluster, you can use minikube to start a lightweight cluster locally by following the [minikube test cluster docs](minikube-test-cluster.md).


## Registry Setup

1. Go to [quay.io](https://quay.io) and create a repository named `ansible-ai-connect-operator` under your username.
2. Login at the CLI:
```sh
podman login quay.io
```

> **Note**: The first time you run `make up`, it will create quay.io repos on your fork. You will need to either make those public or create a global pull secret on your cluster.


## Build and Deploy

Make sure you are logged into your cluster (`oc login` or `kubectl` configured), then run:

```sh
QUAY_USER=username make up
```

This will:
1. Login to container registries
2. Create the target namespace
3. Build the operator image and push it to your registry
4. Deploy the operator via kustomize

> **Note**: The AI Connect operator does not create a CR automatically (`CREATE_CR=false`). You'll need to create the required secrets and CR manually after deployment. See [Creating a CR](#creating-a-cr) below.

> **Note**: If you are using an ARM host (e.g., Apple Silicon), the build will auto-detect the cluster architecture and cross-compile if needed.

### Customization Options

| Variable | Default | Description |
|----------|---------|-------------|
| `QUAY_USER` | _(required)_ | Your quay.io username |
| `NAMESPACE` | `ansible-ai-connect` | Target namespace |
| `DEV_TAG` | `dev` | Image tag for dev builds |
| `CONTAINER_TOOL` | `podman` | Container engine (`podman` or `docker`) |
| `PLATFORM` | _(auto-detected)_ | Target platform (e.g., `linux/amd64`) |
| `MULTI_ARCH` | `false` | Build multi-arch image (`linux/arm64,linux/amd64`) |
| `DEV_IMG` | `quay.io/<QUAY_USER>/ansible-ai-connect` | Override full image path (skips QUAY_USER) |
| `BUILD_IMAGE` | `true` | Set to `false` to skip image build (use existing image) |
| `IMAGE_PULL_POLICY` | `Always` | Set to `Never` for local builds without push |
| `BUILD_ARGS` | _(empty)_ | Extra args passed to container build (e.g., `--no-cache`) |
| `PODMAN_CONNECTION` | _(empty)_ | Remote podman connection name |

Examples:

```bash
# Use a specific namespace and tag
QUAY_USER=username NAMESPACE=ansible-ai-connect DEV_TAG=mytag make up

# Use docker instead of podman
CONTAINER_TOOL=docker QUAY_USER=username make up

# Build for a specific platform (e.g., when on ARM building for x86)
PLATFORM=linux/amd64 QUAY_USER=username make up

# Deploy without building (use an existing image)
BUILD_IMAGE=false DEV_IMG=quay.io/myuser/ansible-ai-connect-operator DEV_TAG=latest make up
```

### Creating a CR

After the operator is deployed, create the required configuration secrets and then an `AnsibleAIConnect` custom resource:

```yaml
# aiconnect.yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: ansible-ai-connect
spec:
  auth_config_secret_name: 'auth-configuration-secret'
  model_config_secret_name: 'model-configuration-secret'
  chatbot_config_secret_name: 'chatbot-configuration-secret'
```

```sh
kubectl apply -f aiconnect.yaml
```

For details on creating the required secrets, see [Using External Configuration Secrets](using-external-configuration-secrets.md).


## Clean up

To tear down your development deployment:

```sh
make down
```

### Teardown Options

| Variable | Default | Description |
|----------|---------|-------------|
| `KEEP_NAMESPACE` | `false` | Set to `true` to keep the namespace for reuse |
| `DELETE_PVCS` | `true` | Set to `false` to preserve PersistentVolumeClaims |
| `DELETE_SECRETS` | `true` | Set to `false` to preserve secrets |

Examples:

```bash
# Keep the namespace for faster redeploy
KEEP_NAMESPACE=true make down

# Keep PVCs (preserve database data between deploys)
DELETE_PVCS=false make down
```


## Testing

### Linting

Run linting checks (required for all PRs):

```sh
make lint
```


## Bundle Generation

If you have the Operator Lifecycle Manager (OLM) installed, you can generate and deploy an operator bundle:

```bash
# Generate bundle manifests and validate
make bundle

# Build and push the bundle image
make bundle-build bundle-push

# Build and push a catalog image
make catalog-build catalog-push
```

After pushing the catalog, create a `CatalogSource` in your cluster pointing to the catalog image. Once the CatalogSource is in a READY state, the operator will be available in OperatorHub.
