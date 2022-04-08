locals {
  topic_file_paths = fileset(path.module, "${var.topic_config_dir}/**/*.yaml")
  topic_configs = {
    for x in flatten([
      for file_path in local.topic_file_paths : [
        for topic, obj in yamldecode(file(file_path)) : {
          (topic) = obj
        }
      ]
    ]) : keys(x)[0] => values(x)[0]
  }
}

resource "aws_sns_topic" "all" {
  for_each = local.topic_configs

  name = each.key

  tags = merge(local.common_tags, {
    "Name" = each.key
  })
}

resource "aws_sns_topic_policy" "all" {
  for_each = local.topic_configs

  arn = aws_sns_topic.all[each.key].arn
  policy = templatefile("${path.module}/config/policies/service-access/sns_topics.json.tmpl", {
    account_id                    = local.account_id
    resource_arn                  = aws_sns_topic.all[each.key].arn
    allowed_publishers_s3_buckets = try(each.value.allowed_publishers.s3_buckets, [])
  })
}
