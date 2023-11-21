from mcstatus import JavaServer
from typing import Dict, Any
from .logger import setup_logging
from .file_handler import JSONHelper, generate_env_file

class MinecraftServer:
    def __init__(self, template_id, ip: str, port: str):
        self.logger = setup_logging()
        self.server_address = f"{ip}:{port}"
        self.java_server = JavaServer.lookup(self.server_address)
        self.template_id = template_id

    def check(self) -> Dict[str, Any]:
        """
        Checks the status of the Minecraft server.
        """
        try:
            status = self.java_server.status()
            return {
                'online': self.java_server.ping() is not None,
                'players_online': status.players.online,
                'version': status.version.name
            }
        except Exception as e:
            self.logger.warning(f"Warning: Could not check the Minecraft server. Maybe its offline? Error: '{str(e)}'.")
            return {
                'online': False,
                'players_online': 0,
                'version': 'unknown'
            }


    def initialize_server_config(self, base_config_path: str, template_config_path: str):
        try:
            # Load Base Config
            base_config = JSONHelper.read_json(base_config_path)
            
            # Load Selected Template
            template_id = self.template_id
            template_config = JSONHelper.read_json(template_config_path)
            templates = template_config.get("templates", {})
            chosen_template = templates.get(template_id)

            # Merge base config and chosen template
            if chosen_template:
                # Note: Chosen Template will override base config
                merged_config = {**base_config, **chosen_template}
                file_path = generate_env_file(merged_config)
                self.logger.info(f"Successfuly Generated Config for '{template_id}'")
                return file_path
            else:
                self.logger.error(f"Template with ID '{template_id}' not found.")
                raise
        except Exception as e:
            self.logger.error(f"Error initializing server config: {str(e)}")
