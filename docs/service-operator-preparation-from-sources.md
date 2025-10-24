# Build and deploy the Ansible AI Connect Service & Operator

This document describes the high level procedure, and instructions to follow, in order to:
- Build and deploy the [ansible-wisdom-ai-connect-service](https://github.com/ansible/ansible-ai-connect-service) to a container registry
- Build and deploy the [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator) into Openshift

_NOTE_: This document assumes the use of [podman](https://podman.io/) as for the local container runtime, 
[quay.io](https://quay.io/) as for the container registry, 
and [Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift) for the management of cloud deployments and services.

## Ansible AI Connect Service

In case the service code has been changed, a new service image has to be created and uploaded to some registry. 

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

In case the operator code changed, or the service image tag updated, please build and deploy the operator.

### Build and push the operator images

In case operator, bundle or catalog images must be generated, please follow:

- Checkout a branch or tag from [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator)
- Login into the registry where to push the images, f.i. [login into quay.io](https://quay.io/tutorial/) 
- Replace variables as appropriate, and run:
  ```
  export IMAGE_TAG_BASE=quay.io/<project>/ansible-ai-connect
  export VERSION=0.x.y
  
  make docker-build docker-push
  make bundle
  make bundle-build bundle-push
  make catalog-build catalog-push
  ```

### Install and run the operator in Openshift

- Checkout a branch or tag from [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator)
- [Install the operator](running-on-openshift-cluster.md)
- [Create an AnsibleAIConnect instance](running-on-openshift-cluster.md#create-an-ansibleaiconnect-instance)

### AAP and WCA Integration

Follow instructions on how to [integrate with AAP and WCA](aap-wca-integrations.md)

### Advanced configurations

For configurations such as database, secrets, accounts, logging or use of certificates, please refer to these [instructions](../README.md#advanced-configuration)
