variable "additional_tags" {
  description = "Additional tags to add to AWS resources that support them"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "main"
}

variable "iam_policy_description" {
  description = "Overrides the auto-generated description of the IAM policy"
  type        = string
  default     = ""
}

variable "iam_policy_json" {
  description = "JSON for IAM policy"
}

variable "iam_policy_name" {
  description = "Overrides the auto-generated name of the IAM policy"
  type        = string
  default     = ""
}

variable "iam_policy_path" {
  description = "Prefix to use for ARN of the IAM policy"
  type        = string
  default     = "/"
}

variable "iam_role_description" {
  description = "Overrides the auto-generated description of the IAM role"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Overrides the auto-generated name of the IAM role"
  type        = string
  default     = ""
}

variable "iam_role_path" {
  description = "Prefix to use for ARN of the IAM role"
  type        = string
  default     = "/"
}

variable "namespace" {
  description = "Namespace that the Kubernetes service accounts reside in"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider associated with the Kubernetes cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider associated with the Kubernetes cluster"
  type        = string
}

variable "prefix" {
  description = "A lowercase word to prepend to names of created resources"
  type        = string
  default     = ""
}

variable "service_account_names" {
  description = "Kubernetes Service Accounts allowed to assume the IAM role"
  type        = list(string)
}
