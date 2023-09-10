locals {
  old_pdf_api_name        = "pdf-api"
  old_pdf_api_description = "JSON-to-PDF API for custom BotC scripts"

  pdf_api_base_name   = "arcane-scripts-api"
  pdf_api_description = "JSON-to-PDF API for custom BotC scripts"

  # let's version the api
  pdf_api_version = "v1"

  render_method_path = "render"
  script_method_path = "script"

  # a set/list that we can loop over to create the methods
  # and integrations for each script
  top_level_methods = [
    {
      method = "POST"
      #path   = local.pdf_render_path
    },
    {
      method = "POST"
      #path   = local.script_method_path
    }
  ]


  tag_defaults = {
    Owner   = "chisel"
    Product = "botc-custom-script-json2pdf"
    InfoURL = "https://github.com/chizmw/botc-custom-script-json2pdf"
  }

  account_id         = "436158765452"
  aws_default_region = "eu-west-2"
}
