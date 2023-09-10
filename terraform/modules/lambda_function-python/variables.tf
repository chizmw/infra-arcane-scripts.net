variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime environment for the Lambda function"
  default     = "python3.11"

}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The number of days to retain the CloudWatch logs for the Lambda function"
  default     = 7
}
