terraform {
  backend "s3" {
    bucket               = "436158765452-terraform-state"
    key                  = "net-arcanescripts-infra"
    region               = "eu-west-2"
    workspace_key_prefix = "tf-state"
  }

  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = local.tag_defaults
  }
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
  default_tags {
    tags = local.tag_defaults
  }
}
