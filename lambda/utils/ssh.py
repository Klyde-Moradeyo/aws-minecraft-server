import os
import paramiko
import time
from .logger import setup_logging

class SSHUtil:
    def __init__(self, machine_ip, username, key_file, retries=5, wait=10):
        self.logger = setup_logging()
        self.machine_ip = machine_ip
        self.username = username
        self.key_file = key_file
        self.retries = retries
        self.wait = wait
        self.ssh = self._connect()
        
    def _connect(self):
        """
        Establish an SSH connection and return the client with retries.
        """
        self.logger.info(f"Establishing an SSH connection to '{self.username}@{self.machine_ip}'...")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        for _ in range(self.retries):
            try:
                ssh.connect(self.machine_ip, username=self.username, key_filename=self.key_file)
                return ssh
            except Exception as e:
                self.logger.error(f"Error connecting to {self.machine_ip} on attempt {_ + 1}: {str(e)}")
                if _ < self.retries - 1:  # if not on the last attempt
                    time.sleep(self.wait)
                else:
                    raise


    def __del__(self):
        if self.ssh:
            self.ssh.close()

    def run_command(self, command, capture_output=False):
        """
        SSH into the machine and run the provided command.
        """
        if not self.ssh:
            raise ConnectionError(f"Unable to establish SSH connection to {self.machine_ip}.")
        
        try:
            stdin, stdout, stderr = self.ssh.exec_command(command)

            # Get Exit status
            exit_status = stdout.channel.recv_exit_status()
            
            # Read and decode output
            err = stderr.read().decode().strip()
            out = stdout.read().decode().strip()

            if exit_status != 0:
                self.logger.error(f"Command exited with status code {exit_status}.")
                raise Exception(f"Command exited with status code {exit_status}. Error: {err}")
            else:
                self.logger.info(f"Command '{command}' executed successfully.")
        except Exception as e:
            self.logger.error(f"Error while executing command '{command}': {e}")
            raise
        
        if capture_output:
            return out
        
    def run_script(self, script_path, log_file_path, *args):
        if not self.ssh:
            self.logger.error(f"SSH connection could not be established to {self.machine_ip}.")
            raise Exception(f"SSH connection could not be established to {self.machine_ip}.")

        # Convert args to a string
        args_str = ' '.join(args)

        try: 
            # Run the bash script and redirect its output to a log file
            stdin, stdout, stderr = self.ssh.exec_command(f"sudo bash {script_path} {args_str} > {log_file_path} 2>&1")
            
            # Wait for the command to finish
            exit_status = stdout.channel.recv_exit_status()

            if exit_status != 0:
                script_logs = self.read_file_output(log_file_path)
                self.logger.error(f"{script_logs} \nScript exited with status code {exit_status}.")
                raise Exception(f"Script exited with status code {exit_status}.")
        except Exception as e:
            self.logger.error(f"Failed to execute script on {self.machine_ip}: {str(e)}.")
            raise

    def scp_to_machine(self, local_path, remote_path):
        """
        Copy a local directory recursively to a remote machine via SCP.
        """
        if not self.ssh:
            raise ConnectionError(f"Unable to establish SSH connection to {self.machine_ip}.")

        with paramiko.SFTPClient.from_transport(self.ssh.get_transport()) as sftp:
            try:
                # Check if local_path is a directory
                if os.path.isdir(local_path):
                    # Recursively upload the directory
                    self._recursive_upload(sftp, local_path, remote_path)
                else:
                    # It's a file, just upload it
                    sftp.put(local_path, remote_path)
            except Exception as e:
                self.logger.error(f"Error copying '{local_path}' to '{remote_path}' on '{self.machine_ip}': {str(e)}")
                raise

    def _recursive_upload(self, sftp, local_path, remote_path):
        """
        Recursively upload a directory to the remote server.
        """
        # Create the remote directory if it does not exist
        try:
            sftp.listdir(remote_path)
        except IOError:
            sftp.mkdir(remote_path)

        for item in os.listdir(local_path):
            local_item_path = os.path.join(local_path, item)
            remote_item_path = os.path.join(remote_path, item)

            if os.path.isdir(local_item_path):
                # Create the remote subdirectory, ignore error if it already exists
                try:
                    sftp.mkdir(remote_item_path)
                except IOError:
                    pass
                # Recurse into the directory
                self._recursive_upload(sftp, local_item_path, remote_item_path)
            else:
                # It's a file, upload it
                sftp.put(local_item_path, remote_item_path)

    def read_file_output(self, file_path):
        """
        SSH into the machine and read the file contents.
        """
        if not self.ssh:
            raise ConnectionError(f"Unable to establish SSH connection to {self.machine_ip}.")
        
        with self.ssh.open_sftp() as sftp:
            try:
                with sftp.file(file_path, 'r') as f:
                    content = f.read().decode()
                self.logger.info(f"Read content from '{file_path}' successfully.")
                return content
            except Exception as e:
                self.logger.error(f"Error while reading file '{file_path}': {e}")
                raise

    def is_installed(self, name, version_command):
        """
        Check if a package or command is installed on the remote machine by running its version command.
        """
        try:
            # Run the version command for the given software
            self.run_command(f"{version_command} >/dev/null 2>&1")
            self.logger.info(f"'{name}' is installed.")
            return True
        except Exception:
            self.logger.info(f"'{name}' is not installed.")
            return False
