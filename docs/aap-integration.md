
# Integrating with Ansible Automation Platform

Lightspeed service depends on a deployed instance of Ansible Automation Platform (AAP).  The following steps decribe how you can configure it.


## Create An Application in AAP

* Login to your AAP
* In the left hand side navigation menu, click [Administration/Application](images/aap-applications.png)
* Click `Add` to create a new application
* Fill in the application details. This is [an example](images/aap-create-application.png)
  * Note that you won't have the exact `Redirect URIs` yet. For now, just enter a valid URL and we will come back to update it after installation of Lightspeed.
  * After clicking `Save`, a pop up with `Client ID` and `Client secret` will show up.
  * Copy `Client secret` and store in a secured storage (e.g. secrets vault) because you will not be able to retrieve after dismissing the popup.
* Now you will have collected the following
  * The application `Client ID` 
  * The application `Client secret` 
  * The AAP API URL which is normally `<your_app_web_url>/api/`


## When instantiating Ansible Lightspeed CR

The 3 fields you will need to fill come from the above step:
1. AAP authentication key: The application `Client ID`
2. AAP authentication secret: The application `Client secret`
3. AAP API URL: AAP API URL which is normally `<your_app_web_url>/api/`

