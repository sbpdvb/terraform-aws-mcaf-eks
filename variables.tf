variable "create_node_group" {
  type        = bool
  default     = true
  description = "Whether or not to create a node group"
}

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

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }
  description = "The config that is used for the node group scaling"
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

variable "permissions_boundary" {
  type        = string
  description = "Optional Boundary Permission for the IAM Role"
  default     = null
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable Private Endpoint Access "
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable Public Endpoint Access "
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = null
  description = "EnableEndpoint Access security groups"
}

variable "addons" {
  description = "EKS Addons"
  default = {
    #   "adot" : null,  # broken on private clusters
    "kube-proxy" : null,
    "vpc-cni" : null,
    "coredns" : null,
    "aws-ebs-csi-driver" : null,
  }
}

variable "disk_size" {
  description = "Root volume disksize"
  default     = 20
}

variable "kms_key_arn" {
  description = "KMS Key arn for the EKS Encryption"
}

variable "user_data" {
  description = "Custom user-data for node instances"
  default     = null
  type        = string
}

variable "enable_launch_template" {
  description = "Enable custom launch template for ec2 nodes"
  default     = false
  type        = bool
}