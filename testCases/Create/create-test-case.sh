#!/bin/bash

# Script to create Amazon Connect test case using AWS CLI
# Parameters are passed as environment variables from Terraform

# Enable strict error handling
set -e
set -u
set -o pipefail

# Validate required environment variables
REQUIRED_VARS=("INSTANCE_ID" "TEST_CASE_NAME" "TEST_CASE_DESCRIPTION" "CONTENT_FILE_PATH" "AWS_REGION" "FLOW_ID")

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Required environment variable $var is not set" >&2
    exit 1
  fi
done

# Validate instance ID format (UUID)
if ! [[ "$INSTANCE_ID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
  echo "Error: INSTANCE_ID must be a valid UUID format" >&2
  exit 1
fi

# Validate flow ID format (UUID)
if ! [[ "$FLOW_ID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
  echo "Error: FLOW_ID must be a valid UUID format" >&2
  exit 1
fi

# Validate content file path format
if ! [[ "$CONTENT_FILE_PATH" =~ ^file:// ]]; then
  echo "Error: CONTENT_FILE_PATH must start with 'file://'" >&2
  exit 1
fi

# Extract actual file path and validate file exists
FILE_PATH="${CONTENT_FILE_PATH#file://}"
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: Content file does not exist: $FILE_PATH" >&2
  exit 1
fi

# Validate JSON format of content file
if ! jq empty "$FILE_PATH" 2>/dev/null; then
  echo "Error: Content file is not valid JSON: $FILE_PATH" >&2
  exit 1
fi

echo "Creating Amazon Connect test case..."
echo "Instance ID: $INSTANCE_ID"
echo "Test Case Name: $TEST_CASE_NAME"
echo "Region: $AWS_REGION"
echo "Flow ID: $FLOW_ID"

aws connect create-test-case \
  --instance-id "$INSTANCE_ID" \
  --name "$TEST_CASE_NAME" \
  --description "$TEST_CASE_DESCRIPTION" \
  --content "$CONTENT_FILE_PATH" \
  --region "$AWS_REGION" \
  --tags Key=ManagedBy,Value=Terraform \
  --entry-point "{\"Type\":\"VOICE_CALL\",\"VoiceCallEntryPointParameters\":{\"FlowId\":\"$FLOW_ID\"}}"

echo "Test case created successfully!"
