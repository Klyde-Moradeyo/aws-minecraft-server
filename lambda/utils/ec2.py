import boto3
from .env_manager import EnvironmentVariables
from .logger import setup_logging

class EC2Manager:
    def __init__(self, instance_id, env_vars):
        self.logger = setup_logging()
        self.client = boto3.client('ec2')
        self.env_vars = env_vars
        self.instance_id = instance_id

    def check_instance_status(self):
        """
        Check the status of an EC2 instance.
        """
        try:
            response = self.client.describe_instances(InstanceIds=[self.instance_id])
            status = response['Reservations'][0]['Instances'][0]['State']['Name']
            self.logger.info(f"Instance '{self.instance_id}' status: '{status}'")
            return status
        except Exception as e:
            self.logger.error(f"Error checking EC2 instance status: {e}")
            raise