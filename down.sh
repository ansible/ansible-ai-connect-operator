#!/bin/bash
# Ansible AI Connect Operator down.sh

# -- Usage
#   NAMESPACE=ansible-ai ./down.sh

# -- Variables
NAMESPACE=${NAMESPACE:-ansible-ai}
TAG=${TAG:-dev}
QUAY_USER=${QUAY_USER:-developer}
IMG=quay.io/$QUAY_USER/ansible-ai-connect-operator:$TAG
DEV_CR=${DEV_CR:-config/samples/aiconnect_v1alpha1_ansibleaiconnect.yaml}

# -- Check for required variables
if [ -z "$NAMESPACE" ]; then
  echo "Error: NAMESPACE env variable is not set. Run the following with your namespace:"
  echo "  export NAMESPACE=developer"
  exit 1
fi

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "$NAMESPACE namespace doesn't exist... nothing to cleanup..."
    exit 0
fi

echo "$NAMESPACE namespace found... deleting resources..."

# -- Delete CRs
echo "Deleting AnsibleAIConnect CRs..."
kubectl delete ansibleaiconnect -n $NAMESPACE --all 2>/dev/null || true
kubectl delete ansiblemcpconnect -n $NAMESPACE --all 2>/dev/null || true

# Wait for CRs to be fully deleted
echo "Waiting for CRs to be deleted..."
sleep 5

# -- Delete operator deployment
echo "Deleting operator deployment..."
kubectl delete deployment ansible-ai-connect-operator-controller-manager -n $NAMESPACE 2>/dev/null || true

# -- Undeploy operator
echo "Undeploying operator..."
make undeploy NAMESPACE=$NAMESPACE 2>/dev/null || true

# -- Uninstall CRDs (optional, uncomment if you want to remove CRDs)
# echo "Uninstalling CRDs..."
# make uninstall

# -- Remove PVCs
echo "Removing PVCs..."
kubectl delete pvc -n $NAMESPACE --all 2>/dev/null || true

# -- Delete secrets
echo "Deleting secrets..."
kubectl delete secrets -n $NAMESPACE --all 2>/dev/null || true

# -- Delete namespace
echo "Deleting namespace $NAMESPACE..."
kubectl delete namespace $NAMESPACE

echo ""
echo "=========================================="
echo "Cleanup complete for namespace: $NAMESPACE"
echo "=========================================="
