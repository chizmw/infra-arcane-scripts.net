
module "core_lambda_function" {
  source               = "./modules/lambda_function-python"
  lambda_function_name = "${local.pdf_api_base_name}-core-lambda"
  s3_bucket_name       = "${local.account_id}-${local.aws_default_region}-lambda-${local.pdf_api_base_name}"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name             = local.pdf_api_base_name
  rest_api_description      = local.pdf_api_description
  api_gateway_region        = local.aws_default_region
  api_gateway_account_id    = local.account_id
  lambda_function_base_name = module.core_lambda_function.base_function_name
  scripts_invoke_arn        = module.core_lambda_function.scripts_invoke_arn
  status_invoke_arn         = module.core_lambda_function.status_invoke_arn
  current_version           = "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"
  depends_on = [
    module.core_lambda_function
  ]
}

output "core_lambda_function_arn" {
  value = module.core_lambda_function.function_arn
}
