# Build and deploy the Ansible AI Connect Service & Operator from sources

This document describes the high level procedure, and instructions to follow, in order to:
- Build and deploy the [ansible-wisdom-ai-connect-service](https://github.com/ansible/ansible-ai-connect-service) to a container registry
- Build and deploy the [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator) into Openshift

_NOTE_: This document assumes the use of [podman](https://podman.io/) as for the local container runtime, 
[quay.io](https://quay.io/) as for the container registry, 
and [Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift) for the management of cloud deployments and services.

## Ansible AI Connect Service

### Build the service

- Checkout a branch or tag from [ansible-wisdom-ai-connect-service](https://github.com/ansible/ansible-ai-connect-service)
- Follow instructions on how to [build de container image](https://github.com/ansible/ansible-ai-connect-service?tab=readme-ov-file#running-the-django-application-standalone-from-container)

### Push the service to a registry

The Ansible AI Connect Service image can be deployed to any public or private container registry.

- [Login into quay.io](https://quay.io/tutorial/)
- Tag the image:
```
podman tag <source> quay.io/<project>/<destination>
# Example: podman tag localhost/ansible_wisdom quay.io/myproject/ansible_wisdom
```
- Push the image:
```
podman push quay.io/<project>/<destination>
# Example: podman push quay.io/myproject/ansible_wisdom
```

## Ansible AI Connect Operator

### Build and deploy the operator

- Checkout a branch or tag from [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator)
- TODO: Login to minikube or Openshift first? So kubectl points to the right destination cluster.
- [Install the operator's images](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#install-the-ansible-ai-connect-operator)
  - TODO: Need for cluster-admin role 
  - TODO: Global CSV & CRD ? implications on other ns? 
- TODO:  Advanced configurations (secrets (private quay.io, AAP, WCA), etc), first??
- [Deploy the operator in Openshift](https://github.com/ansible/ansible-ai-connect-operator/blob/main/docs/running-on-openshift-rosa-cluster.md)
- [Create an AnsibleAIConnect instance](https://github.com/ansible/ansible-ai-connect-operator/blob/main/docs/running-on-openshift-rosa-cluster.md#create-an-ansibleaiconnect-instance)

### AAP  Integration

TODO

### WCA Integration
- 
- Follow instructions on how to [integrate with WCA](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#integrating-with-ansible-automation-platform-and-ibm-watsonx-code-assistant)

### Advanced configurations

Please refer to these [instructions](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#advanced-configuration) for configurations such as use of an external database, secrets, accounts and encryption.
