# Running on a `minikube` cluster

## Overview

This document covers running an instance of `AnsibleAIConnect` on [`minikube`](https://minikube.sigs.k8s.io/docs/).

## Permissions

No additional permissions are required.

## Start a `minikube` cluster.

```
minikube start
```
```
😄  minikube v1.32.0 on Ubuntu 22.04
🎉  minikube 1.33.0 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.33.0
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

✨  Automatically selected the docker driver. Other choices: kvm2, qemu2, virtualbox, ssh
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=7800MB) ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### Addons

#### The `storage-provisioner` addon

If your `minikube` installation does not automatically install and enable the `storage-provisioner` addon run the following:
```
minikube addons enable storage-provisioner
```
```
💡  storage-provisioner is an addon maintained by minikube. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  The 'storage-provisioner' addon is enabled
```
#### The `storage-provisioner` addon

If your `minikube` installation does not automatically install and enable the `default-storageclass` addon run the following:
```
minikube addons enable default-storageclass
```
```
💡  default-storageclass is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
🌟  The 'default-storageclass' addon is enabled
```

## Install the Operator

Login to the repository where the Operator image is published:
```
docker login quay.io
```
Set the Operator image name used by the `makefile`:
```
export IMG=quay.io/ansible/ansible-ai-connect-operator:latest
```
**NOTE:** If the repository is private a `Secret` will also need to be provided:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redhat-operators-pull-secret
  namespace: ansible-ai-connect-operator-system
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

An `AnsibleAIConnect` instance can be created with the following.

1. Create a file `aiconnect.yaml` with the following content.

```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: ansible-ai-connect-operator-system
spec:
  ingress_type: Ingress
  service_type: NodePort
  nodeport_port: 30109
  image_pull_secrets:
    - redhat-operators-pull-secret
  auth:
    auth_api_url: 'TBA'
    auth_api_key: 'TBA'
    auth_api_secret: 'TBA'
  ai:
    username: 'TBA'
    model_url: 'TBA'
    model_api_key: 'TBA'
    model_name: 'TBA'
  database:
    postgres_storage_class: standard
```
2. Now apply the yaml.

```bash
kubectl apply -f aiconnect.yaml
```

3. Once deployed, the `AnsibleAIConnect` instance will be accessible by running:
```bash
minikube service -n ansible-ai-connect-operator-system my-aiconnect-api --url
```