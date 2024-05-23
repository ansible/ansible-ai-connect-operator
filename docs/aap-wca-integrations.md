# Integrating with Ansible Automation Platform and IBM WCA

When deploying Ansible AI Connect service through operator, you will need to configure the integrations with Ansible Automation Platform and IBM watsonx Code Assistant. You can do this through the UI.  You can also try the more advanced way.

## Table of Contents
- [Integrating with Ansible Automation Platform and IBM WCA](#integrating-with-ansible-automation-platform-and-ibm-wca)
  - [Table of Contents](#table-of-contents)
  - [Integrating with Ansible Automation Platform](#integrating-with-ansible-automation-platform)
    - [Create An Application in Ansible Automation Platform](#create-an-application-in-aap)
    - [When instantiating Ansible Lightspeed CR](#when-instantiating-ansible-lightspeed-cr)
    - [After Ansible Lightspeed CR is created](#after-ansible-lightspeed-cr-is-created)
  - [Integrating with IBM watsonx Code Assistant](#integrating-with-ibm-watsonx-code-assistant)
    - [IBM watsonx Code Assistant - Cloud Pack for Data (CPD)](#ibm-watsonx-code-assistant---cloud-pack-for-data-cpd)
    - [IBM watsonx Code Assistant - IBM Cloud](#ibm-watsonx-code-assistant---ibm-cloud)
  - [Advanced Configuration: Using secrets for configs](#advanced-configuration-using-secrets-for-configs)


## Integrating with Ansible Automation Platform

Lightspeed service depends on a deployed instance of Ansible Automation Platform (AAP).  The following steps decribe how you can configure it.

### Create An Application in Ansible Automation Platform

* Login to your Ansible Automation Platform
* In the left hand side navigation menu, click `Administration/Application`

  ![Administration/Application](images/aap-applications.png)
  
* Click `Add` to create a new application
* Fill in the application details. This is an example
  
  ![an example](images/aap-create-application.png)
  * Note that you won't have the exact `Redirect URIs` yet. For now, just enter a valid URL and we will come back to update it after installation of Lightspeed.
  * After clicking `Save`, a pop up with `Client ID` and `Client secret` will show up.
  * Copy the `Client secret` and store it in a secured storage (e.g. secrets vault) because you will not be able to retrieve it after dismissing the popup.
* Now you will have collected the following
  * The application `Client ID` 
  * The application `Client secret` 
  * The Ansible Automation Platform API URL which is normally `<ansible-automation-platform_web_url>/api/`


### When instantiating Ansible Lightspeed CR

When you instantiate an Ansible Lightspeed Custom Resource in the OpenShift cluster, the 3 pieces of information collected from the above will help you fill
1. `Ansible Automation Platform authentication key`: The application `Client ID`
2. `Ansible Automation Platform authentication secret`: The application `Client secret`
3. `Ansible Automation Platform API URL`: The Ansible Automation Platform API URL `<ansible-automation-platform_web_url>/api/`

You can also use an existing `Secret` to store these _sensitive_ values. See [here](using-external-configuration-secrets.md#authentication-secret) for instructions.

### After Ansible Lightspeed CR is created

* A route to the Lightspeed API service will be provisioned in the namespace
* Revisit the application object you have created in the [Create An Application in Ansible Automation Platform](create-an-application-in-aap) section
* Update the `Redirect URIs` field with `<lightspeed_route>/complete/aap/` where `<lightspeed_route>` is the route you just obtained.

## Integrating with IBM watsonx Code Assistant

Currently, IBM watsonx Code Assistant can be delivered through a cloud verson and a on-premise verion, the Cloud Pack for Data.  Lightspeed service can integrate with either of them.

When you instantiate an Ansible Lightspeed Custom Resource in the OpenShift cluster, there is a config section `model_config`.  Near the end of the section, click open the `Advanced configuration` and choose the `Type of AI provider`.  Choose `wca-onprem` to integrate with the Cloud Pack for Data that you have set up in your infrastructure.  Choose `wca` to integrate with the cloud version.


### IBM watsonx Code Assistant - Cloud Pack for Data (CPD)

You will need to fill in these information:

1. `Model provider endpoint`: The URL to your Cloud Pack for Data instance 
2. `Model provider API Key`: [Cloud Pack for Data API key](https://www.ibm.com/docs/en/cloud-paks/cp-data/4.8.x?topic=steps-generating-api-keys) 
3. `Model provider Model Name`: An e.g.: `8e7de79b-8bc2-43cc-9d20-c4207cd92fec<|sepofid|>granite-3b`
4. `Model provider username`: The username that has access to the model/space

### IBM watsonx Code Assistant - IBM Cloud

You will need to fill in these information:

1. `Model provider endpoint`: The URL to IBM Cloud `https://dataplatform.cloud.ibm.com`
2. `Model provider API Key`: API key obtained from your IBM Cloud account
3. `Model provider Model Name`: An e.g.: `8e7de79b-8bc2-43cc-9d20-c4207cd92fec<|sepofid|>granite-3b`

## Advanced Configuration: Using secrets for configs

You can create `Secrets` to store these _sensitive_ values beforehand. See [here](using-external-configuration-secrets.md#model-service-secret) for instructions.
