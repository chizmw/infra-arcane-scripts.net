resource "aws_api_gateway_rest_api" "json2pdf_api" {
  provider    = aws.default
  name        = local.pdf_api_name
  description = local.pdf_api_description
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_resource" "json2pdf_resource" {
  provider    = aws.default
  path_part   = local.pdf_render_path
  parent_id   = aws_api_gateway_rest_api.json2pdf_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
}


# OPTIONS method


resource "aws_api_gateway_method" "options_method" {
  provider      = aws.default
  rest_api_id   = aws_api_gateway_rest_api.json2pdf_api.id
  resource_id   = aws_api_gateway_resource.json2pdf_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}


resource "aws_api_gateway_method_response" "options_200" {
  provider    = aws.default
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
  resource_id = aws_api_gateway_resource.json2pdf_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.options_method]
}


resource "aws_api_gateway_integration" "options_integration" {
  provider    = aws.default
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
  resource_id = aws_api_gateway_resource.json2pdf_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.options_method]
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}


resource "aws_api_gateway_integration_response" "options_integration_response" {
  provider    = aws.default
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
  resource_id = aws_api_gateway_resource.json2pdf_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'X-Chisel-Info,access-control-allow-origin,cache-control,x-requested-with,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}

# we need a gateway reaponse for default 4xx responses that add the following
# header
# Access-Control-Allow-Origin: '*'
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html
resource "aws_api_gateway_gateway_response" "json2pdf_gateway_response" {
  provider    = aws.default
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
  # this is the default 4xx response
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/supported-gateway-response-types.html
  response_type = "DEFAULT_4XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
    "gatewayresponse.header.X-Chisel-Info"               = "'DEFAULT_4XX from terraform'"
  }
  response_templates = {
    "application/json" = jsonencode(
      { "error" : "a non-specific 4XX error has occurred", "chisel" : "was here" }
    )
  }
  depends_on = [aws_api_gateway_rest_api.json2pdf_api]
}

locals {
  gatewayresponses = {
    "ACCESS_DENIED"                  = "The gateway response for authorization failure"
    "API_CONFIGURATION_ERROR"        = "The gateway response for invalid API configuration"
    "AUTHORIZER_CONFIGURATION_ERROR" = "The gateway response when the authorizer configuration is invalid"
    "AUTHORIZER_FAILURE"             = "The gateway response when a custom authorizer failed to authenticate the caller"
    "BAD_REQUEST_PARAMETERS"         = "The gateway response when request parameters are invalid"
    "BAD_REQUEST_BODY"               = "The gateway response when request body is invalid"
    "INVALID_API_KEY"                = "INVALID_API_KEY: check you correctly configured the API key in the source code"
    "MISSING_AUTHENTICATION_TOKEN"   = "The gateway response when the incoming request does not contain an authentication token"
  }

  status_codes = {
    "ACCESS_DENIED"                  = "403"
    "API_CONFIGURATION_ERROR"        = "500"
    "AUTHORIZER_CONFIGURATION_ERROR" = "500"
    "AUTHORIZER_FAILURE"             = "500"
    "BAD_REQUEST_PARAMETERS"         = "400"
    "BAD_REQUEST_BODY"               = "400"
    "INVALID_API_KEY"                = "403"
    "MISSING_AUTHENTICATION_TOKEN"   = "403"
  }
}

resource "aws_api_gateway_gateway_response" "json2pdf_gateway_response_for" {
  provider    = aws.default
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id

  for_each = local.gatewayresponses

  # status_code is the lookup of the key in the local.status_codes map
  status_code = local.status_codes[each.key]

  response_type = each.key
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = jsonencode(
      {
        "error" : each.value,
        "chisel" : "was here",
        "version" : "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"
      }
    )
  }
  depends_on = [aws_api_gateway_rest_api.json2pdf_api]
}
