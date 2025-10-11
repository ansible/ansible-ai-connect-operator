FROM quay.io/operator-framework/ansible-operator:v1.36.1

USER root
RUN dnf update --security --bugfix -y
USER 1001

ARG DEFAULT_AI_CONNECT_VERSION
ARG DEFAULT_CHATBOT_AI_CONNECT_VERSION
ARG DEFAULT_MCP_SERVER_VERSION
ARG OPERATOR_VERSION

ENV DEFAULT_AI_CONNECT_VERSION=${DEFAULT_AI_CONNECT_VERSION}
ENV DEFAULT_CHATBOT_AI_CONNECT_VERSION=${DEFAULT_CHATBOT_AI_CONNECT_VERSION}
ENV DEFAULT_MCP_SERVER_VERSION=${DEFAULT_MCP_SERVER_VERSION}
ENV OPERATOR_VERSION=${OPERATOR_VERSION}

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
