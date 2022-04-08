variable "additional_tags" {
  description = "Additional tags to add to the IAM policies"
  type        = map(string)
  default     = {}
}

variable "clusters" {
  description = "Multiple Elasticsearch clusters to the microservice's EKS service account role"
  type        = list(any)
}

variable "subnet_ids" {
  description = "Subnet ids for the elasticsearch clusters"
  type        = list(any)
}

variable "elasticsearch_conf" {
  description = "Map generated of elasticsearch configurations"
  type        = any
}

variable "prefix" {
  description = "A lowercase word to prepend to names of created resources"
  type        = string
}
variable "security_group_ids" {
  description = "The security group ids for the elasticsearch cluster"
  type        = list(any)
}
variable "account_ids" {
  description = "AWS account ids to be attached to the elasticsearch domain policy"
  type        = list(any)
}
