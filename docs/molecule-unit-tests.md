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

## Start your local Kubernetes runtime
```
minikube start
```

## Configure required environment variables

The `DOCKER_CONFIG_JSON` value should be obtained from your local `.docker/config.json` file.

```
export OPERATOR_IMAGE=manstis/aiconnect:0.0.3
export DOCKER_CONFIG_JSON=`base64 --wrap=0 ~/.docker/config.json`
```

## Run tests
```
molecule test
```
