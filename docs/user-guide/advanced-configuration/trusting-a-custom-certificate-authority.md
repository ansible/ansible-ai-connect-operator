## Trusting a Custom Certificate Authority

In cases which you need to trust a custom Certificate Authority, there are few variables you can customize for the `ansible-ai-connect-operator`.

Trusting a custom Certificate Authority allows the `AnsibleAIConnect` instance to access network services configured with SSL certificates issued locally, such as cloning a project from an internal Git server via HTTPS. If it is needed, you will likely see errors like this when doing project syncs:

```bash
fatal: unable to access 'https://private.repo./mine/ansible-rulebook.git': SSL certificate problem: unable to get local issuer certificate
```


| Name                             | Description                              | Default |
|----------------------------------|------------------------------------------|---------|
| `bundle_cacert_secret`           | Certificate Authority secret name        | ''      |

Please note the `ansible-ai-connect-operator` will look for the data field `bundle-ca.crt` in the specified `bundle_cacert_secret` secret.

Example of customization could be:

```yaml
---
spec:
  ...
  bundle_cacert_secret: <resourcename>-custom-certs
```

Create the secret with CLI:

* Certificate Authority secret

```
# kubectl create secret generic <resourcename>-custom-certs \
    --from-file=bundle-ca.crt=<PATH/TO/YOUR/CA/PEM/FILE>
```

Alternatively, you can also create the secret with `kustomization.yaml` file:

```yaml
...
secretGenerator:
  - name: <resourcename>-custom-certs
    files:
      - bundle-ca.crt=<path+filename>
    options:
      disableNameSuffixHash: true
...
```
