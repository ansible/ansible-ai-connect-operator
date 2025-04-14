# Using external `ANSIBLE_AI_MODEL_MESH_CONFIG` configuration `Secret`

## Overview

Configuration of the "Model Pipelines" is automated from the values within the `Secret` referenced by `model_config_secret_name`.

This however can be overridden by specifying the name of an existing `Secret` in `spec.api.model_pipeline_secret`

## Model Pipeline configuration `Secret`

`spec.api.model_pipeline_secret` should be set to the name of an existing `Secret`. The Operator will use the values set therein to configure the "Model Pipelines". The `Secret` must contain the following values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>
  namespace: <target-namespace>
stringData:
  config: |
    ModelPipelineChatBot:
      config:
        inference_url: '<chatbot-service-url>'
        model_id: '<chatbot-model-id>'
        ...
      provider: '<provider>'
    ModelPipelineStreamingChatBot:
      config:
        inference_url: '<chatbot-service-url>'
        model_id: '<chatbot-model-id>'
        ...
      provider: '<provider>'
    ModelPipelineCompletions:
      config:
        inference_url: '<model-service-url>'
        api_key: '<model-api-key>'
        model_id: '<model-id>'
        ...
      provider: '<provider>'
    ModelPipelineContentMatch:
      config:
        inference_url: '<model-service-url>'
        api_key: '<model-api-key>'
        model_id: '<model-id>'
        ...
      provider: '<provider>'
    ModelPipelinePlaybookGeneration:
      config:
        inference_url: '<model-service-url>'
        api_key: '<model-api-key>'
        model_id: '<model-id>'
        ...
      provider: '<provider>'
    ModelPipelinePlaybookExplanation:
      config:
        inference_url: '<model-service-url>'
        api_key: '<model-api-key>'
        model_id: '<model-id>'
        ...
      provider: '<provider>'
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
  api:
    model_pipeline_secret: '<existing-secret-name>'
  ...
```
