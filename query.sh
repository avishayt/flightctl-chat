#!/usr/bin/env bash

set -e

if [[ ! -f ".env" ]]; then
    echo "No .env file found. Please create one with the required variables."
    exit 1
fi

source .env

curl -X POST "http://localhost:8090/alpha/inference/chat_completion" \
    -H "Content-Type: application/json" \
    -d '{
    "model_id": "'"${MODEL_ID}"'",
    "messages": [
        {
            "role": "user",
            "content": "What is Flight Control? Can you list my devices?",
            "query": "What is Flight Control? Can you list my devices?",
            "additional_context": "The user is asking about Flight Control and wants to see their managed devices."
        }
    ],
    "sampling_params": {
        "strategy": "greedy",
        "temperature": 0,
        "top_p": 0.9
    },
    "response_format": {
        "type": "text"
    },
    "stream": false,
    "logprobs": null
}' | jq
