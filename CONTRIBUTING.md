# Contributing

## Development Environment

There are a couple ways to make and test changes to an Ansible operator. The easiest way is to build and deploy the operator from your branch using the make targets. This is closed to how the operator will be used, and is what is documented below. However, it may be useful to run the AnsibleAIConnect Operator roles directly on your local machine for faster iteration. This involves a bit more set up, and is described in the [Debugging docs](./docs/debugging.md).

First, you need to have a k8s cluster up. If you don't already have a k8s cluster, you can use minikube to start a lightweight k8s cluster locally by following these [minikube test cluster docs](./docs/minikube-test-cluster.md).

### Build Operator Image

Clone the ansible-ai-connect-operator

```
git clone git@github.com:ansible/ansible-ai-connect-operator.git
```

Create an image repo in your user called `ansible-ai-connect-operator` on [quay.io](https://quay.io) or your preferred image registry. 

Build & push the operator image

```
export QUAY_USER=username
export TAG=feature-branch
make docker-build docker-push IMG=quay.io/$QUAY_USER/ansible-ai-connect-operator:$TAG
```

### Deploy AnsibleAIConnect Operator

1. Log in to your K8s or Openshift cluster.

```
kubectl login <cluster-url>
```

2. Run the `make deploy` target

```
NAMESPACE=ansibleaiconnect IMG=quay.io/$QUAY_USER/ansible-ai-connect-operator:$TAG make deploy
```
> **Note** The `latest` tag on the quay.io/ansible/ansible-ai-connect-operator repo is the latest _released_ (tagged) version and the `main` tag is built from the HEAD of the `main` branch. To deploy with the latest code in `main` branch, check out the main branch, and use `IMG=quay.io/ansible/ansible-ai-connect-operator:main` instead.

### Create an AnsibleAIConnect CR

Create a yaml file defining the EDA custom resource

```yaml
# aiconnect.yaml
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
    health_check_api_key: 'TBA'
    health_check_model_name: 'TBA'
```

3. Now apply this yaml

```bash
$ kubectl apply -f aiconnect.yaml
```
