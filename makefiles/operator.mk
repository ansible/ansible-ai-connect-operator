# operator.mk — Ansible AI Connect Operator specific targets and variables
#
# This file is NOT synced across repos. Each operator maintains its own.

#@ Operator Variables

VERSION ?= $(shell git describe --tags 2>/dev/null || echo 0.1.0)
IMAGE_TAG_BASE ?= quay.io/ansible/ansible-ai-connect-operator
NAMESPACE ?= ansible-ai-connect
DEPLOYMENT_NAME ?= ansible-ai-connect-operator-controller-manager

# Feature flags
BUILD_IMAGE ?= true
CREATE_CR ?= false

# Teardown configuration
TEARDOWN_CR_KINDS ?= ansibleaiconnect ansiblemcpconnect
TEARDOWN_BACKUP_KINDS ?=
TEARDOWN_RESTORE_KINDS ?=
OLM_SUBSCRIPTIONS ?=

##@ Ansible AI Connect Operator

.PHONY: operator-up
operator-up: _operator-build-and-push _operator-deploy _operator-wait-ready _operator-post-deploy ## AI Connect-specific deploy
	@:

##@ Release

.PHONY: generate-operator-yaml
generate-operator-yaml: kustomize ## Generate operator.yaml with image tag $(VERSION)
	@cd config/manager && $(KUSTOMIZE) edit set image controller=quay.io/ansible/ansible-ai-connect-operator:${VERSION}
	@$(KUSTOMIZE) build config/default > ./operator.yaml
	@echo "Generated operator.yaml with image tag $(VERSION)"
