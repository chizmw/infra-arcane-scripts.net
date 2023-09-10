
module "core_lambda_function" {
  source               = "./modules/lambda_function-python"
  lambda_function_name = "${local.pdf_api_base_name}-core-lambda"
  s3_bucket_name       = "${local.account_id}-${local.aws_default_region}-lambda-${local.pdf_api_base_name}"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name          = local.pdf_api_base_name
  rest_api_description   = local.pdf_api_description
  api_gateway_region     = local.aws_default_region
  api_gateway_account_id = local.account_id
  lambda_function_name   = module.core_lambda_function.lambda_function_name
  lambda_function_arn    = module.core_lambda_function.lambda_function_arn
  current_version        = "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"
  depends_on = [
    module.core_lambda_function
  ]
}

# always create a deployment in stage "alpha" fpr the API Gateway
resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = module.api_gateway.rest_api_id
  stage_name  = "alpha"
  triggers = {
    redeployment = sha1(jsonencode([
      module.api_gateway.redeployment_triggers,
    ]))
  }
}
