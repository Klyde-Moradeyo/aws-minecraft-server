########################
#         Tags         #
########################
variable "tags" {
  description = "Tags from tags module"
  type        = map(string)
}

########################
#        Lambda        #
########################
variable "lambda_function_name" {
  description = "Target Lambda function name"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The Invoke ARN of the Target Lambda function"
  type        = string
}






