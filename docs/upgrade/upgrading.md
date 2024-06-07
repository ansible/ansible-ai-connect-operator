### Upgrading

Before upgrading, please review the changelog for any breaking or notable changes in the releases between your current version and the one you are upgrading to. These changes can be found on the [Release page](https://github.com/ansible/ansible-ai-connect-operator/releases).


An operator version pins to a specific version of `ansible-ai-connect-service` which is the latest version at the time of the operator release.

To find the version of `ansible-ai-connect-service` that will be installed by the operator, check the version specified in the `DEFAULT_AI_CONNECT_VERSION` variable for that particular release. You can do so by running the following command

```shell
OPERATOR_VERSION=1.0.1
docker run --entrypoint="" quay.io/ansible/ansible-ai-connect-operator:$OPERATOR_VERSION bash -c "env | egrep DEFAULT_AI_CONNECT_VERSION"
```

Follow the installation instructions (`make deploy`, `kustomization`, etc) using the new release version to apply the new operator `yaml` and upgrade the operator. This will in turn also upgrade your `AnsibleAIConnect` deployment.

For example, if you installed with `kustomize`, you could modify the version in your `kustomization.yaml` file from `1.0.0` to `1.0.1` and then apply it.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - config/default

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/ansible-ai-connect-operator
    newTag: 1.0.1

# Specify a custom namespace in which to install AnsibleAIConnect
namespace: ansible-ai-connect
```

Then run this to apply it:

```
kustomize build . | kubectl apply -f -
```

#### PostgreSQL Upgrade Considerations

If there is a PostgreSQL major version upgrade, after the data directory on the `PersistentVolumeClaim` is migrated to the new version, the old `PersistentVolumeClaim` is kept by default.

This provides the ability to roll back if needed, but can take up extra storage space in your cluster unnecessarily. By default, the Postgres `PersistentVolumeClaim` from the previous version will remain unless you manually remove it, or have the `database.postgres_keep_pvc_after_upgrade` parameter set to `false`. You can configure it to be deleted automatically
after a successful upgrade by setting the following variable on the `AnsibleAIConnect` specification.

```yaml
  spec:
    database:
        postgres_keep_pvc_after_upgrade: false
```