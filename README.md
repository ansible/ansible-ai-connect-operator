# Ansible AI Connect Operator

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Code of Conduct](https://img.shields.io/badge/code%20of%20conduct-Ansible-yellow.svg)](https://docs.ansible.com/ansible/latest/community/code_of_conduct.html) 

A Kubernetes operator for Kubernetes built with [Operator SDK](https://github.com/operator-framework/operator-sdk) and Ansible for deploying and maintaining the lifecycle of your [Ansible AI Connect](https://github.com/ansible/ansible-wisdom-service) application.

## Overview

This operator is meant to provide a more Kubernetes-native installation method for Ansible AI Connect via an `AnsibleAIConnect` Custom Resource Definition (CRD). In the future, this operator will grow to be able to maintain the full life-cycle of an Ansible AI Connect deployment. Currently, it can handle fresh installs and upgrades.

Table of Contents
=================

- [Ansible AI Connect Operator](#ansible-ai-connect-operator)
  - [Overview](#overview)
- [Table of Contents](#table-of-contents)
  - [Contributing](#contributing)
    - [Prerequisites](#prerequisites)
  - [Install the Ansible AI Connect Operator](#install-the-ansible-ai-connect-operator)
  - [Deploy AnsibleAIConnect](#deploy-ansibleaiconnect)
  - [Advanced Configuration](#advanced-configuration)
    - [Use external database](#use-external-database)
    - [Deploying Ansible AI Connect Operator using OLM](#deploying-ansible-ai-connect-operator-using-olm)
    - [Admin user account configuration](#admin-user-account-configuration)
    - [Database Fields Encryption Configuration](#database-fields-encryption-configuration)
    - [Additional Advanced Configuration](#additional-advanced-configuration)
  - [Maintainers Docs](#maintainers-docs)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

## Contributing

Please visit [our contributing guide](./CONTRIBUTING.md) which has details about how to set up your development environment.

### Prerequisites

* Install the kubernetes-based cluster of your choice:
  * [Openshift](https://docs.openshift.com/container-platform/4.11/installing/index.html)
  * [K8s](https://kubernetes.io/docs/setup/)
  * [CodeReady containers](https://access.redhat.com/documentation/en-us/red_hat_openshift_local/2.5)
  * [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Install the Ansible AI Connect Operator

Before you begin, you need to have a k8s cluster up. If you don't already have a k8s cluster, you can use minikube to start a lightweight k8s cluster locally by following these [minikube test cluster docs](./docs/minikube-test-cluster.md).

Once you have a running Kubernetes cluster, you can deploy Ansible AI Connect Operator into your cluster using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/). Since kubectl version 1.14 kustomize functionality is built-in (otherwise, follow the instructions here to install the latest version of Kustomize: https://kubectl.docs.kubernetes.io/installation/kustomize/)

> [!Note]
> If you want to do a single-command install with no modifications, please see these docs [here](./docs/single-command-install.md).

First, create a file called `kustomization.yaml` with the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - config/default

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/ansible-ai-connect-operator
    newTag: 0.0.1

# Specify a custom namespace in which to install AnsibleAIConnect
namespace: ansibleaiconnect
```

You can use kustomize directly to dynamically modify things like the operator deployment at deploy time.  For more info, see the [kustomize install docs](./docs/kustomize-install.md).



Install the manifests by running this:

```bash
$ kubectl apply -k .
```

Check that your operator pod is running, this may take about a minute.

```bash
$ kubectl get pods
```

## Deploy AnsibleAIConnect

1. Create a resource definition.
2. 
```yaml
# aiconnect.yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: ansibleaiconnect
spec:
  auth:
    aap_api_url: 'TBA'
    social_auth_aap_key: 'TBA'
    social_auth_aap_secret: 'TBA'
  ai:
    username: 'TBA'
    inference_url: 'TBA'
    model_mesh_api_key: 'TBA'
    model_mesh_model_name: 'TBA'
  service_type: NodePort
```

3. Now apply this yaml

```bash
$ kubectl apply -f aiconnect.yaml
```

Once deployed, the `AnsibleAIConnect` instance will be accessible by running:

```
$ minikube service -n ansibleaiconnect my-aiconnect-api --url
```

If you are using Openshift, you can take advantage of automatic Route configuration an `AnsibleAIConnect` custom resource like this:

```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: ansibleaiconnect
spec:  
  auth:
    aap_api_url: 'TBA'
    social_auth_aap_key: 'TBA'
    social_auth_aap_secret: 'TBA'
  ai:
    username: 'TBA'
    inference_url: 'TBA'
    model_mesh_api_key: 'TBA'
    model_mesh_model_name: 'TBA'
  service_type: ClusterIP
  ingress_type: Route
```

If using Openshift, `AnsibleAIConnect` instance will be accessible by running:

```
$ oc get route -n ansibleaiconnect my-aiconnect-api
```

By default, the admin user is `admin` and the password is available in the `<resourcename>-admin-password` secret. To retrieve the admin password, run:

```bash
$ kubectl get secret my-aiconnect-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo
```

## Advanced Configuration

### Use external database

Ansible AI Connect can be configured to use an existing database. Here is an [example](/docs/openshift-rosa-test-cluster-external-postgres.md)


### Deploying Ansible AI Connect Operator using OLM

You can take advantage of the Operator Lifecycle Manager to deploy the operator.  Here is an [example](/docs/openshift-rosa-test-cluster.md)


### Admin user account configuration

There are three variables that are customizable for the admin user account creation.

| Name                  | Description                                  | Default          |
| --------------------- | -------------------------------------------- | ---------------- |
| `admin_user`            | Name of the admin user                       | `admin`            |
| `admin_email`           | email address of the admin user              | `test@example.com` |
| `admin_password_secret` | Secret that contains the admin user password | Empty string     |


> :warning: **`admin_password_secret` must be a Kubernetes secret and not your text clear password**.

If `admin_password_secret` is not provided, the operator will look for a secret named `<resourcename>-admin-password` for the admin password. If it is not present, the operator will generate a password and create a Secret from it named `<resourcename>-admin-password`.

To retrieve the admin password, run `kubectl get secret <resourcename>-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo`

The secret should be formatted as follows:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: <resourcename>-admin-password
  namespace: <target namespace>
stringData:
  password: mysuperlongpassword
```


### Database Fields Encryption Configuration

This encryption key is used to encrypt sensitive data in the database.

| Name                        | Description                                           | Default          |
| --------------------------- | ----------------------------------------------------- | ---------------- |
| `db_fields_encryption_secret` | Secret that contains the symmetric key for encryption | Generated        |


> :warning: **`db_fields_encryption_secret` must be a Kubernetes secret and not your text clear secret value**.

If `db_fields_encryption_secret` is not provided, the operator will look for a secret named `<resourcename>-db-fields-encryption-secret` for the encryption key. If it is not present, the operator will generate a secret value and create a Secret containing it named `<resourcename>-db-fields-encryption-secret`. It is important to not delete this secret as it will be needed for upgrades and if the pods get scaled down at any point. If you are using a GitOps flow, you will want to pass a secret key secret and not depend on the generated one.

The secret should be formatted as follows:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: custom-aiconnect-db-encryption-secret
  namespace: <target namespace>
stringData:
  secret_key: supersecuresecretkey
```

Then specify the name of the k8s secret on the `AnsibleAIConnect` spec:

```yaml
---
spec:
  ...
  db_fields_encryption_secret: custom-aiconnect-db-encryption-secret
```

### Additional Advanced Configuration
- [No Log](./docs/user-guide/advanced-configuration/no-log.md)
- [Deploy a Specific Version of `AnsibleAIConnect`](./docs/user-guide/advanced-configuration/deploying-a-specific-version.md)
- [Trusting a Custom Certificate Authority](./docs/user-guide/advanced-configuration/trusting-a-custom-certificate-authority.md)

## Maintainers Docs

Maintainers of this repo need to carry out releases, triage issues, etc. There are docs for those types of administrative tasks in the `docs/maintainer/` directory.

To release the `AnsibleAIConnect` Operator, see these docs:
* [Release Operator](./docs/maintainers/release.md)
