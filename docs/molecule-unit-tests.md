# Running Ansible `molecule` tests

## Setup

You need to configure your local environment as follows:
```
python3 -m venv ./venv
source ./venv/bin/activate

pip install ansible
pip install molecule
pip install kubernetes
```

## Configure required environment variables

The scenarios deploy pods that pull `quay.io/ansible/ansible-ai-connect-service`, which is
a private image, so a Docker config containing a credential with **pull** access to that
repository is required. Use a read-only Quay robot account for this, not your personal
login.

Login with the robot credentials. Point `--authfile` at the Docker config so the
`DOCKER_CONFIG_JSON` step below reads the file you just wrote (Podman's default auth
file is `${XDG_RUNTIME_DIR}/containers/auth.json`, not `~/.docker/config.json`):

```
podman login --authfile ~/.docker/config.json \
  --username 'ansible+<robot>' quay.io     # prompts for the robot token
```

That writes the credential to `~/.docker/config.json`; encode that file for the variable:

```
export DOCKER_CONFIG_JSON=`base64 --wrap=0 ~/.docker/config.json`
```

**NOTE:** Mac Users should use the following to set `DOCKER_CONFIG_JSON` as the `base64` implementation is different:

```
export DOCKER_CONFIG_JSON=`base64 -i ~/.docker/config.json`
```

CI does not use a separate secret for this: the Molecule workflows derive the config from
the `QUAY_USER`/`QUAY_TOKEN` robot credentials the publish workflows already use.

## Using `minikube`

### Start your local Kubernetes runtime
```
minikube start
```

### Run tests
The `default` scenario is configured for `minikube`.
```
molecule test
```

## Using `kind`

### Install `kind` for your local environment.

See https://kind.sigs.k8s.io/docs/user/quick-start/#installation

GitHub Actions `runner-image` for `ubuntu-latest` already [includes](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2204-Readme.md) `kind`.


### Run tests
Instruct `molecule` to run the `kind` scenario.
```
molecule test -s kind
```

**NOTE:** `kind` uses `docker` by default. If you are using `podman` the following should be used to run the `kind` scenario:
```
KIND_EXPERIMENTAL_PROVIDER=podman molecule test -s kind
```
