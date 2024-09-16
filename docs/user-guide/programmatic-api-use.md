# Programmatic API use

It is possible to invoke the service programmatically.

In order to programmatically use the API an Access Token must be created.

## Procedure

1. Log in to the Django Administration Portal using the following credentials:

```
Username: admin
Password: <password>
```
- The Django Administration Portal is at `http[s]://<aaic-instance-route>/admin`
- The password can be found in the `Secret` named `<aaic-instance-name>-admin-password` in the cluster namespace where the `AnsibleAIConnect` instance is deployed.

2. In the Django Administration Portal, select "Users" from the "Users" area. 

    A list of users is displayed.


3. Verify that the user to whom you want to grant programmatic access is in the Users list.

NOTE: An access token can only be granted to an existing AAP User. The applicable User must first log into `Ansible AI Connect` with their credentials to create a User record in the Django database. Users created with `wisdom-manage createsuperuser` cannot be granted API access tokens.


4. From the "Django Oauth toolkit" area, select "Access tokens" → "Add". 

    Provide the following information and click "Save":

    - `User`: Use the magnifying glass icon to search and select the user.
    - `Token`: Specify a token for the user. Copy this token for later use.
    - `Id token`: Select the Token ID. The default `------` is acceptable.
    - `Application`: Select "Ansible Lightspeed for VS Code".
    - `Expires`: Select the date and time when you want the token to expire.
    - `Scope`: Specify the scope as `read write`.


5. An access token is created for the user.


6. Log out from the Django Administration Portal.

## Example API call
```
curl -X 'POST' \
'<aaic-instance-url>/api/v0/ai/completions/' \
-H 'accept: application/json' \
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer <token from earlier>' \
-d '{
"prompt": "---\n- hosts: all\n  tasks:\n  - name: Install nginx"
}'
```
