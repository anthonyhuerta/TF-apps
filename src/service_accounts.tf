locals {
  service_accounts = {
    "aws_ebs_csi_driver_role" = {
      # Ref: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/v1.1.0/docs/example-iam-policy.json
      iam_policy_json        = file("${path.root}/config/policies/iam-permissions/aws-ebs-csi-driver.json")
      iam_policy_description = "For Kubernetes app aws-ebs-csi-driver in namespace infra"
      iam_role_description   = "Kubernetes app aws-ebs-csi-driver in namespace infra"
      namespace              = "infra"
      service_account_names  = ["aws-ebs-csi-driver", "ebs-csi-controller-sa", "ebs-csi-node-sa", "ebs-snapshot-controller"]
    }
    "main_infra_aws_load_balancer_controller" = {
      # Ref: https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
      # Source: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/v2.2.0/docs/install/iam_policy.json
      iam_policy_json       = file("${path.root}/config/policies/iam-permissions/aws-load-balancer-controller.json")
      namespace             = "infra"
      service_account_names = ["aws-load-balancer-controller"]
    }
    "main_infra_chartmuseum_internal" = {
      # Ref: https://chartmuseum.com/docs/#using-amazon-s3
      iam_policy_json = templatefile("${path.root}/config/policies/iam-permissions/chartmuseum.json.tmpl", {
        s3_arn = aws_s3_bucket.helm.arn
      })
      namespace             = "infra"
      service_account_names = ["chartmuseum-internal"]
    }
    "main_infra_chartmuseum_public" = {
      # Ref: https://chartmuseum.com/docs/#using-amazon-s3
      iam_policy_json = templatefile("${path.root}/config/policies/iam-permissions/chartmuseum.json.tmpl", {
        s3_arn = aws_s3_bucket.helm.arn
      })
      namespace             = "infra"
      service_account_names = ["chartmuseum-public"]
    }
    "main_infra_external_dns_private" = {
      # Ref: https://github.com/kubernetes-sigs/external-dns/blob/v0.7.0/docs/tutorials/aws.md
      iam_policy_json = templatefile("config/policies/iam-permissions/external_dns.json.tmpl", {
        read_write_statement_effect = local.private_hosted_zones == {} ? "Deny" : "Allow"
        read_write_hosted_zone_ids  = local.private_hosted_zones == {} ? ["*"] : [for k in local.private_hosted_zones : "${k.zone_id}"]
      })
      namespace             = "infra"
      service_account_names = ["external-dns-private"]
    }
    "main_infra_external_dns_public" = {
      iam_policy_json = templatefile("config/policies/iam-permissions/external_dns.json.tmpl", {
        read_write_statement_effect = local.public_hosted_zones == {} ? "Deny" : "Allow"
        read_write_hosted_zone_ids  = local.public_hosted_zones == {} ? ["*"] : [for k in local.public_hosted_zones : "${k.zone_id}"]
      })
      namespace             = "infra"
      service_account_names = ["external-dns-public"]
    }
    "main_infra_external_secrets" = {
      # Ref: https://github.com/godaddy/kubernetes-external-secrets#secrets-manager-access
      # Source: https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html
      iam_policy_json = templatefile("config/policies/iam-permissions/asm_read_only.json.tmpl", {
        account_id = local.account_id
        read_only_secrets = distinct([
          "/apps/*",
          "/clusters/main/*",
          "${local.slash_prefix}/apps/*",
          "${local.slash_prefix}/clusters/main/*"
        ])
        region = var.region
      })
      namespace             = "infra"
      service_account_names = ["external-secrets"]
    }
    "main_jenkins_jenkins_controller" = {
      iam_policy_json = templatefile("config/policies/iam-permissions/jenkins_controller.json.tmpl", {
        account_id = local.account_id
        read_only_secrets = distinct([
          "/apps/datadog/rds/postgres/*",
          "/apps/gmd-nav-service/DB_PASSWORD_CRYPT-*",
          "/apps/file-transfer-service/DB_PASSWORD_CRYPT-*",
          "/apps/puppet/postgres/ROOT_USER_PASSWORD-*",
          "/apps/puppet/postgres/SERVICE_USER_PASSWORD-*",
          "/apps/subscription-service/DB_PASSWORD_CRYPT-*",
          "/apps/glue/jobs/shared/*",
          "/aws-resources/rds/*",
          "${local.slash_prefix}/apps/datadog/rds/postgres/*",
          "${local.slash_prefix}/apps/gmd-nav-service/DB_PASSWORD_CRYPT-*",
          "${local.slash_prefix}/apps/file-transfer-service/DB_PASSWORD_CRYPT-*",
          "${local.slash_prefix}/apps/puppet/postgres/ROOT_USER_PASSWORD-*",
          "${local.slash_prefix}/apps/subscription-service/DB_PASSWORD_CRYPT-*",
          "${local.slash_prefix}/apps/transaction-etl-service/POSTGRES_PASSWORD-*",
          "${local.slash_prefix}/apps/glue/jobs/shared/*",
          "${local.slash_prefix}/aws-resources/rds/*"
        ])
        read_write_secrets = distinct([
          "/apps/jenkins/*",
          "/clusters/main/quay-registry",
          "${local.slash_prefix}/apps/jenkins/*",
          "${local.slash_prefix}/clusters/main/quay-registry"
        ])
        read_write_bucket_paths = [
          "fundrocket-data/*",
          "womply-archives/*",
          "womply-external-partners/*",
          "womply-maven/*",
          "womply-pci-archives/*",
          "womply-pgp/*",
          "womply-reports/*",
          "womply-samtest/*",
          "womply-testing-txn-etl-svc/*",
          "womply-${var.env}-backups/databases/womply-puppet/postgres/*"
        ]
        read_write_statement_effect = local.private_hosted_zones == {} ? "Deny" : "Allow"
        read_write_hosted_zone_ids  = local.private_hosted_zones == {} ? ["*"] : [for k in local.private_hosted_zones : "${k.zone_id}"]
        region                      = var.region
      })
      namespace             = "jenkins"
      service_account_names = ["jenkins-controller"]
    }
    "main_kube_system_cluster_autoscaler" = {
      ## Ref: https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-chart-9.9.2/charts/cluster-autoscaler#aws---iam
      ## Ref: https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-chart-9.9.2/cluster-autoscaler/cloudprovider/aws/README.md
      ## Ref: https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
      iam_policy_json = templatefile("config/policies/iam-permissions/cluster-autoscaler.json.tmpl", {
        account_id   = local.account_id
        cluster_name = local.cluster_id
        region       = var.region
      })
      namespace             = "kube-system"
      service_account_names = ["cluster-autoscaler", "aws-cluster-autoscaler"]
    }
  }
}

#####
# Service Accounts
#####

module "service_accounts_roles" {
  for_each = local.service_accounts

  source = "./modules/service-account-roles"
  # Ref: https://chartmuseum.com/docs/#using-amazon-s3
  iam_policy_json        = each.value["iam_policy_json"]
  iam_policy_name        = try(each.value["iam_policy_name"], "")
  iam_policy_description = try(each.value["iam_policy_description"], "")

  iam_role_name         = try(each.value["iam_role_name"], "")
  iam_role_description  = try(each.value["iam_role_description"], "")
  namespace             = each.value["namespace"]
  service_account_names = each.value["service_account_names"]

  prefix            = var.prefix
  oidc_provider_arn = local.cluster_oidc_provider_arn
  oidc_provider_url = local.cluster_oidc_provider_url
  additional_tags   = local.common_tags
}

