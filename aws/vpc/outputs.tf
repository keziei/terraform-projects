output "vpc_details" {
  description = "Details of the created VPC, including subnets and route tables"
  value = {
    vpc_id   = aws_vpc.main.id
    vpc_cidr = aws_vpc.main.cidr_block
    vpc_name = var.vpc_name
  }
}



