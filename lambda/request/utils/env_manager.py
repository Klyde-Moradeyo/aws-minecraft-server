import os
import json
from typing import Dict, Any, List
from .logger import setup_logging

class EnvironmentVariables:
    def __init__(self, action) -> None:
        self.logger = setup_logging() # Setting up logging
        self.REQUIRED_VARS = self.get_required_vars()
        self.configured = self.check_configuration()
        self.env_vars: Dict[str, Any] = {}
        self.action = action

    def get_required_vars(self):
        required_configs = [    
                                # Minecraft Specifi\c Env Vars
                                'MC_PORT', 'MC_SERVER_IP', 

                                # Worker Lambda
                                'WORKER_LAMBDA_NAME',

                                # EC2
                                'EC2_INSTANCE_ID',
                                
                                # DYNAMBO_TABLE_NAME
                                'DYNAMO_DB_TABLE_NAME',

                                # Fargate Task
                                'ECS_CLUSTER_NAME', 
                                'ECS_MC_ARCHIVE_TASK_DEFINITION_NAME', 
                                'ECS_MC_ARCHIVE_CONTAINER_NAME',
                                'ECS_SUBNET_ID',
                                'ECS_SECURITY_GROUP_ID',

                                # S3 (used for fargate task)
                                'S3_MC_WORLD_URI',
                                'S3_MC_ASSETS_URI'
                            ]
        return required_configs

    def check_configuration(self):
        # Check for required configurations
        missing_configs = []
        for config in self.REQUIRED_VARS:
            if config not in os.environ:
                self.logger.error(f"Environment variable for '{config}' is missing!")
                missing_configs.append(config)
                
        if missing_configs:
            raise MissingConfigurationException(missing_configs)
        else:
            self.logger.info("All configurations are set!")

    def get_vars(self) -> Dict[str, Any]:
        """
        Fetches and decodes the environment variables. Returns the fetched variables.
        """
        self._fetch_required_variables()
        self._decode_tags_json()
        self._verify_missing_variables()
        self._log_env_variables()

        return self.env_vars
        
    def _fetch_required_variables(self) -> None:
        """
        Fetches required environment variables.
        """
        self.env_vars.update({var: os.getenv(var) for var in self.REQUIRED_VARS})

    def _decode_tags_json(self) -> None:
        """
        Decodes the TAGS_JSON environment variable and updates env_vars.
        """
        tags_json = os.getenv('TAGS_JSON')
        if not tags_json:
            raise ValueError("Missing environment variable: TAGS_JSON")

        try:
            tags = json.loads(tags_json)
        except json.JSONDecodeError:
            raise ValueError("Error decoding TAGS_JSON. Ensure it's a valid JSON string.")

        self.env_vars.update({
            'TAG_NAMESPACE': tags.get('Namespace'),
            'TAG_ENVIRONMENT': tags.get('Environment'),
            'TAG_RUNNING_COMMAND': self.action
        })

    def _verify_missing_variables(self) -> None:
        """
        Checks and raises an error if any required environment variable is missing.
        """
        missing_vars = [key for key, value in self.env_vars.items() if value is None]
        if missing_vars:
            raise ValueError(f"Missing environment variables: {', '.join(missing_vars)}")

    def _log_env_variables(self) -> None:
        """
        Logs the environment variables.
        """
        self.logger.info(f"Configured Environment Variables:")
        for key, value in self.env_vars.items():
            self.logger.info(f"{key}: {value}")

class MissingConfigurationException(Exception):
    """
    Raised when required environment variables are missing.
    """
    def __init__(self, missing_configs):
        super().__init__(f"Missing environment variables: {', '.join(missing_configs)}")
        self.missing_configs = missing_configs
