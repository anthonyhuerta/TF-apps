locals {
  app_file_paths = fileset(path.module, "${var.app_config_dir}/**/*.yaml")
  app_configs = {
    for x in flatten([
      for file_path in local.app_file_paths : [
        for app, obj in yamldecode(file(file_path)) : {
          (app) = obj
        }
      ]
    ]) : keys(x)[0] => values(x)[0]
  }
}

#####
# Secrets
#####

# Terraform will create and manage everything EXCEPT the value of the secret, which we will update manually
module "app_secrets" {
  for_each = local.app_configs

  source = "./modules/secrets"

  secret_prefix           = local.slash_prefix
  secret_names            = lookup(each.value, "secrets_with_details", {})
  recovery_window_in_days = 7 # minimum recovery window
  additional_tags         = local.common_tags
}
