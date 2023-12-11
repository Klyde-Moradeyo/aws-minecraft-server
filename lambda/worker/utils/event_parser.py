import json
from .logger import setup_logging
from .helper import format_dictionary
from .authorizer import Authorization

class APIEventParser:
    def __init__(self, event):
        self.logger = setup_logging() # Setting up logging
        self.body = self._parse_body(event)
        self.header = self._parse_headers(event)
        # self.isAuthorized = Authorization.check("ssm_param_name")

        self.logger.info(f"body: {format_dictionary(self.body)}")

    def parse(self):
        action = self.extract_key("action", required=True)
        server_template = self.extract_key("server_template", required=True)
        task_id = self.extract_key("task_id", required=True)
        dynambodb_table_name = self.extract_key("dynambodb_table_name", required=True)
        mc_server_ip = self.extract_key("mc_server_ip", required=True)
        mc_server_port = self.extract_key("mc_server_port", required=True)
        ec2_instance_id = self.extract_key("ec2_instance_id", required=True)

        body = {
            "action": action,
            "server_template": server_template,
            "task_id": task_id,
            "dynambodb_table_name": dynambodb_table_name,
            "mc_server_ip": mc_server_ip,
            "mc_server_port": mc_server_port,
            "ec2_instance_id": ec2_instance_id
        }
        self._log_body(body)

        return body

    def extract_key(self, key, required=True):
        """
        Extract a specific key from the body. If the key is required and not found,
        raise a ValueError. If the key is not required and not found, return None.
        """
        value = self.body.get(key)
        if value is None and required:
            raise ValueError(f"Key '{key}' not found in input")
        return value

    def _parse_body(self, event):
        """
        Parse the body of the event and return it as a dictionary.
        """
        body = event.get('body', '{}')

        # Check if the body is already a dictionary
        if isinstance(body, dict):
            return body

        # If body is a string, parse it as JSON
        try:
            return json.loads(body)
        except json.JSONDecodeError as e:
            self.logger.error(f"Invalid JSON input: {e}")
            raise ValueError(f"Invalid JSON input: {e}")

    def _parse_headers(self, event):
        """
        Extract headers from the event.
        """
        return event.get('headers', {})

    def parse_query_parameters(self, event):
        """
        Extract query string parameters from the event.
        """
        return event.get('queryStringParameters', {})

    def parse_path_parameters(self, event):
        """
        Extract path parameters from the event.
        """ 
        return event.get('pathParameters', {})
    
    def _log_body(self, body) -> None:
        """
        Logs the Event Body.
        """
        self.logger.info(f"Received Event Body:")
        for key, value in body.items():
            self.logger.info(f"{key}: {value}") 
