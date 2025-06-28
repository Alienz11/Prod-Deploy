#!/bin/bash

set -euo pipefail # Exit on error, unset variables, pipeline errors

# --- Configuration ---
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=91542516212 #This is a random number not a real account ID
ECR="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_NAME="item-service"
APP_VERSION="1.0.0" # Or dynamically generate this (e.g. from git commit hash, or datetime, or buid id/number)
NAMESPACE="item-service-ns"
K8S_MANIFESTS_DIR="../k8s" # Relative path to your k8s manifests

# --- Functions ---
build_and_push_image() {
    echo "Building Docker image: ${ECR}/${IMAGE_NAME}:${APP_VERSION}"

    # Login to ECR (This only work if an IAM user is registered on the AWS CLI where this script runs)
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    docker build -t "${ECR}/${IMAGE_NAME}:${APP_VERSION}" -f ../Dockerfile ..

    echo "Pushing Docker image: ${ECR}/${IMAGE_NAME}:${APP_VERSION}"
    docker push "${ECR}/${IMAGE_NAME}:${APP_VERSION}"
    echo "Docker image pushed successfully."
}

apply_k8s_manifests() {
    echo "Applying Kubernetes manifests to namespace: ${NAMESPACE}"

    # Ensure the namespace exists first (from pod-security.yaml)
    kubectl apply -f ../security/pod-security.yaml
    kubectl apply -f ../security/rbac.yaml

    # Apply core application manifests in order
    kubectl apply -f "${K8S_MANIFESTS_DIR}/serviceaccount.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/configmap.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/secret.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/deployment.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/service.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/ingress.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/hpa.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${K8S_MANIFESTS_DIR}/networkpolicy.yaml" -n "${NAMESPACE}"

    echo "Kubernetes manifests applied successfully."
}

wait_for_deployment() {
    echo "Waiting for deployment ${IMAGE_NAME} to be ready..."
    kubectl rollout status deployment/${IMAGE_NAME} -n "${NAMESPACE}" --timeout=5m
    if [ $? -ne 0 ]; then
        echo "Deployment failed to become ready in time."
        exit 1
    fi
    echo "Deployment is ready."
}

# --- Main Script Execution ---
echo "Starting deployment process for ${IMAGE_NAME}:${APP_VERSION}..."

build_and_push_image
apply_k8s_manifests
wait_for_deployment

echo "Deployment completed successfully!"
