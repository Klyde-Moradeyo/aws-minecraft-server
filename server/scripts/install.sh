#!/bin/bash

# Title: EC2 Install
# Use: Installs Docker, Docker Compose, AWS CLI, and Git
# Ref:
#   https://docs.docker.com/engine/install/ubuntu/
#   https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
#   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $script_dir/helper.sh

# Trap the ERR signal
trap 'if [[ $? -ne 0 ]]; then error_handler; fi' EXIT

## Set Architecture
ARCH=$(uname -m)
echo "System Architecture: ${ARCH}"
declare -A ARCH_MAP
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    # For ARM architecture
    ARCH_MAP["docker"]="arm64"
    ARCH_MAP["docker_compose"]="aarch64"
    ARCH_MAP["aws"]="aarch64"
    ARCH_MAP["node_exporter"]="arm64"
    ARCH_MAP["process_exporter"]="arm64"
elif [[ "$ARCH" == "x86_64" ]]; then
    # For x86_64 architecture
    ARCH_MAP["docker"]="x86_64"
    ARCH_MAP["docker_compose"]="x86_64"
    ARCH_MAP["aws"]="x86_64"
    ARCH_MAP["node_exporter"]="x86_64"
    ARCH_MAP["process_exporter"]="x86_64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Run the apt-get command 
# DPkg::Lock checks if apt lock is in use - Timeout set to -1 for unlimited. 60 for 60 sec
apt_get() {
  sudo apt-get -o DPkg::Lock::Timeout=-1 "$@"
}

########################
# Dependencies Install #
########################
function install_dependencies {
  echo "Installing dependencies..."

  # Check if sudo is installed, install it if it's not
  if ! command -v sudo &> /dev/null; then
    echo "sudo not found. Installing sudo..."
    add-apt-repository -y universe
    apt-get install -y sudo
  else
    echo "sudo is already installed."
  fi
  
  apt_get update -y
  apt_get install -y \
    apt-utils \
    lsof \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    zip \
    bc \
    rsync \
    wget
}

########################
#    Docker Install    #
########################
function install_docker {
  echo "Starting Docker install"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add Docker package repository
  echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  apt_get update
  apt_get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io
  echo "Docker install complete"
  install_docker_compose
}

# Docker Compose installation
function install_docker_compose {
  local ARCH="${ARCH_MAP[github_docker_compose]}"
  echo "Starting ${ARCH} Docker Compose install"
  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  mkdir -p "$DOCKER_CONFIG/cli-plugins"
  curl -SL "https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-${ARCH}" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
  chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"
  echo "Docker Compose install complete"
}


########################
#    AWS CLI Install   #
########################
function install_aws_cli {
  local ARCH="${ARCH_MAP[aws]}"
  echo "Starting ${ARCH} AWS CLI install"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
  echo "Unzipping AWS CLI package..."
  unzip -o -q awscliv2.zip
  echo "Installing AWS CLI..."
  ./aws/install
  rm -rf aws awscliv2.zip
  echo "AWS CLI install complete"
}

########################
#     Install Git      #
########################
function install_git {
  echo "Starting Git Install"
  apt_get install git -y
  echo "Git install complete"
}

############################
# Install Cloudwatch Agent #
############################
function install_cloudwatch_agent {
  local ARCH="${ARCH_MAP[cloudwatch_agent]}"
  local config_file_path="./amazon-cloudwatch-agent.json"
  wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
  sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m onPremise -s -c file:$config_file_path
  rm -rf amazon-cloudwatch-agent.deb
}

#########################
# Install node_exporter #
#########################
function install_node_exporter {
  local NODE_EXPORTER_VERSION="1.6.1"
  local ARCH="${ARCH_MAP[node_exporter]}"
  echo "Installing ${ARCH} node_exporter version $NODE_EXPORTER_VERSION"
  wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH}.tar.gz"
  tar xvfz "node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64.tar.gz"
  sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64/node_exporter" $NODE_EXPORTER_PATH
  rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64" "node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64.tar.gz"
  echo "Prometheus Node Exporter installed successfully!"
}

##############################
#  Install process_exporter  #
##############################
function install_process_exporter {
  local PROCESS_EXPORTER_VERSION="0.7.10"
  local ARCH="${ARCH_MAP[process_exporter]}"
  echo "Installing ${ARCH} process_exporter version $PROCESS_EXPORTER_VERSION"
  wget "https://github.com/ncabatoff/process-exporter/releases/download/v${PROCESS_EXPORTER_VERSION}/process-exporter-${PROCESS_EXPORTER_VERSION}.linux-${ARCH}.tar.gz"
  tar xvfz "process-exporter-${PROCESS_EXPORTER_VERSION}.linux-arm64.tar.gz"
  sudo mv "process-exporter-${PROCESS_EXPORTER_VERSION}.linux-arm64/process-exporter" $PROCESS_EXPORTER_PATH
  rm -rf "process-exporter-${PROCESS_EXPORTER_VERSION}.linux-arm64" "process-exporter-${PROCESS_EXPORTER_VERSION}.linux-arm64.tar.gz"
  echo "Prometheus Process Exporter installed successfully!"
}

########################
#     Post Install     #
########################
function post_install {
    echo "-------------------------------------"
    echo "              Installed              "
    echo "-------------------------------------"

    if command -v docker > /dev/null 2>&1; then
        echo "Docker:
              $(docker --version)
              $(docker compose version)"
    else
        echo "Docker: Not Installed"
    fi

    if command -v aws > /dev/null 2>&1; then
        echo "AWS CLI: $(aws --version)"
    else
        echo "AWS CLI: Not Installed"
    fi

    if command -v git > /dev/null 2>&1; then
        echo "GIT: $(git --version)"
    else
        echo "GIT: Not Installed"
    fi

    # Check if the CloudWatch agent is installed
    if command -v /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent > /dev/null 2>&1; then
        isCloudwatchAgentInstalled="Installed"
        agentOutput=$(sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status)
        if [[ $agentOutput == *"running"* ]]; then
            isCloudwatchAgentRunning="Running"
        else
            isCloudwatchAgentRunning="Not Running"
        fi
    else
        isCloudwatchAgentInstalled="Not Installed"
        isCloudwatchAgentRunning="Not Running"
    fi
    echo "Cloudwatch Agent: $isCloudwatchAgentInstalled | $isCloudwatchAgentRunning"

    # Check if node_exporter is installed
    if [ -f $NODE_EXPORTER_PATH ]; then
        echo "Node Exporter: Installed at $NODE_EXPORTER_PATH"
    else
        echo "Node Exporter: Not Installed"
    fi

    # Check if process_exporter is installed
    if [ -f $PROCESS_EXPORTER_PATH ]; then
        echo "Process Exporter: Installed at $PROCESS_EXPORTER_PATH"
    else
        echo "Process Exporter: Not Installed"
    fi
    echo "-------------------------------------"
}

function run {
  install_dependencies

  # Run installations in parallel
  run_parallel \
      "install_docker" \
      "install_aws_cli" \
      "install_git" \
      "install_node_exporter" \
      "install_process_exporter"
      # "install_cloudwatch_agent"

  post_install
}

# Call the run function
start=$(date +%s.%N)
run
finish=$(date +%s.%N)

get_current_date
calculate_runtime $start $finish
