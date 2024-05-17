#!/bin/bash

# List of instance IDs (replace these with your actual instance IDs)
INSTANCE_IDS=("i-0123456789abcdef0" "i-0123456789abcdef1" "i-0123456789abcdef2" ...) # up to 100 instances

# SSM Document name (Command to be run on the instances)
SSM_DOCUMENT_NAME="AWS-RunShellScript"

# Command to run on the instances
SSM_COMMAND='echo $(grep VERSION /etc/os-release)'

# Send the SSM command to the list of instances
send_ssm_command() {
    INSTANCE_IDS_STR=$(IFS=,; echo "${INSTANCE_IDS[*]}")
    COMMAND_ID=$(aws ssm send-command \
        --document-name "$SSM_DOCUMENT_NAME" \
        --parameters 'commands=["'"$SSM_COMMAND"'"]' \
        --instance-ids $INSTANCE_IDS_STR \
        --query "Command.CommandId" \
        --output text)

    echo "SSM Command ID: $COMMAND_ID"
    echo "Waiting for command to complete..."
    sleep 10

    for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
        # Get the command invocation result for each instance
        COMMAND_INVOCATION=$(aws ssm get-command-invocation \
            --command-id "$COMMAND_ID" \
            --instance-id "$INSTANCE_ID" \
            --query '{InstanceId:InstanceId, Status:Status, StandardOutputContent:StandardOutputContent, StandardErrorContent:StandardErrorContent}' \
            --output json)
        
        # Extract fields
        INSTANCE_ID=$(echo "$COMMAND_INVOCATION" | jq -r '.InstanceId')
        STATUS=$(echo "$COMMAND_INVOCATION" | jq -r '.Status')
        OUTPUT=$(echo "$COMMAND_INVOCATION" | jq -r '.StandardOutputContent')
        ERROR=$(echo "$COMMAND_INVOCATION" | jq -r '.StandardErrorContent')

        echo "Instance ID: $INSTANCE_ID"
        echo "SSM Command Status: $STATUS"
        if [ "$STATUS" == "Success" ]; then
            echo "Command Output: $OUTPUT"
        else
            echo "Command Error: $ERROR"
        fi
        echo "-----------------------------------"
    done
}

# Main function
main() {
    send_ssm_command
}

# Execute main function
main
