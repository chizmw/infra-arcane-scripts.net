
moved {
  from = aws_api_gateway_method.options_method
  to   = module.method_render.aws_api_gateway_method.method_path_options_method
}

moved {
  from = aws_api_gateway_method_response.options_200
  to   = module.method_render.aws_api_gateway_method_response.method_path_options_200
}

moved {
  from = aws_api_gateway_integration.options_integration
  to   = module.method_render.aws_api_gateway_integration.method_path_options_integration
}

moved {
  from = aws_api_gateway_integration_response.options_integration_response
  to   = module.method_render.aws_api_gateway_integration_response.method_path_options_integration_response
}

moved {
  from = aws_api_gateway_resource.rest_api_resource
  to   = aws_api_gateway_resource.slash-scripts
}
