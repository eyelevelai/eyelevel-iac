variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID for an existing VPC"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "ingress_cidr" {
  description = "The CIDR block for network ingress"
  type        = string
  default     = "0.0.0.0/0"
}

variable "network_cidr" {
  description = "The CIDR block for the network (VPC, VNet, etc.)"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
}

variable "create_subnets" {
  description = "Whether to create new subnets"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Whether to create new VPC"
  type        = bool
  default     = false
}