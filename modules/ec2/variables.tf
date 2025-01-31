variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "vpc_details" {
  description = "VPC details including subnets and security groups"
  type        = any
}
