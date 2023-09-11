//using archive_file data source to zip the lambda code:
locals {
  lambda_function_name = var.lambda_function_name
  lambda_runtime       = var.lambda_runtime
  s3_bucket_name       = var.s3_bucket_name
  s3_bucket_key        = "function_code-${local.lambda_runtime}.zip"
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/function_code"
  output_path = "${path.module}/${local.s3_bucket_key}"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.s3_bucket_name
}
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = local.s3_bucket_key
  source = data.archive_file.lambda_code.output_path
  etag   = filemd5(data.archive_file.lambda_code.output_path)
}

resource "aws_lambda_function" "slash_scripts" {
  function_name    = "${var.lambda_function_name}-slash_scripts"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code.key
  runtime          = var.lambda_runtime
  handler          = "lambda.slash_scripts"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}
resource "aws_lambda_function" "slash_status" {
  function_name    = "${var.lambda_function_name}-slash_status"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code.key
  runtime          = var.lambda_runtime
  handler          = "lambda.slash_status"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}
resource "aws_cloudwatch_log_group" "lambda_log_group-slash_scripts" {
  name              = "/aws/lambda/${aws_lambda_function.slash_scripts.function_name}"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "lambda_log_group-slash_status" {
  name              = "/aws/lambda/${aws_lambda_function.slash_status.function_name}"
  retention_in_days = 7
}
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_${var.lambda_function_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# a policy to allow dynamodb access:
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_policy_${var.lambda_function_name}"
  description = "A policy to allow lambda to access dynamodb"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# # attaching the policy to the role:
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}
