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

        # For debuging later
        # self.logger.info(f"query params: {self.parse_query_parameters(event)}")
        # self.logger.info(f"path params: \n{self.parse_path_parameters(event)}")
        self.logger.info(f"body: {format_dictionary(self.body)}")

    def parse(self):
        action = self.extract_key("action", required=True)
        server_template = self.extract_key("server_template", required=False)

        return {
            "action": action,
            "server_template": server_template  # This will be None if not provided
        }

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
        try:
            body = event.get('body', '{}')
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
        
