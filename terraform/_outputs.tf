
output "commit_version" {
  value = data.external.useful_version_info.result.commit_version
}

output "project_version" {
  value = "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"
}

output "status_invoke_arn" {
  value = module.core_lambda_function.status_invoke_arn
}

output "scripts_invoke_arn" {
  value = module.core_lambda_function.scripts_invoke_arn
}
