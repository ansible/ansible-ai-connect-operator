# Single-Command Installation Guide

This document provides comprehensive instructions for the quick, single-command installation of the `AnsibleAIConnect` Operator. Also covered are additional details such as prerequisites, uninstallation, and troubleshooting tips.

## Prerequisites
Before proceeding with the installation, ensure that the following prerequisites are met:

1. **Kubernetes Cluster**: You need an active Kubernetes cluster. If you do not have one, you can set it up using platforms like Minikube, Kind, or a cloud provider like AWS, Azure, or GCP.

2. **kubectl**: The Kubernetes command-line tool, kubectl, should be installed and configured to communicate with your cluster. You can check its availability by running `kubectl version`.

## Installation
The `AnsibleAIConnect` Operator can be installed using a single command. This command applies a `YAML` file from the `AnsibleAIConnect` Operator's GitHub repository directly to your Kubernetes cluster.

Run the following command in your terminal to install the latest operator

```bash
kubectl apply -f https://github.com/ansible/ansible-ai-connect-operator/releases/latest/download/operator.yaml
```

If you want to install a specific version instead, modify the version to whichever version you want to install. For example:

```bash
kubectl apply -f https://github.com/ansible/ansible-ai-connect-operator/releases/download/1.0.0/operator.yaml
```

> [!Note]
> This will create the `AnsibleAIConnect` Operator resources in the `ansible-ai-connect-operator-system` namespace.

Now create your `AnsibleAIConnect` custom resource by applying the `aiconnect-demo.yml` file and you will soon have a working `AnsibleAIConnect` instance!

```yaml
# aiconnect-demo.yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
spec:
  auth:
    aap_api_url: 'TBA'
    social_auth_aap_key: 'TBA'
    social_auth_aap_secret: 'TBA'
  wca:
    inference_url: 'TBA'
    model_mesh_api_key: 'TBA'
    model_mesh_model_name: 'TBA'
```

```bash
kubectl apply -f aiconnect-demo.yaml
```

See the [README.md](../README.md) for more information on configuring `AnsibleAIConnect` by modifying the `spec`.

## Upgrading

## Pre-Upgrade Checklist

* **Backup**

  - Backup your `AnsibleAIConnect` instance. 


* **Review Release Notes**

  - Check the release notes for the new version of the `AnsibleAIConnect` Operator. This can be found on the GitHub [releases page](https://github.com/ansible/ansible-ai-connect-operator/releases). Pay attention to any breaking changes, new features, or specific instructions for upgrading from your current version.

### Upgrade the Operator

Check the [Releases Page](https://github.com/ansible/ansible-ai-connect-operator/releases) for the latest `AnsibleAIConnect` Operator version. Copy the URL to the `operator.yaml` artifact for it, then apply it.

For example, if upgrading to version 1.1.0, the command would be:

```bash
kubectl apply -f https://github.com/ansible/ansible-ai-connect-operator/releases/download/1.1.0/operator.yaml
``````

Monitor the upgrade process by checking the status of the Pods in the `ansible-ai-connect-operator-system` namespace. You can use the following command:

```bash
kubectl get pods -n ansible-ai-connect-operator-system
```

## Cleanup
If you wish to remove the `AnsibleAIConnect` Operator from your Kubernetes cluster, follow these steps:

Run the following command:

```bash
kubectl delete -f https://github.com/ansible/ansible-ai-connect-operator/releases/download/1.0.0/operator.yaml
```
