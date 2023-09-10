# OPTIONS method for /scripts
resource "aws_api_gateway_method" "root_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
