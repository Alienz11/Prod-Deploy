#!/bin/bash

set -euo pipefail

# --- Configuration ---
INGRESS_HOST="api-item-server.user.com" #  Application's external URL

# --- Functions ---
check_app_health_endpoint() {
    echo "Checking application health endpoint via Ingress URL..."

    CURL_URL="https://${INGRESS_HOST}/health"

    for i in {1..5}; do 
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_URL}")

        if [[ "$RESPONSE" == "200" ]]; then
            echo "✅ Healthy"
            echo "Application health check (GET /health) via Ingress returned 200 OK."
            exit 0
        else
            echo "Application health check (GET /health) via Ingress FAILED. HTTP Status: ${RESPONSE}"
            echo "Waiting for app to be healthy... (attempt $i)"
            sleep 5
            echo "Attempting to curl: ${CURL_URL}"
        fi
    done
    echo "❌ Health check failed."
    exit 1
}

# --- Main Script Execution ---
echo "Performing health checks for FastAPI Item Service..."

check_app_health_endpoint

