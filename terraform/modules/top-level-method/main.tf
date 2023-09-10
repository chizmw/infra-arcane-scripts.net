provider "aws" {
  region = "eu-west-2"
  alias  = "default"
}

variable "method_path" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "rest_api_id" {
  type = string
}

locals {
  options_method = "OPTIONS"
}



resource "aws_api_gateway_resource" "path_resource" {
  provider    = aws.default
  path_part   = var.method_path
  parent_id   = var.parent_id
  rest_api_id = var.rest_api_id
}

resource "aws_api_gateway_method" "method_path_options_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.parent_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}


resource "aws_api_gateway_method_response" "method_path_options_200" {
  provider    = aws.default
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_resource.id
  http_method = local.options_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.method_path_options_method]
}


resource "aws_api_gateway_integration" "method_path_options_integration" {
  provider    = aws.default
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_resource.id
  http_method = local.options_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.method_path_options_method]
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}


resource "aws_api_gateway_integration_response" "method_path_options_integration_response" {
  provider    = aws.default
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.path_resource.id
  http_method = local.options_method
  status_code = aws_api_gateway_method_response.method_path_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'X-Chisel-Info,access-control-allow-origin,cache-control,x-requested-with,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.method_path_options_200]
}
