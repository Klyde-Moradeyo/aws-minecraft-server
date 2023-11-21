import boto3
from botocore.exceptions import ClientError
from .logger import setup_logging

class S3Util:
    def __init__(self, env_vars, server_template):
        self.logger = setup_logging()
        self.s3 = boto3.client('s3')
        self.server_template = server_template

        self.envs = env_vars
        self.MC_WORLD_URI = self.envs["S3_MC_WORLD_URI"]
        self.MC_ASSETS_URI = self.envs["S3_MC_ASSETS_URI"]
        
    def get_minecraft_world_path(self):
        """
        Get the S3 path for the Minecraft world.
        """
        return f"{self.MC_WORLD_URI}/minecraft-world/{self.server_template}"

    def get_server_assets_path(self):
        """
        Get the S3 path for the server's assets.
        """
        return f"{self.MC_ASSETS_URI}/{self.server_template}/assets"
    
    def get_archive_mc_world_path(self):
        """
        Get the S3 path for the server's assets.
        """
        return f"{self.get_server_assets_path()}/world_archive"