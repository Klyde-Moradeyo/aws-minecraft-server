# config/__init__.py
import os

# --- Git ---
GIT_REPO_NAME = "aws-minecraft-server"
GIT_REPO_URL = "git@github.com:Klyde-Moradeyo/aws-minecraft-server.git"
EC2_SCRIPTS_PATH = os.path.join(GIT_REPO_NAME, "server", "scripts")

# --- Server Script Paths ---
LOCAL_INSTALL_SCRIPT_PATH = os.path.join(EC2_SCRIPTS_PATH, "install.sh")
REMOTE_INSTALL_SCRIPT_PATH = "install/install.sh"
REMOTE_INSTALL_LOGS_PATH = "install/install.log"

LOCAL_HELPER_SCRIPT_PATH = os.path.join(EC2_SCRIPTS_PATH, "helper.sh")
REMOTE_HELPER_SCRIPT_PATH = "install/helper.sh"

# --- EC2 USERNAME ---
EC2_USERNAME = "ubuntu"