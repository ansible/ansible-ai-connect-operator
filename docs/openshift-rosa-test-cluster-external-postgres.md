# Running on an OpenShift `ROSA` cluster for testing with an external Postgres instance

This document assumes you have an OpenShift `ROSA` cluster running.

See https://docs.openshift.com/rosa/welcome/index.html

It also assumes you have deployed the Operator. See [here](openshift-rosa-test-cluster.md#install-the-operator).

## Permissions

Users will require the OpenShift Dedicated Admins [role](https://docs.openshift.com/dedicated/authentication/osd-admin-roles.html#the-dedicated-admin-role) for the namespace in which they wish to install the Operator. At the time of writing this is called `dedicated-admins-project`.

## Create the database `Secret`

If `database.database_secret` is not set in the `AnsibleAIConnect` definition the Operator will create a _managed_ instance of Postgres.

If `database.database_secret` is set to the name of an existing `Secret` the Operator will use the values set therein to connect to an existing Postgres instance. The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-postgres-configuration
  namespace: <target-namespace>
data:
  database: <base64 encoded database name>
  username: <base64 encoded username>
  password: <base64 encoded password>
  host: <base64 encoded host>
  port: <base64 encoded port>
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
  database:
    database_secret: <secret-name>-postgres-configuration
```
## Example

### Create an _external_ Postgres instance
```
oc new-app \
  -e POSTGRESQL_USER=<username> \
  -e POSTGRESQL_PASSWORD=<password> \
  -e POSTGRESQL_DATABASE=<database name> \
  registry.redhat.io/rhscl/postgresql-13-rhel7
```
### Create the database `Secret`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-postgres-configuration
  namespace: <target-namespace>
data:
  database: <base64 encoded database name>
  username: <base64 encoded username>
  password: <base64 encoded password>
  # base64 encode "postgresql-13-rhel7.<target-namespace>.svc.cluster.local"
  # 'postgresql-13-rhel7' is the name of the Postgres image/deployment
  host: <base64 encoded host>
  port: <base64 encoded port>
type: Opaque
```

### Create an `AnsibleAIConnect` instance
```yaml
apiVersion: aiconnect.ansible.com/v1alpha1
kind: AnsibleAIConnect
metadata:
  name: <instance-name>
  namespace: <target-namespace>
spec:
  ingress_type: Route
  service_type: ClusterIP
  image_pull_secrets:
    - redhat-operators-pull-secret
  auth:
    aap_api_url: 'TBA'
    social_auth_aap_key: 'TBA'
    social_auth_aap_secret: 'TBA'
  ai:
    username: 'TBA'
    inference_url: 'TBA'
    model_mesh_api_key: 'TBA'
    model_mesh_model_name: 'TBA'
  database:
    database_secret: '<secret-name>-postgres-configuration'
```