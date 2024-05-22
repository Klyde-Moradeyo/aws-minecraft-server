
########################
#    Resource Naming   #
########################
variable "name" {
  description = "The name of the resources"
  type        = string
}

##########################
#        Lambda          #
##########################
variable "handler" {
  description = "The entry point in your code."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
  default     = ""
}

##########################
#        IAM Policy      #
##########################
variable "iam_policy_statements" {
  description = "The list of policy statements for the Lambda execution role."
  type        = list(any)
  default = [
    {
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }
  ]
}

##########################
#        S3 Bucket       #
##########################
variable "s3_bucket" {
  description = "The name of the S3 bucket containing the Lambda function code."
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "The S3 key of the Lambda function code."
  type        = string
  default     = ""
}

##########################
#       Zip and Image    #
##########################
variable "zip_file" {
  description = "Path to the local ZIP file containing the Lambda function code."
  type        = string
  default     = ""
}

variable "s3_file_hash" {
  description = "Base64-encoded SHA256 hash of the S3 file."
  type        = string
  default     = ""
}

variable "image_uri" {
  description = "URI of a Docker image containing the Lambda function."
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the Lambda function."
  type        = string
  default     = ""
}

variable "timeout" {
  description = "The timeout for the Lambda function."
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "The amount of memory in MB your Lambda function can use at runtime."
  type        = number
  default     = 128
}

variable "publish" {
  description = "Whether to publish creation/change as a new Lambda function version."
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "A list of Lambda layer ARNs."
  type        = list(string)
  default     = []
}

variable "permissions" {
  description = "A list of Lambda permissions."
  type = list(object({
    statement_id = string
    action       = string
    principal    = string
    source_arn   = string
  }))
  default = []
}

variable "reserved_concurrent_executions" {
  description = "The maximum number of concurrent executions reserved for this function."
  type        = number
  default     = -1
}

##########################
#      CloudWatch        #
##########################
variable "log_retention_in_days" {
  type        = number
  description = "The number of days to retain log events in CloudWatch"
}

########################
#         Tags         #
########################
variable "tags" {
  description = "Tags to assign"
  type        = map(string)
}