# Using external configuration `Secret`'s

## Overview

Configuration parameters for the both the authentication backend and model service **must** be provided using `Secret`'s.

## Authentication `Secret`

`auth_config_secret_name` should be set to the name of an existing `Secret`. The Operator will use the values set therein to configure the authentication backend integration. The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-auth-configuration
  namespace: <target-namespace>
data:
  auth_api_url: <base64 encoded Authentication service URL>
  auth_api_key: <base64 encoded Authentication service API Key>
  auth_api_secret: <base64 encoded Authentication service API Secret>
  auth_verify_ssl: <base64 encoded boolean>
  auth_allowed_hosts: <base64 encoded domains>
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
  auth_config_secret_name: <secret-name>-auth-configuration
```

## Model service `Secret`

`model_config_secret_name` should be set to the name of an existing `Secret`. The Operator will use the values set therein to configure the model service integration. The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-model-configuration
  namespace: <target-namespace>
data:
  username: <base64 encoded WCA "on prem" username[1]>
  model_url: <base64 encoded WCA service URL>
  model_api_key: <base64 encoded WCA API Key>
  model_name: <base64 encoded WCA Model Name>
  model_type: <base64 encoded WCA type[2]>
type: Opaque
```
- [1] `username` is only required for `wca-onprem`. The value is discarded for `wca`.
- [2] `model_type` is either `wca` or `wca-onprem`

The `AnsibleAIConnect` configuration would look like this:
```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: <instance-name>
  namespace: <target-namespace>
spec:
  ...
  model_config_secret_name: <secret-name>-model-configuration
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
  auth_api_url: <base64 encoded Authentication service URL>
  auth_api_key: <base64 encoded Authentication service API Key>
  auth_api_secret: <base64 encoded Authentication service API Secret>
  auth_verify_ssl: <base64 encoded boolean>
  auth_allowed_hosts: <base64 encoded domains>
type: Opaque
```

### Create the model `Secret`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret-model-configuration
  namespace: mynamespace
data:
  username: <base64 encoded WCA username>
  model_url: <base64 encoded WCA service URL>
  model_api_key: <base64 encoded WCA API Key>
  model_name: <base64 encoded WCA Model Name>
  model_type: <base64 encoded WCA type>
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
  auth_config_secret_name: 'my-secret-auth-configuration'
  model_config_secret_name: 'my-secret-model-configuration'
```