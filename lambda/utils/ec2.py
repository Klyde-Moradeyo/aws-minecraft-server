import boto3
from botocore.exceptions import ClientError
from .env_manager import EnvironmentVariables
from .logger import setup_logging

class EC2Util:
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

    def instance_exists(self):
        """
        Check if the specified EC2 instance exists.
        """
        try:
            self.client.describe_instances(InstanceIds=[self.instance_id])
            self.logger.info("EC2 Instance Exists!")
            return True
        except ClientError as e:
            if 'InvalidInstanceID.NotFound' in str(e):
                self.logger.info(f"Instance {self.instance_id} does not exist.")
                return False
            else:
                self.logger.error(f"Error occurred while checking if instance exists: {e}")
                raise

    def start_instance(self):
        """
        Start the EC2 instance.
        """
        try:
            if self.check_instance_status() == 'stopped':
                self.client.start_instances(InstanceIds=[self.instance_id])
                self.logger.info(f"Starting instance '{self.instance_id}'.")
            else:
                self.logger.info(f"Instance '{self.instance_id}' is not in a stopped state.")
        except ClientError as e:
            self.logger.error(f"Error occurred while starting the instance: {e}")
            raise

    def stop_instance(self):
        """
        Stop the EC2 instance.
        """
        try:
            if self.check_instance_status() in ['running', 'pending']:
                self.client.stop_instances(InstanceIds=[self.instance_id])
                self.logger.info(f"Stopping instance '{self.instance_id}'.")
            else:
                self.logger.info(f"Instance '{self.instance_id}' is not in a running or pending state.")
        except ClientError as e:
            self.logger.error(f"Error occurred while stopping the instance: {e}")
            raise