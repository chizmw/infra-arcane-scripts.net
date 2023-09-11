
resource "aws_api_gateway_resource" "slash-scripts" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "scripts"
}


resource "aws_api_gateway_method" "rest_api_POST_method_slash-scripts" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.slash-scripts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_api_POST_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.slash-scripts.id
  http_method             = aws_api_gateway_method.rest_api_POST_method_slash-scripts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.scripts_invoke_arn
}

resource "aws_api_gateway_method_response" "rest_api_POST_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.slash-scripts.id
  http_method = aws_api_gateway_method.rest_api_POST_method_slash-scripts.http_method
  status_code = "200"
}

resource "aws_lambda_permission" "api_gateway_lambda_POST_slash-scripts" {
  statement_id  = "AllowExecutionFromAPIGateway-slash-scripts"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_base_name}-slash_scripts"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_POST_method_slash-scripts.http_method}${aws_api_gateway_resource.slash-scripts.path}"

}
