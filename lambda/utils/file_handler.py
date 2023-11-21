import tempfile
import json
from utils.logger import setup_logging
from typing import Dict, Any

def convert_bytes(byte_value):
    # Conversion factors
    KB = 1024
    MB = KB ** 2
    GB = KB ** 3
    
    # Calculate sizes
    size_kb = byte_value / KB
    size_mb = byte_value / MB
    size_gb = byte_value / GB
    
    return {
        "size_bytes": byte_value,
        "size_kb": size_kb,
        "size_mb": size_mb,
        "size_gb": size_gb
    }

def write_to_tmp_file(content):
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
        temp_file.write(content)
        temp_file.flush() # Ensure any buffered data is written to the file
        dir = temp_file.name
    return dir

def generate_env_file(config: Dict[str, Any]):
    """
    Generates an .env file from the provided configuration.
    """
    # Preparing content for the temporary file
    content = '\n'.join(f"{key}={value}" for key, value in config.items())
    
    # Writing to temporary file
    temp_file_path = write_to_tmp_file(content)

    return temp_file_path

class JSONHelper:
    @staticmethod
    def read_json(file_path: str) -> Dict[str, Any]:
        try:
            with open(file_path, 'r') as file:
                return json.load(file)
        except FileNotFoundError:
            # Add appropriate logging here
            raise
        except json.JSONDecodeError:
            # Add appropriate logging here
            raise


