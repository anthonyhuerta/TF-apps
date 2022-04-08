resource "aws_s3_bucket" "helm" {
  bucket = "${var.realm}-${var.env}-helm"
  acl    = "private"

  tags = merge(local.common_tags, {
    Name = "${var.realm}-${var.env}-helm"
  })
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.realm}-${var.env}-backups"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.cmk.kms_keys.s3-cmk.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.realm}-${var.env}-backups"
  })
}
