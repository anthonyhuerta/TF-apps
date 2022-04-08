#####
# TFC Workspace
#####

terraform {
  backend "remote" {
    organization = "womply"

    workspaces {
      name = "prod-apps"
    }
  }
}

#####
# Providers
#####

provider "aws" {
  region = var.region

  assume_role {
    role_arn = local.terraform_administrator_role_arns["prod"]
  }
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"

  assume_role {
    role_arn = local.terraform_administrator_role_arns["prod"]
  }
}
