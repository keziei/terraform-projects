variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair to be used for EC2 instances"
  type        = string
}
