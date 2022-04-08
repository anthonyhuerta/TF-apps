# womply - apps

#####
# Data & Locals
#####

data "terraform_remote_state" "master_org" {
  backend = "remote"
  config = {
    organization = "womply"
    workspaces = {
      # TFC bug causes false validation errors unless name includes a variable
      name = var.region != "" ? "master-org" : "master-org"
    }
  }
}

data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "womply"
    workspaces = {
      name = lookup(var.tfc_workspaces, "network", "") != "" ? var.tfc_workspaces["network"] : "network-${var.env}"
    }
  }
}

locals {
  account_ids = {
    beta       = data.terraform_remote_state.master_org.outputs.beta_account_id
    prod       = data.terraform_remote_state.master_org.outputs.prod_account_id
    sandbox    = "639015794711"
    legacy     = "985433556411"
    fundrocket = "754841671700"
  }
  account_id = local.account_ids[var.env]
  region     = var.region
  terraform_administrator_role_arns = {
    beta = data.terraform_remote_state.master_org.outputs.beta_terraform_administrator_role_arn
    prod = data.terraform_remote_state.master_org.outputs.prod_terraform_administrator_role_arn
  }
  vpc = {
    id   = data.terraform_remote_state.network.outputs.vpc_id
    name = var.env
  }
  subnets = {
    private = {
      ids         = data.terraform_remote_state.network.outputs.private_subnets
      cidr_blocks = data.terraform_remote_state.network.outputs.private_subnets_cidr_blocks
    }
    public = {
      ids         = data.terraform_remote_state.network.outputs.public_subnets
      cidr_blocks = data.terraform_remote_state.network.outputs.public_subnets_cidr_blocks
    }
    elasticache = {
      ids         = data.terraform_remote_state.network.outputs.elasticache_subnets
      cidr_blocks = data.terraform_remote_state.network.outputs.elasticache_subnets_cidr_blocks
    }
    database = {
      ids         = data.terraform_remote_state.network.outputs.database_subnets
      cidr_blocks = data.terraform_remote_state.network.outputs.database_subnets_cidr_blocks
    }
  }
  network_security_groups = {
    for k, v in data.terraform_remote_state.network.outputs.security_group_arns :
    k => {
      arn = v
      id  = data.terraform_remote_state.network.outputs.security_group_ids[k]
    }
  }
  additional_security_groups = {
    ecs-beta-cluster = {
      arn = "arn:aws:ec2:us-west-2:${local.account_ids.legacy}:security-group/sg-3c56e844"
      id  = "${local.account_ids.legacy}/sg-3c56e844"
    }
    ecs-prod-cluster = {
      arn = "arn:aws:ec2:us-west-2:${local.account_ids.legacy}:security-group/sg-b97f85dd"
      id  = "${local.account_ids.legacy}/sg-b97f85dd"
    }
    eks-cluster = {
      arn = "arn:aws:ec2:${local.region}:${local.account_id}:security-group/${local.cluster_primary_security_group_id}"
      id  = local.cluster_primary_security_group_id
    }
    legacy-vpn = {
      arn = "arn:aws:ec2:us-west-2:${local.account_ids.legacy}:security-group/sg-6432b901"
      id  = "${local.account_ids.legacy}/sg-6432b901"
    }
    ecs-prod-rds = {
      arn = "arn:aws:ec2:us-west-2:${local.account_ids.legacy}:security-group/sg-cb1854b3"
      id  = "${local.account_ids.legacy}/sg-cb1854b3"
    }
    ecs-beta-rds = {
      arn = "arn:aws:ec2:us-west-2:${local.account_ids.legacy}:security-group/sg-3e56e846"
      id  = "${local.account_ids.legacy}/sg-3e56e846"
    }
  }
  security_groups                   = merge(local.network_security_groups, local.additional_security_groups)
  cloudfront_acm_certificates       = data.terraform_remote_state.network.outputs.cloudfront_acm_certificates
  database_subnet_group             = data.terraform_remote_state.network.outputs.database_subnet_group
  elasticache_subnet_group          = data.terraform_remote_state.network.outputs.elasticache_subnet_group_name
  network_acm_certificates          = data.terraform_remote_state.network.outputs.acm_certificates
  private_hosted_zones              = data.terraform_remote_state.network.outputs.private_hosted_zones
  public_hosted_zones               = data.terraform_remote_state.network.outputs.public_hosted_zones
  cluster_id                        = data.terraform_remote_state.network.outputs.cluster_id
  cluster_oidc_provider_arn         = data.terraform_remote_state.network.outputs.oidc_provider_arn
  cluster_oidc_provider_url         = replace(data.terraform_remote_state.network.outputs.cluster_oidc_issuer_url, "https://", "")
  cluster_primary_security_group_id = data.terraform_remote_state.network.outputs.cluster_primary_security_group_id

  prefix_dash  = var.prefix == "" ? "" : "${var.prefix}-"
  slash_prefix = var.prefix == "" ? "" : "/${var.prefix}"

  common_tags = {
    "Env"                  = var.env
    "ManagedBy"            = "terraform"
    "Realm"                = var.realm
    "Terraform:RootModule" = "apps"
  }
}

#######################
# Security Group Rules
#######################

locals {
  sgrule_file_paths = fileset(path.module, "${var.sgrules_config_dir}/*.yaml")
  sgrule_configs = {
    for x in flatten([
      for file_path in local.sgrule_file_paths : [
        for rules, obj in yamldecode(file(file_path)) : {
          (rules) = obj
        }
      ]
    ]) : keys(x)[0] => values(x)[0]
  }
}

resource "aws_security_group_rule" "rules" {
  for_each = local.sgrule_configs

  description              = each.key
  from_port                = each.value["from_port"]
  protocol                 = each.value["protocol"]
  security_group_id        = local.security_groups[each.value["security_group_id"]].id
  to_port                  = each.value["to_port"]
  type                     = lookup(each.value, "type", "ingress")
  cidr_blocks              = lookup(each.value, "cidr_block", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = contains(keys(each.value), "source_security_group_id") ? local.security_groups[each.value["source_security_group_id"]].id : null
}
