import boto3
from utils.helper import *
from config import *

s3_client = boto3.client("s3")

def s3_download(s3_bucket_path, s3_object_key, local_path):
    try:
        s3_client.download_file(s3_bucket_path, s3_object_key, local_path)
        logger.info(f"Downloaded '{s3_object_key}' from '{s3_bucket_path}' to '{local_path}'")
    except Exception as e:
        print(f"Error downloading {s3_object_key} from S3: {e}")
        exit(1)

def s3_download_folder(s3_bucket_name, s3_folder_key, local_dir_path):
    paginator = s3_client.get_paginator('list_objects_v2')
    for page in paginator.paginate(Bucket=s3_bucket_name, Prefix=s3_folder_key):
        for obj in page.get('Contents', []):
            key = obj['Key']
            if not key.endswith('/'):  # skip directories
                # Calculate relative path from the s3_folder_key
                relative_path = os.path.relpath(key, s3_folder_key)
                local_file_path = os.path.join(local_dir_path, relative_path)

                # Create the directory if it doesn't exist
                os.makedirs(os.path.dirname(local_file_path), exist_ok=True)

                try:
                    s3_client.download_file(s3_bucket_name, key, local_file_path)
                    logger.info(f"Downloaded {key} from S3 to {local_file_path}")
                except Exception as e:
                    logger.error(f"Error downloading {key} from S3: {e}")

    logger.info(f"Downloaded all files from '{s3_folder_key}' in bucket '{s3_bucket_name}' to '{local_dir_path}'")

def s3_upload(s3_bucket_path, local_path, s3_object_key):
    try:
        s3_client.upload_file(local_path, s3_bucket_path, s3_object_key)
    except Exception as e:
        print(f"Error uploading {local_path} to S3: {e}")
        exit(1)

def check_s3_file_exists(s3_bucket_path, s3_object_key):
    try:
        s3_client.head_object(Bucket=s3_bucket_path, Key=s3_object_key)
        return True
    except:
        return False
    
def list_folders_in_s3(bucket_name, prefix):
    """
    List the names of folders within a specific S3 directory (prefix).
    """
    paginator = s3_client.get_paginator('list_objects_v2')
    folder_names = set()

    for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix, Delimiter='/'):
        for content in page.get('CommonPrefixes', []):
            folder_name = content.get('Prefix')
            if folder_name: 
                # Remove the prefix and trailing slash to get the folder name
                clean_folder_name = folder_name[len(prefix):-1]
                folder_names.add(clean_folder_name)

    return list(folder_names)