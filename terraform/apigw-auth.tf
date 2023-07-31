
# Declare the local zip archive
data "archive_file" "lambda_code_auth" {
  type        = "zip"
  source_file = "./lambda-src/apigw_auth.py"
  output_path = "./tmp/apigwauth.zip"
}

resource "aws_lambda_function" "lambda_apigw_auth" {
  # checkov:skip=CKV_AWS_115: ADD REASON
  # checkov:skip=CKV_AWS_116: ADD REASON
  # checkov:skip=CKV_AWS_117: ADD REASON
  # checkov:skip=CKV_AWS_50: ADD REASON
  function_name                  = "apigw-auth"
  filename                       = data.archive_file.lambda_code_auth.output_path
  source_code_hash               = data.archive_file.lambda_code_auth.output_base64sha256
  role                           = data.aws_iam_role.iam_for_lambda.arn
  handler                        = "apigw_auth.lambda_handler"
  runtime                        = "python3.10"
  tags                           = local.tag_defaults
  reserved_concurrent_executions = 10

}
