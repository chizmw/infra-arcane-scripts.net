
# Declare the local zip archive
data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "./lambda-src/apigw_auth.py"
  output_path = "./tmp/apigwauth.zip"
}

data "aws_iam_role" "iam_for_lambda" {
  name = "deploy_json2pdf"
}

resource "aws_lambda_function" "lambda_apigw_auth" {
  function_name    = "apigw-auth"
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  role             = data.aws_iam_role.iam_for_lambda.arn
  handler          = "apigw_auth.lambda_handler"
  runtime          = "python3.11"
}
