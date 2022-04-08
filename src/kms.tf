locals {
  kms_file_paths = fileset(path.module, "${var.kms_config_dir}/**/*.yaml")
  kms_key_configs = {
    for x in flatten([
      for file_path in local.kms_file_paths : [
        for kms_key, obj in yamldecode(file(file_path)) : {
          (kms_key) = obj
        }
    ]]) : keys(x)[0] => values(x)[0]
  }
}

module "cmk" {
  source          = "./modules/kms"
  account_id      = local.account_id
  region          = var.region
  tags            = local.common_tags
  prefix          = var.prefix
  kms_key_configs = local.kms_key_configs
}
