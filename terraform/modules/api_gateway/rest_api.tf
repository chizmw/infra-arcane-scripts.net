# https://hands-on.cloud/terraform-api-gateway/

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.rest_api_name
  description = var.rest_api_description
}



resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  stage_name        = var.rest_api_stage_name
  stage_description = var.current_version
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.rest_api_POST_method_slash-scripts.id,
      aws_api_gateway_integration.rest_api_GET_method_integration.id,
    ]))
  }
  depends_on = [
    aws_api_gateway_method.rest_api_POST_method_slash-scripts,
    aws_api_gateway_integration.rest_api_GET_method_integration,
  ]
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name
  depends_on    = [aws_api_gateway_rest_api.rest_api]
}
