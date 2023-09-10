# locals {
#   gatewayresponses = {
#     "ACCESS_DENIED"                  = "The gateway response for authorization failure"
#     "API_CONFIGURATION_ERROR"        = "The gateway response for invalid API configuration"
#     "AUTHORIZER_CONFIGURATION_ERROR" = "The gateway response when the authorizer configuration is invalid"
#     "AUTHORIZER_FAILURE"             = "The gateway response when a custom authorizer failed to authenticate the caller"
#     "BAD_REQUEST_PARAMETERS"         = "The gateway response when request parameters are invalid"
#     "BAD_REQUEST_BODY"               = "The gateway response when request body is invalid"
#     "INVALID_API_KEY"                = "INVALID_API_KEY: check you correctly configured the API key in the source code"
#     "MISSING_AUTHENTICATION_TOKEN"   = "The gateway response when the incoming request does not contain an authentication token"
#   }

#   status_codes = {
#     "ACCESS_DENIED"                  = "403"
#     "API_CONFIGURATION_ERROR"        = "500"
#     "AUTHORIZER_CONFIGURATION_ERROR" = "500"
#     "AUTHORIZER_FAILURE"             = "500"
#     "BAD_REQUEST_PARAMETERS"         = "400"
#     "BAD_REQUEST_BODY"               = "400"
#     "INVALID_API_KEY"                = "403"
#     "MISSING_AUTHENTICATION_TOKEN"   = "403"
#   }

# }

# # we need a gateway reaponse for default 4xx responses that add the following
# # header
# # Access-Control-Allow-Origin: '*'
# # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html
# resource "aws_api_gateway_gateway_response" "gateway_response" {
#   rest_api_id = aws_api_gateway_rest_api.rest_api.id
#   # this is the default 4xx response
#   # https://docs.aws.amazon.com/apigateway/latest/developerguide/supported-gateway-response-types.html
#   response_type = "DEFAULT_4XX"
#   response_parameters = {
#     "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
#     "gatewayresponse.header.X-Chisel-Info"               = "'DEFAULT_4XX from terraform'"
#   }
#   response_templates = {
#     "application/json" = jsonencode(
#       { "error" : "a non-specific 4XX error has occurred", "chisel" : "was here" }
#     )
#   }
#   depends_on = [aws_api_gateway_rest_api.rest_api]
# }

# resource "aws_api_gateway_gateway_response" "gateway_response_for" {
#   rest_api_id = aws_api_gateway_rest_api.rest_api.id

#   for_each = local.gatewayresponses

#   # status_code is the lookup of the key in the local.status_codes map
#   status_code = local.status_codes[each.key]

#   response_type = each.key
#   response_parameters = {
#     "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
#   }
#   response_templates = {
#     "application/json" = jsonencode(
#       {
#         "error" : each.value,
#         "chisel" : "was here",
#         "version" : var.current_version,
#       }
#     )
#   }
#   depends_on = [aws_api_gateway_rest_api.rest_api]
# }
