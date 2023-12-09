import time
import json
import os
from datetime import datetime
import requests
from typing import List, Dict, Any
import logging
from mcrcon import MCRcon
from mcstatus import JavaServer

SERVER_HOST = os.environ["SERVER_HOST"]
SERVER_PORT = os.environ["SERVER_PORT"]
RCON_HOST = os.environ["RCON_HOST"]
RCON_PORT = os.environ["RCON_PORT"]
RCON_PASS = os.environ["RCON_PASSWORD"]
API_GATEWAY_URL = os.environ["API_GW_URL"]
INACTIVE_TIME =  1200  # 20 minutes |  Time in seconds for inactive players check
CHECK_INTERVAL = 60  # Time in seconds for the check interval
LOG_FILE = 'logs/player_activity_watchdog.log'  # Log file name

######################################################################
#                               LOG                                  #
######################################################################
class LOG:
    def __init__(self, log_file):
        self.log_file = log_file
        self.logger = setup_logging()

    def format_data(self, online, players_online, version, time_without_players, timer_status):  
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        return {    
            "timestamp": timestamp,
            "server_online": online,
            "players_online": players_online,
            "server_version": version,
            "time_without_players": time_without_players,
            "timer_status": timer_status
            }

    def log(self, data):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        if isinstance(data, dict):
            timestamped_data = {'timestamp': timestamp, **data}
            self.logger.info(timestamped_data)
            self.log_to_file(', '.join([f"{k}: {v}" for k, v in timestamped_data.items()]))
        else:
            self.logger.info(f"{timestamp}: {data}")
            self.log_to_file(f"{timestamp}: {data}")

    def log_to_file(self, data):
        with open(self.log_file, 'a') as f:
            if isinstance(data, dict):
                f.write(json.dumps(data, indent=4))
            else:
                f.write(data)
            f.write('\n')

def setup_logging():
    """
    Setup logging configuration.
    """
    # Get the root logger
    logger = logging.getLogger()
    
    # Set the logger level
    log_level = logging.INFO
    logger.setLevel(log_level)
   
    # Ensure there is no duplicated handlers
    if not logger.handlers:
        # configure the handler and formatter at the root logger level
        ch = logging.StreamHandler() # Create console handler and
        ch.setLevel(log_level) # set level to info
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s') # Create formatter
        ch.setFormatter(formatter) # Add formatter to ch
        logger.addHandler(ch) # Add ch to logger

    # Write logs to a file
    # log_directory = "log/"
    # if not os.path.exists(log_directory):
    #     os.makedirs(log_directory)
    # log_file = os.path.join(log_directory, 'app.log')
    # file_handler = logging.FileHandler(log_file)
    # file_handler.setFormatter(logging.Formatter(log_format))
    # logging.getLogger().addHandler(file_handler)

    return logging.getLogger()      

######################################################################
#                           Monitor Class                            #
######################################################################
class MonitorError(Exception):
    pass

class MONITOR:
    def __init__(self, server, log, inactive_time, check_interval, api_url, rcon_pass):
        self.server = server
        self.log = log
        self.inactive_time = inactive_time
        self.check_interval = check_interval
        self.api_url = api_url
        self.rcon_pass = rcon_pass
        self.inactive_players_timer_start = None
        self.logger = setup_logging()

    def get_basic_server_info(self):
        try:
            status = self.server.status()
            online = self.server.ping() is not None
            players_online = status.players.online
            version = status.version.name
        except Exception as e:
            online = False
            players_online = 0
            version = None

        return {
            'online': online,
            'players_online': players_online,
            'version': version
        }
    
    def send_to_api(self, command, reason, endpoint="command", timeout=20, retries=5, wait_time=2):
        """
        Sends data to the API and returns the response.
        """
        url = self.api_url + f"/{endpoint}"
        data = { "action": command, "server_template": "None" }
        data["metadata"] = {
            "requestTime": datetime.now().isoformat(),
            "reason": str(reason)
        }

        self.logger.info(f"API Payload: {data}")
        headers = {'Content-Type': 'application/json'}

        self.logger.info(f"Sending Data to API at '{url}'")
        for attempt in range(retries):
            self.logger.info(f"Sending Data to API at endpoint '{endpoint}' (Attempt: {attempt + 1})")

            try:
                response = requests.post(url, headers=headers, json=data, timeout=timeout)
                response.raise_for_status()

                self.logger.info(f"Received successful response from {endpoint}")
                return response.json()

            except requests.exceptions.Timeout:
                self.logger.warning(f"Request timed out for endpoint: {endpoint}.")
            except requests.exceptions.RequestException as err:
                self.logger.warning(f"Error occurred while sending data to {endpoint}: {err}.")
            
            if attempt < retries - 1:  # To avoid sleeping after the last attempt
                self.logger.info(f"Waiting {wait_time}s before retry.")
                time.sleep(wait_time)

        self.logger.error(f"Failed to send data to API after {retries} attempts.")
        return None

    def get_inactive_time_string(self):
        minutes, seconds = divmod(self.inactive_time, 60)
        return f"{minutes} minutes {seconds} seconds"

    def run(self):
        while True:
            try:
                basic_info = self.get_basic_server_info()

                server_info = { **basic_info }

                if server_info.get('players_online', 0) == 0:
                    if self.inactive_players_timer_start is None:
                        self.inactive_players_timer_start = time.time()
                        data = self.log.format_data(server_info['online'], server_info['players_online'], server_info['version'], 0, "STARTING")
                        self.log.log(data)
                    elif time.time() - self.inactive_players_timer_start >= self.inactive_time: # Send to API Gateway if no players for inactive_time
                        data = self.log.format_data(server_info['online'], server_info['players_online'], server_info['version'], self.get_inactive_time_string(), "EXPIRED - SIGNALING MC SERVER STOP")
                        self.log.log(data)
                        self.send_to_api("stop", f"Server Automation Script: User's are inactive for '{self.get_inactive_time_string()}.' Sending stop request...")
                        self.inactive_players_timer_start = None
                    else:
                        elapsed_time = int(time.time() - self.inactive_players_timer_start)
                        data = self.log.format_data(server_info['online'], server_info['players_online'], server_info['version'], elapsed_time, "RUNNING")
                        self.log.log(data)
                else:
                    self.inactive_players_timer_start = None
                    data = self.log.format_data(server_info['online'], server_info['players_online'], server_info['version'], 0, "RESET")
                    self.log.log(data)

            except MonitorError:
                self.log.log("Monitoring error occurred")

            # Wait for the check interval before checking again
            time.sleep(self.check_interval)

if __name__ == "__main__":
    minecraft_server = JavaServer.lookup(f"{SERVER_HOST}:{SERVER_PORT}")
    log = LOG(LOG_FILE)
    monitor = MONITOR(minecraft_server, log, INACTIVE_TIME, CHECK_INTERVAL, API_GATEWAY_URL, RCON_PASS)
    monitor.run()