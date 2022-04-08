variable "app_config_dir" {
  description = "Directory containing app config yaml relative to asm.tf"
  default     = "config/microservices/"
}

variable "cloudfront_config_dir" {
  description = "Directory relative to `cloudfront_distributions.tf` containing config yaml for cloudfront distributions"
  default     = "config/cloudfront/"
}

variable "env" {
  description = "Name of the environment, eg prod"
  type        = string
}

variable "legacy_datalake_bucket_arn" {
  description = "The arn of womply_datalake_data bucket exit in the legacy account"
  type        = string
  default     = "arn:aws:s3:::womply-datalake-data"
}

variable "microservice_config_dir" {
  description = "Directory containing microservice config yaml relative to microservices.tf"
  default     = "config/microservices/"
}

variable "kms_config_dir" {
  description = "Directory containing kms config yaml"
  default     = "config/kms/"
}

variable "prefix" {
  description = "A lowercase word to prepend to names of created resources"
  type        = string
  default     = ""
}

variable "private_infrastructure" {
  description = "Whether all created infrastructure should only be available when using VPN"
  type        = bool
  default     = true
}

variable "realm" {
  description = "Maps to our organization on TFC: womply, cde"
  type        = string
  default     = "womply"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "sgrules_config_dir" {
  description = "Directory containing security group rules config yaml relative to main.tf"
  default     = "config/sgrules/"
}

variable "tfc_workspaces" {
  description = "The Terraform Cloud workspaces that this one has as dependencies"
  type        = map(string)
  default = {
    clusters = ""
    network  = ""
  }
}

variable "topic_config_dir" {
  description = "Directory containing topic config yaml relative to topics.tf"
  default     = "config/topics/"
}
