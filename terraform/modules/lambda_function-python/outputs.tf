
output "function_arn" {
  value = aws_lambda_function.slash_scripts.arn
}

output "base_function_name" {
  value = var.lambda_function_name
}

output "scripts_invoke_arn" {
  value = aws_lambda_function.slash_scripts.invoke_arn
}

output "status_invoke_arn" {
  value = aws_lambda_function.slash_status.invoke_arn
}
