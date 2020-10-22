variable "log_retention" {
  type        = number
  default     = 7
  description = "Retention of CloudWatch logs for the EKS cluster"
}

variable "name" {
  type        = string
  description = "Name of the cluster"
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs to deploy EKS in"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the cluster"
}
