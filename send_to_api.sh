#!/bin/bash
set -e

# Prompt the user for the command value
echo "Please enter the command value:"
read user_input

# Define the AWS API Gateway endpoint URL
API_ENDPOINT="$(cd terraform && terraform output api_gateway_url  | tr -d '"')/command"
echo "API_ENDPOINT: $API_ENDPOINT"

# Define the API Key if necessary (you can remove this if you're not using API Keys)
API_KEY="YOUR_API_KEY"

# The data payload with the user's input
DATA_PAYLOAD="{
  \"action\": \"$user_input\"
}"

# Send a POST request to the API Gateway
curl -X POST \
     -H "Content-Type: application/json" \
     -d "$DATA_PAYLOAD" \
     $API_ENDPOINT

# Note: If you're not using API keys for authentication, you can uncomment the "-H "x-api-key: $API_KEY"\" line.
