
output "rest_api_url" {
  value = "${aws_api_gateway_deployment.rest_api_deployment.invoke_url}${aws_api_gateway_stage.rest_api_stage.stage_name}${aws_api_gateway_resource.rest_api_resource.path}"
}

# the api id
output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "redeployment_triggers" {
  value = aws_api_gateway_deployment.rest_api_deployment.triggers["redeployment"]
}


# output the API Gateway endpoint
output "api_gateway_endpoint" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}
