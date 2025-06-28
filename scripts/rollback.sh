#!/bin/bash

DEPLOYMENT_NAME="item-service"
NAMESPACE="item-service-ns"

echo "Rolling back $DEPLOYMENT_NAME in $NAMESPACE..."

kubectl rollout undo deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}

echo "✅ Rollback completed."