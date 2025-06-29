#!/usr/bin/env bash

set -e

podman pod logs flightctl-chat-pod --follow --names --since 0
