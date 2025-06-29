#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

! -d "${SCRIPT_DIR}/flightctl-mcp" ||
{
    echo "Warning: flightctl-mcp directory exists but it should be a git submodule"
    echo "Perhaps you forgot to run 'git submodule init && git submodule update'?"
    echo "Or you created a regular directory instead of initializing the submodule?"
    echo "If you want to use the existing directory, remove this check in the script"
    echo "If you want to use the submodule, run:"
    echo "  rm -rf '${SCRIPT_DIR}/flightctl-mcp'"
    echo "  git submodule init"
    echo "  git submodule update"
    exit 1
}

function build_flightctl_mcp() {
    pushd "${SCRIPT_DIR}/flightctl-mcp"
    podman build -t localhost/local-fc-chat-flightctl-mcp:latest .
    popd
}

function build_lightspeed_plus_llama() {
    # Build the lightspeed stack image first
    echo "Building lightspeed-stack..."
    pushd "${SCRIPT_DIR}/lightspeed-stack"
    podman build -f Containerfile -t localhost/local-fc-chat-lightspeed-stack:latest .
    popd

    # Use the containerfile to add llama to lightspeed
    echo "Building combined lightspeed + llama stack..."
    podman build -f "${SCRIPT_DIR}/Containerfile.add_llama_to_lightspeed" -t localhost/local-fc-chat-lightspeed-stack-plus-llama-stack "${SCRIPT_DIR}"
}

function build_inspector() {
    pushd "${SCRIPT_DIR}/inspector"
    podman build -t localhost/local-fc-chat-inspector:latest .
    popd
}

function build_ui() {
    echo "Building Flight Control UI..."
    pushd "${SCRIPT_DIR}/flightctl-ui"
    podman build -f Containerfile -t localhost/local-fc-chat-ui:latest .
    popd
}

build_flightctl_mcp
build_lightspeed_plus_llama
build_inspector
build_ui
