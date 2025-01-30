variable "aws_region" {
  description = "AWS region where VPC will be created"
  type        = string
  default     = "us-east-1" # Change as needed
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "kezie-lab-vpc"
}

variable "public_web_subnet_cidr" {
  description = "CIDR block for the public web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_bastion_subnet_cidr" {
  description = "Name of the public bastion subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_app_subnet_cidr" {
  description = "CIDR block for the private app subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_db_subnet_cidr" {
  description = "Name of the private app subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "public_bastion_az" {
  description = "Availability zone for the public bastion subnet"
  type        = string
  default     = "us-east-1a" # Change as needed
}

variable "public_web_az" {
  description = "Availability zone for the public web subnet"
  type        = string
  default     = "us-east-1a" # Change as needed
}

variable "private_app_az" {
  description = "Availability zone for the private app subnet"
  type        = string
  default     = "us-east-1a" # Change as needed
}

variable "private_db_az" {
  description = "Availability zone for the private db subnet"
  type        = string
  default     = "us-east-1a" # Change as needed
}
