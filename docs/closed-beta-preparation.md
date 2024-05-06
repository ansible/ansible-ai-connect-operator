# Closed-Beta Preparation for Ansible AI Connect Operator

This document describes the high level procedure, and instructions to follow, in order to:
- Build and deploy the [ansible-wisdom-ai-connect-service](https://github.com/ansible/ansible-ai-connect-service) to a container registry
- Build and deploy the [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator) into Openshift

## Ansible AI Connect Service

### Build the service

- Checkout a branch or tag from [ansible-wisdom-ai-connect-service](https://github.com/ansible/ansible-ai-connect-service)
- Follow instructions on how to [build de container image](https://github.com/ansible/ansible-ai-connect-service?tab=readme-ov-file#running-the-django-application-standalone-from-container)

### Push the service to a registry

The Ansible AI Connect Service image can be deployed to any public or private container registry. 

_NOTE_: For this document we assume using 'podman' as container runtime, and [quay.io](https://quay.io/) as the registry.

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

### Automating the build & deploy for the service

The build and deploy for the Ansible AI Connect Service can be automated, for example, by using GitHub Actions (GHA). 

See an example of [GHA for the Ansible AI Connect Service](https://github.com/ansible/ansible-ai-connect-service/blob/main/.github/workflows/Build_Push_Image.yml)


## Ansible AI Connect Operator

### Build and deploy the operator

- Checkout a branch or tag from [ansible-wisdom-ai-connect-operator](https://github.com/ansible/ansible-ai-connect-operator)
- Follow instructions on how to [build and deploy the operator's images](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#install-the-ansible-ai-connect-operator)
- Follow instructions on how to [deploy the operator in Openshift](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#deploy-an-ansibleaiconnect-instance)

### Advanced configurations

Please refer to these [instructions](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#advanced-configuration) for configurations such as use of an external database, secrets, accounts and encryption.

### WCA Integration
- Follow instructions on how to [integrate with WCA](https://github.com/ansible/ansible-ai-connect-operator?tab=readme-ov-file#integrating-with-ansible-automation-platform-and-ibm-watsonx-code-assistant)