
resource "aws_api_gateway_resource" "slash-status" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "status"
}


resource "aws_api_gateway_method" "rest_api_GET_method_slash-status" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.slash-status.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_api_GET_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.slash-status.id
  http_method             = aws_api_gateway_method.rest_api_GET_method_slash-status.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = var.status_invoke_arn
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.slash-status.id
  http_method = aws_api_gateway_method.rest_api_GET_method_slash-status.http_method
  status_code = "200"
}

resource "aws_lambda_permission" "api_gateway_lambda_GET_slash-status" {
  statement_id  = "AllowExecutionFromAPIGateway-slash-status"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_base_name}-slash_status"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_GET_method_slash-status.http_method}${aws_api_gateway_resource.slash-status.path}"

}
