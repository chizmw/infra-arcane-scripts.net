variable "rest_api_name" {
  type        = string
  description = "Name of the API Gateway created"
}
variable "rest_api_description" {
  type        = string
  description = "Description of the API Gateway created"
}
variable "api_gateway_region" {
  type        = string
  description = "The region in which to create/manage resources"
} //value comes from main.tf
variable "api_gateway_account_id" {
  type        = string
  description = "The account ID in which to create/manage resources"
} //value comes from main.tf

variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "alpha" //add a stage name as per your requirement
}

variable "current_version" {
  type        = string
  description = "The current version of the API"
}

variable "lambda_function_base_name" {
  type        = string
  description = "The base name of the Lambda function"
}

variable "scripts_invoke_arn" {
  type        = string
  description = "The invoke URL for the scripts endpoint"
}

variable "status_invoke_arn" {
  type        = string
  description = "The invoke URL for the status endpoint"
}
