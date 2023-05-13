
output "commit_version" {
  value = data.external.useful_version_info.result.commit_version
}

output "project_verion" {
  value = "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"
}
