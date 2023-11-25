# config/__init__.py
import os

# --- Git ---
GIT_REPO_NAME = "aws-minecraft-server"
GIT_REPO_URL = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git"

# --- Server Path ---
LOCAL_SERVER_FOLDER_PATH = os.path.join(GIT_REPO_NAME, "server")
REMOTE_SERVER_FOLDER_PATH = "server"

# --- Server Config Paths ---
LOCAL_TEMPLATES_PATH = os.path.join(LOCAL_SERVER_FOLDER_PATH, "config")
LOCAL_BASE_CONFIG_PATH = os.path.join(LOCAL_TEMPLATES_PATH, "base.json")
LOCAL_TEMPLATE_CONFIG_PATH = os.path.join(LOCAL_TEMPLATES_PATH, "template.json")

REMOTE_CONFIG_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/config"
REMOTE_MC_SERVER_ENV_FILE_PATH = f"{REMOTE_CONFIG_PATH}/.server-env"
REMOTE_MC_MONITOR_ENV_FILE_PATH = f"{REMOTE_CONFIG_PATH}/.monitoring-env"
REMOTE_TEMPLATE_INFO_FILE_PATH = f"{REMOTE_CONFIG_PATH}/.template-id"

REMOTE_DOCKER_COMPOSE_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/docker-compose.yml"

# --- Server Scripts Paths ---
REMOTE_SCRIPT_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/scripts"
REMOTE_SCRIPT_LOGS_PATH = f"{REMOTE_SCRIPT_PATH}/logs"

REMOTE_INSTALL_SCRIPT_PATH = f"{REMOTE_SCRIPT_PATH}/install.sh"
REMOTE_HELPER_SCRIPT_PATH = f"{REMOTE_SCRIPT_PATH}/helper.sh"

REMOTE_INSTALL_LOGS_PATH = f"{REMOTE_SCRIPT_LOGS_PATH}/install.log"

# --- Minecraft World Paths ---
REMOTE_MINECRAFT_SERVER_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/minecraft-data"
REMOTE_MINECRAFT_WORLD_PATH = f"{REMOTE_MINECRAFT_SERVER_PATH}/world"
CONTAINER_MINECRAFT_WORLD_PATH = f"./data/world"

# --- Minecraft Server Memory Buffer ---
MEMORY_BUFFER = 0.80 # Allocate 80% of the operating systems memory just for minecraft
MIN_OS_MEMORY = 1 # Amount of Memory to Reserve for the EC2's operating system

# --- Minecraft Server RCON PORT  ---
RCON_PORT = "25575"

# --- EC2 USERNAME ---
EC2_USERNAME = "ubuntu"