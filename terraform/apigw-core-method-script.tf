module "method_script" {
  source = "./modules/top-level-method"

  method_path = "script"
  parent_id   = aws_api_gateway_rest_api.json2pdf_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.json2pdf_api.id
}