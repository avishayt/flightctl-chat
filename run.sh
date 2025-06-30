#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Export all environment variables from .env file
export $(cat "$SCRIPT_DIR"/.env | xargs)

# --add-host='host.docker.internal:host-gateway' is the equivalent of docker's --add-host
# And is used to allow containers to hit the host (used by the UI container to talk to Flight Control)

podman pod kill flightctl-chat-pod >/dev/null || true
podman pod rm flightctl-chat-pod >/dev/null || true

# Use envsubst to replace the variables in the pod file
# Add --userns=keep-id to handle SELinux permissions properly
podman play kube --userns=keep-id <(envsubst < "$SCRIPT_DIR"/flightctl-chat-pod.yaml)

# Wait for lightspeed to be ready
until curl -s http://localhost:8090/health > /dev/null; do sleep 1; done

# All good
echo "All services are ready"
