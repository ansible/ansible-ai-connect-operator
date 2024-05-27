# Clean up a cluster operator installation

## Clean up Subscriptions
Get the subscriptions for all namespaces:
```
oc get subscription.operators.coreos.com -A | grep ansible-ai-connect
```
For each one, delete it:
```
oc delete subscription.operators.coreos.com ansible-ai-connect-operator -n <namespace>
```

## Clean up ClusterServiceVersion
Get the ClusterServiceVersions for all namespaces:
```
oc get clusterserviceversion -A | grep ansible-ai-connect-operator.v
```
For each one, delete it:
```
oc delete clusterserviceversion ansible-ai-connect-operator.v0.1.20 -n <namespace>
```

## Clean up CatalogSource
Get the CatalogSources for all namespaces:
```
oc get CatalogSource -A | grep ansible-ai-connect
```
For each one, delete it:
```
oc delete CatalogSource ansible-ai-connect-operator-dev -n <namespace>
```

## Clean up AnsibleAIConnect
Get the AnsibleAIConnect instances for all namespaces:
```
oc get  AnsibleAIConnect -A | grep ansible
```
For each one, delete it:
```
oc delete  AnsibleAIConnect my-aiconnect -n <namespace>
```

## Clean up Operators
Get the Operators for all namespaces:
```
oc get operators -A | grep ansible-ai-connect-operator
```
For each one, delete it:
```
oc delete operators ansible-ai-connect-operator.<namespace>
```

**NOTE**: If operators are re-created after deleting, please follow https://access.redhat.com/solutions/6992707
