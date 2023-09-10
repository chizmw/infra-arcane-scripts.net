module "lambda_function" {
  source               = "./modules/lambda_function"
  s3_bucket_name       = "${local.account_id}-${local.aws_default_region}-lambda-${local.pdf_api_name}"
  lambda_function_name = "${local.pdf_api_name}-DEMO-lambda"
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  api_gateway_region     = local.aws_default_region
  api_gateway_account_id = local.account_id
  lambda_function_name   = module.lambda_function.lambda_function_name
  lambda_function_arn    = module.lambda_function.lambda_function_arn
  depends_on = [
    module.lambda_function
  ]
}
