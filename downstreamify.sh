#!/usr/bin/bash

set -eux

# -- Set Variables

AAP_XY_VERSION=${AAP_XY_VERSION:-2.6}
AAP_XY=$(echo $AAP_XY_VERSION | sed -e 's/\.//g')

# -- General replaces section

replacements=(
    AnsibleAIConnect:AnsibleLightspeed
    aiconnect.ansible.com:lightspeed.ansible.com
    AnsibleMCPConnect:AnsibleMCPServer
    mcpconnect.ansible.com:mcpserver.ansible.com
)

# Replace in roles files; settings configmap is intentionally left out to keep settings in tact
for row in "${replacements[@]}"; do
    upstream="$(echo $row | cut -d: -f1)";
    downstream="$(echo $row | cut -d: -f2)";
    find ./roles -type f -name '*' \
      -not -path '*.md' \
      -not -path roles/model/templates/model.configmap.yaml.j2 \
	    -exec sed -i -e "s/${upstream}/${downstream}/g" {} \;
done

# Replace in watches.yaml
for row in "${replacements[@]}"; do
    upstream="$(echo $row | cut -d: -f1)";
    downstream="$(echo $row | cut -d: -f2)";
    sed -i -e "s/${upstream}/${downstream}/g" ./watches.yaml ;
done

# -- Replace deployment_type

sed -i -e "s/ansible-ai-connect/ansible-lightspeed/g" ./roles/common/defaults/main.yml\
                                   ./roles/chatbot/defaults/main.yml \
                                   ./roles/model/defaults/main.yml \
                                   ./roles/postgres/defaults/main.yml ;
                                  #  ./roles/backup/vars/main.yml \
                                  #  ./roles/restore/vars/main.yml \ ;

sed -i -e "s/ansible-mcp-connect/ansible-mcp-server/g" ./roles/mcpserver/defaults/main.yml\
                                   ./roles/mcpserver/tasks/main.yml ;

# -- Set Fully Qualified Domain Names for k8s modules

find ./roles ./playbooks -type f -name '*.y*ml' \
  -exec sed -i -e "s/ k8s\(.*\):/ kubernetes.core.k8s\1:/g" {} \;

# Use operator_sdk.utils.k8s_status
find ./roles ./playbooks -type f -name '*.y*ml' \
  -exec sed -i -e " s/ kubernetes.core.k8s_status:/ operator_sdk.util.k8s_status:/g" {} \;

# -- Inject Downstream Settings Variables for Controller

# placeholder

# -- Inject RELATED_IMAGES_ references

if ! grep -qF 'name: RELATED_IMAGE_ANSIBLE_AI_CONNECT' config/manager/manager.yaml; then
  sed -i -e "/fieldPath: metadata.namespace/a \\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT\n\
            value: quay.io/ansible/wisdom-service:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_CHATBOT\n\
            value: quay.io/ansible/ansible-chatbot-stack:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_CHATBOT_MCP_GATEWAY\n\
            value: quay.io/ansible/ansible-mcp-gateway:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_CHATBOT_MCP_CONTROLLER\n\
            value: quay.io/ansible/ansible-mcp-controller:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_CHATBOT_MCP_LIGHTSPEED\n\
            value: quay.io/ansible/ansible-mcp-lightspeed:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_CHATBOT_RAG_DB\n\
            value: quay.io/ansible/aap-rag-content:latest\n\
          - name: RELATED_IMAGE_ANSIBLE_AI_CONNECT_POSTGRES\n\
            value: quay.io/sclorg/postgresql-15-c9s:latest" config/manager/manager.yaml
fi

if ! grep -qF 'name: RELATED_IMAGE_ANSIBLE_MCP_SERVER' config/manager/manager.yaml; then
  sed -i -e "/fieldPath: metadata.namespace/a \\
          - name: RELATED_IMAGE_ANSIBLE_MCP_SERVER\n\
            value: quay.io/ttakamiy/aap-mcp-server:latest" config/manager/manager.yaml
fi

# -- Inject Downstream Settings Variables
if ! grep -qF '# Downstream variables' roles/model/templates/model.configmap.yaml.j2; then
  sed -i -e "/ENABLE_HEALTHCHECK_SECRET_MANAGER: /a \\
  # Downstream variables\n\
  ANSIBLE_AI_PROJECT_NAME: \"Red Hat Ansible Lightspeed with IBM watsonx Code Assistant\"" roles/model/templates/model.configmap.yaml.j2
fi

# -- Inject Downstream MCP commands
if ! grep -qF 'controller_server.py' roles/chatbot/templates/chatbot.deployment.yaml.j2; then
  sed -i -e "/name: ansible-mcp-controller/a \\
        command:\n\
          - python3.12\n\
          - controller_server.py" roles/chatbot/templates/chatbot.deployment.yaml.j2
fi
if ! grep -qF 'gateway_server.py' roles/chatbot/templates/chatbot.deployment.yaml.j2; then
  sed -i -e "/name: ansible-mcp-gateway/a \\
        command:\n\
          - python3.12\n\
          - gateway_server.py" roles/chatbot/templates/chatbot.deployment.yaml.j2
fi
if ! grep -qF 'lightspeed_server.py' roles/chatbot/templates/chatbot.deployment.yaml.j2; then
  sed -i -e "/name: ansible-mcp-lightspeed/a \\
        command:\n\
          - python3.12\n\
          - lightspeed_server.py" roles/chatbot/templates/chatbot.deployment.yaml.j2
fi

# Set default operator pod container
sed -i -e "s|default-container: ansibleaiconnect-manager|default-container: ansible-lightspeed-manager|g" config/manager/manager.yaml
sed -i -e "s|name: ansibleaiconnect-manager|name: ansible-lightspeed-manager|g" config/manager/manager.yaml

# Set dummy pull secret contents
sed -i -e "s|operator: ansibleaiconnect|operator: ansible-lightspeed|g" playbooks/ansibleaiconnect.yml
sed -i -e "s|operator: ansibleaiconnect|operator: ansible-lightspeed|g" playbooks/ansiblemcpconnect.yml


# -- Set default ingress_type to Route

files=(
    roles/model/defaults/main.yml
    roles/mcpserver/defaults/main.yml
)
for file in "${files[@]}"; do
    sed -i -e "s/ingress_type:\ none/ingress_type:\ Route/g" ${file};
done

files=(
    config/crd/bases/aiconnect.ansible.com_ansibleaiconnects.yaml
    config/crd/bases/mcpconnect.ansible.com_ansiblemcpconnects.yaml
)
for file in "${files[@]}"; do
  if ! grep -qF 'default: Route' ${file}; then
    sed -i -e "/ingress_type:/a \\
                default:\ Route" ${file};
  fi
done
