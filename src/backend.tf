terraform {
  backend "remote" {
    organization = "womply"

    workspaces {
      prefix = "apps-"
    }
  }
}

provider "aws" {
  region = var.region

  # Prevent using master account
  forbidden_account_ids = ["985433556411"]
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"

  # Prevent using master account
  forbidden_account_ids = ["985433556411"]
}
