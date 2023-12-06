import shutil
from utils.helper import *
from config import *

def git_clone(source, destination):
    run_command(f"git clone {source} {destination}")
    logger.info(f"Git cloned '{source}' to '{destination}'")

def is_git_repo_dirty(repo_dir):
    """
    Check if there are changes in the git repository.
    """
    status = subprocess.run(f"git -C '{repo_dir}' status --porcelain", shell=True, capture_output=True, text=True)
    return len(status.stdout.strip()) > 0

def git_commit(repo_dir, commit_msg):
    """
    Commit changes to a git repository, if there are any changes.
    """
    if is_git_repo_dirty(repo_dir):
        run_command(f"git -C '{repo_dir}' add .")
        run_command(f"git -C '{repo_dir}' commit -m \"{commit_msg}\"")
        logger.info(f"Git Commit in '{repo_dir}' - message: {commit_msg}")
    else:
        logger.info(f"No changes to commit in '{repo_dir}'")

def configure_git(repo_dir):
    run_command(f"git -C '{repo_dir}' config user.name 'Minecraft Archiver Bot'")
    run_command(f"git -C '{repo_dir}' config user.email 'minecraft-archiver-bot@local.com'")

def create_git_bundle(repo_dir, output):
    """
    Create a git bundle for a repository.
    """
    logger.info(f"Creating git bundle for Repo: '{repo_dir}'")
    run_command(f"git -C '{repo_dir}' bundle create '{output}' --all")
    logger.info(f"Git bundle created at '{output}'")

def create_repo(repo_dir, remove_existing=False):
    """
    Create a new git repository.
    """
    if remove_existing:
        logger.info(f"Removing old '{repo_dir}'")
        shutil.rmtree(repo_dir, ignore_errors=True)
    
    logger.info(f"Creating new '{repo_dir}'")
    os.makedirs(repo_dir, exist_ok=True)
    run_command(f"git init '{repo_dir}'")