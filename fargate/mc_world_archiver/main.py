import os
from datetime import datetime
from config import *
from utils.s3 import *
from utils.git import *

def run():
    # Generate Commit Message
    current_datetime = datetime.now()
    formatted_date = current_datetime.strftime("%d/%m/%Y")
    commit_msg = f"Auto-commit: Add Minecraft Data {formatted_date}"

    # Find which templates we will be backing up
    clean_path_mc_world_path = BASE_S3_LATEST_MINECRAFT_WORLD_PATH.replace("{template_id}", "")
    templates = list_folders_in_s3(S3_MC_WORLD_BUCKET, clean_path_mc_world_path)
    logger.info(f"Templates to archive: {templates}")

    # For Monitoring execution time
    start_time = datetime.now()
    results = []
    
    for index, template in enumerate(templates):
        try:
            logger.info(f"Building Archive for template: '{template}'")
            # Template start time
            template_start_time = datetime.now()

            S3_LATEST_MINECRAFT_WORLD_PATH = BASE_S3_LATEST_MINECRAFT_WORLD_PATH.format(template_id=template)
            S3_ARCHIVE_MINECRAFT_WORLD_PATH = BASE_S3_ARCHIVE_MINECRAFT_WORLD_PATH.format(template_id=template)

            # Ensure the working directory exists
            os.makedirs(LOCAL_LATEST_WORLD_DIR, exist_ok=True)
            os.makedirs(LOCAL_ARCHIVE_WORLD_DIR, exist_ok=True)
            os.makedirs(BUILD_OUTPUT_DIR, exist_ok=True)

            # If not a first time build
            if check_s3_file_exists(S3_MC_ASSETS_BUCKET, S3_ARCHIVE_MINECRAFT_WORLD_PATH):
                logger.info("Existing Archive File Found. Starting Incremental Build...")

                # Download Minecraft world and Archive World
                s3_download(S3_MC_ASSETS_BUCKET, S3_ARCHIVE_MINECRAFT_WORLD_PATH, DOWNLOADED_S3_WORLD_ARCHIVE_BUNDLE_PATH)
                s3_download_folder(S3_MC_WORLD_BUCKET, S3_LATEST_MINECRAFT_WORLD_PATH, LOCAL_LATEST_WORLD_DIR) 

                # Clone the Archive world and configure git
                git_clone(DOWNLOADED_S3_WORLD_ARCHIVE_BUNDLE_PATH, LOCAL_ARCHIVE_WORLD_DIR)
                configure_git(LOCAL_ARCHIVE_WORLD_DIR)

                # Remove the Archive world bundle
                run_command(f"rm -rfv '{DOWNLOADED_S3_WORLD_ARCHIVE_BUNDLE_PATH}'")
                logger.info("Removed S3 Archive Bundle")

                # Replace Archive world files with the Latest World files
                run_command(f"cp -rfv '{LOCAL_LATEST_WORLD_DIR}/.' '{LOCAL_ARCHIVE_WORLD_DIR}/'")
                logger.info("Added latest world files to Archive repo")

                git_commit(LOCAL_ARCHIVE_WORLD_DIR, commit_msg)
            else:
                logger.info("Running First Time Build...")

                # Download Minecraft world
                s3_download_folder(S3_MC_WORLD_BUCKET, S3_LATEST_MINECRAFT_WORLD_PATH, LOCAL_LATEST_WORLD_DIR) 

                # Create Archive Repo
                create_repo(LOCAL_ARCHIVE_WORLD_DIR)
                configure_git(LOCAL_ARCHIVE_WORLD_DIR)

                # Copy Latest World files to Archive world
                run_command(f"cp -rfv '{LOCAL_LATEST_WORLD_DIR}/.' '{LOCAL_ARCHIVE_WORLD_DIR}/'")
                logger.info("Added latest world files to Archive repo")

                git_commit(LOCAL_ARCHIVE_WORLD_DIR, commit_msg)
            
            # Create Git Bundle from the archive repo
            create_git_bundle(LOCAL_ARCHIVE_WORLD_DIR, OUTPUT_ARCHIVE_FILE_NAME)

            # Copy bundle to output directory
            run_command(f"cp -rfv '{LOCAL_ARCHIVE_WORLD_DIR}/{OUTPUT_ARCHIVE_FILE_NAME}' '{BUILD_OUTPUT_DIR}'")

            # Upload to s3
            s3_upload(S3_MC_ASSETS_BUCKET, f"{BUILD_OUTPUT_DIR}/{OUTPUT_ARCHIVE_FILE_NAME}", S3_ARCHIVE_MINECRAFT_WORLD_PATH)
            logger.info(f"Successfuly uploaded archive for template: '{template}'")

            # If not the last iteration, ready the working directory for the next one
            if index < len(templates) - 1:
                next_template = templates[index + 1]
                run_command(f"rm -rfv '{WORKING_DIR}'")
                logger.info(f"Deleted working directory '{WORKING_DIR}' to process the next template: '{next_template}'")

            logger.info(f"BUILD '{template}': SUCCESS")
            template_end_time = datetime.now()
            results.append((template, "SUCCESS", (template_end_time - template_start_time).total_seconds()))
        except Exception as e:
            logger.error(f"Error processing template '{template}': {e}")
            template_end_time = datetime.now()
            results.append((template, "FAILED", (template_end_time - template_start_time).total_seconds()))

    total_time = (datetime.now() - start_time).total_seconds()
    logger.info("All templates processed.")
    logger.info("Execution Summary:")
    for template, status, time in results:
        logger.info(f"Template: {template}, Status: {status}, Time: {time} seconds")

    logger.info(f"Total execution time: {total_time} seconds")

if __name__ == "__main__":
    run()
