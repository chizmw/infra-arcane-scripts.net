# use SNS to send notification to the invalidate-cache lambda function when objects are created or modified in the S3 bucket
# data "aws_iam_policy_document" "topic_invalidate" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["s3.amazonaws.com"]
#     }

#     actions   = ["SNS:Publish"]
#     resources = ["arn:aws:sns:*:*:s3-event-notification-topic"]

#     condition {
#       test     = "ArnLike"
#       variable = "aws:SourceArn"
#       values   = [aws_s3_bucket.wkspc_www_bucket.arn]
#     }
#   }
# }

# resource "aws_sns_topic" "sns_invalidate_cache" {
#   name   = "invalidate-cache"
#   policy = data.aws_iam_policy_document.topic_invalidate.json
# }

# resource "aws_sns_topic_subscription" "sns_invalidate_cache_lambda" {
#   topic_arn = aws_sns_topic.sns_invalidate_cache.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.lambda_invalidate_cache.arn
# }

# this needs to live in The Other Place, not here
# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.wkspc_www_bucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.lambda_invalidate_cache.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
# }

# Declare the local zip archive
data "archive_file" "lambda_code_cache" {
  type        = "zip"
  source_file = "./lambda-src/invalidate_cache.py"
  output_path = "./tmp/invalidatecache.zip"
}

resource "aws_lambda_function" "lambda_invalidate_cache" {
  # checkov:skip=CKV_AWS_116: ADD REASON
  # checkov:skip=CKV_AWS_117: ADD REASON
  # checkov:skip=CKV_AWS_50: ADD REASON
  function_name                  = "invalidate-cache"
  filename                       = data.archive_file.lambda_code_cache.output_path
  source_code_hash               = data.archive_file.lambda_code_cache.output_base64sha256
  role                           = data.aws_iam_role.iam_for_lambda.arn
  handler                        = "invalidate_cache.lambda_handler"
  runtime                        = "python3.10"
  tags                           = local.tag_defaults
  reserved_concurrent_executions = 10

}
