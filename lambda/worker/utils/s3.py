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
        return f"{self.MC_WORLD_URI}/{self.server_template}/minecraft-world"

    def get_server_assets_path(self):
        """
        Get the S3 path for the server's assets.
        """
        return f"{self.MC_ASSETS_URI}/{self.server_template}/assets"
    
    def get_archive_mc_world_path(self):
        """
        Get the S3 path for the server's assets.
        """
        server_assets = self.get_server_assets_path()
        return f"{server_assets}/world_archive"
    
    def get_server_mods_path(self):
        """
        Get the S3 path for the server's mods
        """
        server_assets = self.get_server_assets_path()
        return f"{server_assets}/mod_config"
    
    def get_server_logs_path(self):
        """
        Get the S3 path for the server's logs
        """
        server_assets = self.get_server_assets_path()
        return f"{self.MC_ASSETS_URI}/{self.server_template}/logs"
    
    def update_server_template(self, template_id):
        self.server_template = template_id
        return self.server_template