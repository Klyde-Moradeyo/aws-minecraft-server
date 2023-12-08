import os
from utils.logger import setup_logging

# --- 
logger = setup_logging()

# --- S3 Buckets Paths ---
OUTPUT_ARCHIVE_FILE_NAME = "minecraft-world-archive.bundle"

# --- S3 Buckets ---
S3_MC_WORLD_BUCKET = os.getenv("S3_MC_WORLD_URI").replace("s3://", "")
S3_MC_ASSETS_BUCKET = os.getenv("S3_MC_ASSETS_URI").replace("s3://", "")

# --- S3 Buckets Paths ---
BASE_S3_LATEST_MINECRAFT_WORLD_PATH = "minecraft-world/{template_id}"
BASE_S3_ARCHIVE_MINECRAFT_WORLD_PATH = f"{{template_id}}/world_bck_up/{OUTPUT_ARCHIVE_FILE_NAME}"

# --- Build Area ---
WORKING_DIR = "tmp"
LOCAL_LATEST_WORLD_DIR = os.path.join(WORKING_DIR, "latest")
LOCAL_ARCHIVE_WORLD_DIR = os.path.join(WORKING_DIR, "archive")
BUILD_OUTPUT_DIR = os.path.join(WORKING_DIR, "output")

DOWNLOADED_S3_WORLD_ARCHIVE_BUNDLE_PATH = os.path.join(WORKING_DIR, OUTPUT_ARCHIVE_FILE_NAME)

# export S3_MC_WORLD_BUCKET="s3://fargate-test-minecraft-world-data-qodsejtk"
# export S3_MC_ASSETS_BUCKET="s3://fargate-test-minecraft-mc-server-assets-tvguzokf"
# git config --global --add safe.directory /app/tmp/latest
# git config --global --add safe.directory /app/tmp/archive