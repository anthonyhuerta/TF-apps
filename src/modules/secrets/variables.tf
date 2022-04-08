variable "additional_tags" {
  description = "A map of additional tags to use for to the certificate"
  type        = map(string)
  default     = {}
}

variable "recovery_window_in_days" {
  description = "Specifies the number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days."
  type        = number
  default     = 0
}

variable "secret_prefix" {
  description = "A string to prepend to all secret names/paths"
  type        = string
  default     = ""
}

variable "secret_names" {
  description = "A dictionary of secret names and their descriptions"
  type        = map(any)
}
