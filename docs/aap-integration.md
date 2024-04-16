
# Integrating with Ansible Automation Platform

Lightspeed service depends on a deployed instance of Ansible Automation Platform (AAP).  The following steps decribe how you can configure it.


## Create An Application in AAP

* Login to your AAP
* In the left hand side navigation menu, click `Administration/Application`

  ![Administration/Application](images/aap-applications.png =100x)
  
* Click `Add` to create a new application
* Fill in the application details. This is an example
  
  ![an example](images/aap-create-application.png)
  * Note that you won't have the exact `Redirect URIs` yet. For now, just enter a valid URL and we will come back to update it after installation of Lightspeed.
  * After clicking `Save`, a pop up with `Client ID` and `Client secret` will show up.
  * Copy the `Client secret` and store it in a secured storage (e.g. secrets vault) because you will not be able to retrieve it after dismissing the popup.
* Now you will have collected the following
  * The application `Client ID` 
  * The application `Client secret` 
  * The AAP API URL which is normally `<aap_web_url>/api/`


## When instantiating Ansible Lightspeed CR

When you instantiate an Ansible Lightspeed Custom Resource in the OpenShift cluster, the 3 pieces of information collected from the above will help you fill
1. AAP authentication key: The application `Client ID`
2. AAP authentication secret: The application `Client secret`
3. AAP API URL: The AAP API URL `<aap_web_url>/api/`

## After Ansible Lightspeed CR is created

* A route to the Lightspeed API service will be provisioned in the namespace
* Revisit the application object you have created in the [Create An Application in AAP](create-an-application-in-aap) section
* Update the `Redirect URIs` field with `<lightspeed_route>/completion/aap/` where `<lightspeed_route>` is the route you just obtained.
