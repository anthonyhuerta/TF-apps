#############
# SSH Keypair
#############

resource "tls_private_key" "citus" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "citus" {
  key_name   = "${var.env}-citus"
  public_key = tls_private_key.citus.public_key_openssh
}

#################
# Citus Instances
#################

module "microservice_citus" {
  #Ref: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  for_each = local.microservice_citus

  name                   = "${var.env}-${each.value["name"]}"
  instance_count         = each.value["instance_count"]
  use_num_suffix         = each.value["use_num_suffix"]
  ami                    = each.value["ami"]
  instance_type          = each.value["instance_type"]
  key_name               = aws_key_pair.citus.key_name
  vpc_security_group_ids = [local.security_groups.citus.id]
  subnet_ids             = local.subnets.database.ids

  root_block_device = [
    {
      delete_on_termination = each.value["root_block_device"].delete_on_termination
      volume_size           = each.value["root_block_device"].volume_size
    }
  ]

  tags = merge(local.common_tags, {
    "ConfiguredBy" = "ansible"
  })
}
