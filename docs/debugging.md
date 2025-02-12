# Debugging the `AnsibleAIConnect` Operator

## General Debugging

When the operator is deploying `AnsibleAIConnect`, it is running the `ai` role inside the operator container. If the `AnsibleAIConnect` CR's status is `Failed`, it is often useful to look at the `ansible-ai-connect-operator` container logs, which shows the output of the installer role. To see these logs, run:

```
kubectl logs deployments/ansible-ai-connect-operator-controller-manager -c ansibleaiconnect-manager -f
```

### Inspect k8s Resources

It is often useful to inspect various resources the `AnsibleAIConnect` Operator manages like:
* `pod`
* `deployment`
* `statefulset`
* `pvc`
* `service`
* `ingress`
* `route`
* `secrets`
* `serviceaccount`

And if installing via OperatorHub and OLM:
* `subscription`
* `csv`
* `installPlan`
* `catalogSource`

To inspect these resources you can use these commands

```
# Inspecting k8s resources
kubectl describe -n <namespace> <resource> <resource-name>
kubectl get -n <namespace> <resource> <resource-name> -o yaml
kubectl logs -n <namespace> <resource> <resource-name>

# Inspecting Pods
kubectl exec -it -n <namespace> <pod> <pod-name>
```

### Configure No Log

It is possible to show task output for debugging by setting `no_log` to false on the `AnsibleAIConnect` CR spec.
This will show output in the `ansible-ai-connect-operator` logs for any failed tasks where `no_log` was set to `true`.

For example:

```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect
  namespace: ansibleaiconnect
spec:
  no_log: false        # <------------
  auth_config_secret_name: 'auth-configuration-secret'
  model_config_secret_name: 'model-configuration-secret'
  chatbot_config_secret_name: 'chatbot-configuration-secret'
```

## Iterating on the installer without deploying the operator

Go through the [normal basic install](https://github.com/ansible/ansible-ai-connect-operator/blob/devel/README.md#install-the-ansible-ai-connect-operator) steps.

Install some dependencies:

```
$ ansible-galaxy collection install -r molecule/requirements.yml
$ pip install -r molecule/requirements.txt
```

To prevent the changes we're about to make from being overwritten, scale down any running instance of the operator:

```
$ kubectl scale deployment ansible-ai-connect-operator-controller-manager --replicas=0
```

Create a playbook that invokes the installer role (the operator uses `ansible-runner`'s role execution feature):

```yaml
# run.yml
---
- hosts: localhost
  vars:
    service_type: ClusterIP
    ingress_type: Route

    no_log: false
    ansible_operator_meta:
      name: my-aiconnect
      namespace: my-aiconnect
    set_self_labels: false
      #image: quay.io/username/wisdom-service
      #image_version: feature-branch
    api:
      replicas: 1
      resource_requirements:
        requests:
          cpu: 200m
          memory: 512Mi
    image_pull_policy: Always

  tasks:
    - include_role:
        name: ai
```

Run the installer:

```
$ ansible-playbook run.yml -e @vars.yml -v
```

Grab the URL and `admin` password:

```
$ minikube service my-aiconnect-api --url -n my-aiconnect
$ minikube kubectl get secret my-aiconnect-admin-password -- -o jsonpath="{.data.password}" | base64 --decode
```
