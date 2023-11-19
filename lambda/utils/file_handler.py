import tempfile
from utils.logger import setup_logging

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

