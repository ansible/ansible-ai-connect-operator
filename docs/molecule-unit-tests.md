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

The `DOCKER_CONFIG_JSON` value should be obtained from your local `.docker/config.json` file.

```
export DOCKER_CONFIG_JSON=`base64 --wrap=0 ~/.docker/config.json`
```

For setting `DOCKER_CONFIG_JSON` on Mac, the `base64` usage is a bit different:

```
export DOCKER_CONFIG_JSON=`base64 -i ~/.docker/config.json`
```

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
