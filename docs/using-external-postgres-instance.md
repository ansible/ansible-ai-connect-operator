# Using an external Postgres instance

## Overview

The Operator will create a _managed_ instance of Postgres by default. The Operator also creates a `Secret` containing the various parameters required for the service to connect to the database.

If you have an existing Postgres instance that you wish to use you can create the `Secret` manually with the necessary parameters and the Operator will use this instead. You will need to set `database.database_secret` to the name of the `Secret` you create.

_Managed_ instances of Postgres follow the lifecycle of the `AnsibleAIConnect` instance and the Operator will destroy the applicable resources if the `AnsibleAIConnect` instance is deleted.

You will need to manage the Postgres resources yourself for _unmanaged_ instances where you've specified an existing `database.database_secret`.

## Create the database `Secret`

The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>-postgres-configuration
  namespace: <target-namespace>
stringData:
  database: <database name>
  username: <username>
  password: <password>
  host: <host>
  port: <port>
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

The follow demonstrates how you can create a freestanding Postgress instance on OpenShift `ROSA`.
```
oc new-app \
  -e POSTGRESQL_USER=<username> \
  -e POSTGRESQL_PASSWORD=<password> \
  -e POSTGRESQL_DATABASE=<database name> \
  registry.redhat.io/rhel8/postgresql-15
```
### Create the database `Secret`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret-postgres-configuration
  namespace: mynamespace
stringData:
  database: <database name>
  username: <username>
  password: <password>
  # 'postgresql-15' is the name of the Postgres image/deployment
  host: "postgresql-15.mynamespace.svc.cluster.local"
  port: <port>
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
  auth_config_secret_name: 'auth-configuration-secret'
  model_config_secret_name: 'model-configuration-secret'
  database:
    database_secret: 'my-secret-postgres-configuration'
```