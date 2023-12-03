class ResponseFormatter:
    @staticmethod
    def success_response(status, action, task_id, info):
        """
        Formats a success response.
        """
        return {
            "STATUS": status,
            "ACTION": action,
            "TASK_ID": task_id,
            "INFO": info
        }

    @staticmethod
    def error_response(status, action, task_id, info, exception):
        """
        Formats an error response.
        """
        return {
            "STATUS": status,
            "ACTION": action,
            "TASK_ID": task_id,
            "INFO": info,
            "EXCEPTION": exception
        }
