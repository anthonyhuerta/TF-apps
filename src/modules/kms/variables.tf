variable "resource_name" {
  description = "Resource name to be managed by the key"
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of tags"
  type        = map(string)
  default     = {}
}

variable "account_id" {
  description = "AWS account_id"
  type        = string
}

variable "kms_key_configs" {
  description = "KMS keys and their associated policies"
  type        = map(any)
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "prefix" {
  description = "A lowercase word to prepend to names of created resources"
  type        = string
  default     = ""
}
