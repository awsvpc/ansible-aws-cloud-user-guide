#!/bin/bash

# Function to check if required commands are installed
check_commands() {
  for cmd in aws jq; do
    if ! command -v $cmd &>/dev/null; then
      echo "$cmd could not be found, please install it to continue."
      exit 1
    fi
  done
}

# Function to send SSM command to instances
send_ssm_command() {
  local instance_ids=("$@")
  local instance_ids_string=$(IFS=, ; echo "${instance_ids[*]}")

  command_id=$(aws ssm send-command \
    --instance-ids $instance_ids_string \
    --document-name "AWS-RunShellScript" \
    --comment "Your command description" \
    --parameters commands=["echo Hello World"] \
    --query "Command.CommandId" \
    --output text)

  echo "Command sent. Command ID: $command_id"
}

# Function to wait for the command to complete
wait_for_command_completion() {
  local command_id=$1
  local status=""

  while true; do
    status=$(aws ssm list-command-invocations \
      --command-id $command_id \
      --query "CommandInvocations[*].Status" \
      --output text)

    if [[ $status == "Success" || $status == "Failed" || $status == "Cancelled" ]]; then
      break
    fi

    echo "Waiting for command to complete..."
    sleep 5
  done

  echo "Command $command_id completed with status: $status"
}

# Function to print command output for each instance
print_command_output() {
  local command_id=$1
  local instance_id

  for instance_id in "${instance_ids[@]}"; do
    output=$(aws ssm get-command-invocation \
      --command-id $command_id \
      --instance-id $instance_id \
      --query 'StandardOutputContent' \
      --output text)

    echo "Instance ID: $instance_id"
    echo "Output: $output"
  done
}

# Main script execution starts here

# Check if AWS CLI and jq are installed
check_commands

# Read the list of instance IDs from input
read -p "Enter the instance IDs separated by space: " -a instance_ids

# Send SSM command
send_ssm_command "${instance_ids[@]}"

# Wait for the command to complete
wait_for_command_completion $command_id

# Print the command status and output per instance ID
print_command_output $command_id
