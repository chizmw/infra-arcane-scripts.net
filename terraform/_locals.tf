locals {

  pdf_api_name        = "pdf-api"
  pdf_api_description = "JSON-to-PDF API for custom BotC scripts"
  pdf_render_path     = "render"


  version = "${data.external.useful_version_info.result.project_dir}:${data.external.useful_version_info.result.commit_version}"

  tag_defaults = {
    Owner   = "chisel"
    Product = "botc-custom-script-json2pdf"
    InfoURL = "https://github.com/chizmw/botc-custom-script-json2pdf"
    Version = local.version
  }
}
