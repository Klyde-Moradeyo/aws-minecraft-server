#!/bin/bash

set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $script_dir/helper.sh

# Trap the ERR signal
trap 'if [[ $? -ne 0 ]]; then error_handler; fi' EXIT

#########################
# Setup node_exporter   #
#########################
function setup_node_exporter_service {
  echo "Setting up node_exporter as a system service"

  echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=$NODE_EXPORTER_PATH

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

  sudo systemctl daemon-reload
  sudo systemctl enable node_exporter
  sudo systemctl start node_exporter
  echo "Node Exporter service setup complete"
}

##############################
# Setup process_exporter     #
##############################
function setup_process_exporter_service {
  echo "Setting up process_exporter as a system service"

  # Copy config file
  REPO_CONFIG_FILE_PATH="$script_dir/../observability/process-exporter-config.yml"
  CONFIG_FILE_PATH="/etc/process-exporter-config.yml"
  sudo cp "$REPO_CONFIG_FILE_PATH"  "$CONFIG_FILE_PATH"

  echo "[Unit]
Description=Process Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=$PROCESS_EXPORTER_PATH -config.path $CONFIG_FILE_PATH

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/process_exporter.service

  sudo systemctl daemon-reload
  sudo systemctl enable process_exporter
  sudo systemctl start process_exporter
  echo "Process Exporter service setup complete"
}

function run {
  # Run SETUP in parallel
  run_parallel \
      "setup_node_exporter_service" \
      "setup_process_exporter_service"

  echo "Node Exporter and Process Exporter services have been set up and started"
}

# Call the run function
start=$(date +%s.%N)
run
finish=$(date +%s.%N)

get_current_date
calculate_runtime $start $finish


