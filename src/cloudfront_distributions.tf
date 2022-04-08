locals {
  cloudfront_distributions_file_paths = fileset(path.module, "${var.cloudfront_config_dir}/*.yaml")
  cloudfront_distributions_configs = {
    for x in flatten([
      for file_path in local.cloudfront_distributions_file_paths : [
        for distributions, obj in yamldecode(file(file_path)) : {
          (distributions) = merge(
            {
              aliases                             = []
              has_ssl_cert                        = lookup(obj, "acm_cert_domain_name", "") != ""
              ordered_cache_behavior              = {}
              lambda_function_association_default = {}
            },
            obj
          )
        }
      ]
    ]) : keys(x)[0] => values(x)[0]
  }

  lambda_functions = {
    for k, v in local.cloudfront_distributions_configs : k => merge(
      try(v.lambda_function_association_default, {})
    )
  }
  lambda_final_functions = zipmap(
    flatten([for item in local.lambda_functions : keys(item)]),
    flatten([for item in local.lambda_functions : values(item)])
  )
}

# Once we have WAFs we can use them to restrict non-prod CloudFront distributions to internal traffic only
resource "aws_cloudfront_distribution" "common" {
  for_each = local.cloudfront_distributions_configs

  dynamic "origin" {
    for_each = local.cloudfront_distributions_configs[each.key].origins

    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id

      custom_origin_config {
        http_port              = lookup(origin.value, "http_port", "80")
        https_port             = lookup(origin.value, "https_port", "443")
        origin_protocol_policy = lookup(origin.value, "origin_protocol_policy", "https-only")
        origin_ssl_protocols   = lookup(origin.value, "origin_ssl_protocols", ["TLSv1.2"])
      }
    }
  }
  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = each.value.aliases

  default_cache_behavior {
    allowed_methods  = lookup(each.value.default_cache_behavior, "allowed_methods", ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
    cached_methods   = lookup(each.value.default_cache_behavior, "cached_methods", ["GET", "HEAD"])
    target_origin_id = lookup(each.value.default_cache_behavior, "target_origin_id", "")
    forwarded_values {
      query_string = lookup(each.value.default_cache_behavior, "query_string", true)
      cookies {
        forward = lookup(each.value.default_cache_behavior, "cookies", "all")
      }
    }
    viewer_protocol_policy = lookup(each.value.default_cache_behavior, "viewer_protocol_policy", "redirect-to-https")
    min_ttl                = lookup(each.value.default_cache_behavior, "min_ttl", null)     # Defaults to 0 days
    default_ttl            = lookup(each.value.default_cache_behavior, "default_ttl", null) # Defaults to 1 day
    max_ttl                = lookup(each.value.default_cache_behavior, "max_ttl", null)     # Defaults to 365 days

    dynamic "lambda_function_association" {
      for_each = each.value.lambda_function_association_default

      content {
        event_type   = lookup(lambda_function_association.value, "event_type", "")
        lambda_arn   = aws_lambda_function.cloudfront_lambda_edge[lambda_function_association.key].qualified_arn
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = each.value.ordered_cache_behavior

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = lookup(ordered_cache_behavior.value, "allowed_methods", ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      cached_methods   = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD", "OPTIONS"])
      target_origin_id = ordered_cache_behavior.value.target_origin_id
      forwarded_values {
        query_string = lookup(ordered_cache_behavior.value, "query_string", true)
        cookies {
          forward = lookup(ordered_cache_behavior.value, "forward", "none")
        }
      }
      min_ttl                = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      default_ttl            = lookup(ordered_cache_behavior.value, "default_ttl", 86400)
      max_ttl                = lookup(ordered_cache_behavior.value, "max_ttl", 31536000)
      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !each.value.has_ssl_cert

    acm_certificate_arn = each.value.has_ssl_cert ? local.cloudfront_acm_certificates[each.value.acm_cert_domain_name].arn : null
    ssl_support_method  = each.value.has_ssl_cert ? "sni-only" : null
  }

  tags = merge(local.common_tags, {
    Name   = each.key
    Region = "us-east-1"
  })
}

# Eventually we may need to change this to support multiple aliases in multiple zones
data "aws_route53_zone" "cloudfront_distributions" {
  for_each = local.cloudfront_distributions_configs

  name         = each.value.acm_cert_domain_name
  private_zone = var.private_infrastructure
}

# For the first alias only, create a Route53 record that points to the CloudFront distribution
resource "aws_route53_record" "cloudfront_distributions" {
  for_each = local.cloudfront_distributions_configs

  name    = each.value.aliases[0]
  type    = "CNAME"
  zone_id = data.aws_route53_zone.cloudfront_distributions[each.key].zone_id
  records = [aws_cloudfront_distribution.common[each.key].domain_name]
  ttl     = "300"
}
