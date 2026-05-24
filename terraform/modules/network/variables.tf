variable "vpc_cidr" {
  type        = string
  description = "The IP range for the VPC"
  default     = "10.20.0.0/16"
}

variable "environment" {
  type        = string
  description = "The deployment environment name"
}

variable "aws_region" {
  type        = string
  description = "The target AWS region"
}
