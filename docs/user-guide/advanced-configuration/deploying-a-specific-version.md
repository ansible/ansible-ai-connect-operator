## Deploying a specific version of `AnsibleAIConnect`

There are a few variables that are customizable for eda the image management.

| Name                     | Description               | Default                                          |
|--------------------------|---------------------------|--------------------------------------------------|
| `image`                  | Path of the image to pull | `quay.io/ansible/eda-server`                     |
| `image_version`          | Image version to pull     | value of `DEFAULT_AI_CONNECT_VERSION` or `main`  |
| `image_pull_policy`      | The pull policy to adopt  | `IfNotPresent`                                   |
| `image_pull_secrets`     | The pull secrets to use   | `None`                                           |
| `postgres_image`         | Path of the image to pull | `postgres`                                       |
| `postgres_image_version` | Image version to pull     | `latest`                                         |

Example of customization could be:

```yaml
---
spec:
  ...
  image: myorg/my-custom-eda
  image_version: main
  image_pull_policy: Always
  image_pull_secrets:
    - pull_secret_name
```

  > **Note**: The `image` and `image_version` style variables are intended for local mirroring scenarios. Please note that using a version of `AnsibleAIConnect` other than the one bundled with the `ansible-ai-connect-operator` is **not** supported even though it will likely work and can be useful for pinning a version. For the default values, check the [main.yml](https://github.com/ansible/ansible-ai-connect_operator/blob/main/roles/ansibleaiconnect/defaults/main.yml) file.


### Configuring an image pull secret

1. Log in with that token, or username/password, then create a pull secret from the docker/config.json

```bash
docker login quay.io -u <user> -p <token>
```

2. Then, create a k8s secret from your .docker/config.json file. This pull secret should be created in the same namespace you are installing the `AnsibleAIConnect` Operator.

```bash
kubectl create secret generic redhat-operators-pull-secret \
  --from-file=.dockerconfigjson=.docker/config.json \
  --type=kubernetes.io/dockerconfigjson
```

3. Add that image pull secret to your `AnsibleAIConnect` spec

```yaml
---
spec:
  image_pull_secrets:
    - redhat-operators-pull-secret
```
