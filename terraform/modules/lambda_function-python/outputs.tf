output "lambda_function_arn" {
  value = aws_lambda_function.get__scripts.invoke_arn
}
output "lambda_function_name" {
  value = aws_lambda_function.get__scripts.function_name
}
