# config/__init__.py
import os

# --- Git ---
GIT_REPO_NAME = "aws-minecraft-server"
GIT_REPO_URL = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git"

# --- Server Path ---
LOCAL_SERVER_FOLDER_PATH = os.path.join(GIT_REPO_NAME, "server")
REMOTE_SERVER_FOLDER_PATH = "server"

REMOTE_HELPER_SCRIPT_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/scripts/helper.sh"

REMOTE_INSTALL_SCRIPT_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/scripts/install.sh"
REMOTE_INSTALL_LOGS_PATH = f"{REMOTE_SERVER_FOLDER_PATH}/scripts/install.log"

# --- EC2 USERNAME ---
EC2_USERNAME = "ubuntu"