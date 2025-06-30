#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# If .env doesn't exist, we want to prompt the user to fill it
# and exit if they don't want to
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo "Missing the .env file that should contain your configuration."
    echo "Would you like help creating the .env file interactively? (y/n)"
    read -r answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo "Flight Control MCP Server authentication setup:"
        echo "Please enter your Flight Control API base URL (e.g., https://api.flightctl.example.com):"
        read -r API_BASE_URL
        echo "API_BASE_URL=$API_BASE_URL" >"$SCRIPT_DIR/.env"

        echo "Please enter your OIDC token URL (e.g., https://auth.flightctl.example.com/realms/flightctl/protocol/openid-connect/token):"
        echo "Note: If you only have the base realm URL, the server will automatically append '/protocol/openid-connect/token'"
        read -r OIDC_TOKEN_URL
        echo "OIDC_TOKEN_URL=$OIDC_TOKEN_URL" >>"$SCRIPT_DIR/.env"

        echo "Please enter your OIDC client ID (defaults to 'flightctl' if left empty):"
        read -r OIDC_CLIENT_ID
        OIDC_CLIENT_ID=${OIDC_CLIENT_ID:-flightctl}
        echo "OIDC_CLIENT_ID=$OIDC_CLIENT_ID" >>"$SCRIPT_DIR/.env"

        echo "Please enter your Flight Control OAuth2 refresh token:"
        echo "This token should have appropriate permissions to read Flight Control resources"
        read -r REFRESH_TOKEN
        echo "REFRESH_TOKEN=$REFRESH_TOKEN" >>"$SCRIPT_DIR/.env"

        echo "Skip SSL certificate verification? (true/false, defaults to false for production):"
        read -r INSECURE_SKIP_VERIFY
        INSECURE_SKIP_VERIFY=${INSECURE_SKIP_VERIFY:-false}
        echo "INSECURE_SKIP_VERIFY=$INSECURE_SKIP_VERIFY" >>"$SCRIPT_DIR/.env"

        echo "Set MCP log level (DEBUG/INFO/WARNING/ERROR, defaults to INFO):"
        read -r LOG_LEVEL
        LOG_LEVEL=${LOG_LEVEL:-INFO}
        echo "LOG_LEVEL=$LOG_LEVEL" >>"$SCRIPT_DIR/.env"

        echo "Set MCP transport mechanism (defaults to stdio):"
        read -r MCP_TRANSPORT
        MCP_TRANSPORT=${MCP_TRANSPORT:-stdio}
        echo "MCP_TRANSPORT=$MCP_TRANSPORT" >>"$SCRIPT_DIR/.env"

        echo 'Visit https://console.cloud.google.com/apis/credentials and get your Gemini API key'
        read -r GEMINI_API_KEY
        echo "GEMINI_API_KEY=$GEMINI_API_KEY" >>"$SCRIPT_DIR/.env"

        echo "Please enter your model ID (e.g., gemini-1.5-pro):"
        read -r MODEL_ID
        echo "MODEL_ID=$MODEL_ID" >>"$SCRIPT_DIR/.env"
    else
        echo "Exiting. You can create .env file manually with the required variables."
        exit 1
    fi
fi

# Load environment variables from .env file
source "$SCRIPT_DIR/.env"

# Check if required environment variables are set
if [[ -z "${API_BASE_URL:-}" ]]; then
    echo "API_BASE_URL is not set in .env file."
    exit 1
fi

if [[ -z "${OIDC_TOKEN_URL:-}" ]]; then
    echo "OIDC_TOKEN_URL is not set in .env file."
    exit 1
fi

if [[ -z "${REFRESH_TOKEN:-}" ]]; then
    echo "REFRESH_TOKEN is not set in .env file."
    exit 1
fi

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "GEMINI_API_KEY is not set in .env file."
    exit 1
fi

if [[ -z "${MODEL_ID:-}" ]]; then
    echo "MODEL_ID is not set in .env file."
    exit 1
fi

mkdir -p "$SCRIPT_DIR/config"
# Generate configuration files using envsubst
envsubst < "lightspeed-stack.template.yaml" > "$SCRIPT_DIR/config/lightspeed-stack.yaml"
envsubst < "config/llama_stack_client_config.yaml" > "$SCRIPT_DIR/config/llama_stack_client_config_generated.yaml"

