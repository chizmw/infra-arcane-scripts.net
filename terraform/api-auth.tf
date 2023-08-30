
# aws_dynamodb_table.pdf_api_auth_dynamodb_table will be destroyed
# (because aws_dynamodb_table.pdf_api_auth_dynamodb_table is not in configuration)
resource "aws_dynamodb_table" "pdf_api_auth_dynamodb_table" {
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = true
  hash_key                    = "Client"
  name                        = "pdf-api-auth"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  write_capacity              = 1

  attribute {
    name = "Client"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
}
