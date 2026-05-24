variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "The deployment environment name"
  default     = "staging"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "The CIDR block allowed to SSH into instances"
  default     = "0.0.0.0/0"
}
