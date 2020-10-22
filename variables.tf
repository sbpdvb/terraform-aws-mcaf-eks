variable "log_retention" {
  type        = number
  default     = 7
  description = "Retention of CloudWatch logs for the EKS cluster"
}

variable "instance_types" {
  type        = list(string)
  default     = null
  description = "List of EC2 instance types to use for the worker nodes"
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
