variable "additional_tags" {
  description = "Additional tags to add to the IAM policies"
  type        = map(string)
  default     = {}
}

variable "policies" {
  description = "Extra policies to attach to the microservice's EKS service account role"
  type        = map(any)
}

variable "role_name" {
  description = "Name of the microservice's EKS service account role"
  type        = string
}
