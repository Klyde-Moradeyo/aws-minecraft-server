import random
from mcstatus import JavaServer
from typing import Dict, Any
from .logger import setup_logging
from .file_handler import JSONHelper, generate_env_file, convert_megabytes
from .ssh import SSHUtil

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
        
    def select_icon(self):
        return
    
    def select_icon(self):
        """
        Selects a random Minecraft server icon URL
        """
        urls = [
            "https://drive.google.com/uc?id=1cKMBJ9YR3nco-eAd2H-N1Rrg3UkAdMRx",
            "https://drive.google.com/uc?id=1M-U5Id6gjk3IUcvJv9kXRvWA7x9PTBpE",
            "https://drive.google.com/uc?id=18zAABmF2vimdQ_275c4llR9GTKdLNX7D",
            "https://drive.google.com/uc?id=1whYab8byQ3pW5aVW70iCu-EBi6p_VdVn",
            "https://drive.google.com/uc?id=1rMjv3bdBIQVmbjUnWcfKkiBd8jPbp9UX",
            "https://drive.google.com/uc?id=1VvTbz130Q2vmu7CSFP-ztoij04ZKkt4O",
            "https://drive.google.com/uc?id=1LkfW4ERVI-Y2r74KoyA-gGLYM-k2fnsz"
        ]

        # Select a random URL from the list
        icon_url = random.choice(urls)
        print(f"Using Minecraft server icon: '{icon_url}'")
        return icon_url
    
    def get_memory(ssh_util: SSHUtil):
        try:
            # Command to get total RAM (using 'free -m')
            command = "free -m | awk '/Mem:/ {print $2 \" MB\"}'"
            
            # Run the command and capture output
            total_ram = ssh_util.run_command(command, capture_output=True)
            total_ram = convert_megabytes(total_ram)

            ram_mb = total_ram["size_mb"]
            ram_gb = total_ram["size_gb"]
            
            print(f"Total RAM on the EC2 machine: '{ram_gb} GB' | '{ram_mb} MB'")
            return ram_gb
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            # Further exception handling as required

    def initialize_server_config(self, base_config_path: str, template_config_path: str, additional_config: dict = None):
        try:
            # Load Base Config
            base_config = JSONHelper.read_json(base_config_path)
            
            # Load Selected Template
            template_id = self.template_id
            template_config = JSONHelper.read_json(template_config_path)
            templates = template_config.get("templates", {})
            chosen_template = templates.get(template_id)

            # Initialize additional_config if it's None
            if additional_config is None:
                additional_config = {}

            # Merge base config and chosen template
            if chosen_template:
                # Merge with chosen template and then with additional configuration
                # Note: Chosen Template and Additional Config will override base config
                merged_config = {**base_config, **chosen_template, **additional_config}
                file_path = generate_env_file(merged_config)
                self.logger.info(f"Successfully Generated Config for '{template_id}'")
                return file_path
            else:
                self.logger.error(f"Template with ID '{template_id}' not found.")
                raise
        except Exception as e:
            self.logger.error(f"Error initializing server config: {str(e)}")
