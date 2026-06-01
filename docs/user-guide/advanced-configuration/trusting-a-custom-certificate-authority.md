## Trusting a Custom Certificate Authority

In cases which you need to trust a custom Certificate Authority, there are few variables you can customize for the `ansible-ai-connect-operator`.

Trusting a custom Certificate Authority allows the `AnsibleAIConnect` and `AnsibleMCPConnect` instances to access network services configured with SSL certificates issued locally, such as cloning a project from an internal Git server via HTTPS or validating tokens against AAP with self-signed certificates. If it is needed, you will likely see errors like this:

```bash
fatal: unable to access 'https://private.repo./mine/ansible-rulebook.git': SSL certificate problem: unable to get local issuer certificate
```

or for MCP Server:

```bash
Error: self-signed certificate in certificate chain
    code: 'SELF_SIGNED_CERT_IN_CHAIN'
```

| Name                             | Description                              | Default |
|----------------------------------|------------------------------------------|---------|
| `bundle_cacert_secret`           | Certificate Authority secret name        | ''      |

Please note the `ansible-ai-connect-operator` will look for the data field `bundle-ca.crt` in the specified `bundle_cacert_secret` secret.

### OpenShift Auto-Discovery

**New in this release:** When deploying `AnsibleMCPConnect` on OpenShift, the operator automatically discovers and trusts the cluster's router CA certificate if `bundle_cacert_secret` is not explicitly set. This eliminates the need for manual configuration in most OpenShift environments.

The auto-discovery feature:
- Only runs on OpenShift clusters (detected via route.openshift.io API group)
- Searches for the default ingress controller's TLS certificate in the `openshift-ingress` namespace
- Creates a copy of the certificate in the operator's namespace
- Automatically configures the MCP server deployment to trust the certificate

To disable auto-discovery or use a different certificate, explicitly set `bundle_cacert_secret` to your preferred secret name.



### Example of customization could be:

```yaml
---
spec:
  ...
  bundle_cacert_secret: <resourcename>-custom-certs
```

### Download the self-signed cert from the subject host

```
openssl s_client -showcerts -connect {HOST}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate.crt

```

### Create the secret with CLI:

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
