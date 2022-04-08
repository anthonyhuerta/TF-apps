output "microservice_elasticsearch" {
  description = "Elasticsearch clusters owned by microservices"
  value = {
    for k in var.clusters :
    k => {
      arn         = aws_elasticsearch_domain.this[k].arn
      domain_name = aws_elasticsearch_domain.this[k].domain_name
      endpoint    = aws_elasticsearch_domain.this[k].endpoint
    }
  }
}
