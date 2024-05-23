# Using external configuration `Secret`'s

## Overview

Configuration parameters for the both the authentication backend and model service can be provided as explicit parameters in the `AnsibleAIConnect` definition. For example:
```yaml
spec:
  auth_config:
    aap_api_url: 'TBA'
    social_auth_aap_key: 'TBA'
    social_auth_aap_secret: 'TBA'
  model_config:
    username: 'TBA'
    inference_url: 'TBA'
    model_mesh_api_key: 'TBA'
    model_mesh_model_name: 'TBA'
```
If it is undesirable to provide these in plain text _external_ `Secret`'s can be used instead.

## Authentication `Secret`

If `auth_config.auth_secret_name` is set to the name of an existing `Secret` the Operator will use the values set therein to connect to configure the authentication backend integration. The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-auth-configuration
  namespace: <target-namespace>
data:
  aap_api_url: <base64 encoded Ansible Automation Platform API service URL>
  social_auth_aap_key: <base64 encoded Ansible Automation Platform Application Client ID>
  social_auth_aap_secret: <base64 encoded Ansible Automation Platform Application Secret>
  social_auth_verify_ssl: <base64 encoded boolean>
  ansible_wisdom_domain: <base64 encoded domains>
type: Opaque
```
The `AnsibleAIConnect` configuration would look like this:
```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: <instance-name>
  namespace: <target-namespace>
spec:
  ...
  auth_config:
    auth_secret_name: <secret-name>-auth-configuration
```

## Model service `Secret`

If `model_config.model_secret_name` is set to the name of an existing `Secret` the Operator will use the values set therein to connect to configure the model service integration. The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-model-configuration
  namespace: <target-namespace>
data:
  username: <base64 encoded WCA "on prem" username[1]>
  inference_url: <base64 encoded WCA service URL>
  model_mesh_api_key: <base64 encoded WCA API Key>
  model_mesh_model_name: <base64 encoded WCA Model Name>
  model_mesh_type: <base64 encoded WCA type[2]>
type: Opaque
```
- [1] `username` is only required for `wca-onprem`. The value is discarded for `wca`.
- [2] `model_mesh_type` is either `wca` or `wca-onprem`

The `AnsibleAIConnect` configuration would look like this:
```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: <instance-name>
  namespace: <target-namespace>
spec:
  ...
  model_config:
    model_secret_name: <secret-name>-model-configuration
```

## Example

### Create the authentication `Secret`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret-auth-configuration
  namespace: mynamespace
data:
  aap_api_url: <base64 encoded Ansible Automation Platform API service URL>
  social_auth_aap_key: <base64 encoded Ansible Automation Platform Application Client ID>
  social_auth_aap_secret: <base64 encoded Ansible Automation Platform Application Secret>
  social_auth_verify_ssl: <base64 encoded boolean>
  ansible_wisdom_domain: <base64 encoded domains>
type: Opaque
```

### Create the Model `Secret`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret-model-configuration
  namespace: mynamespace
data:
  username: <base64 encoded WCA username>
  inference_url: <base64 encoded WCA service URL>
  model_mesh_api_key: <base64 encoded WCA API Key>
  model_mesh_model_name: <base64 encoded WCA Model Name>
  model_mesh_type: <base64 encoded WCA type>
type: Opaque
```

### Create an `AnsibleAIConnect` instance
```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: my-aiconnect-instance
  namespace: mynamespace
spec:
  ingress_type: Route
  service_type: ClusterIP
  auth_config:
    auth_secret_name: my-secret-auth-configuration
  model_config:
    model_secret_name: my-secret-model-configuration
```