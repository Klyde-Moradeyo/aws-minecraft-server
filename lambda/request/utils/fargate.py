import boto3
from .env_manager import EnvironmentVariables
from .logger import setup_logging

class FargateUtil:
    def __init__(self, cluster_name, task_definition, container_name, environment_variables, env_vars):
        self.logger = setup_logging() # Setting up logging
        self.cluster_name = cluster_name
        self.client = boto3.client('ecs')
        self.env_vars = env_vars
        self.task_definition = task_definition
        self.container_name = container_name
        self.environment_variables = environment_variables
        self.network_configuration = self.set_network_config()
        self.tags = self.set_task_tags()      

    def create_fargate_container(self):
        try:
            response = self.client.run_task(
                cluster=self.cluster_name,
                launchType="FARGATE",
                taskDefinition=self.task_definition,
                count=1,
                platformVersion="LATEST",
                # networkConfiguration=self.network_configuration,
                overrides={
                    "containerOverrides": [{
                        "name": self.container_name,
                        "environment": self.environment_variables
                    }]
                },
                tags=self.tags
            )
            task_arn = response["tasks"][0]["taskArn"]
            self.logger.debug(f"Created Fargate container with ARN: '{task_arn}'")
            return task_arn
        except Exception as e:
            self.logger.error(f"Error creating Fargate container: {e}")
            raise

    def is_task_with_tags_exists(self):
        try:
            desired_tags = self.get_task_tags()
            tasks_response = self.client.list_tasks(cluster=self.cluster_name)
            for task_arn in tasks_response.get('taskArns'):
                current_task_details = self.client.describe_tasks(
                    cluster=self.cluster_name,
                    tasks=[task_arn],
                    include=['TAGS'],
                )
                for task_data in current_task_details.get('tasks'):
                    if self._tags_match(task_data.get('tags', []), desired_tags):
                        self.logger.info(f"Located task with ARN '{task_arn}' matching the specified tags.")
                        return True
            self.logger.info(f"No tasks matching the provided tags were found in cluster '{self.cluster_name}'.")
            return False
        except Exception as e:
            self.logger.error(f"Error checking if task with tags exists: {e}")
            raise

    def check_task_status(self, tags):
        try:
            list_tasks_response = self.client.list_tasks(cluster=self.cluster_name)
            for task_arn in list_tasks_response.get("taskArns", []):
                describe_task_response = self.client.describe_tasks(cluster=self.cluster_name, tasks=[task_arn], include=['TAGS'])
                task = describe_task_response["tasks"][0]
                if self._tags_match(task.get('tags', []), tags):
                    self.logger.debug(f"Task Status: {task['lastStatus']}")
                    return task["lastStatus"]
            self.logger.info(f"No tasks matched the provided tags: {tags}.")
            return None
        except Exception as e:
            self.logger.warning(f"Error checking task status: {e}")
            raise

    def _tags_match(self, task_tags, desired_tags):
        tag_match_count = 0
        for tag_to_check in desired_tags:
            if tag_to_check['key'] == 'TAG_RUNNING_COMMAND':
                if any(existing_tag['key'] == tag_to_check['key'] for existing_tag in task_tags):
                    tag_match_count += 1
            else:
                if tag_to_check in task_tags:
                    tag_match_count += 1
        return tag_match_count == len(desired_tags)


    def set_env_vars(self, environment_variables={}):
        return environment_variables
        
    def set_task_tags(self):
        task_tags = [ {'key': key, 'value': value} for key, value in self.env_vars.items() if key.startswith('TAG_') ]
        return task_tags
    
    def get_env_vars(self):
        return self.environment_variables
        
    def get_task_tags(self):
        return self.tags