// create a dynamodb table
resource "aws_dynamodb_table" "pdf_api_auth_dynamodb_table" {
  # checkov:skip=CKV_AWS_119: we'll encrypt later
  name         = "pdf-api-auth"
  billing_mode = "PROVISIONED"
  hash_key     = "Client"

  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "Client"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tag_defaults
}
